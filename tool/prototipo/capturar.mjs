// Captura as telas dos protótipos visuais em PNG usando o protocolo de
// depuração do Chrome (CDP). O headless do Chrome não respeita largura de
// janela abaixo de 500 px; por CDP dá para emular 390x844 como um celular.
//
// Uso:
//   1. abra o Chrome em segundo plano:
//      chrome.exe --headless=new --disable-gpu --no-sandbox --hide-scrollbars
//        --disable-breakpad --disable-crash-reporter --remote-debugging-port=9333
//        --user-data-dir=<pasta>
//   2. node tool/prototipo/capturar.mjs <lista.json>
//
// A lista é um JSON: [{ "url": "...", "largura": 1600, "altura": 900,
//   "escala": 1.5, "celular": false, "saida": "caminho/arquivo.png" }, ...]

import { writeFileSync } from 'node:fs';
import { setTimeout as dormir } from 'node:timers/promises';

const PORTA = Number(process.env.AURORA_CDP_PORTA || 9333);
const lista = JSON.parse((await import('node:fs')).readFileSync(process.argv[2], 'utf8'));

async function alvo() {
  for (let i = 0; i < 60; i++) {
    try {
      const r = await fetch(`http://127.0.0.1:${PORTA}/json/version`);
      if (r.ok) return true;
    } catch {}
    await dormir(250);
  }
  throw new Error('Chrome não respondeu na porta ' + PORTA);
}

class Sessao {
  constructor(ws) {
    this.ws = ws;
    this.id = 0;
    this.pendentes = new Map();
    this.eventos = new Map();
    ws.addEventListener('message', (e) => {
      const m = JSON.parse(e.data);
      if (m.id && this.pendentes.has(m.id)) {
        const { ok, falha } = this.pendentes.get(m.id);
        this.pendentes.delete(m.id);
        m.error ? falha(new Error(JSON.stringify(m.error))) : ok(m.result);
      } else if (m.method) {
        const fila = this.eventos.get(m.method);
        if (fila) { this.eventos.delete(m.method); fila.forEach((f) => f(m.params)); }
      }
    });
  }
  enviar(method, params = {}) {
    const id = ++this.id;
    return new Promise((ok, falha) => {
      this.pendentes.set(id, { ok, falha });
      this.ws.send(JSON.stringify({ id, method, params }));
    });
  }
  esperar(method, ms = 15000) {
    return new Promise((ok) => {
      const fila = this.eventos.get(method) || [];
      fila.push(ok);
      this.eventos.set(method, fila);
      setTimeout(() => ok(null), ms);
    });
  }
}

async function abrir() {
  const r = await fetch(`http://127.0.0.1:${PORTA}/json/new?about:blank`, { method: 'PUT' });
  const t = await r.json();
  const ws = new WebSocket(t.webSocketDebuggerUrl);
  await new Promise((ok, falha) => {
    ws.addEventListener('open', ok, { once: true });
    ws.addEventListener('error', falha, { once: true });
  });
  return { t, s: new Sessao(ws), ws };
}

await alvo();
for (const item of lista) {
  const { t, s, ws } = await abrir();
  await s.enviar('Page.enable');
  await s.enviar('Emulation.setDeviceMetricsOverride', {
    width: item.largura,
    height: item.altura,
    deviceScaleFactor: item.escala || 1,
    mobile: !!item.celular,
    screenWidth: item.largura,
    screenHeight: item.altura,
  });
  const carregou = s.esperar('Page.loadEventFired');
  await s.enviar('Page.navigate', { url: item.url });
  await carregou;
  // espera as fontes (Google Fonts) e o primeiro quadro do céu
  try {
    await s.enviar('Runtime.evaluate', {
      expression: 'document.fonts.ready.then(()=>true)',
      awaitPromise: true,
      timeout: 12000,
    });
  } catch {}
  await dormir(900);
  const { data } = await s.enviar('Page.captureScreenshot', {
    format: 'png',
    fromSurface: true,
    captureBeyondViewport: false,
  });
  writeFileSync(item.saida, Buffer.from(data, 'base64'));
  console.log('ok ' + item.saida);
  ws.close();
  await fetch(`http://127.0.0.1:${PORTA}/json/close/${t.id}`);
}
