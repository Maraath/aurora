// Teste dos limites da IA (supabase/functions/assistente/limites.ts) com um banco
// simulado. Rodar com Node 24, copiando comum.ts, limites.ts e este arquivo para
// ./fn (com {"type":"module"} em fn/package.json):
//   node --no-warnings fn/teste_limites.ts
// A soma de verdade está em consumir_uso_ia (migração 20261101120000_limites_ia.sql).

import { consumirUso, type Servico } from "./limites.ts";

const ambiente: Record<string, string> = {};
(globalThis as unknown as { Deno: unknown }).Deno = { env: { get: (nome: string) => ambiente[nome] } };

type Linha = Record<string, number>;

/// Banco simulado: consumir_uso_ia devolve nulo acima do limite, como o de verdade.
function banco(linhas: Linha[] = [], { erroLeitura = false, erroRpc = false } = {}) {
  const chamadas: Record<string, unknown>[] = [];
  const contas = new Map<string, number>();
  const servico: Servico = {
    rpc(_funcao, argumentos) {
      chamadas.push(argumentos);
      if (erroRpc) return Promise.resolve({ data: null, error: { message: "fora do ar" } });
      const chave = String(argumentos.tipo_uso);
      const atual = contas.get(chave) ?? 0;
      if (atual >= (argumentos.limite as number)) return Promise.resolve({ data: null, error: null });
      contas.set(chave, atual + 1);
      return Promise.resolve({ data: atual + 1, error: null });
    },
    from: () => ({
      select: () => ({
        eq: () => Promise.resolve({ data: erroLeitura ? null : linhas, error: erroLeitura ? { message: "fora do ar" } : null }),
      }),
    }),
  };
  return { servico, chamadas };
}

const pessoa = { id: "u1", email: "alguem@exemplo.com" };
let falhas = 0;
function confere(nome: string, certo: boolean) {
  console.log(`${certo ? "ok " : "FALHOU"} ${nome}`);
  if (!certo) falhas++;
}
const status = (r: Response | null) => r?.status ?? 200;
const erro = async (r: Response | null) => ((await r?.json()) as { erro?: string } | undefined)?.erro ?? "";

{
  const { servico } = banco();
  ambiente.LIMITE_DIARIO = "2";
  confere("1º pedido passa", status(await consumirUso(servico, pessoa, "pedido")) === 200);
  confere("2º pedido passa", status(await consumirUso(servico, pessoa, "pedido")) === 200);
  const r = await consumirUso(servico, pessoa, "pedido");
  confere("3º pedido é recusado", status(r) === 429);
  confere("a recusa diz o limite", (await erro(r)).includes("limite de 2 pedidos"));
  delete ambiente.LIMITE_DIARIO;
}

{
  const { servico, chamadas } = banco();
  ambiente.LIMITE_DIARIO = "1";
  await consumirUso(servico, pessoa, "volta");
  confere("voltas valem pedidos × 6", chamadas[0].limite === 6);
  for (let i = 0; i < 5; i++) await consumirUso(servico, pessoa, "volta");
  confere("7ª volta é recusada", status(await consumirUso(servico, pessoa, "volta")) === 429);
  delete ambiente.LIMITE_DIARIO;
}

{
  const { servico, chamadas } = banco();
  ambiente.LIMITE_AUDIO_DIARIO = "1";
  confere("1º áudio passa", status(await consumirUso(servico, pessoa, "audio")) === 200);
  confere("2º áudio é recusado", status(await consumirUso(servico, pessoa, "audio")) === 429);
  confere("áudio tem contador próprio", chamadas[0].tipo_uso === "audio");
  delete ambiente.LIMITE_AUDIO_DIARIO;
}

{
  const { servico, chamadas } = banco([{ pedidos: 200 }, { pedidos: 100 }]);
  const r = await consumirUso(servico, pessoa, "pedido");
  confere("limite geral recusa", status(r) === 429 && (await erro(r)).includes("para todos"));
  confere("limite geral não gasta o da conta", chamadas.length === 0);
}

{
  const { servico } = banco([{ pedidos: 300 }]);
  ambiente.IA_SEM_LIMITE_GERAL = " Alguem@exemplo.com ,outro@exemplo.com";
  confere("e-mail livre passa do geral", status(await consumirUso(servico, pessoa, "pedido")) === 200);
  delete ambiente.IA_SEM_LIMITE_GERAL;
}

{
  const { servico } = banco([{ voltas: 1799 }]);
  confere("voltas: geral é pedidos × 6", status(await consumirUso(servico, pessoa, "volta")) === 200);
  const { servico: cheio } = banco([{ voltas: 1800 }]);
  confere("voltas: geral recusa no teto", status(await consumirUso(cheio, pessoa, "volta")) === 429);
}

{
  const { servico } = banco([], { erroLeitura: true });
  confere("falha ao ler o geral recusa", status(await consumirUso(servico, pessoa, "pedido")) === 503);
  const { servico: semRpc } = banco([], { erroRpc: true });
  confere("falha ao somar recusa", status(await consumirUso(semRpc, pessoa, "audio")) === 503);
}

console.log(falhas ? `\n${falhas} falha(s)` : "\nTudo certo");
if (falhas) (globalThis as unknown as { process: { exit(c: number): void } }).process.exit(1);
