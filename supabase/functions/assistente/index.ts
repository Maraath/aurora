// Aurora · assistente com IA.
//
// O app manda o pedido, um resumo dos dados (montado no próprio aparelho) e o
// fim da conversa. A função confere quem está logado, aplica o limite diário,
// chama a IA e devolve:
//   { resposta: string, comandos: string[] }
// "comandos" são frases no formato dos comandos rápidos do app ("gastei 35 no
// mercado", "me lembra de X amanhã às 10h"); o APP executa cada uma, com o
// mesmo interpretador que funciona offline.
//
// Fornecedor trocável por segredo: IA_FORNECEDOR = "gemini" (padrão) ou
// "anthropic". Chaves só em segredos: GEMINI_API_KEY / ANTHROPIC_API_KEY.
// Limite diário por pessoa: LIMITE_DIARIO (padrão 60).

import { createClient } from "npm:@supabase/supabase-js@2";

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

type Mensagem = { papel: "eu" | "aurora"; texto: string };

const INSTRUCOES = `Você é a Aurora, assistente pessoal dentro de um app de rotina
(tarefas, hábitos, treino, finanças, metas e lembretes). Fale português do Brasil,
de forma direta e calorosa, em no máximo 4 frases curtas, sem markdown.

Use o RESUMO DOS DADOS para responder sobre a vida da pessoa. Não invente números
que não estejam lá; se faltar informação, diga.

Quando a pessoa pedir para CRIAR ou REGISTRAR algo, não diga que criou: coloque em
"comandos" frases exatamente neste formato (o app executa):
- "gastei 35,90 no mercado" | "gastei 50 no restaurante ontem" | "recebi 500 do freela"
- "me lembra de ligar pro dentista amanhã às 10h" | "me lembra de pagar a luz todo dia 10"
  | "me lembra de ir à academia toda segunda e quarta às 19h"
- "tarefa: revisar currículo" | "adiciona tarefa de mandar e-mail amanhã às 14h"
- "fiz o cardio" (nome do hábito) | "pesei 74,5" | "braço 37,5 cm"
- "comi 200 g de frango no almoço" | "comi 2 ovos no café" | "bebi 300 ml de leite no jantar"
  (use o nome de um dos "Alimentos cadastrados"; refeições: café, almoço, lanche, jantar, ceia)
Na "resposta", diga em uma frase o que vai ser feito. Sem pedido de ação, "comandos" = [].

Responda SOMENTE com JSON: {"resposta": "...", "comandos": ["..."]}`;

function json(corpo: unknown, status = 200) {
  return new Response(JSON.stringify(corpo), {
    status,
    headers: { ...cors, "Content-Type": "application/json" },
  });
}

/// Erro que já vem com a mensagem para a pessoa (e o status HTTP a devolver).
class ErroParaPessoa extends Error {
  constructor(mensagem: string, readonly status: number) {
    super(mensagem);
  }
}

async function chamarGemini(sistema: string, historico: Mensagem[], pedido: string) {
  const chave = Deno.env.get("GEMINI_API_KEY");
  if (!chave) throw new Error("GEMINI_API_KEY não configurada");
  // Lite e sem "raciocínio": responde em poucos segundos, o que basta para
  // falar dos dados do app e montar comandos.
  const modelo = Deno.env.get("GEMINI_MODELO") ?? "gemini-flash-lite-latest";
  const pedir = (semRaciocinio: boolean) =>
    fetch(`https://generativelanguage.googleapis.com/v1beta/models/${modelo}:generateContent`, {
      method: "POST",
      headers: { "Content-Type": "application/json", "x-goog-api-key": chave },
      body: JSON.stringify({
        systemInstruction: { parts: [{ text: sistema }] },
        contents: [
          ...historico.map((m) => ({
            role: m.papel === "eu" ? "user" : "model",
            parts: [{ text: m.texto }],
          })),
          { role: "user", parts: [{ text: pedido }] },
        ],
        generationConfig: {
          responseMimeType: "application/json",
          temperature: 0.4,
          ...(semRaciocinio ? { thinkingConfig: { thinkingBudget: 0 } } : {}),
        },
      }),
      signal: AbortSignal.timeout(40_000),
    });

  let r = await pedir(true);
  // Modelo que não aceita desligar o raciocínio: tenta de novo sem a opção.
  if (r.status === 400) r = await pedir(false);
  if (r.status === 429) {
    throw new ErroParaPessoa(
      "A IA gratuita chegou ao limite de pedidos por minuto. Tente de novo em instantes.",
      429,
    );
  }
  if (!r.ok) throw new Error(`Gemini ${r.status}: ${(await r.text()).slice(0, 300)}`);
  const dados = await r.json();
  return dados?.candidates?.[0]?.content?.parts?.map((p: { text?: string }) => p.text ?? "").join("") ?? "";
}

async function chamarAnthropic(sistema: string, historico: Mensagem[], pedido: string) {
  const chave = Deno.env.get("ANTHROPIC_API_KEY");
  if (!chave) throw new Error("ANTHROPIC_API_KEY não configurada");
  const modelo = Deno.env.get("ANTHROPIC_MODELO") ?? "claude-haiku-5-5";
  const r = await fetch("https://api.anthropic.com/v1/messages", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "x-api-key": chave,
      "anthropic-version": "2023-06-01",
    },
    body: JSON.stringify({
      model: modelo,
      max_tokens: 800,
      system: sistema,
      messages: [
        ...historico.map((m) => ({ role: m.papel === "eu" ? "user" : "assistant", content: m.texto })),
        { role: "user", content: pedido },
      ],
    }),
  });
  if (!r.ok) throw new Error(`Anthropic ${r.status}: ${(await r.text()).slice(0, 300)}`);
  const dados = await r.json();
  return (dados?.content ?? []).map((b: { text?: string }) => b.text ?? "").join("");
}

/// Tira o JSON da resposta (alguns modelos cercam com ```json).
function lerResposta(texto: string): { resposta: string; comandos: string[] } {
  const inicio = texto.indexOf("{");
  const fim = texto.lastIndexOf("}");
  try {
    const o = JSON.parse(texto.slice(inicio, fim + 1));
    return {
      resposta: String(o.resposta ?? "").trim(),
      comandos: Array.isArray(o.comandos) ? o.comandos.map(String).slice(0, 5) : [],
    };
  } catch {
    return { resposta: texto.trim(), comandos: [] };
  }
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

  let corpo: { pedido?: string; contexto?: string; historico?: Mensagem[] };
  try {
    corpo = await req.json();
  } catch {
    return json({ erro: "Pedido inválido." }, 400);
  }
  const pedido = (corpo.pedido ?? "").trim().slice(0, 2000);
  if (!pedido) return json({ erro: "Pedido vazio." }, 400);

  // Limite diário por pessoa (a tabela só é gravada com a chave de serviço).
  const servico = createClient(url, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!);
  const limite = Number(Deno.env.get("LIMITE_DIARIO") ?? "60");
  const hoje = new Date().toLocaleDateString("en-CA", { timeZone: "America/Sao_Paulo" });
  const { data: uso } = await servico
    .from("uso_ia").select("pedidos").eq("user_id", user.id).eq("dia", hoje).maybeSingle();
  const usados = uso?.pedidos ?? 0;
  if (usados >= limite) {
    return json({ erro: `Você chegou ao limite de ${limite} pedidos à IA hoje. Amanhã libera de novo.` }, 429);
  }
  await servico.from("uso_ia").upsert({ user_id: user.id, dia: hoje, pedidos: usados + 1 });

  const sistema = `${INSTRUCOES}\n\nRESUMO DOS DADOS (feito pelo app agora):\n${(corpo.contexto ?? "").slice(0, 12000)}`;
  const historico = (corpo.historico ?? [])
    .filter((m) => (m.papel === "eu" || m.papel === "aurora") && m.texto)
    .slice(-10);

  try {
    const fornecedor = (Deno.env.get("IA_FORNECEDOR") ?? "gemini").toLowerCase();
    const bruto = fornecedor === "anthropic"
      ? await chamarAnthropic(sistema, historico, pedido)
      : await chamarGemini(sistema, historico, pedido);
    const r = lerResposta(bruto);
    if (!r.resposta && r.comandos.length === 0) throw new Error("Resposta vazia da IA");
    return json(r);
  } catch (e) {
    console.error(e);
    if (e instanceof ErroParaPessoa) return json({ erro: e.message }, e.status);
    return json({ erro: "A IA não respondeu agora. Tente de novo daqui a pouco." }, 502);
  }
});
