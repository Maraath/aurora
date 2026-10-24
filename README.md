# Aurora

App pessoal de rotina com assistente de IA: tarefas, hábitos, treino, alimentação, finanças, metas, projetos e
lembretes num lugar só. Um código Flutter para **Windows, Android, iOS e web (PWA)**, que funciona **100% offline**
e sincroniza com a nuvem quando há internet.

> **In English:** Aurora is a personal routine app (tasks, habits, workouts, nutrition, finances, goals, reminders)
> with an AI assistant that can create and edit your data through tool calls. One Flutter codebase for Windows,
> Android, iOS and web; offline-first with SQLite (Drift), synced to Supabase (Postgres + Row Level Security).
> Source-available under PolyForm Noncommercial 1.0.0.

Versão atual: **1.10.2** · ~54 mil linhas de Dart · 260 testes automatizados

## O que o app faz

- **Visão**: o dia em 5 blocos (em foco, linha do dia, semana, painel das áreas e insights).
- **Tarefas, hábitos e lembretes** com recorrência por regra (nunca uma linha por dia), calendário, avisos locais e
  despertador de tela cheia no Android.
- **Finanças** em centavos: lançamentos, contas fixas e parceladas, e um painel com 8 gráficos personalizáveis
  (Sankey do fluxo do dinheiro, mapa de calor, trajetória com projeção, categorias no tempo...).
- **Saúde**: ficha de treino com 470 exercícios animados, medidas, fotos de evolução e dieta com a tabela TACO.
- **Metas e projetos**, com análises de produtividade por área.
- **Assistente com IA** em texto e voz: entende pedidos como "gastei 35 no mercado" ou "me lembra de pagar a luz
  amanhã às 9" e cria, edita ou exclui os dados pelo app, com "Desfazer" e confirmação antes de apagar.
  Sem internet, comandos rápidos por regras continuam funcionando.
- **Busca global** (Ctrl+K), atalhos flutuantes, bloqueio por PIN ou biometria, tema escuro "céu estrelado" e claro.

## Arquitetura

```
┌───────────────────────── App Flutter ─────────────────────────┐
│ UI (lib/ui)  →  repositórios (lib/data)  →  SQLite local (Drift) │
│                         │                                       │
│      sincronização incremental  ·  ferramentas da IA no aparelho │
└──────────────┬──────────────────────────────┬───────────────────┘
               │                              │ stream SSE
     Supabase Postgres + RLS          Edge Function "assistente"
     (dados por usuário)              (Vercel AI SDK, cadeia de modelos)
```

- **Offline-first**: o banco local é a fonte da verdade; a sincronização envia e recebe mudanças por
  `servidor_em`, com chave `(user_id, id)` e Row Level Security em todas as tabelas.
- **IA sem chave no app**: o app conversa com uma Edge Function (Deno + Vercel AI SDK) que escolhe o modelo numa
  cadeia (Claude e vários Gemini). Se um modelo esgota a cota, falha ou demora, o próximo assume sem o app perceber.
  As ferramentas (criar lançamento, editar tarefa, consultar dados...) **rodam no aparelho**, sobre o banco local.
- **Protocolo de UI da AI SDK** implementado em Dart (o papel do `useChat` é do `AssistenteRepo`): resposta em
  stream, várias voltas de ferramentas, retomada automática e limite diário por conta.
- **Fotos privadas**: compressão em WebP sem metadados, balde privado com URL assinada e opção "só neste aparelho".
- **Integração nativa**: barra de título própria no Windows (C++ no runner, snap layouts do Windows 11), voz SAPI,
  Web Push no PWA do iPhone, alarmes exatos no Android.
- **Distribuição**: instalador Inno Setup e APK por arquitetura com atualização automática dentro do app; PWA no
  Cloudflare Pages com Service Worker próprio.

## Tecnologias

Flutter · Dart · Drift (SQLite) · Supabase (Auth, Postgres, Storage, Edge Functions) · TypeScript/Deno ·
Vercel AI SDK · Claude e Gemini · C++ (runner do Windows) · PowerShell (scripts de build e publicação)

## Metodologia de desenvolvimento

O Aurora é um projeto meu, do início ao fim. Ele foi construído com práticas de **AI-Assisted Development**, usando
o [Claude Code](https://claude.com/claude-code) (Anthropic) como ferramenta de *pair programming* para acelerar a
escrita do código. A arquitetura, as decisões de design, as regras de negócio, a validação de cada funcionalidade e
os testes foram definidos e conferidos por mim. Por isso os commits trazem o Claude como coautor
(`Co-Authored-By`): ele foi a ferramenta, e a autoria e as decisões do projeto são minhas.

> **Development methodology:** built with AI-assisted development, using Claude Code as a pair-programming tool to
> speed up coding. Architecture, design decisions, business rules, validation and tests were defined by me.

## Estrutura

| Pasta | Conteúdo |
| --- | --- |
| `lib/ui` | telas e componentes (vidro, céu estrelado, menu dock, gráficos) |
| `lib/data` | banco, repositórios, sincronização, análises e o cliente da IA (`lib/data/ia`) |
| `lib/core` | tema, notificações, bloqueio, atualização, efeitos |
| `supabase/functions` | Edge Functions: `assistente`, `avisos-push`, `excluir-conta` |
| `supabase/migrations` | esquema do servidor, RLS e permissões |
| `test` | testes de widgets e de regras |
| `tool` | scripts de ícone, publicação, backup e conversão de dados |
| `docs` | especificação e protótipo de referência |

## Rodar

```bash
flutter pub get
dart run build_runner build
flutter run -d windows
```

O app abre vazio e funciona offline. A conta, a sincronização e o assistente usam o projeto Supabase do autor.

## Licença

Copyright © 2026 Maraath. Código disponível sob a [PolyForm Noncommercial 1.0.0](LICENSE): pode ler, estudar,
modificar e usar para fins **não comerciais**. Uso comercial só com autorização do autor.
Contribuições: ver [CONTRIBUTING.md](CONTRIBUTING.md).

Conteúdo de terceiros: fontes Sora e Manrope (SIL Open Font License); dados de alimentos da Tabela Brasileira de
Composição de Alimentos (TACO), 4ª edição, NEPA/Unicamp, 2011. As animações dos exercícios não fazem parte deste
repositório. Detalhes em [docs/licencas.md](docs/licencas.md).
