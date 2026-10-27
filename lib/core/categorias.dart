/// Categorias de gasto e de entrada de Finanças, num lugar só: o formulário,
/// os gráficos, o comando rápido do assistente e a IA leem daqui.
///
/// O nome é o que fica gravado na transação (texto). [apelidos] são as palavras
/// que o comando rápido e a IA usam para escolher a categoria sozinhas.
/// Categorias antigas que saíram do formulário continuam em [categoriasLegado]
/// para o histórico não perder o ícone.
library;

enum TipoCategoria { saida, entrada }

class CategoriaFinancas {
  const CategoriaFinancas(this.nome, this.tipo, this.apelidos);
  final String nome;
  final TipoCategoria tipo;
  final List<String> apelidos;
}

/// Ordem em que aparecem no formulário: as mais usadas primeiro.
const categoriasDeSaida = <CategoriaFinancas>[
  CategoriaFinancas('Mercado', TipoCategoria.saida, [
    'mercado', 'supermercado', 'feira', 'padaria', 'acougue', 'hortifruti',
    'mercearia', 'sacolao', 'atacadao', 'assai', 'carrefour', 'pao de acucar',
  ]),
  CategoriaFinancas('Alimentação fora', TipoCategoria.saida, [
    'restaurante', 'lanche', 'lanchonete', 'ifood', 'delivery', 'bar',
    'cerveja', 'chope', 'cafe', 'cafeteria', 'pizzaria', 'pizza', 'hamburguer',
    'hamburgueria', 'sushi', 'marmita', 'cantina', 'food truck', 'sorvete',
    'acai',
  ]),
  CategoriaFinancas('Transporte', TipoCategoria.saida, [
    'uber', '99', 'onibus', 'metro', 'taxi', 'passagem', 'bilhete', 'trem',
    'van', 'bike', 'patinete', 'bilhete unico',
  ]),
  CategoriaFinancas('Moradia', TipoCategoria.saida, [
    'aluguel', 'condominio', 'luz', 'energia', 'agua', 'gas',
    'iptu', 'faxina', 'diarista', 'encanador', 'eletricista', 'reforma',
    'pintura', 'mudanca',
  ]),
  CategoriaFinancas('Assinaturas e planos', TipoCategoria.saida, [
    'netflix', 'spotify', 'icloud', 'assinatura', 'streaming', 'disney',
    'youtube', 'prime video', 'globoplay', 'deezer', 'kindle unlimited',
    'celular', 'plano de celular', 'plano de dados', 'internet',
    'plano de internet', 'software', 'adobe', 'chatgpt', 'canva',
  ]),
  CategoriaFinancas('Saúde', TipoCategoria.saida, [
    'farmacia', 'remedio', 'medico', 'consulta', 'exame', 'dentista',
    'terapia', 'psicologo', 'hospital', 'oculos', 'plano de saude',
    'seguro de vida', 'vacina', 'fisioterapia', 'nutricionista', 'laboratorio',
  ]),
  CategoriaFinancas('Lazer', TipoCategoria.saida, [
    'cinema', 'show', 'jogo', 'balada', 'museu', 'parque', 'ingresso',
    'teatro', 'festa', 'passeio', 'hobby', 'game', 'videogame', 'console',
  ]),
  CategoriaFinancas('Compras', TipoCategoria.saida, [
    'roupa', 'camisa', 'calca', 'tenis', 'sapato', 'eletronico', 'computador',
    'notebook', 'celular novo', 'movel', 'decoracao', 'utensilio', 'shopee',
    'mercado livre', 'amazon', 'compras',
  ]),
  CategoriaFinancas('Estudos', TipoCategoria.saida, [
    'faculdade', 'curso', 'livro', 'escola', 'mensalidade', 'apostila',
    'pos-graduacao', 'idiomas', 'ingles', 'educacao', 'material escolar',
  ]),
  CategoriaFinancas('Academia e suplementos', TipoCategoria.saida, [
    'academia', 'personal', 'suplemento', 'whey', 'creatina', 'crossfit',
    'pilates', 'yoga', 'natacao', 'musculacao', 'boxe', 'luta',
  ]),
  CategoriaFinancas('Carro', TipoCategoria.saida, [
    'carro', 'moto', 'seguro', 'gasolina', 'combustivel', 'estacionamento',
    'pedagio', 'manutencao', 'revisao', 'pneu', 'oleo', 'mecanico', 'lavagem',
    'ipva', 'licenciamento', 'detran',
  ]),
  CategoriaFinancas('Viagem', TipoCategoria.saida, [
    'viagem', 'passagem aerea', 'hotel', 'hospedagem', 'airbnb', 'pousada',
    'turismo', 'cruzeiro', 'pacote', 'milhas',
  ]),
  CategoriaFinancas('Presentes e doações', TipoCategoria.saida, [
    'presente', 'doacao', 'dizimo', 'caridade', 'vaquinha', 'lembrancinha',
    'casamento', 'natal',
  ]),
  CategoriaFinancas('Impostos e taxas', TipoCategoria.saida, [
    'darf', 'imposto', 'imposto de renda', 'taxa', 'tarifa', 'cartorio',
    'multa', 'iof', 'anuidade', 'receita federal',
  ]),
  CategoriaFinancas('Pets', TipoCategoria.saida, [
    'pet', 'racao', 'veterinario', 'banho e tosa', 'vacina pet', 'petisco',
    'areia', 'gato', 'cachorro',
  ]),
  CategoriaFinancas('Cuidados pessoais', TipoCategoria.saida, [
    'barbearia', 'barbeiro', 'cabelo', 'cabeleireiro', 'corte de cabelo',
    'salao de beleza', 'manicure', 'pedicure', 'unha', 'estetica',
    'cosmetico', 'maquiagem', 'perfume', 'depilacao', 'massagem', 'higiene',
    'shampoo', 'hidratante', 'skincare',
  ]),
  CategoriaFinancas('Serviços', TipoCategoria.saida, [
    'lavanderia', 'chaveiro', 'tecnico', 'conserto', 'costureira', 'frete',
    'baba', 'mao de obra', 'montagem', 'dedetizacao',
  ]),
  CategoriaFinancas('Dívidas e juros', TipoCategoria.saida, [
    'emprestimo', 'financiamento', 'consignado', 'cheque especial', 'rotativo',
    'juros', 'juros do cartao', 'divida', 'boleto atrasado', 'crediario',
    'parcela do emprestimo',
  ]),
  CategoriaFinancas('Investimentos', TipoCategoria.saida, [
    'investimento', 'aporte', 'aplicacao', 'tesouro', 'cdb', 'fii', 'fundo',
    'acao', 'acoes', 'previdencia', 'cripto', 'bitcoin', 'moeda', 'poupanca',
  ]),
  CategoriaFinancas('Outros', TipoCategoria.saida, []),
];

/// Entradas. "Outros" fica por último, como reserva.
const categoriasDeEntrada = <CategoriaFinancas>[
  CategoriaFinancas('Salário', TipoCategoria.entrada, [
    'salario', 'pagamento do mes', 'contracheque', 'holerite', 'pro-labore',
    'decimo terceiro', 'ferias',
  ]),
  CategoriaFinancas('Freela', TipoCategoria.entrada, [
    'freela', 'freelance', 'job', 'bico', 'projeto', 'servico', 'consultoria',
    'aula',
  ]),
  CategoriaFinancas('Reembolso', TipoCategoria.entrada, [
    'reembolso', 'estorno', 'devolucao', 'ressarcimento', 'cashback',
  ]),
  CategoriaFinancas('Rendimentos', TipoCategoria.entrada, [
    'rendimento', 'juros', 'dividendo', 'investimento', 'aluguel', 'fii',
    'cdb', 'poupanca', 'bonificacao', 'lucro', 'tesouro', 'acao', 'fundo',
  ]),
  CategoriaFinancas('Outros', TipoCategoria.entrada, []),
];

/// Categorias que não são mais oferecidas, mas seguem nos lançamentos antigos.
/// "Educação" é o nome antigo de Estudos (o histórico é convertido ao abrir a
/// área de Finanças); "Serviços" voltou a ser oferecida.
const categoriasLegado = <String>['Educação'];

/// Grupos de gasto: a rosca de "Despesas por categoria" com 20 fatias fica
/// ilegível (muita fatia de 1-2%), então o cartão pode somar por grupo.
const gruposDeGasto = <String>[
  'Alimentação',
  'Casa e contas',
  'Transporte',
  'Saúde e treino',
  'Pessoal',
  'Lazer e viagem',
  'Financeiro',
  'Outros',
];

/// Grupo de cada categoria oferecida (e do legado, que continua no histórico).
const grupoDaCategoria = <String, String>{
  'Mercado': 'Alimentação',
  'Alimentação fora': 'Alimentação',
  'Transporte': 'Transporte',
  'Carro': 'Transporte',
  'Moradia': 'Casa e contas',
  'Assinaturas e planos': 'Casa e contas',
  'Serviços': 'Casa e contas',
  'Saúde': 'Saúde e treino',
  'Academia e suplementos': 'Saúde e treino',
  'Compras': 'Pessoal',
  'Cuidados pessoais': 'Pessoal',
  'Estudos': 'Pessoal',
  'Pets': 'Pessoal',
  'Lazer': 'Lazer e viagem',
  'Viagem': 'Lazer e viagem',
  'Presentes e doações': 'Lazer e viagem',
  'Impostos e taxas': 'Financeiro',
  'Dívidas e juros': 'Financeiro',
  'Investimentos': 'Financeiro',
  'Outros': 'Outros',
  'Educação': 'Pessoal', // nome antigo de Estudos
};

/// Grupo de uma categoria. Categoria desconhecida (histórico antigo) cai em
/// "Outros", como no gráfico.
String grupoDe(String categoria) => grupoDaCategoria[categoria] ?? 'Outros';

/// Ordem de teste dos apelidos: as regras mais específicas vêm antes (ex.:
/// "mercado livre" é Compras, "passagem aérea" é Viagem, "plano de saúde" é
/// Saúde, "seguro de vida" é Saúde e "seguro do carro" é Carro; "conserto do
/// celular" é Serviços, que vem antes de Assinaturas e planos).
const ordemClassificacaoSaida = <String>[
  'Pets',
  'Compras',
  'Mercado',
  'Alimentação fora',
  'Viagem',
  'Transporte',
  'Saúde',
  'Academia e suplementos',
  'Cuidados pessoais',
  'Estudos',
  'Moradia',
  'Serviços',
  'Assinaturas e planos',
  'Dívidas e juros',
  'Investimentos',
  'Lazer',
  'Presentes e doações',
  'Carro',
  'Impostos e taxas',
  'Outros',
];

const ordemClassificacaoEntrada = <String>[
  'Reembolso',
  'Rendimentos',
  'Salário',
  'Freela',
  'Outros',
];

final Map<String, CategoriaFinancas> categoriasPorNome = {
  for (final c in [...categoriasDeSaida, ...categoriasDeEntrada]) c.nome: c,
};

CategoriaFinancas? categoriaPorNomeDe(String nome) => categoriasPorNome[nome];

List<String> nomesCategorias(TipoCategoria tipo) => [
      for (final c in tipo == TipoCategoria.saida ? categoriasDeSaida : categoriasDeEntrada) c.nome,
    ];
