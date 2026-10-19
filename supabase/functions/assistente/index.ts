// Aurora · assistente com IA (Edge Function).
//
// Formato novo (app 1.9+): o app manda { mensagens, contexto }:
//   mensagens: a conversa no formato ModelMessage da AI SDK (pessoa, Aurora e
//              resultados de ferramentas), já recortada pelo app;
//   contexto:  resumo dos dados montado no aparelho agora.
// A resposta é um stream SSE no protocolo de UI da Vercel AI SDK (o mesmo que o
// useChat consome): "text-delta" com pedaços do texto, "tool-input-available"
// quando a IA quer usar uma ferramenta, "error" e "finish". O app executa as
// ferramentas no banco local e chama de novo com os resultados (ver agente.ts).
//
// Formato antigo ({ pedido, contexto, historico } → JSON): ver legado.ts.
//
// Modelo: Claude (ANTHROPIC_API_KEY) ou Gemini (GEMINI_API_KEY), ver agente.ts.
// Limite diário por pessoa: LIMITE_DIARIO (padrão 60). Limite diário somando
// todas as contas: LIMITE_GERAL_DIARIO (padrão 300); e-mails em
// IA_SEM_LIMITE_GERAL ficam fora dele (o dono). Só conta pedido da pessoa: a
// volta com resultados de ferramenta é parte da mesma resposta.

import { createClient } from "@supabase/supabase-js";
import { APICallError, streamText } from "ai";
import { escolherModelo, esquemaMensagens, ferramentas, janela, PERSONA } from "./agente.ts";
import { cors, json } from "./comum.ts";
import { type MensagemLegada, responderLegado } from "./legado.ts";

/// Voltas seguidas de ferramenta depois de uma mensagem da pessoa.
const MAX_VOLTAS_FERRAMENTA = 6;

/// Mensagem para a pessoa a partir de um erro do fornecedor.
function mensagemDeErro(e: unknown): string {
  console.error(e);
  // RetryError guarda o último erro; APICallError tem o status HTTP.
  const ultimo = (e as { lastError?: unknown })?.lastError ?? e;
  const status = APICallError.isInstance(ultimo) ? ultimo.statusCode : undefined;
  if (status === 429) return "A IA chegou ao limite de pedidos por minuto. Tente de novo em instantes.";
  if (status === 529 || status === 503) return "A IA está sobrecarregada agora. Tente de novo daqui a pouco.";
  if (status === 401 || status === 403) return "A chave da IA no servidor não foi aceita. Avise o dono do app.";
  return "A IA não respondeu agora. Tente de novo daqui a pouco.";
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  if (req.method !== "POST") return json({ erro: "Use POST." }, 405);

  const url = Deno.env.get("SUPABASE_URL")!;
  const autorizacao = req.headers.get("Authorization") ?? "";
  const comoUsuario = createClient(url, Deno.env.get("SUPABASE_ANON_KEY")!, {
    global: { headers: { Authorization: autorizacao } },
  });
  const { data: { user } } = await comoUsuario.auth.getUser();
  if (!user) return json({ erro: "Entre na sua conta para usar a IA." }, 401);

  let corpo: { pedido?: string; contexto?: string; historico?: MensagemLegada[]; mensagens?: unknown };
  try {
    corpo = await req.json();
  } catch {
    return json({ erro: "Pedido inválido." }, 400);
  }
  const contexto = String(corpo.contexto ?? "").slice(0, 16000);
  const legado = typeof corpo.pedido === "string";

  // Conversa (formato novo) ou pedido (legado).
  let mensagens;
  let daPessoa: boolean;
  if (legado) {
    if (!corpo.pedido!.trim()) return json({ erro: "Pedido vazio." }, 400);
    daPessoa = true;
  } else {
    const lida = esquemaMensagens.safeParse(corpo.mensagens);
    if (!lida.success) return json({ erro: "Conversa inválida." }, 400);
    mensagens = janela(lida.data);
    if (mensagens.length === 0) return json({ erro: "Conversa vazia." }, 400);
    const ultima = mensagens[mensagens.length - 1];
    daPessoa = ultima.role === "user";
    const voltas = mensagens.length - 1 - mensagens.findLastIndex((m) => m.role === "user");
    if (!daPessoa && (ultima.role !== "tool" || voltas > MAX_VOLTAS_FERRAMENTA * 2)) {
      return json({ erro: "Conversa inválida." }, 400);
    }
  }

  // Limite diário por pessoa (a tabela só é gravada com a chave de serviço).
  const servico = createClient(url, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!);
  const limite = Number(Deno.env.get("LIMITE_DIARIO") ?? "60");
  const hoje = new Date().toLocaleDateString("en-CA", { timeZone: "America/Sao_Paulo" });
  const { data: uso } = await servico
    .from("uso_ia").select("pedidos").eq("user_id", user.id).eq("dia", hoje).maybeSingle();
  const usados = uso?.pedidos ?? 0;
  if (daPessoa) {
    if (usados >= limite) {
      return json({ erro: `Você chegou ao limite de ${limite} pedidos à IA hoje. Amanhã libera de novo.` }, 429);
    }
    // Limite de todas as contas juntas: criar contas novas não esgota a cota da
    // IA. Quem está em IA_SEM_LIMITE_GERAL (e-mails separados por vírgula) passa.
    const limiteGeral = Number(Deno.env.get("LIMITE_GERAL_DIARIO") ?? "300");
    const livres = (Deno.env.get("IA_SEM_LIMITE_GERAL") ?? "")
      .split(",").map((e) => e.trim().toLowerCase()).filter(Boolean);
    if (!livres.includes((user.email ?? "").toLowerCase())) {
      const { data: hojeTodos } = await servico.from("uso_ia").select("pedidos").eq("dia", hoje);
      const total = (hojeTodos ?? []).reduce((s, l) => s + (l.pedidos ?? 0), 0);
      if (total >= limiteGeral) {
        return json({ erro: "A IA chegou ao limite do dia para todos. Amanhã libera de novo." }, 429);
      }
    }
    await servico.from("uso_ia").upsert({ user_id: user.id, dia: hoje, pedidos: usados + 1 });
  } else if (usados === 0) {
    // Volta de ferramenta sem nenhum pedido hoje: não veio de uma conversa real.
    return json({ erro: "Conversa inválida." }, 400);
  }

  if (legado) return responderLegado(corpo.pedido!.trim().slice(0, 2000), contexto, corpo.historico ?? []);

  let escolha;
  try {
    escolha = escolherModelo();
  } catch (e) {
    return json({ erro: mensagemDeErro(e) }, 500);
  }

  const resultado = streamText({
    model: escolha.model,
    system: `${PERSONA}\n\nRESUMO DOS DADOS (montado pelo app agora):\n${contexto}`,
    messages: mensagens!,
    tools: ferramentas,
    temperature: escolha.temperature,
    providerOptions: escolha.providerOptions,
    maxOutputTokens: 4000,
    abortSignal: req.signal,
  });
  return resultado.toUIMessageStreamResponse({
    headers: cors,
    sendReasoning: false,
    onError: mensagemDeErro,
  });
});
