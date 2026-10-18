# Licenças do conteúdo de terceiros

Conferido em 18/10/2026, antes de abrir o Aurora ao público.

## TACO (catálogo de alimentos)

- Fonte: Tabela Brasileira de Composição de Alimentos (TACO), 4ª edição revisada e ampliada, NEPA/Unicamp, 2011.
  Arquivo em `docs/taco/Taco-4a-Edicao.xlsx`, convertido para `assets/taco.json` por `tool/taco/converter.dart`.
- Termos da publicação: a reprodução total ou parcial é permitida **desde que a fonte seja citada**.
- O app cita a fonte na tela de Alimentação (`fonteTaco`, em `lib/data/catalogo_taco.dart`), nos Termos de uso e em
  Conta › Licenças. Os nomes foram adaptados e alguns itens foram filtrados (crus que não se comem), e os valores
  continuam os da tabela.
- **Em aberto:** o texto não fala de uso comercial, nem para permitir nem para proibir. Para o app gratuito, citar a
  fonte basta. Antes de cobrar pelo app, pedir confirmação por escrito ao NEPA/Unicamp (o contato da edição era
  taco@unicamp.br).

## Animações de exercícios (470 GIFs)

- Origem: arquivos do dono, na pasta `Exercicios/` (fora do Git), convertidos para WebP e servidos pelo balde
  público `exercicios`.
- Não há créditos, autor nem licença nos arquivos. O estilo (figuras 3D em cinza com os músculos em vermelho, fundo
  branco) é o dos pacotes comerciais de ilustrações de exercícios vendidos com licença de uso.
- **Bloqueio para o público:** só distribuir com a licença comprovada (nota fiscal ou termos do pacote que permitam
  uso em app). Sem ela, o caminho é tirar as animações do app público (manter só os nomes e grupos) ou trocar por
  um acervo com licença aberta ou comprada.

## Código aberto

Os pacotes Flutter/Dart usados têm licenças próprias (MIT, BSD, Apache). O app lista todas em Conta › Licenças
(`showLicensePage`). As fontes Sora e Manrope usam a SIL Open Font License e entram nessa lista.
