// Aurora · cérebro do assistente: persona, ferramentas, escolha do modelo e
// janela de memória. Tudo com a Vercel AI SDK (streamText).
//
// As ferramentas NÃO têm `execute`: quem executa é o APP, no banco local do
// aparelho (os dados moram lá e o app funciona offline). O modelo pede a
// ferramenta, o stream entrega o pedido ao app, o app executa e manda de volta
// o resultado numa nova chamada; o modelo então continua a resposta. É o mesmo
// ciclo que o useChat faz no navegador com ferramentas do lado do cliente.

import { createAnthropic } from "@ai-sdk/anthropic";
import { createGoogleGenerativeAI } from "@ai-sdk/google";
import { type JSONValue, type LanguageModel, type ModelMessage, tool } from "ai";
import { z } from "zod";

// ------------------------------------------------------------------- persona

export const PERSONA = `Você é a Aurora, a assistente pessoal do app Aurora: um app de rotina com
tarefas, hábitos, treino (ficha, medidas, exercícios e fotos de evolução "Shape"), alimentação,
finanças, metas, projetos e lembretes. Você conversa em português do Brasil.

Seu jeito: amigável, próxima e motivadora, sem exagero nem frases feitas. Você entende de verdade
de treino de força, hipertrofia, cardio, recuperação, alimentação e hábitos, e também sabe usar
cada parte do app. Elogie progresso real, dê o próximo passo concreto e seja honesta quando algo
não vai bem. Em saúde, oriente com bom senso e sugira um profissional quando houver dor, lesão,
doença ou remédio no meio.

Como responder:
- Converse naturalmente. Respostas curtas para coisas simples; mais completas quando a pessoa pede
  um plano, uma explicação ou uma análise. Pode usar listas curtas com "•" e **negrito** em poucas
  palavras-chave; nada de títulos (#), tabelas ou outros recursos de markdown.
- Personalize: use o RESUMO DOS DADOS e as ferramentas de consulta. Cite números reais dela.
  Nunca invente dados; se faltar informação, consulte ou pergunte.
- Lembre do que já foi dito nesta conversa e continue de onde parou.

Ferramentas (você age de verdade nos dados do app, não só conversa):
- Sempre que a pessoa pedir para CRIAR, REGISTRAR, MUDAR ou EXCLUIR algo, use a ferramenta certa
  na hora, sem mandar ela fazer manualmente: gasto, receita, tarefa, lembrete, hábito feito, medida,
  refeição, treino ("criar_treino"), metas de dieta ou metas do app ("atualizar_metas"), edições
  ("editar_lancamento", "editar_tarefa", "editar_lembrete", "editar_treino"), exclusões de lançamento,
  tarefa, lembrete ou treino ("excluir_item") e registros do Shape ("excluir_registro_shape"). Nunca
  diga para ela tocar no item e editar ou excluir: você faz. Só diga que fez depois do resultado da
  ferramenta; se ela falhar, explique o motivo que veio no resultado.
- Datas relativas ("amanhã", "segunda", "mês passado") se resolvem pela data de hoje do resumo.
  Treino "para amanhã" = treino com o dia da semana de amanhã.
- Pedido ambíguo que mexe em dados (falta valor, dia ou nome)? Pergunte antes de criar.
- EDIÇÃO e EXCLUSÃO precisam do id do registro: ache com "buscar" (pelo nome) ou "consultar" (área
  "financas", "tarefas", "lembretes", "treino", "shape" ou "medidas"); os ids vêm no resultado, como
  "(id ...)". Nunca invente um id. Se houver mais de um registro possível, pergunte qual antes.
  Na edição, mande só os campos que mudam; a pessoa pode desfazer pela conversa.
- EXCLUSÃO: diga em uma frase o que vai excluir e chame a ferramenta: o app mostra à pessoa um botão
  de confirmação antes de apagar. Se o resultado disser que ela cancelou, não insista.
- Para responder sobre a vida dela além do resumo, use "consultar" ou "buscar".
- Quando ela quiser VER uma parte do app ("mostre minhas fotos do shape", "abre minhas finanças"),
  use "abrir_tela".
- Pode chamar várias ferramentas na mesma resposta quando o pedido tiver várias partes.`;

// --------------------------------------------------------------- ferramentas

const data = z.string().regex(/^\d{4}-\d{2}-\d{2}$/).describe("Data no formato aaaa-mm-dd");
const hora = z.string().regex(/^\d{1,2}:\d{2}$/).describe("Hora no formato HH:mm (24 h)");

export const ferramentas = {
  registrar_lancamento: tool({
    description: "Registra um gasto ou uma receita JÁ acontecidos. Atualiza o saldo em Finanças.",
    inputSchema: z.object({
      tipo: z.enum(["gasto", "receita"]),
      valor: z.number().positive().describe("Valor em reais, ex.: 35.9"),
      descricao: z.string().min(1).describe("O que foi, ex.: Mercado, Uber, Salário"),
      categoria: z.string().optional().describe("Categoria; se omitida, o app deduz pela descrição"),
      data: data.optional().describe("Dia em que aconteceu; padrão hoje"),
    }),
  }),
  criar_tarefa: tool({
    description: "Cria uma tarefa (algo a fazer), com ou sem prazo.",
    inputSchema: z.object({
      titulo: z.string().min(1),
      data: data.optional(),
      hora: hora.optional(),
    }),
  }),
  criar_lembrete: tool({
    description:
      "Cria um lembrete que avisa no dia e hora. Para repetir, preencha 'repeticao' em português, " +
      "ex.: 'todo dia', 'toda segunda e quarta', 'todo dia 10', 'toda semana'.",
    inputSchema: z.object({
      texto: z.string().min(1).describe("Do que lembrar, ex.: ligar pro dentista"),
      data: data.describe("Primeiro dia do aviso"),
      hora: hora,
      repeticao: z.string().optional(),
    }),
  }),
  marcar_habito: tool({
    description: "Marca um hábito como feito hoje. Use o nome de um dos hábitos da pessoa.",
    inputSchema: z.object({ nome: z.string().min(1) }),
  }),
  registrar_medida: tool({
    description: "Registra uma medida corporal de hoje (peso, cintura, braço, gordura etc.).",
    inputSchema: z.object({
      tipo: z.string().min(1).describe("Ex.: Peso, Cintura, Braço, Gordura"),
      valor: z.number().positive(),
      unidade: z.string().describe("Ex.: kg, cm, %"),
    }),
  }),
  registrar_refeicao: tool({
    description:
      "Registra algo que a pessoa comeu hoje. Informe gramas OU porções. Prefira nomes dos " +
      "'Alimentos cadastrados'; o app também procura na tabela TACO.",
    inputSchema: z.object({
      alimento: z.string().min(1),
      gramas: z.number().positive().optional(),
      porcoes: z.number().positive().optional(),
      refeicao: z.enum(["cafe", "almoco", "lanche", "jantar", "ceia"]).optional(),
    }),
  }),
  criar_treino: tool({
    description:
      "Cria um treino novo na ficha, com exercícios, séries, repetições e carga inicial. Para um dia " +
      "específico (ex.: 'para amanhã'), coloque o dia da semana dele em 'dias'. Sem dia dito, pergunte. " +
      "Monte os exercícios com bom senso de treino se a pessoa não listar.",
    inputSchema: z.object({
      nome: z.string().min(1).describe("Ex.: Treino C"),
      foco: z.string().optional().describe("Ex.: Pernas e glúteos"),
      dias: z.array(z.enum(["seg", "ter", "qua", "qui", "sex", "sab", "dom"])).default([]),
      exercicios: z.array(z.object({
        nome: z.string().min(1),
        series: z.number().int().min(1).max(10),
        repeticoes: z.number().int().min(1).max(50),
        carga: z.number().min(0).optional().describe("Carga inicial em kg"),
      })).min(1).max(15),
    }),
  }),
  excluir_registro_shape: tool({
    description:
      "Exclui uma foto do Shape ou uma medida corporal. Use o id que veio de 'consultar' (área 'shape' " +
      "ou 'medidas'). O app pede a confirmação da pessoa antes de apagar.",
    inputSchema: z.object({
      tipo: z.enum(["foto", "medida"]),
      id: z.string().min(1),
    }),
  }),
  editar_lancamento: tool({
    description:
      "Muda um gasto ou receita já registrado (id vindo de 'buscar' ou 'consultar' financas). Só os " +
      "campos informados mudam. Num lançamento que repete (conta fixa, parcelado), valor, descrição e " +
      "categoria valem para todas as ocorrências e a data não muda por aqui.",
    inputSchema: z.object({
      id: z.string().min(1),
      tipo: z.enum(["gasto", "receita"]).optional(),
      valor: z.number().positive().optional().describe("Valor em reais, ex.: 35.9"),
      descricao: z.string().min(1).optional(),
      categoria: z.string().min(1).optional(),
      data: data.optional().describe("Novo dia do lançamento"),
    }),
  }),
  editar_tarefa: tool({
    description:
      "Muda uma tarefa (id vindo de 'buscar' ou 'consultar' tarefas): título, prazo, hora, tirar o prazo " +
      "ou marcar como feita/não feita. Só os campos informados mudam.",
    inputSchema: z.object({
      id: z.string().min(1),
      titulo: z.string().min(1).optional(),
      data: data.optional().describe("Novo dia do prazo"),
      hora: hora.optional().describe("Nova hora do prazo"),
      sem_prazo: z.boolean().optional().describe("true tira a data da tarefa"),
      concluida: z.boolean().optional().describe("true marca como feita; false reabre"),
    }),
  }),
  editar_lembrete: tool({
    description:
      "Muda um lembrete (id vindo de 'buscar' ou 'consultar' lembretes): texto, dia, hora, repetição em " +
      "português ('todo dia', 'toda terça'; 'não repete' tira a repetição) ou liga/desliga o aviso. " +
      "Só os campos informados mudam.",
    inputSchema: z.object({
      id: z.string().min(1),
      texto: z.string().min(1).optional(),
      data: data.optional(),
      hora: hora.optional(),
      repeticao: z.string().optional(),
      ativo: z.boolean().optional().describe("false silencia o lembrete sem apagar"),
    }),
  }),
  editar_treino: tool({
    description:
      "Muda um treino da ficha (id vindo de 'consultar' treino ou 'buscar'): nome, foco, dias e/ou a " +
      "lista de exercícios. 'exercicios' SUBSTITUI a lista inteira: para mudar um só, mande todos, " +
      "com o que mudou (veja a lista atual em 'consultar' treino). 'dias' também substitui.",
    inputSchema: z.object({
      id: z.string().min(1),
      nome: z.string().min(1).optional(),
      foco: z.string().optional(),
      dias: z.array(z.enum(["seg", "ter", "qua", "qui", "sex", "sab", "dom"])).optional(),
      exercicios: z.array(z.object({
        nome: z.string().min(1),
        series: z.number().int().min(1).max(10),
        repeticoes: z.number().int().min(1).max(50),
        carga: z.number().min(0).optional().describe("Carga inicial em kg"),
      })).min(1).max(15).optional(),
    }),
  }),
  excluir_item: tool({
    description:
      "Exclui um lançamento, uma tarefa, um lembrete ou um treino da ficha. Use o id que veio de " +
      "'buscar' ou 'consultar'. O app pede a confirmação da pessoa antes de apagar.",
    inputSchema: z.object({
      tipo: z.enum(["lancamento", "tarefa", "lembrete", "treino"]),
      id: z.string().min(1),
    }),
  }),
  atualizar_metas: tool({
    description:
      "Muda metas. alvo 'dieta': calorias e macros do dia (de treino, de descanso ou os dois); só os " +
      "campos informados mudam. alvo 'meta': uma meta do app pelo nome (ex.: Reserva de emergência, " +
      "Shape 80kg), mudando o valor atual, o alvo e/ou a data.",
    inputSchema: z.object({
      alvo: z.enum(["dieta", "meta"]),
      dia: z.enum(["treino", "descanso", "ambos"]).optional().describe("Só para dieta; padrão ambos"),
      kcal: z.number().positive().optional(),
      proteina: z.number().min(0).optional().describe("Gramas por dia"),
      carboidrato: z.number().min(0).optional().describe("Gramas por dia"),
      gordura: z.number().min(0).optional().describe("Gramas por dia"),
      nome_meta: z.string().optional().describe("Só para meta: o nome dela"),
      valor_atual: z.number().optional(),
      valor_alvo: z.number().optional(),
      data_alvo: data.optional(),
    }),
  }),
  consultar: tool({
    description:
      "Lê dados detalhados do app (além do resumo). Use para responder perguntas sobre a rotina, " +
      "evolução ou histórico da pessoa, e para achar o id de um registro antes de editar ou excluir " +
      "(tarefas, lançamentos, lembretes, treinos, medidas e fotos do 'shape' vêm com ids).",
    inputSchema: z.object({
      area: z.enum([
        "tarefas",
        "habitos",
        "financas",
        "treino",
        "medidas",
        "alimentacao",
        "metas",
        "projetos",
        "lembretes",
        "shape",
      ]),
      periodo_dias: z.number().int().min(1).max(365).optional().describe("Quantos dias para trás; padrão 30"),
    }),
  }),
  buscar: tool({
    description:
      "Procura um termo em tudo do app (tarefas, lançamentos, hábitos, lembretes, metas, treinos). " +
      "Cada resultado vem com o id, para editar ou excluir.",
    inputSchema: z.object({ termo: z.string().min(2) }),
  }),
  abrir_tela: tool({
    description: "Abre uma tela do app para a pessoa ver (a conversa continua aberta).",
    inputSchema: z.object({
      tela: z.enum([
        "visao",
        "tarefas",
        "habitos",
        "treino",
        "medidas",
        "exercicios",
        "shape",
        "alimentacao",
        "lembretes",
        "automacoes",
        "metas",
        "projetos",
        "financas",
        "conta",
      ]),
    }),
  }),
};

// ------------------------------------------------------------------- modelo

export type Escolha = {
  model: LanguageModel;
  /// Só para o Gemini: a Claude Sonnet 5.5 recusa temperatura diferente da padrão.
  temperature?: number;
  providerOptions?: Record<string, Record<string, JSONValue>>;
  nome: string;
};

/// Claude quando há ANTHROPIC_API_KEY; senão, Gemini. IA_FORNECEDOR força um
/// dos dois. Modelos trocáveis por segredo (ANTHROPIC_MODELO, GEMINI_MODELO).
export function escolherModelo(): Escolha {
  const forcado = (Deno.env.get("IA_FORNECEDOR") ?? "").toLowerCase();
  const chaveClaude = Deno.env.get("ANTHROPIC_API_KEY");
  const usarClaude = forcado === "anthropic" || (forcado !== "gemini" && !!chaveClaude);
  if (usarClaude) {
    if (!chaveClaude) throw new Error("ANTHROPIC_API_KEY não configurada");
    const nome = Deno.env.get("ANTHROPIC_MODELO") ?? "claude-sonnet-5-5";
    return {
      model: createAnthropic({ apiKey: chaveClaude })(nome),
      nome,
      providerOptions: {
        anthropic: {
          // Conversa: esforço baixo responde rápido e basta para as ferramentas.
          effort: Deno.env.get("IA_ESFORCO") ?? "low",
          // Se a Claude recusar por segurança, o servidor tenta outro modelo.
          fallbacks: "default",
        },
      },
    };
  }
  const chave = Deno.env.get("GEMINI_API_KEY");
  if (!chave) throw new Error("GEMINI_API_KEY não configurada");
  const nome = Deno.env.get("GEMINI_MODELO") ?? "gemini-flash-latest";
  return {
    model: createGoogleGenerativeAI({ apiKey: chave })(nome),
    nome,
    temperature: 0.7,
  };
}

// -------------------------------------------------------- janela de memória

/// Limites da conversa mandada ao modelo: as últimas mensagens até caberem em
/// ~40 mil caracteres (uns 10 mil tokens). O app já corta antes; aqui é a garantia.
const MAX_MENSAGENS = 40;
const MAX_CARACTERES = 40_000;

function tamanho(m: ModelMessage): number {
  return typeof m.content === "string" ? m.content.length : JSON.stringify(m.content).length;
}

/// Mantém o fim da conversa. A janela sempre começa numa mensagem da pessoa,
/// para não sobrar resultado de ferramenta sem o pedido que o originou.
export function janela(mensagens: ModelMessage[]): ModelMessage[] {
  let total = 0;
  let inicio = mensagens.length;
  while (inicio > 0 && mensagens.length - inicio < MAX_MENSAGENS) {
    const t = tamanho(mensagens[inicio - 1]);
    if (total + t > MAX_CARACTERES && inicio < mensagens.length) break;
    total += t;
    inicio--;
  }
  while (inicio < mensagens.length && mensagens[inicio].role !== "user") inicio++;
  return mensagens.slice(inicio);
}

// ------------------------------------------------------------- validação

const parteTexto = z.object({ type: z.literal("text"), text: z.string().max(8000) });
const chamada = z.object({
  type: z.literal("tool-call"),
  toolCallId: z.string().max(200),
  toolName: z.string().max(60),
  input: z.unknown(),
});
const resultado = z.object({
  type: z.literal("tool-result"),
  toolCallId: z.string().max(200),
  toolName: z.string().max(60),
  output: z.union([
    z.object({ type: z.literal("text"), value: z.string().max(20000) }),
    z.object({ type: z.literal("error-text"), value: z.string().max(2000) }),
  ]),
});

/// O que o app pode mandar: só texto, chamadas e resultados de ferramenta.
/// (Nada de "system": o app não muda as instruções.)
export const esquemaMensagens = z.array(z.discriminatedUnion("role", [
  z.object({ role: z.literal("user"), content: z.union([z.string().max(8000), z.array(parteTexto).max(10)]) }),
  z.object({
    role: z.literal("assistant"),
    content: z.union([z.string().max(20000), z.array(z.union([parteTexto, chamada])).max(20)]),
  }),
  z.object({ role: z.literal("tool"), content: z.array(resultado).min(1).max(20) }),
])).min(1).max(200);
