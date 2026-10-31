# Diretrizes de Projeto: Commits Humanizados e Economia de Tokens

Este documento estabelece as regras de operação para o agente Antigravity neste repositório. O objetivo é manter um histórico Git legível, natural e profissional, além de otimizar o consumo de tokens eliminando leituras e varreduras desnecessárias de arquivos.

---

## 1. Nomenclatura e Estilo de Commits

Em vez de mensagens rígidas ou puramente robóticas (como `chore(versao): 1.14.6+51`), adote mensagens naturais, diretas e descritivas em português. O histórico deve ser legível por qualquer ser humano sem parecer um log gerado por script.

### 1.1. Regras Principais
1. **Foco no valor real entregue:** Descreva *o que* foi feito e *por quê*, em linguagem fluida.
2. **Atualização de versão em conjunto:** Se uma nova funcionalidade for adicionada e a versão for incrementada, agrupe ou mencione a versão de forma sutil, em vez de criar múltiplos commits mecânicos e isolados de `chore(versao)`.
3. **Tom conversacional e claro:** Use verbos no presente ou passado direto, evitando excesso de etiquetas e escopos formais quando não agregarem contexto.

### 1.2. Exemplos de Comparação

| Antes (Robótico / Rígido) | Depois (Humanizado / Claro) |
| :--- | :--- |
| `chore(versao): 1.14.6+51` | *(Evitar commits isolados apenas para subir build, ou agrupar com a feature correspondente)* |
| `feat(foco): integrar players do YouTube e Spotify no Windows e restringir sala de foco a PC` | Adiciona players do YouTube e Spotify no desktop e limita sala de foco ao PC |
| `feat(anotacoes): permite segurar e arrastar notas para dentro das pastas` | Permite arrastar e soltar notas diretamente dentro das pastas |
| `feat(foco, objetivos): separa etapas de tarefas e adiciona sala de foco com aviso desktop` | Separa tarefas em etapas e adiciona alertas de desktop na sala de foco |
| `fix(auth): fix token expiration on refresh issue in login screen` | Corrige perda de sessão ao renovar token na tela de login |

---

## 2. Economia de Tokens e Restrição de Contexto

Para evitar o consumo excessivo de contexto e leituras completas do repositório a cada comando ou tarefa:

### 2.1. Regras de Leitura e Inspeção de Arquivos
* **Proibido varrer o projeto inteiro:** Nunca execute listagens profundas recursivas (`ls -R`, `find .`, leituras completas de diretórios raiz) a menos que explicitamente solicitado pelo usuário.
* **Inspeção pontual:** Leia estritamente os arquivos envolvidos na tarefa atual e suas dependências diretas.
* **Uso de buscas direcionadas:** Para localizar trechos de código, use ferramentas de busca textual cirúrgicas (como `grep` ou busca de símbolos) focadas em diretórios específicos (`src/`, `lib/`), evitando carregar arquivos inteiros no prompt.
* **Nunca leia diretórios de build ou dependências:**
  * Pastas ignoradas por padrão: `node_modules/`, `.git/`, `dist/`, `build/`, `.dart_tool/`, `.next/`, `vendor/`, `out/`, etc.

### 2.2. Fluxo para Operações de Git
* **Para preparar commits:**
  * Utilize apenas `git status -s` e `git diff --staged` (ou `git diff <arquivo>`) para analisar as alterações exatas.
  * **Não releia o repositório inteiro** para formular a mensagem de commit; baseie-se unicamente no `git diff` pontual dos arquivos modificados.
* **Commits atômicos:** Modifique e comite apenas o que foi solicitado na sessão atual.

---

## 3. Resumo Operacional para o Agente

1. **Antes de agir:** Analise apenas os arquivos que receberam comando direto de edição.
2. **Durante o diff:** Verifique apenas as linhas alteradas (`git diff`).
3. **Ao gerar o commit:** Escreva uma mensagem fluida, em português, direta ao ponto e sem repetições burocráticas de versão.