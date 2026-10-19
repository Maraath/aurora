// Formato antigo do assistente (app até a 1.8.x, inclusive o Android 1.7):
// o app manda { pedido, contexto, historico } e espera, de uma vez só,
// { resposta: string, comandos: string[] }. "comandos" são frases no formato
// dos comandos rápidos do app, que ele executa com o interpretador offline.
// Fica aqui até todos os aparelhos usarem o formato novo (ver index.ts).

import { ErroParaPessoa, json } from "./comum.ts";

export type MensagemLegada = { papel: "eu" | "aurora"; texto: string };

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

async function chamarGemini(sistema: string, historico: MensagemLegada[], pedido: string) {
  const chave = Deno.env.get("GEMINI_API_KEY");
  if (!chave) throw new Error("GEMINI_API_KEY não configurada");
  const modelo = Deno.env.get("GEMINI_MODELO_LEGADO") ?? "gemini-flash-lite-latest";
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

/// Responde no formato antigo (o limite diário já foi conferido no index.ts).
export async function responderLegado(
  pedido: string,
  contexto: string,
  historicoBruto: MensagemLegada[],
): Promise<Response> {
  const sistema = `${INSTRUCOES}\n\nRESUMO DOS DADOS (feito pelo app agora):\n${contexto.slice(0, 12000)}`;
  const historico = historicoBruto
    .filter((m) => (m.papel === "eu" || m.papel === "aurora") && m.texto)
    .slice(-10);
  try {
    const r = lerResposta(await chamarGemini(sistema, historico, pedido));
    if (!r.resposta && r.comandos.length === 0) throw new Error("Resposta vazia da IA");
    return json(r);
  } catch (e) {
    console.error(e);
    if (e instanceof ErroParaPessoa) return json({ erro: e.message }, e.status);
    return json({ erro: "A IA não respondeu agora. Tente de novo daqui a pouco." }, 502);
  }
}
