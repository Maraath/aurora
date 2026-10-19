// Teste da cadeia de modelos (supabase/functions/assistente/cadeia.ts) com modelos
// simulados. Rodar com Node 24 numa pasta com `npm i ai @ai-sdk/anthropic @ai-sdk/google zod`
// nas versões do deno.json, copiando os .ts da função para ./fn e este arquivo junto:
//   node --no-warnings fn/teste_cadeia.ts   (com {"type":"module"} em fn/package.json)

import { APICallError } from "ai";
import { responderComCadeia } from "./cadeia.ts";

const usage = { inputTokens: { total: 1, noCache: 1, cacheRead: 0, cacheWrite: 0 }, outputTokens: { total: 1, text: 1, reasoning: 0 } };
const chamados: string[] = [];
function modelo(nome: string, status?: number) {
  return {
    specificationVersion: "v4", provider: "mock", modelId: nome, supportedUrls: {},
    async doGenerate() { throw new Error("no"); },
    async doStream() {
      chamados.push(nome);
      if (status) {
        throw new APICallError({ message: `quota ${nome}`, url: "x", requestBodyValues: {}, statusCode: status, isRetryable: status === 429 });
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
const msgs = [{ role: "user" as const, content: "oi" }];
const sinal = new AbortController().signal;

// 1) principal no limite (dia), segundo no limite (minuto), terceiro responde.
let r = await responderComCadeia(
  [{ model: modelo("flash", 429), nome: "flash" }, { model: modelo("lite", 503), nome: "lite" }, { model: modelo("2.5", undefined), nome: "2.5" }],
  "s", msgs, sinal);
let corpo = await r.text();
console.log("1:", r.status, chamados.join(">"), corpo.includes("oi de 2.5") && !corpo.includes('"error"') ? "OK" : "FALHOU\n" + corpo);

// 2) todos no limite: o último erro vai para o app como evento de erro.
chamados.length = 0;
r = await responderComCadeia([{ model: modelo("a", 429), nome: "a" }, { model: modelo("b", 429), nome: "b" }], "s", msgs, sinal);
corpo = await r.text();
console.log("2:", chamados.join(">"), corpo.includes("limite de pedidos por minuto") ? "OK" : "FALHOU\n" + corpo);

// 3) erro do pedido (400) não troca de modelo.
chamados.length = 0;
r = await responderComCadeia([{ model: modelo("a", 400), nome: "a" }, { model: modelo("b"), nome: "b" }], "s", msgs, sinal);
corpo = await r.text();
console.log("3:", chamados.join(">"), chamados.length === 1 && corpo.includes('"error"') ? "OK" : "FALHOU\n" + corpo);
