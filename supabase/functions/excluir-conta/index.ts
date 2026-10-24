// Aurora · excluir a conta de quem está logado.
//
// Apaga as fotos (balde privado "fotos": <user_id>/fotos e /miniaturas; e o
// antigo "shape") e depois o usuário do Auth. As linhas de todas as tabelas
// somem junto, porque cada
// user_id referencia auth.users com "on delete cascade". O app só chama esta
// função depois de a pessoa confirmar; nada aqui pode ser desfeito.

import { createClient } from "npm:@supabase/supabase-js@2";

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

function json(corpo: unknown, status = 200) {
  return new Response(JSON.stringify(corpo), {
    status,
    headers: { ...cors, "Content-Type": "application/json" },
  });
}

/// Apaga os arquivos de uma pasta em blocos de 100, até esvaziar.
async function esvaziarPasta(servico: ReturnType<typeof createClient>, balde: string, pasta: string) {
  for (;;) {
    const { data, error } = await servico.storage.from(balde).list(pasta, { limit: 100 });
    if (error) throw error;
    const arquivos = (data ?? []).filter((a) => a.id != null); // pastas vêm com id nulo
    if (arquivos.length === 0) return;
    const { error: erroApagar } = await servico.storage.from(balde).remove(arquivos.map((a) => `${pasta}/${a.name}`));
    if (erroApagar) throw erroApagar;
  }
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  if (req.method !== "POST") return json({ erro: "Use POST." }, 405);

  const url = Deno.env.get("SUPABASE_URL")!;
  const comoUsuario = createClient(url, Deno.env.get("SUPABASE_ANON_KEY")!, {
    global: { headers: { Authorization: req.headers.get("Authorization") ?? "" } },
  });
  const { data: { user } } = await comoUsuario.auth.getUser();
  if (!user) return json({ erro: "Entre na sua conta para excluí-la." }, 401);

  const servico = createClient(url, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!);

  // Fotos: tudo dentro de {user_id}/ nos baldes privados ("fotos": fotos/ e
  // miniaturas/; "shape": o formato antigo, sem subpastas).
  try {
    await esvaziarPasta(servico, "fotos", `${user.id}/fotos`);
    await esvaziarPasta(servico, "fotos", `${user.id}/miniaturas`);
    await esvaziarPasta(servico, "shape", user.id);
    // Áudios das anotações (balde privado "audios", app 1.11+).
    await esvaziarPasta(servico, "audios", `${user.id}/audios`);
  } catch (e) {
    console.error("excluir-conta fotos", user.id, String(e));
    return json({ erro: "Não deu para apagar as fotos. Tente de novo." }, 500);
  }

  const { error } = await servico.auth.admin.deleteUser(user.id);
  if (error) {
    console.error("excluir-conta", user.id, error.message);
    return json({ erro: "Não deu para excluir a conta agora. Tente de novo." }, 500);
  }
  return json({ ok: true });
});
