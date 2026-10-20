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
import { cadeiaDeModelos, type Escolha, esquemaMensagens, janela, PERSONA } from "./agente.ts";
import { mensagemDeErro, responderComCadeia } from "./cadeia.ts";
import { cors, ErroParaPessoa, json } from "./comum.ts";
import { type MensagemLegada, responderLegado } from "./legado.ts";
import { FORMATOS_AUDIO, MAX_AUDIO_BASE64, transcrever } from "./transcrever.ts";

/// Voltas seguidas de ferramenta depois de uma mensagem da pessoa.
const MAX_VOLTAS_FERRAMENTA = 6;

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

  let corpo: {
    pedido?: string;
    contexto?: string;
    historico?: MensagemLegada[];
    mensagens?: unknown;
    audio?: unknown;
    formato?: unknown;
  };
  try {
    corpo = await req.json();
  } catch {
    return json({ erro: "Pedido inválido." }, 400);
  }

  // Comando por voz (app 1.9.7+): { audio: base64, formato } → { texto }. Não
  // conta no limite do dia: o texto volta ao app e o pedido conta quando ele
  // for enviado à conversa.
  if (corpo.audio !== undefined) {
    const formato = String(corpo.formato ?? "");
    if (typeof corpo.audio !== "string" || !corpo.audio || !FORMATOS_AUDIO.has(formato)) {
      return json({ erro: "Áudio inválido." }, 400);
    }
    if (corpo.audio.length > MAX_AUDIO_BASE64) return json({ erro: "Áudio longo demais: fale em até um minuto." }, 413);
    try {
      return json({ texto: await transcrever(corpo.audio, formato, req.signal) });
    } catch (e) {
      return e instanceof ErroParaPessoa ? json({ erro: e.message }, e.status) : json({ erro: mensagemDeErro(e) }, 500);
    }
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

  let cadeia: Escolha[];
  try {
    // "x-ia-reserva: 1": o app já viu o primeiro modelo no limite; começa do segundo.
    cadeia = cadeiaDeModelos(req.headers.get("x-ia-reserva") === "1");
  } catch (e) {
    return json({ erro: mensagemDeErro(e) }, 500);
  }
  const sistema = `${PERSONA}\n\nRESUMO DOS DADOS (montado pelo app agora):\n${contexto}`;
  return responderComCadeia(cadeia, sistema, mensagens!, req.signal);
});
