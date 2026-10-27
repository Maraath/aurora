// Céu (estrelas), escala do palco e utilidades dos protótipos visuais.
(function () {
  const p = new URLSearchParams(location.search);
  const fone = window.innerWidth < 760;
  const estatico = p.get('estatico') === '1' ||
    window.matchMedia('(prefers-reduced-motion: reduce)').matches;

  // ---------- escala do palco (1600x900) ----------
  const palco = document.getElementById('palco');
  function ajustar() {
    if (fone) { palco.style.transform = ''; palco.style.left = ''; palco.style.top = ''; return; }
    const s = Math.min(window.innerWidth / 1600, window.innerHeight / 900);
    palco.style.transform = 'scale(' + s + ')';
    palco.style.left = Math.max(0, (window.innerWidth - 1600 * s) / 2) + 'px';
    palco.style.top = Math.max(0, (window.innerHeight - 900 * s) / 2) + 'px';
  }

  // ---------- estrelas ----------
  function estrelas() {
    const cv = document.getElementById('ceu');
    if (!cv) return;
    const dpr = Math.min(window.devicePixelRatio || 1, 2);
    const w = cv.clientWidth, h = cv.clientHeight;
    cv.width = Math.round(w * dpr);
    cv.height = Math.round(h * dpr);
    const c = cv.getContext('2d');
    c.setTransform(dpr, 0, 0, dpr, 0, 0);
    c.clearRect(0, 0, w, h);
    let s = 1709;
    const r = () => (s = (s * 16807) % 2147483647) / 2147483647;
    const area = (w * h) / (1600 * 900);
    const camadas = [
      [Math.round(190 * area), .5, .8, .18, .38],
      [Math.round(80 * area), .8, 1.15, .38, .6],
      [Math.round(16 * area), 1.2, 1.7, .6, .9],
    ];
    for (const [n, rmin, rmax, omin, omax] of camadas) {
      for (let i = 0; i < n; i++) {
        const x = r() * w, y = r() * h, raio = rmin + r() * (rmax - rmin);
        const a = omin + r() * (omax - omin);
        c.globalAlpha = a;
        c.fillStyle = i % 11 === 0 ? '#CFFFE9' : '#FFFFFF';
        c.beginPath();
        c.arc(x, y, raio, 0, 7);
        c.fill();
      }
    }
    // poucas estrelas com brilho em cruz
    c.globalAlpha = 1;
    let s2 = 2610;
    const r2 = () => (s2 = (s2 * 16807) % 2147483647) / 2147483647;
    for (let i = 0; i < Math.round(7 * area) + 2; i++) {
      const x = r2() * w, y = r2() * h * .9, t = 2 + r2() * 2.4;
      const g = c.createRadialGradient(x, y, 0, x, y, t * 3.4);
      g.addColorStop(0, 'rgba(207,255,233,.6)');
      g.addColorStop(.35, 'rgba(207,255,233,.12)');
      g.addColorStop(1, 'rgba(207,255,233,0)');
      c.fillStyle = g;
      c.beginPath(); c.arc(x, y, t * 3.4, 0, 7); c.fill();
      c.strokeStyle = 'rgba(232,255,246,.24)';
      c.lineWidth = .6;
      c.beginPath(); c.moveTo(x - t * 1.6, y); c.lineTo(x + t * 1.6, y);
      c.moveTo(x, y - t * 1.6); c.lineTo(x, y + t * 1.6); c.stroke();
    }
  }

  // ---------- aurora em camadas (CSS anima; aqui só monta) ----------
  function aurora() {
    const host = document.querySelector('.aurora');
    if (!host) return;
    const qtd = parseInt(host.dataset.camadas || '3', 10);
    for (let i = 0; i < qtd; i++) host.appendChild(document.createElement('i'));
    if (host.dataset.cortina === '1') {
      const cor = document.createElement('span');
      cor.className = 'cortina';
      host.appendChild(cor);
      const cor2 = document.createElement('span');
      cor2.className = 'cortina c2';
      host.appendChild(cor2);
    }
    if (estatico) host.classList.add('estatico');
  }

  function tudo() {
    ajustar(); estrelas(); aurora();
    if (p.get('debug') === '1') {
      const alvo = document.querySelector('.coluna') || document.body;
      const d = document.createElement('pre');
      d.style.cssText = 'position:fixed;left:0;top:0;z-index:9999;background:#000;color:#0f0;font:12px monospace;padding:6px;margin:0;pointer-events:none';
      d.textContent = [
        'html.class=' + document.documentElement.className,
        'inner=' + window.innerWidth + 'x' + window.innerHeight,
        'body.scrollW=' + document.body.scrollWidth,
        'palco=' + document.getElementById('palco').getBoundingClientRect().width,
        'coluna=' + alvo.getBoundingClientRect().width,
      ].join('\n');
      document.body.appendChild(d);
    }
  }
  window.addEventListener('resize', function () { estrelas(); ajustar(); });
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', tudo);
  else tudo();
})();
