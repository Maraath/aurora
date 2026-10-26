// Cadeia de modelos: tenta cada modelo em ordem e passa para o próximo quando
// um bate no limite (por minuto ou por dia) ou está fora do ar ANTES de
// responder. O app não percebe a troca: recebe um stream só.

import {
  APICallError,
  createUIMessageStreamResponse,
  type ModelMessage,
  streamText,
  type ToolSet,
  type UIMessageChunk,
} from "ai";
import { type Escolha, ferramentas } from "./agente.ts";
import { cors } from "./comum.ts";

/// O conjunto de ferramentas oferecido (o app da Rotina recebe mais).
type Ferramentas = ToolSet;

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

/// Quanto um modelo pode demorar para começar a responder antes de passar ao
/// próximo (um modelo sobrecarregado chegou a levar 57 s só para dizer 503).
/// [sinalDeVidaMs]: enquanto procura um modelo que responda, manda um pedaço
/// vazio ("data-espera", que o app ignora) para a conexão não parecer morta: o
/// app desiste depois de 60 s sem nada chegando. [tempoTotalMs]: depois disso
/// não tenta mais modelos (a Edge Function tem limite de tempo). [escalonarMs]:
/// quanto esperar um modelo começar antes de chamar o próximo junto (um Flash
/// saudável costuma começar em 2 a 5 s).
export const config = { tempoParaComecarMs: 20_000, sinalDeVidaMs: 10_000, tempoTotalMs: 100_000, escalonarMs: 6_000 };

/// Modelos sem cota agora → até quando pular (só vale enquanto esta instância
/// da função está quente; numa fria, o primeiro 429 volta a ensinar).
const esgotados = new Map<string, number>();

/// Modelo sobrecarregado ou lento fica de fora por um tempo: cada volta de
/// ferramenta é um pedido novo e não deve esperar por ele de novo.
const PAUSA_SOBRECARGA_MS = 120_000;

/// Até quando pular o modelo: sem cota do dia, até a meia-noite do Pacífico
/// (~08:00 UTC); do minuto, 1 minuto; sobrecarregado ou lento, 2 minutos.
function esgotadoAte(e: unknown, agora: number): number | undefined {
  const status = statusDoErro(e);
  if (e instanceof Demorou || status === 500 || status === 503 || status === 529) return agora + PAUSA_SOBRECARGA_MS;
  if (status !== 429) return undefined;
  const ultimo = (e as { lastError?: unknown })?.lastError ?? e;
  const corpo = APICallError.isInstance(ultimo) ? ultimo.responseBody ?? "" : "";
  if (!/PerDay/i.test(corpo)) return agora + 60_000;
  const volta = new Date(agora);
  volta.setUTCHours(8, 0, 0, 0);
  if (volta.getTime() <= agora) volta.setUTCDate(volta.getUTCDate() + 1);
  return volta.getTime();
}

/// Pede ao modelo e lê só o começo: até o primeiro pedaço de verdade (texto,
/// ferramenta, fim) ou um erro. "start"/"start-step" não contam. Sem começo em
/// [config.tempoParaComecarMs], desiste deste modelo.
async function comecar(
  escolha: Escolha,
  sistema: string,
  mensagens: ModelMessage[],
  sinal: AbortSignal,
  uteis: Ferramentas,
): Promise<Inicio> {
  let erro: unknown;
  const semFerramentas = escolha.semFerramentas ?? false;
  // Cancela se o app desistir OU se o modelo demorar demais para começar.
  const controle = new AbortController();
  const desistir = () => controle.abort();
  sinal.addEventListener("abort", desistir);
  let demorou = false;
  const relogio = setTimeout(() => {
    demorou = true;
    controle.abort();
  }, config.tempoParaComecarMs);
  const resultado = streamText({
    model: escolha.model,
    system: semFerramentas ? `${sistema}\n\n${AVISO_SEM_FERRAMENTAS}` : sistema,
    messages: semFerramentas ? emTexto(mensagens) : mensagens,
    tools: semFerramentas ? undefined : uteis,
    temperature: escolha.temperature,
    providerOptions: escolha.providerOptions,
    maxOutputTokens: 4000,
    abortSignal: controle.signal,
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
  try {
    while (true) {
      const { value, done } = await leitor.read();
      if (done) break;
      lidos.push(value);
      if (value.type === "start" || value.type === "start-step") continue;
      if (value.type === "error" || value.type === "abort") {
        return { lidos, leitor, erro: demorou ? new Demorou() : erro ?? new Error(value.type === "error" ? value.errorText : "abortado") };
      }
      break;
    }
  } catch (e) {
    return { lidos, leitor, erro: demorou ? new Demorou() : e };
  } finally {
    // Começou (ou falhou): daqui em diante só o app cancela.
    clearTimeout(relogio);
  }
  return { lidos, leitor };
}

/// O modelo não começou a responder a tempo.
class Demorou extends Error {
  constructor() {
    super("O modelo demorou demais para começar a responder.");
  }
}

/// Uma tentativa em andamento: o modelo [i] da fila e como cancelá-la.
type Tentativa = { i: number; controle: AbortController; fim: Promise<{ t: Tentativa; inicio: Inicio }> };

/// Tenta os modelos em ordem. Se um bate no limite (por minuto ou por dia) ou
/// está fora do ar ANTES de responder, passa para o próximo. Se um demora
/// [config.escalonarMs] sem começar, o próximo é chamado JUNTO e fica o
/// primeiro que começar (um modelo sobrecarregado pode levar quase um minuto,
/// e cada volta de ferramenta paga essa espera). Nulo se nenhum começou dentro
/// do tempo total (ou o app desistiu).
async function primeiroQueResponde(
  cadeia: Escolha[],
  sistema: string,
  mensagens: ModelMessage[],
  sinal: AbortSignal,
  uteis: Ferramentas,
): Promise<Inicio | null> {
  // Pula os que já se sabe sem cota (se sobrar nenhum, tenta todos mesmo).
  const comeco = Date.now();
  const livres = cadeia.filter((e) => (esgotados.get(e.nome) ?? 0) <= comeco);
  const fila = livres.length ? livres : cadeia;
  const ativas = new Set<Tentativa>();
  let proximo = 0;
  let ultimoLancamento = 0;
  const noTempo = () => Date.now() - comeco <= config.tempoTotalMs;

  const lancar = () => {
    const i = proximo++;
    const controle = new AbortController();
    sinal.addEventListener("abort", () => controle.abort(), { once: true });
    const t = { i, controle } as Tentativa;
    t.fim = comecar(fila[i], sistema, mensagens, controle.signal, uteis).then((inicio) => ({ t, inicio }));
    ativas.add(t);
    ultimoLancamento = Date.now();
  };
  /// Cancela as outras tentativas (a vencedora segue sozinha).
  const encerrarOutras = () => {
    for (const t of ativas) {
      t.controle.abort();
      t.fim.then(({ inicio }) => inicio.leitor.cancel()).catch(() => {});
    }
    ativas.clear();
  };

  lancar();
  while (ativas.size) {
    if (sinal.aborted) {
      encerrarOutras();
      return null;
    }
    const podeEscalonar = proximo < fila.length && noTempo();
    let relogio: number | undefined;
    const escalonar = podeEscalonar
      ? new Promise<null>((ok) => {
        relogio = setTimeout(() => ok(null), Math.max(0, ultimoLancamento + config.escalonarMs - Date.now()));
      })
      : undefined;
    const r = await Promise.race([...[...ativas].map((t) => t.fim), ...(escalonar ? [escalonar] : [])]);
    clearTimeout(relogio);
    if (r === null) {
      console.log(`IA: ${fila[proximo - 1].nome} ainda não começou; chamando ${fila[proximo].nome} junto`);
      lancar();
      continue;
    }
    const { t, inicio } = r;
    ativas.delete(t);
    if (inicio.erro === undefined) {
      // Os chamados antes dele e ainda calados perderam para um mais novo: lentos
      // agora, ficam de fora um tempo (a próxima volta vai direto a este).
      for (const outra of ativas) {
        if (outra.i < t.i) esgotados.set(fila[outra.i].nome, Date.now() + PAUSA_SOBRECARGA_MS);
      }
      encerrarOutras();
      return inicio;
    }
    const ate = esgotadoAte(inicio.erro, Date.now());
    if (ate) esgotados.set(fila[t.i].nome, ate);
    const trocavel = vaiProProximo(inicio.erro) || inicio.erro instanceof Demorou;
    const temProximo = proximo < fila.length;
    // Erro do pedido em si (400), ou o último modelo falhou: o erro vai para o app.
    if (!trocavel || (!temProximo && ativas.size === 0)) {
      encerrarOutras();
      return inicio;
    }
    await inicio.leitor.cancel().catch(() => {});
    if (ativas.size === 0 && !noTempo()) {
      console.log(`IA: ${fila[t.i].nome} indisponível e o tempo acabou; desisto`);
      return null;
    }
    if (temProximo && noTempo()) {
      console.log(`IA: ${fila[t.i].nome} indisponível (${statusDoErro(inicio.erro) ?? "demorou"}); tentando ${fila[proximo].nome}`);
      lancar();
    }
  }
  return null;
}

/// Responde em stream. A resposta sai NA HORA (o app espera só 30 s pelo
/// começo) e, enquanto a cadeia procura um modelo livre, leva sinais de vida.
/// O primeiro modelo que começar a responder segue até o fim; o app não
/// percebe a troca.
export function responderComCadeia(
  cadeia: Escolha[],
  sistema: string,
  mensagens: ModelMessage[],
  sinal: AbortSignal,
  uteis: Ferramentas = ferramentas,
): Response {
  let leitor: ReadableStreamDefaultReader<UIMessageChunk> | undefined;
  const stream = new ReadableStream<UIMessageChunk>({
    async start(c) {
      const sinalDeVida = () => {
        try {
          c.enqueue({ type: "data-espera", data: null, transient: true });
        } catch {
          // o app já fechou a conexão
        }
      };
      // O primeiro já, para os cabeçalhos saírem (o servidor só os manda com o
      // primeiro pedaço) e o app saber que a IA está procurando.
      sinalDeVida();
      const vida = setInterval(sinalDeVida, config.sinalDeVidaMs);
      let inicio: Inicio | null;
      try {
        inicio = await primeiroQueResponde(cadeia, sistema, mensagens, sinal, uteis);
      } finally {
        clearInterval(vida);
      }
      if (!inicio) {
        c.enqueue({ type: "error", errorText: "A IA não respondeu agora. Tente de novo daqui a pouco." });
        c.close();
        return;
      }
      leitor = inicio.leitor;
      for (const pedaco of inicio.lidos) c.enqueue(pedaco);
    },
    async pull(c) {
      if (!leitor) return;
      const { value, done } = await leitor.read();
      if (done) c.close();
      else c.enqueue(value);
    },
    cancel() {
      return leitor?.cancel();
    },
  });
  return createUIMessageStreamResponse({ headers: cors, stream });
}
