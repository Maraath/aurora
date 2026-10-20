// Peças usadas pelos dois formatos do assistente (novo e legado).

export const cors = {
  "Access-Control-Allow-Origin": "*",
  // x-ia-reserva e accept: mandados pelo app na web (PWA); sem eles o navegador barra o pedido.
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type, accept, x-ia-reserva",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

export function json(corpo: unknown, status = 200) {
  return new Response(JSON.stringify(corpo), {
    status,
    headers: { ...cors, "Content-Type": "application/json" },
  });
}

/// Erro que já vem com a mensagem para a pessoa (e o status HTTP a devolver).
export class ErroParaPessoa extends Error {
  readonly status: number;
  constructor(mensagem: string, status: number) {
    super(mensagem);
    this.status = status;
  }
}
