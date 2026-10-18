// Aurora · excluir a conta de quem está logado.
//
// Apaga as fotos do Shape (balde privado "shape", pasta <user_id>/) e depois o
// usuário do Auth. As linhas de todas as tabelas somem junto, porque cada
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

  // Fotos: lista a pasta da pessoa em blocos e apaga até esvaziar.
  for (;;) {
    const { data: arquivos, error } = await servico.storage.from("shape").list(user.id, { limit: 100 });
    if (error) return json({ erro: "Não deu para apagar as fotos. Tente de novo." }, 500);
    if (!arquivos || arquivos.length === 0) break;
    const { error: erroApagar } = await servico.storage
      .from("shape").remove(arquivos.map((a) => `${user.id}/${a.name}`));
    if (erroApagar) return json({ erro: "Não deu para apagar as fotos. Tente de novo." }, 500);
  }

  const { error } = await servico.auth.admin.deleteUser(user.id);
  if (error) {
    console.error("excluir-conta", user.id, error.message);
    return json({ erro: "Não deu para excluir a conta agora. Tente de novo." }, 500);
  }
  return json({ ok: true });
});
