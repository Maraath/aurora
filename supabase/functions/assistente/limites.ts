// Limites diários da IA. Tudo que chama um modelo conta: o pedido da pessoa, cada
// volta de ferramenta e cada áudio transcrito. A soma é feita no banco numa
// operação só (consumir_uso_ia), então pedidos ao mesmo tempo não escapam. Se não
// der para conferir, recusa: limite que falha aberto não é limite.
//
// Trocáveis sem publicar: LIMITE_DIARIO (60 pedidos por conta), LIMITE_VOLTAS_DIARIO
// (padrão: o que os pedidos do dia usam no máximo), LIMITE_AUDIO_DIARIO (100) e
// LIMITE_GERAL_DIARIO (300 pedidos somando as contas; e-mails em
// IA_SEM_LIMITE_GERAL ficam fora dele).

import { json } from "./comum.ts";

/// Voltas seguidas de ferramenta depois de uma mensagem da pessoa.
export const MAX_VOLTAS_FERRAMENTA = 6;

/// Conversa inteira depois da janela, em caracteres. A janela sempre guarda a
/// última mensagem, então sem este teto ela podia ter 400 mil.
export const MAX_CONVERSA = 100_000;

export type TipoUso = "pedido" | "volta" | "audio";

const COLUNA = { pedido: "pedidos", volta: "voltas", audio: "audios" } as const;

const AVISO_CONTA = {
  pedido: (limite: number) => `Você chegou ao limite de ${limite} pedidos à IA hoje. Amanhã libera de novo.`,
  volta: () => "A IA fez ações demais hoje nesta conta. Amanhã libera de novo.",
  audio: () => "Você chegou ao limite de áudios transcritos hoje. Amanhã libera de novo.",
};

type Consulta = PromiseLike<{ data: Record<string, number>[] | null; error: unknown }>;

/// O que este arquivo usa do cliente com a chave de serviço.
export type Servico = {
  rpc(funcao: string, argumentos: Record<string, unknown>): PromiseLike<{ data: unknown; error: unknown }>;
  from(tabela: string): { select(colunas: string): { eq(coluna: string, valor: string): Consulta } };
};

function numero(nome: string, padrao: number): number {
  const valor = Number(Deno.env.get(nome) ?? "");
  return Number.isFinite(valor) && valor > 0 ? valor : padrao;
}

/// Soma um uso de [tipo] na conta. Nulo se pode seguir; senão, a resposta de recusa.
export async function consumirUso(
  servico: Servico,
  usuario: { id: string; email?: string },
  tipo: TipoUso,
): Promise<Response | null> {
  const limiteConta = numero("LIMITE_DIARIO", 60);
  const limite = tipo === "pedido"
    ? limiteConta
    : tipo === "volta"
    ? numero("LIMITE_VOLTAS_DIARIO", limiteConta * MAX_VOLTAS_FERRAMENTA)
    : numero("LIMITE_AUDIO_DIARIO", 100);
  const limiteGeral = numero("LIMITE_GERAL_DIARIO", 300) * (tipo === "volta" ? MAX_VOLTAS_FERRAMENTA : 1);
  const dia = new Date().toLocaleDateString("en-CA", { timeZone: "America/Sao_Paulo" });
  const indisponivel = () => json({ erro: "Não deu para conferir seu limite agora. Tente de novo em instantes." }, 503);

  // Limite de todas as contas juntas: criar contas novas não esgota a cota da IA.
  const livres = (Deno.env.get("IA_SEM_LIMITE_GERAL") ?? "")
    .split(",").map((e) => e.trim().toLowerCase()).filter(Boolean);
  if (!livres.includes((usuario.email ?? "").toLowerCase())) {
    const { data, error } = await servico.from("uso_ia").select(COLUNA[tipo]).eq("dia", dia);
    if (error) {
      console.error("Limite geral", error);
      return indisponivel();
    }
    const total = (data ?? []).reduce((s, l) => s + (l[COLUNA[tipo]] ?? 0), 0);
    if (total >= limiteGeral) {
      return json({ erro: "A IA chegou ao limite do dia para todos. Amanhã libera de novo." }, 429);
    }
  }

  const { data, error } = await servico.rpc("consumir_uso_ia", {
    conta: usuario.id,
    dia_uso: dia,
    tipo_uso: tipo,
    limite,
  });
  if (error) {
    console.error("Limite da conta", error);
    return indisponivel();
  }
  return data === null ? json({ erro: AVISO_CONTA[tipo](limite) }, 429) : null;
}
