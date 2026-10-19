// Peças usadas pelos dois formatos do assistente (novo e legado).

export const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

export function json(corpo: unknown, status = 200) {
  return new Response(JSON.stringify(corpo), {
    status,
    headers: { ...cors, "Content-Type": "application/json" },
  });
}

/// Erro que já vem com a mensagem para a pessoa (e o status HTTP a devolver).
export class ErroParaPessoa extends Error {
  constructor(mensagem: string, readonly status: number) {
    super(mensagem);
  }
}
