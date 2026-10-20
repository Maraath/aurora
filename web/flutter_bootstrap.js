{{flutter_js}}
{{flutter_build_config}}

// Bootstrap do Aurora na web (o `flutter build web` preenche as duas linhas acima).
// - O Flutter desenha dentro de #app (que respeita o safe-area do iPhone).
// - A tela #abertura some no primeiro quadro; se demorar, avisa sobre a internet.
// - O Service Worker é o nosso (sw.js), não o do Flutter: guarda tudo para abrir offline.

(function () {
  const abertura = document.getElementById('abertura');
  const aviso = document.getElementById('abertura-aviso');

  const avisoLento = setTimeout(() => {
    aviso.textContent = navigator.onLine
      ? 'A internet está lenta. Continuando a abrir...'
      : 'Sem internet. Abrindo com o que está guardado no aparelho...';
  }, 6000);

  window.addEventListener('flutter-first-frame', () => {
    clearTimeout(avisoLento);
    abertura.classList.add('saindo');
    setTimeout(() => abertura.remove(), 400);
  }, { once: true });

  // Service Worker: só em HTTPS (ou localhost). Nova versão entra sozinha na próxima abertura.
  if ('serviceWorker' in navigator && (location.protocol === 'https:' || location.hostname === 'localhost')) {
    navigator.serviceWorker.register('sw.js').catch((e) => console.warn('[sw] registro falhou', e));
  }

  _flutter.loader.load({
    onEntrypointLoaded: async (engineInitializer) => {
      const appRunner = await engineInitializer.initializeEngine({
        hostElement: document.getElementById('app'),
      });
      await appRunner.runApp();
    },
  }).catch((e) => {
    clearTimeout(avisoLento);
    aviso.textContent = 'Não deu para abrir o Aurora. Confira a internet e abra de novo.';
    console.error(e);
  });
})();
