// Aurora · comando por voz: o app grava, manda o áudio aqui e recebe o texto.
// O texto volta para o app, que o envia à conversa como se a pessoa tivesse
// digitado (comandos rápidos, ferramentas e "Desfazer" funcionam igual).
//
// Quem transcreve é o Gemini (a Claude não ouve áudio). Cada modelo tem a sua
// cota no plano gratuito, então tenta em ordem, os Lite primeiro (mais cota e
// mais rápidos; transcrever é fácil).

import { createGoogleGenerativeAI } from "@ai-sdk/google";
import { generateText } from "ai";
import { statusDoErro } from "./cadeia.ts";
import { ErroParaPessoa } from "./comum.ts";

/// Trocável sem publicar versão: segredo GEMINI_MODELOS_VOZ ("a,b,c").
export const MODELOS_TRANSCRICAO = [
  "gemini-3.5-flash-lite",
  "gemini-3.1-flash-lite",
  "gemini-3.5-flash",
  "gemini-3-flash-preview",
];

/// Formatos que o app grava (o Gemini aceita os dois).
export const FORMATOS_AUDIO = new Set(["audio/flac", "audio/wav"]);

/// ~90 s de FLAC ou ~60 s de WAV 16 kHz mono, em base64.
export const MAX_AUDIO_BASE64 = 3_000_000;

/// Quanto cada modelo pode levar antes de passar ao próximo.
export const config = { tempoPorModeloMs: 20_000 };

const INSTRUCAO = `Transcreva o áudio: é uma pessoa falando com a Aurora, a assistente de um app de rotina
(tarefas, hábitos, treino, alimentação, finanças, metas, lembretes), em português do Brasil.
Devolva SÓ o que ela disse, com pontuação, sem comentários, aspas ou explicações.
Escreva números com algarismos ("gastei 35 no mercado", "às 10h", "74,5 kg", "dia 10").
Se não houver fala compreensível, devolva exatamente: (silêncio)`;

/// Áudio em base64 → texto. Lança [ErroParaPessoa] se nenhum modelo conseguir.
export async function transcrever(audio: string, formato: string, sinal: AbortSignal): Promise<string> {
  const chave = Deno.env.get("GEMINI_API_KEY");
  if (!chave) throw new ErroParaPessoa("A transcrição de voz não está configurada no servidor.", 500);
  const google = createGoogleGenerativeAI({ apiKey: chave });
  const nomes = (Deno.env.get("GEMINI_MODELOS_VOZ") ?? "").split(",").map((n) => n.trim()).filter(Boolean);
  let ultimo: unknown;
  for (const nome of nomes.length ? nomes : MODELOS_TRANSCRICAO) {
    if (sinal.aborted) break;
    try {
      const { text } = await generateText({
        model: google(nome),
        messages: [{
          role: "user",
          content: [
            { type: "text", text: INSTRUCAO },
            { type: "file", data: audio, mediaType: formato },
          ],
        }],
        temperature: 0,
        maxOutputTokens: 1000,
        maxRetries: 0,
        abortSignal: AbortSignal.any([sinal, AbortSignal.timeout(config.tempoPorModeloMs)]),
      });
      const limpo = text.trim().replace(/^["“]|["”]$/g, "").trim();
      return limpo === "(silêncio)" ? "" : limpo;
    } catch (e) {
      ultimo = e;
      console.log(`Voz: ${nome} falhou (${statusDoErro(e) ?? (e as Error)?.name ?? "erro"}); tentando o próximo`);
    }
  }
  console.error(ultimo);
  throw new ErroParaPessoa("Não deu para entender o áudio agora. Tente de novo daqui a pouco ou digite.", 502);
}
