// Cadeia de modelos: tenta cada modelo em ordem e passa para o próximo quando
// um bate no limite (por minuto ou por dia) ou está fora do ar ANTES de
// responder. O app não percebe a troca: recebe um stream só.

import {
  APICallError,
  createUIMessageStreamResponse,
  type ModelMessage,
  streamText,
  type UIMessageChunk,
} from "ai";
import { type Escolha, ferramentas } from "./agente.ts";
import { cors, json } from "./comum.ts";

/// Status HTTP do erro do fornecedor (RetryError guarda o último erro).
export function statusDoErro(e: unknown): number | undefined {
  const ultimo = (e as { lastError?: unknown })?.lastError ?? e;
  return APICallError.isInstance(ultimo) ? ultimo.statusCode : undefined;
}

/// Vale passar para o próximo modelo: cota (por minuto ou por dia) ou fornecedor
/// fora do ar. Erro do pedido em si (400) não melhora trocando de modelo.
export function vaiProProximo(e: unknown): boolean {
  const s = statusDoErro(e);
  return s === 429 || s === 500 || s === 503 || s === 529 || s === 404;
}

/// Mensagem para a pessoa a partir de um erro do fornecedor.
export function mensagemDeErro(e: unknown): string {
  console.error(e);
  const status = statusDoErro(e);
  if (status === 429) return "A IA chegou ao limite de pedidos por minuto. Tente de novo em instantes.";
  if (status === 529 || status === 503) return "A IA está sobrecarregada agora. Tente de novo daqui a pouco.";
  if (status === 401 || status === 403) return "A chave da IA no servidor não foi aceita. Avise o dono do app.";
  return "A IA não respondeu agora. Tente de novo daqui a pouco.";
}

/// Começo do stream de um modelo: os pedaços já lidos e o resto para seguir.
/// [erro] vem preenchido quando o modelo falhou antes de mandar qualquer coisa.
type Inicio = {
  lidos: UIMessageChunk[];
  leitor: ReadableStreamDefaultReader<UIMessageChunk>;
  erro?: unknown;
};

/// Pede ao modelo e lê só o começo: até o primeiro pedaço de verdade (texto,
/// ferramenta, fim) ou um erro. "start"/"start-step" não contam.
/// Para o modelo de último recurso, que não usa ferramentas.
const AVISO_SEM_FERRAMENTAS = `AGORA VOCÊ ESTÁ SEM AS FERRAMENTAS (os outros modelos estão ocupados).
Converse normalmente com o que está no resumo e na conversa. Se a pessoa pedir para criar, mudar ou
excluir algo, diga com gentileza que agora não dá para mexer nos dados e que ela pode pedir de novo
em alguns minutos. Nunca diga que fez uma ação.`;

/// A conversa só em texto (para modelo sem ferramentas): chamadas de
/// ferramenta somem e os resultados viram uma nota; papéis seguidos se juntam.
export function emTexto(mensagens: ModelMessage[]): ModelMessage[] {
  const saida: { role: "user" | "assistant"; content: string }[] = [];
  const somar = (role: "user" | "assistant", texto: string) => {
    if (!texto.trim()) return;
    const ultima = saida[saida.length - 1];
    if (ultima?.role === role) ultima.content += `\n${texto}`;
    else saida.push({ role, content: texto });
  };
  for (const m of mensagens) {
    if (m.role === "user" || m.role === "assistant") {
      const texto = typeof m.content === "string"
        ? m.content
        : m.content.map((p) => (p.type === "text" ? p.text : "")).join("");
      somar(m.role, texto);
    } else if (m.role === "tool") {
      const notas = m.content.map((p) =>
        p.type === "tool-result" && "value" in p.output ? `(${p.toolName}: ${String(p.output.value)})` : ""
      );
      somar("assistant", notas.join("\n"));
    }
  }
  return saida;
}

async function comecar(escolha: Escolha, sistema: string, mensagens: ModelMessage[], sinal: AbortSignal): Promise<Inicio> {
  let erro: unknown;
  const semFerramentas = escolha.semFerramentas ?? false;
  const resultado = streamText({
    model: escolha.model,
    system: semFerramentas ? `${sistema}\n\n${AVISO_SEM_FERRAMENTAS}` : sistema,
    messages: semFerramentas ? emTexto(mensagens) : mensagens,
    tools: semFerramentas ? undefined : ferramentas,
    temperature: escolha.temperature,
    providerOptions: escolha.providerOptions,
    maxOutputTokens: 4000,
    abortSignal: sinal,
    // Sem repetir no mesmo modelo: no limite, repetir na hora só gasta cota.
    // Quem resolve é a troca para o próximo modelo da cadeia.
    maxRetries: 0,
  });
  const leitor = resultado.toUIMessageStream({
    sendReasoning: false,
    onError: (e) => {
      erro = e;
      return mensagemDeErro(e);
    },
  }).getReader();
  const lidos: UIMessageChunk[] = [];
  while (true) {
    const { value, done } = await leitor.read();
    if (done) break;
    lidos.push(value);
    if (value.type === "start" || value.type === "start-step") continue;
    if (value.type === "error") return { lidos, leitor, erro: erro ?? new Error(value.errorText) };
    break;
  }
  return { lidos, leitor };
}

/// Tenta os modelos em ordem. Se um bate no limite (por minuto ou por dia) ou
/// está fora do ar ANTES de responder, passa para o próximo sem o app perceber.
/// O primeiro que começar a responder segue até o fim, em stream.
export async function responderComCadeia(
  cadeia: Escolha[],
  sistema: string,
  mensagens: ModelMessage[],
  sinal: AbortSignal,
): Promise<Response> {
  for (let i = 0; i < cadeia.length; i++) {
    const inicio = await comecar(cadeia[i], sistema, mensagens, sinal);
    const temProximo = i < cadeia.length - 1;
    if (inicio.erro !== undefined && temProximo && vaiProProximo(inicio.erro)) {
      console.log(`IA: ${cadeia[i].nome} indisponível (${statusDoErro(inicio.erro)}); tentando ${cadeia[i + 1].nome}`);
      await inicio.leitor.cancel().catch(() => {});
      continue;
    }
    const { lidos, leitor } = inicio;
    const stream = new ReadableStream<UIMessageChunk>({
      start(c) {
        for (const pedaco of lidos) c.enqueue(pedaco);
      },
      async pull(c) {
        const { value, done } = await leitor.read();
        if (done) c.close();
        else c.enqueue(value);
      },
      cancel() {
        return leitor.cancel();
      },
    });
    return createUIMessageStreamResponse({ headers: cors, stream });
  }
  return json({ erro: "A IA não respondeu agora. Tente de novo daqui a pouco." }, 502);
}
