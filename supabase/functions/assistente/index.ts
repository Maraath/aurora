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
// Limites diários: ver limites.ts. Pedido, volta de ferramenta e áudio contam
// cada um no seu contador, antes de chamar qualquer modelo.

import { createClient } from "@supabase/supabase-js";
import {
  cadeiaDeModelos,
  type Escolha,
  esquemaMensagens,
  ferramentas,
  ferramentasRotina,
  janela,
  PERSONA,
  PERSONA_ROTINA,
} from "./agente.ts";
import { mensagemDeErro, responderComCadeia } from "./cadeia.ts";
import { cors, ErroParaPessoa, json } from "./comum.ts";
import { esquemaHistorico, type MensagemLegada, responderLegado } from "./legado.ts";
import { consumirUso, MAX_CONVERSA, MAX_VOLTAS_FERRAMENTA, type Servico } from "./limites.ts";
import { FORMATOS_AUDIO, FORMATOS_NOTA, MAX_AUDIO_BASE64, MAX_NOTA_BASE64, transcrever } from "./transcrever.ts";

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
    uso?: unknown;
    /// O que o app sabe fazer além do básico (app 1.12+: ["rotina"]).
    recursos?: unknown;
  };
  try {
    corpo = await req.json();
  } catch {
    return json({ erro: "Pedido inválido." }, 400);
  }

  // A tabela de uso só é gravada com a chave de serviço.
  const servico = createClient(url, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!) as unknown as Servico;

  // Comando por voz (app 1.9.7+): { audio: base64, formato } → { texto }. Conta
  // nos áudios do dia; o texto volta ao app e conta como pedido quando ele for
  // enviado à conversa.
  // Nota de áudio das Anotações (app 1.11+): { audio, formato, uso: "nota" },
  // até 10 minutos, transcrita como ditado.
  if (corpo.audio !== undefined) {
    const formato = String(corpo.formato ?? "");
    const nota = corpo.uso === "nota";
    if (typeof corpo.audio !== "string" || !corpo.audio || !(nota ? FORMATOS_NOTA : FORMATOS_AUDIO).has(formato)) {
      return json({ erro: "Áudio inválido." }, 400);
    }
    if (corpo.audio.length > (nota ? MAX_NOTA_BASE64 : MAX_AUDIO_BASE64)) {
      return json({ erro: nota ? "Áudio longo demais para transcrever (até 10 minutos)." : "Áudio longo demais: fale em até um minuto." }, 413);
    }
    const recusaAudio = await consumirUso(servico, user, "audio");
    if (recusaAudio) return recusaAudio;
    try {
      return json({ texto: await transcrever(corpo.audio, formato, req.signal, nota) });
    } catch (e) {
      return e instanceof ErroParaPessoa ? json({ erro: e.message }, e.status) : json({ erro: mensagemDeErro(e) }, 500);
    }
  }
  const contexto = String(corpo.contexto ?? "").slice(0, 16000);
  const legado = typeof corpo.pedido === "string";

  // Conversa (formato novo) ou pedido (legado).
  let mensagens;
  let historico: MensagemLegada[] = [];
  let daPessoa: boolean;
  if (legado) {
    if (!corpo.pedido!.trim()) return json({ erro: "Pedido vazio." }, 400);
    const lido = esquemaHistorico.safeParse(corpo.historico ?? []);
    if (!lido.success) return json({ erro: "Conversa inválida." }, 400);
    historico = lido.data;
    daPessoa = true;
  } else {
    const lida = esquemaMensagens.safeParse(corpo.mensagens);
    if (!lida.success) return json({ erro: "Conversa inválida." }, 400);
    mensagens = janela(lida.data);
    if (mensagens.length === 0) return json({ erro: "Conversa vazia." }, 400);
    if (JSON.stringify(mensagens).length > MAX_CONVERSA) return json({ erro: "Conversa grande demais." }, 413);
    const ultima = mensagens[mensagens.length - 1];
    daPessoa = ultima.role === "user";
    const voltas = mensagens.length - 1 - mensagens.findLastIndex((m) => m.role === "user");
    if (!daPessoa && (ultima.role !== "tool" || voltas > MAX_VOLTAS_FERRAMENTA * 2)) {
      return json({ erro: "Conversa inválida." }, 400);
    }
  }

  const recusa = await consumirUso(servico, user, daPessoa ? "pedido" : "volta");
  if (recusa) return recusa;

  if (legado) return responderLegado(corpo.pedido!.trim().slice(0, 2000), contexto, historico);

  let cadeia: Escolha[];
  try {
    // "x-ia-reserva: 1": o app já viu o primeiro modelo no limite; começa do segundo.
    cadeia = cadeiaDeModelos(req.headers.get("x-ia-reserva") === "1");
  } catch (e) {
    return json({ erro: mensagemDeErro(e) }, 500);
  }
  // App da Rotina (1.12+): compromisso, calendário e as telas novas.
  const comRotina = Array.isArray(corpo.recursos) && corpo.recursos.includes("rotina");
  const sistema = `${PERSONA}${comRotina ? PERSONA_ROTINA : ""}\n\nRESUMO DOS DADOS (montado pelo app agora):\n${contexto}`;
  return responderComCadeia(cadeia, sistema, mensagens!, req.signal, comRotina ? ferramentasRotina : ferramentas);
});
