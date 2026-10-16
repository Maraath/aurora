# Especificação do meu app de rotina

Oct 15, 2026 · @Maraath

## Visão geral

Um app pessoal que junta tarefas, dinheiro, hábitos, treino e metas numa tela só, com um assistente de IA que entende pedidos em linguagem natural. Roda no Windows, no iPhone (iOS) e no Android, com os mesmos dados nos três.

Princípios:

- **Funciona offline.** Os dados ficam no aparelho e sincronizam quando há internet.
- **Uma tela de resumo manda no dia.** Ao abrir, você vê o que fazer agora, o que está atrasado e como estão dinheiro e metas.
- **Tudo se cria de dois jeitos.** Por formulário ou pedindo ao assistente ("lembra de pagar a faculdade todo dia 11").
- **Uso pessoal.** Uma conta, sem planos pagos nem multiusuário na primeira versão.

## Identidade

O app se chama **Aurora**. Visual aprovado no [protótipo](https://claude.ai/artifact/CiB2znP5dtB7juauMQ6zca): azul-marinho com fundo escuro como padrão e modo claro opcional. Logo definitiva fica para depois.

| Cor | Modo escuro | Modo claro |
| --- | --- | --- |
| Fundo | #060B18 | #F2F5FB |
| Cartões | #0D1730 | #FFFFFF |
| Texto | #E9EFFC | #0A1530 |
| Destaque (azul) | #6B9AF2 | #1E56C8 |
| Botões | #2F63D6 | #1E56C8 |
| Concluído (verde-água) | #4FD6C3 | #0B7A6B |
| Atrasado | #F27E8C | #B92F44 |

Fontes: Sora nos títulos, Manrope no texto.

Pedido já registrado: biblioteca de exercícios a partir de um arquivo seu de GIFs, com busca, reprodução do movimento e montagem de fichas. Os GIFs serão convertidos para vídeo curto ou WebP para o app não ficar pesado.

## Módulos e funções

Dez módulos, acessados por uma barra inferior (celular) ou lateral (desktop). A coluna "Prioridade" diz o que entra na primeira versão.

| Módulo | O que faz | Telas e funções | Prioridade |
| --- | --- | --- | --- |
| Visão (início) | Resumo do dia | Saudação; visão Dia, Semana e Mês; "em foco agora" com botão de começar foco (timer) e trocar de item; lista de hoje por horário; panorama com tarefas, hábitos, saldo do mês, contas vencidas, patrimônio, progresso das metas e projetos; busca e botão criar | V1 |
| Tarefas | Afazeres com prazo | Abas Hoje, Tarefas, Recorrentes e Análise; contadores de atrasadas, pendentes e feitas hoje; lista "resolver agora"; prioridade alta, média ou baixa; vínculo a uma meta; índice de saúde das tarefas; gráfico de concluídas em 7 dias; calendário mensal com filtro | V1 |
| Finanças | Controle de dinheiro do mês | Abas Resumo, Variáveis, Recorrentes, Parceladas, Contas e Análise; entra x sai do mês; contas atrasadas com botão pagar; contas e cartões com saldo; categorias ("para onde foi"); extrato por dia; parcelas do mês; gráfico recebido x gasto por mês | V1 |
| Hábitos | Rotina diária | Abas Resumo, Calendário, Hábitos, Saúde e Análise; feitos hoje; semana com progresso por dia; hábitos com horário ou duração | V1 |
| Saúde (dentro de Hábitos) | Treino, dieta e corpo | Ficha de treino que diz o que treinar a cada dia, com carga sugerida pelo histórico; plano alimentar com alvo para dia de treino e de descanso; medidas do corpo (peso, braço) com gráfico de evolução | V1 (treino e medidas), V2 (dieta) |
| Metas | Objetivos com prazo | Progresso em %, ritmo necessário por semana, data-alvo, aviso de meta parada | V1 |
| Projetos | Metas vistas no tempo | Linha do tempo por mês com cada projeto, status (em risco, em dia), itens feitos sobre o total e dias restantes | V2 |
| Lembretes | Avisos com hora | "A seguir", hoje, atrasados, esta semana; visão Lista, Semana e Mês; lembretes recorrentes (vitamina, academia, fatura); notificações no aparelho | V1 |
| Assistente | Chat com IA | Pedidos em texto ou voz; ler resposta em voz alta; anexar e citar itens com @; briefing diário; retomar a conversa anterior | V2 |
| Automações | Rotinas agendadas do assistente | Modelos prontos (revisão semanal do dinheiro, atrasadas de manhã, metas e dinheiro no domingo, hábitos da semana) e montar do zero; liga e desliga geral | V3 |

## Modelo de dados

Nove entidades guardam tudo; meta é o ponto que liga tarefas, hábitos e projetos. Todo registro leva também `id`, `criado_em`, `atualizado_em` e `apagado_em` (para sincronizar sem perder nada).

| Entidade | Campos principais | Liga com |
| --- | --- | --- |
| Tarefa | título, notas, prazo (data e hora), prioridade (alta, média, baixa), status, feita\_em, regra de repetição | Meta |
| Hábito | nome, tipo (marcar, duração, quantidade), dias da semana, horário opcional, alvo | Meta; registros diários |
| Registro de hábito | data, feito, valor (minutos ou quantidade) | Hábito |
| Transação | descrição, valor, tipo (entrada, saída), data, vencimento, pago\_em, categoria, recorrência, parcela (n de total) | Conta |
| Conta ou cartão | nome, tipo (corrente, poupança, cartão), saldo inicial, dia de fechamento e vencimento | Transações |
| Meta | nome, valor inicial, valor alvo, unidade, data-alvo, status | Tarefas, hábitos, projeto |
| Treino | ficha (dias e exercícios), séries, repetições, carga por série, data | Histórico de cargas |
| Medida do corpo | data, peso, braço, cintura e outras medidas livres | — |
| Lembrete | texto, data e hora, regra de repetição, notificar antes | Qualquer item |

A regra de repetição segue o padrão de calendário (todo dia, dias da semana, todo mês no dia X). Assim o app gera as ocorrências em vez de guardar uma tarefa por dia, o que evita uma pilha de tarefas atrasadas repetidas.

## Tecnologia

Proposta: **Flutter**, um código só gerando os três instaladores. Entre as opções que atendem Windows, iOS e Android ao mesmo tempo, é a mais madura no Android, onde a alternativa Tauri ainda é recente.

| Parte | Escolha | Por quê |
| --- | --- | --- |
| Interface | Flutter (Dart) | Mesmo visual nas três plataformas; animações e gráficos fluidos |
| Banco local | SQLite com Drift | Funciona offline; consultas rápidas para os resumos |
| Sincronização | Supabase (gratuito para uso pessoal) ou PocketBase no seu PC | Mesmos dados no celular e no computador; fica para a V2 |
| Notificações | flutter\_local\_notifications | Lembretes e hábitos no horário, sem servidor |
| Gráficos | fl\_chart | Evolução do corpo, gastos por mês, tarefas concluídas |
| Assistente | API da Anthropic (Claude) com ferramentas que criam e consultam os dados do app | Entende pedidos em português; exige chave de API paga por uso |
| Builds | GitHub Actions | Gera o instalador do Windows, o `.apk` do Android e o app do iPhone (este numa máquina macOS do próprio GitHub) a cada versão |

Eu escrevo e testo o código no meu ambiente. Os instaladores saem do GitHub Actions, porque a rede do meu ambiente é restrita e não dá para contar com o SDK do Android ou gerar `.exe`; para isso você precisa de um repositório no GitHub (grátis).

### Assistente e servidor: pronto para abrir ao público

Decisão de 15/10/2026: uso pessoal primeiro, mas com a estrutura de um app público desde o início, para não refazer nada depois.

- **O app nunca guarda a chave da IA.** Ele fala com uma função no servidor (Supabase Edge Function), e só ela chama a IA. Trocar de fornecedor de IA muda só essa função.
- **Login desde a V1** (Supabase Auth, com e-mail, Google ou Apple). Hoje só você tem conta; depois é só abrir o cadastro.
- **Dados separados por usuário** no banco, com regras que impedem um usuário de ver os dados de outro.
- **Assistente híbrido:** IA na nuvem com internet; comandos rápidos por regras sem internet; pedidos maiores ficam na fila.
- **Limite de uso de IA por usuário**, configurável no servidor, para o custo não fugir do controle.

Para abrir ao público, faltará decidir:

- [ ] Como cobrir o custo da IA (assinatura, plano grátis com limite)
- [ ] Política de privacidade e termos de uso (LGPD: o app guarda dados de saúde e finanças)
- [ ] Contas de desenvolvedor na App Store e na Google Play
- [ ] Plano pago do Supabase quando passar do limite gratuito

## Plano e decisões em aberto

A primeira versão usável sai na etapa 3; cada etapa termina com um instalador que você testa.

1. **Base:** projeto Flutter, banco local, navegação com os módulos e a tela Visão com dados de exemplo.
2. **Tarefas, Hábitos e Lembretes:** criar, repetir, concluir, notificar; contadores e calendário.
3. **Finanças e Metas:** contas, transações, recorrentes e parceladas, categorias, gráficos; metas ligadas a tarefas. Aqui está a V1.
4. **Saúde:** ficha de treino com carga pelo histórico, medidas do corpo e evolução.
5. **V2:** sincronização entre aparelhos, assistente com IA, projetos na linha do tempo, plano alimentar.
6. **V3:** automações agendadas e briefing diário.

Decisões suas:

- [ ] Nome do app e identidade visual (cores, fonte, ícone)
- [ ] Confirmar Flutter, ou preferir outra tecnologia
- [ ] Criar um repositório no GitHub para o código e os instaladores
- [ ] Sincronizar celular e PC já na V1, ou começar só offline
- [ ] Usar o assistente com IA (tem custo de API por uso)
