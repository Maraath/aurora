# Aurora

App pessoal de rotina: tarefas, hábitos, treino, finanças, metas, projetos, lembretes e um assistente com IA.
Flutter (Dart), um código só para Windows, Android e iOS. Funciona 100% offline (SQLite com Drift).

- Especificação: [docs/especificacao.md](docs/especificacao.md)
- Protótipo aprovado (referência visual): [docs/prototipo/Main.dc.html](docs/prototipo/Main.dc.html)
- Instruções do projeto e decisões: [CLAUDE.md](CLAUDE.md)

## Rodar

```bash
flutter pub get
dart run build_runner build
flutter run -d windows
```

## Estado

- [x] Fase 1: base (tema, navegação, banco local, tela Visão com dados de exemplo)
- [x] Fase 2: Tarefas, Hábitos e Lembretes (recorrência por regra, calendário, notificações)
- [ ] Fase 3: Finanças e Metas (V1)
- [ ] Fase 4: Saúde (treino e medidas)
- [ ] Fase 5: V2 (sincronização, assistente com IA, projetos, dieta)
- [ ] Fase 6: V3 (automações e briefing diário)

Fontes Sora e Manrope sob a SIL Open Font License (ver `assets/fonts/`).
