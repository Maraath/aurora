// Ponte entre a página e o Flutter: safe-area, avisos por push e áudios (carregado pelo index.html).

// Safe-area do iPhone em px: [cima, direita, baixo, esquerda]. O Flutter lê a cada montagem
// (girar a tela muda os lados).
// Teste no computador: ?area=47,0,34,0 simula o iPhone 14 (cima, direita, baixo, esquerda).
const areaDeTeste = new URLSearchParams(location.search).get('area');
const medida = document.getElementById('medida-area');
// iPhone na tela de início com a barra de status translúcida: o iOS deixa a página mais curta
// que a tela (falta a altura da barra de status) e NÃO desenha nada na faixa de baixo; só a cor
// de fundo do html aparece lá (esticar o #app só cortava a barra). Então:
//  - o Flutter fica na área visível;
//  - a margem do indicador de início que já cai dentro da faixa não entra de novo (folga);
//  - a faixa ganha a cor da barra de baixo (auroraCorDaBorda), e parece uma barra só.
// O screen do iOS não gira: em pé a altura é o maior lado; deitado, o menor.
const iosNaTelaDeInicio = navigator.standalone === true;
function alturaDaTela() {
  const deitado = window.innerWidth > window.innerHeight;
  return deitado ? Math.min(screen.width, screen.height) : Math.max(screen.width, screen.height);
}
function folgaEmbaixo() {
  return iosNaTelaDeInicio ? Math.max(0, alturaDaTela() - window.innerHeight) : 0;
}
function margensDoSistema() {
  const s = getComputedStyle(medida);
  return [s.paddingTop, s.paddingRight, s.paddingBottom, s.paddingLeft].map((v) => parseFloat(v) || 0);
}
window.auroraAreaSegura = function () {
  if (areaDeTeste) return areaDeTeste.split(',').map((v) => parseFloat(v) || 0);
  const [cima, direita, baixo, esquerda] = margensDoSistema();
  return [cima, direita, Math.max(0, baixo - folgaEmbaixo()), esquerda];
};
window.auroraCorDaBorda = function (cor) {
  document.documentElement.style.background = cor;
  document.body.style.background = cor;
};
// Conta (só na web) mostra estas medidas, para diagnosticar outros aparelhos.
window.auroraMedidasDaTela = function () {
  const [cima, direita, baixo, esquerda] = margensDoSistema();
  return `tela ${screen.width}×${screen.height} · página ${window.innerWidth}×${window.innerHeight}` +
    ` · margens ${cima}/${direita}/${baixo}/${esquerda} · folga ${folgaEmbaixo()}` +
    ` · ${iosNaTelaDeInicio ? 'tela de início' : 'navegador'}`;
};

// Avisos por Web Push (lib/core/avisos_push_web.dart). No iPhone só existem com o app na tela
// de início (iOS 16.4+), e o pedido de permissão tem de sair de um toque: ativar() chama
// requestPermission antes de qualquer outra espera.
function chaveEmBytes(base64url) {
  const b64 = (base64url + '='.repeat((4 - base64url.length % 4) % 4)).replace(/-/g, '+').replace(/_/g, '/');
  return Uint8Array.from(atob(b64), (c) => c.charCodeAt(0));
}
async function inscricaoAtual() {
  const registro = await navigator.serviceWorker.getRegistration();
  return registro ? registro.pushManager.getSubscription() : null;
}
window.auroraAvisos = {
  estado: async function () {
    const suporta = 'serviceWorker' in navigator && 'PushManager' in window && 'Notification' in window;
    if (!suporta) return /iPhone|iPad|iPod/.test(navigator.userAgent) && !iosNaTelaDeInicio ? 'instalar' : 'sem-suporte';
    if (Notification.permission === 'denied') return 'negado';
    return (await inscricaoAtual()) ? 'ativo' : 'desligado';
  },
  ativar: async function (chave) {
    const permissao = await Notification.requestPermission();
    if (permissao !== 'granted') return null;
    const registro = await navigator.serviceWorker.getRegistration();
    if (!registro) throw new Error('Sem Service Worker (abra pelo endereço publicado).');
    const inscricao = (await registro.pushManager.getSubscription()) ||
      (await registro.pushManager.subscribe({ userVisibleOnly: true, applicationServerKey: chaveEmBytes(chave) }));
    return JSON.stringify(inscricao.toJSON());
  },
  inscricao: async function () {
    const inscricao = await inscricaoAtual();
    return inscricao ? JSON.stringify(inscricao.toJSON()) : null;
  },
  desativar: async function () {
    const inscricao = await inscricaoAtual();
    if (!inscricao) return null;
    const json = JSON.stringify(inscricao.toJSON());
    await inscricao.unsubscribe();
    return json;
  },
  aparelho: function () {
    const ua = navigator.userAgent;
    return /iPhone/.test(ua) ? 'iPhone' : /iPad/.test(ua) ? 'iPad' : /Android/.test(ua) ? 'Android'
      : /Windows/.test(ua) ? 'Windows' : /Mac/.test(ua) ? 'Mac' : 'Navegador';
  },
};

// Áudios das notas guardados no navegador (lib/data/fotos/disco_audios_web.dart): IndexedDB,
// um registro por arquivo ("<id>.<ext>" → bytes). Some junto com os dados do site.
let bancoAudios = null;
function abrirAudios() {
  bancoAudios = bancoAudios || new Promise((ok, erro) => {
    const pedido = indexedDB.open('aurora-audios', 1);
    pedido.onupgradeneeded = () => pedido.result.createObjectStore('audios');
    pedido.onsuccess = () => ok(pedido.result);
    pedido.onerror = () => { bancoAudios = null; erro(pedido.error); };
  });
  return bancoAudios;
}
async function noBancoAudios(modo, fazer) {
  const banco = await abrirAudios();
  return new Promise((ok, erro) => {
    const transacao = banco.transaction('audios', modo);
    const pedido = fazer(transacao.objectStore('audios'));
    transacao.oncomplete = () => ok(pedido.result);
    transacao.onerror = () => erro(transacao.error);
    transacao.onabort = () => erro(transacao.error);
  });
}
window.auroraAudios = {
  // slice(): guarda só estes bytes, não o buffer inteiro por trás da vista.
  gravar: (nome, bytes) => noBancoAudios('readwrite', (s) => s.put(bytes.slice(), nome)).then(() => null),
  ler: (nome) => noBancoAudios('readonly', (s) => s.get(nome)).then((v) => v ? new Uint8Array(v) : null),
  apagar: (nome) => noBancoAudios('readwrite', (s) => s.delete(nome)).then(() => null),
  existe: (nome) => noBancoAudios('readonly', (s) => s.count(nome)).then((n) => n > 0),
  // Só os nomes (JSON), sem ler os áudios.
  nomes: () => noBancoAudios('readonly', (s) => s.getAllKeys()).then((k) => JSON.stringify(k)),
};

function ajustarTela() {
  // Avisa o Flutter (lib/core/area_segura_web.dart) para ler o safe-area de novo.
  if (window.auroraAreaMudou) window.auroraAreaMudou();
}
ajustarTela();
new ResizeObserver(ajustarTela).observe(medida);
window.addEventListener('resize', ajustarTela);
window.addEventListener('orientationchange', () => setTimeout(ajustarTela, 300));
document.addEventListener('visibilitychange', ajustarTela);
