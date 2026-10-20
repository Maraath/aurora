// Service Worker do Aurora (web/PWA).
//
// `tool/release/web.ps1` preenche VERSAO e ARQUIVOS depois do `flutter build web` (lista de tudo que
// saiu em build/web). Sem isso (flutter run), só guarda o que for sendo pedido.
//
// - install: baixa e guarda todos os arquivos da versão (o app abre offline desde a 1ª vez).
// - activate: apaga os caches de versões antigas e assume as abas abertas.
// - fetch: página e arquivos do app vêm do cache desta versão (abre na hora, mesmo com internet ruim).
//   Supabase e IA nunca passam por aqui (outra origem).
//   Fontes de reserva do Flutter (emoji etc., em gstatic) ficam guardadas depois da 1ª vez.

const VERSAO = 'dev';
const ARQUIVOS = /*ARQUIVOS*/[]/*FIM*/;

const CACHE_APP = `aurora-app-${VERSAO}`;
const CACHE_EXTRA = 'aurora-extra';
const ORIGENS_EXTRA = ['https://fonts.gstatic.com', 'https://www.gstatic.com'];

self.addEventListener('install', (evento) => {
  evento.waitUntil((async () => {
    const cache = await caches.open(CACHE_APP);
    // cache: 'reload' pula o cache HTTP do navegador (main.dart.js não muda de nome entre versões).
    await Promise.all(ARQUIVOS.map(async (caminho) => {
      const resposta = await fetch(new Request(caminho, { cache: 'reload' }));
      if (!resposta.ok) throw new Error(`[sw] ${caminho}: ${resposta.status}`);
      await cache.put(caminho, resposta);
    }));
    // A versão nova vale já na próxima abertura (no iPhone o app é fechado com frequência).
    await self.skipWaiting();
  })());
});

// Apaga os caches de outras versões. Roda ao assumir e de novo a cada abertura do app: a aba
// aberta com a versão anterior ainda guardava arquivos no cache velho e o recriava.
async function limparAntigos() {
  const nomes = await caches.keys();
  await Promise.all(nomes
    .filter((n) => n.startsWith('aurora-app-') && n !== CACHE_APP)
    .map((n) => caches.delete(n)));
}

self.addEventListener('activate', (evento) => {
  evento.waitUntil((async () => {
    await limparAntigos();
    await self.clients.claim();
  })());
});

self.addEventListener('fetch', (evento) => {
  const pedido = evento.request;
  if (pedido.method !== 'GET') return;
  if (pedido.mode === 'navigate') evento.waitUntil(limparAntigos());
  const url = new URL(pedido.url);

  if (url.origin === self.location.origin) {
    evento.respondWith(pedido.mode === 'navigate' ? pagina(pedido) : doApp(pedido));
  } else if (ORIGENS_EXTRA.includes(url.origin)) {
    evento.respondWith(guardarDepois(pedido, CACHE_EXTRA));
  }
});

// Avisos por Web Push (Edge Function avisos-push): {titulo, corpo, id}. O iOS exige mostrar uma
// notificação a cada push recebido, então sempre mostra (mesmo se o JSON vier estranho).
self.addEventListener('push', (evento) => {
  let dados = {};
  try {
    dados = evento.data ? evento.data.json() : {};
  } catch (_) {
    dados = { corpo: evento.data ? evento.data.text() : '' };
  }
  evento.waitUntil(self.registration.showNotification(dados.titulo || 'Aurora', {
    body: dados.corpo || '',
    icon: 'icons/Icon-192.png',
    badge: 'icons/Icon-192.png',
    tag: dados.id ? `aviso-${dados.id}` : undefined,
    data: { url: './' },
  }));
});

// Tocar no aviso abre o Aurora (ou traz para a frente se já estiver aberto).
self.addEventListener('notificationclick', (evento) => {
  evento.notification.close();
  evento.waitUntil((async () => {
    const abertos = await self.clients.matchAll({ type: 'window', includeUncontrolled: true });
    for (const cliente of abertos) {
      if ('focus' in cliente) return cliente.focus();
    }
    return self.clients.openWindow('./');
  })());
});

// Página: a guardada desta versão (abre na hora e nunca mistura index.html novo com JS velho).
// A versão nova chega pelo próprio navegador, que confere o sw.js a cada abertura: o SW novo
// baixa tudo, assume, e a próxima abertura já é a nova. Sem nada guardado, tenta a rede.
async function pagina(pedido) {
  const cache = await caches.open(CACHE_APP);
  const guardada = (await cache.match('./')) || (await cache.match('index.html'));
  if (guardada) return guardada;
  try {
    return await comPrazo(fetch(pedido), 10000);
  } catch (_) {
    return Response.error();
  }
}

// Arquivos do app: cache primeiro; o que não estava na lista é guardado ao chegar.
async function doApp(pedido) {
  const cache = await caches.open(CACHE_APP);
  const guardada = await cache.match(pedido, { ignoreSearch: true });
  if (guardada) return guardada;
  const resposta = await fetch(pedido);
  if (resposta.ok && resposta.type === 'basic') cache.put(pedido, resposta.clone());
  return resposta;
}

async function guardarDepois(pedido, nomeCache) {
  const cache = await caches.open(nomeCache);
  const guardada = await cache.match(pedido);
  if (guardada) return guardada;
  const resposta = await fetch(pedido);
  if (resposta.ok || resposta.type === 'opaque') cache.put(pedido, resposta.clone());
  return resposta;
}

function comPrazo(promessa, ms) {
  return Promise.race([
    promessa,
    new Promise((_, rejeitar) => setTimeout(() => rejeitar(new Error('prazo')), ms)),
  ]);
}
