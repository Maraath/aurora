// Aurora · avisos por Web Push (app na web, como o PWA no iPhone).
//
// Chamada a cada minuto pelo pg_cron (migração 20261020200000_avisos_push.sql)
// quando há aviso vencido. Pega os vencidos (pegar_avisos_vencidos, que já os
// marca como enviados) e manda para cada aparelho inscrito da conta. Não exige
// login (deploy com --no-verify-jwt): só envia o que já venceu, então chamar
// antes da hora não adianta nada.
//
// Segredos (gerados por tool/push/gerar_chaves.ps1; o dono cadastra): VAPID_PUBLICO e VAPID_PRIVADO.
// A chave pública também vai no app (lib/core/avisos_push.dart).

import webpush from "npm:web-push@3.6.7";
import { createClient } from "npm:@supabase/supabase-js@2";

function json(corpo: unknown, status = 200) {
  return new Response(JSON.stringify(corpo), { status, headers: { "Content-Type": "application/json" } });
}

type Aviso = { id: number; user_id: string; titulo: string; corpo: string };
type Inscricao = { endpoint: string; user_id: string; p256dh: string; auth: string };

Deno.serve(async () => {
  const publico = Deno.env.get("VAPID_PUBLICO");
  const privado = Deno.env.get("VAPID_PRIVADO");
  if (!publico || !privado) {
    console.error("avisos-push: faltam os segredos VAPID_PUBLICO e VAPID_PRIVADO");
    return json({ erro: "Faltam as chaves dos avisos." }, 500);
  }
  // O serviço de push pede um contato do remetente (e-mail ou site).
  webpush.setVapidDetails(Deno.env.get("VAPID_ASSUNTO") ?? "https://aurora-ar2.pages.dev", publico, privado);

  const servico = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!);
  const { data: avisos, error } = await servico.rpc("pegar_avisos_vencidos");
  if (error) {
    console.error("avisos-push: pegar_avisos_vencidos", error.message);
    return json({ erro: error.message }, 500);
  }
  const lista = (avisos ?? []) as Aviso[];
  if (lista.length === 0) return json({ enviados: 0 });

  const contas = [...new Set(lista.map((a) => a.user_id))];
  const { data: inscricoes, error: erroInscricoes } = await servico
    .from("push_inscricoes")
    .select("endpoint, user_id, p256dh, auth")
    .in("user_id", contas);
  if (erroInscricoes) {
    console.error("avisos-push: push_inscricoes", erroInscricoes.message);
    return json({ erro: erroInscricoes.message }, 500);
  }

  let enviados = 0;
  const vencidas = new Set<string>();
  await Promise.all(
    lista.flatMap((aviso) =>
      ((inscricoes ?? []) as Inscricao[])
        .filter((i) => i.user_id === aviso.user_id)
        .map(async (i) => {
          try {
            await webpush.sendNotification(
              { endpoint: i.endpoint, keys: { p256dh: i.p256dh, auth: i.auth } },
              JSON.stringify({ titulo: aviso.titulo, corpo: aviso.corpo, id: aviso.id }),
              // Até 1 hora para entregar (aparelho sem internet recebe quando voltar).
              { TTL: 3600, urgency: "high" },
            );
            enviados++;
          } catch (e) {
            const status = (e as { statusCode?: number }).statusCode;
            // 404/410: o aparelho cancelou a inscrição (desinstalou, tirou a permissão).
            if (status === 404 || status === 410) vencidas.add(i.endpoint);
            else console.error("avisos-push: envio", status, String(e));
          }
        })
    ),
  );
  if (vencidas.size > 0) {
    await servico.from("push_inscricoes").delete().in("endpoint", [...vencidas]);
  }
  return json({ avisos: lista.length, enviados, removidas: vencidas.size });
});
