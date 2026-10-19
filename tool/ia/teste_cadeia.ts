// Teste da cadeia de modelos (supabase/functions/assistente/cadeia.ts) com modelos
// simulados. Rodar com Node 24 numa pasta com `npm i ai @ai-sdk/anthropic @ai-sdk/google zod`
// nas versões do deno.json, copiando os .ts da função para ./fn e este arquivo junto:
//   node --no-warnings fn/teste_cadeia.ts   (com {"type":"module"} em fn/package.json)
// Cada caso usa nomes de modelo próprios: a cadeia lembra quem ficou sem cota.

import { APICallError } from "ai";
import { config, responderComCadeia } from "./cadeia.ts";

const usage = { inputTokens: { total: 1, noCache: 1, cacheRead: 0, cacheWrite: 0 }, outputTokens: { total: 1, text: 1, reasoning: 0 } };
const chamados: string[] = [];
let visto: { tools?: unknown[]; prompt: unknown[] } | undefined;

/// Modelo simulado: com [status], falha com esse HTTP (e [corpo]); com [demora],
/// espera antes de responder.
function modelo(nome: string, status?: number, { corpo = "", demora = 0 } = {}) {
  return {
    specificationVersion: "v4", provider: "mock", modelId: nome, supportedUrls: {},
    async doGenerate() { throw new Error("no"); },
    async doStream(opcoes: { abortSignal?: AbortSignal; tools?: unknown[]; prompt: unknown[] }) {
      chamados.push(nome);
      visto = opcoes;
      if (demora) {
        await new Promise((ok, falha) => {
          const t = setTimeout(ok, demora);
          opcoes.abortSignal?.addEventListener("abort", () => { clearTimeout(t); falha(new DOMException("abortado", "AbortError")); });
        });
      }
      if (status) {
        throw new APICallError({ message: `falha ${nome}`, url: "x", requestBodyValues: {}, statusCode: status, responseBody: corpo, isRetryable: status === 429 });
      }
      const partes = [
        { type: "stream-start", warnings: [] },
        { type: "text-start", id: "t" }, { type: "text-delta", id: "t", delta: `oi de ${nome}` }, { type: "text-end", id: "t" },
        { type: "finish", usage, finishReason: { unified: "stop", raw: "stop" } },
      ];
      return { stream: new ReadableStream({ start(c) { partes.forEach((p) => c.enqueue(p)); c.close(); } }) };
    },
  } as never;
}
const e = (nome: string, status?: number, opcoes = {}, semFerramentas = false) =>
  ({ model: modelo(nome, status, opcoes), nome, semFerramentas });
const msgs = [{ role: "user" as const, content: "oi" }];
const sinal = new AbortController().signal;
const ok = (cond: boolean, extra: string) => (cond ? "OK" : `FALHOU\n${extra}`);

// 1) principal sem cota, segundo fora do ar, terceiro responde.
let r = await responderComCadeia([e("c1-a", 429), e("c1-b", 503), e("c1-c")], "s", msgs, sinal);
let corpo = await r.text();
console.log("1:", chamados.join(">"), ok(corpo.includes("oi de c1-c") && !corpo.includes('"error"'), corpo));

// 2) todos sem cota: o último erro vai para o app como evento de erro.
chamados.length = 0;
r = await responderComCadeia([e("c2-a", 429), e("c2-b", 429)], "s", msgs, sinal);
corpo = await r.text();
console.log("2:", chamados.join(">"), ok(corpo.includes("limite de pedidos por minuto"), corpo));

// 3) erro do pedido (400) não troca de modelo.
chamados.length = 0;
r = await responderComCadeia([e("c3-a", 400), e("c3-b")], "s", msgs, sinal);
corpo = await r.text();
console.log("3:", chamados.join(">"), ok(chamados.length === 1 && corpo.includes('"error"'), corpo));

// 4) último recurso sem ferramentas: conversa só em texto e nenhuma ferramenta.
chamados.length = 0;
const comFerramenta = [
  { role: "user" as const, content: "apaga o netflix" },
  { role: "assistant" as const, content: [{ type: "tool-call" as const, toolCallId: "c", toolName: "consultar", input: {} }] },
  { role: "tool" as const, content: [{ type: "tool-result" as const, toolCallId: "c", toolName: "consultar", output: { type: "text" as const, value: "Netflix R$ 50" } }] },
];
r = await responderComCadeia([e("c4-a", 429), e("c4-gemma", undefined, {}, true)], "s", comFerramenta, sinal);
corpo = await r.text();
const prompt = JSON.stringify(visto!.prompt);
console.log("4:", ok(corpo.includes("oi de c4-gemma") && !visto!.tools?.length && !prompt.includes("tool-call") && prompt.includes("Netflix R$ 50"), prompt));

// 5) modelo que demora para começar: desiste dele e vai para o próximo.
chamados.length = 0;
config.tempoParaComecarMs = 300;
r = await responderComCadeia([e("c5-lento", undefined, { demora: 5000 }), e("c5-b")], "s", msgs, sinal);
corpo = await r.text();
console.log("5:", chamados.join(">"), ok(corpo.includes("oi de c5-b"), corpo));
config.tempoParaComecarMs = 20_000;

// 6) sem cota do DIA: na próxima pergunta nem tenta esse modelo.
chamados.length = 0;
const diario = '{"error":{"details":[{"quotaId":"GenerateRequestsPerDayPerProjectPerModel-FreeTier"}]}}';
await (await responderComCadeia([e("c6-dia", 429, { corpo: diario }), e("c6-b")], "s", msgs, sinal)).text();
await (await responderComCadeia([e("c6-dia", 429, { corpo: diario }), e("c6-b")], "s", msgs, sinal)).text();
console.log("6:", chamados.join(">"), ok(chamados.join(">") === "c6-dia>c6-b>c6-b", ""));

// 7) enquanto procura um modelo livre, a resposta já saiu e leva sinais de vida.
chamados.length = 0;
config.tempoParaComecarMs = 400;
config.sinalDeVidaMs = 100;
r = await responderComCadeia([e("c7-lento", undefined, { demora: 5000 }), e("c7-b")], "s", msgs, sinal);
corpo = await r.text();
console.log("7:", chamados.join(">"), ok(corpo.includes('"data-espera"') && corpo.includes("oi de c7-b"), corpo));

// 8) sobrecarregado (503) ou lento: na próxima volta nem tenta de novo.
chamados.length = 0;
await (await responderComCadeia([e("c8-cheio", 503), e("c8-lento", undefined, { demora: 5000 }), e("c8-b")], "s", msgs, sinal)).text();
await (await responderComCadeia([e("c8-cheio", 503), e("c8-lento", undefined, { demora: 5000 }), e("c8-b")], "s", msgs, sinal)).text();
console.log("8:", chamados.join(">"), ok(chamados.join(">") === "c8-cheio>c8-lento>c8-b>c8-b", ""));

// 9) passou do tempo total: para de tentar e avisa o app com um erro.
chamados.length = 0;
config.tempoTotalMs = 300;
r = await responderComCadeia([e("c9-a", undefined, { demora: 5000 }), e("c9-b")], "s", msgs, sinal);
corpo = await r.text();
console.log("9:", chamados.join(">"), ok(chamados.join(">") === "c9-a" && corpo.includes('"error"'), corpo));
config.tempoParaComecarMs = 20_000;
config.sinalDeVidaMs = 10_000;
config.tempoTotalMs = 100_000;

// 10) modelo lento sem dar erro: depois de escalonarMs o próximo é chamado junto
// e fica o primeiro que começar (o lento é cancelado).
chamados.length = 0;
config.escalonarMs = 200;
r = await responderComCadeia([e("c10-lento", undefined, { demora: 5000 }), e("c10-b")], "s", msgs, sinal);
corpo = await r.text();
console.log("10:", chamados.join(">"), ok(corpo.includes("oi de c10-b") && !corpo.includes("c10-lento"), corpo));

// 11) um lento correndo e o chamado junto falha (503): o seguinte entra na hora.
chamados.length = 0;
const t11 = Date.now();
r = await responderComCadeia([e("c11-lento", undefined, { demora: 5000 }), e("c11-cheio", 503), e("c11-c")], "s", msgs, sinal);
corpo = await r.text();
console.log("11:", chamados.join(">"), ok(corpo.includes("oi de c11-c") && Date.now() - t11 < 1000, corpo));
config.escalonarMs = 6_000;

// 12) quem perdeu a corrida por lentidão fica de fora na próxima volta.
chamados.length = 0;
config.escalonarMs = 200;
await (await responderComCadeia([e("c12-lento", undefined, { demora: 5000 }), e("c12-b")], "s", msgs, sinal)).text();
await (await responderComCadeia([e("c12-lento", undefined, { demora: 5000 }), e("c12-b")], "s", msgs, sinal)).text();
console.log("12:", chamados.join(">"), ok(chamados.join(">") === "c12-lento>c12-b>c12-b", ""));
config.escalonarMs = 6_000;
