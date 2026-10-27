import 'package:flutter/material.dart';

/// Ícone e cor de cada categoria de lançamento (painel, extrato e gráficos).
/// As cores saem da paleta Aurora; no modo claro, tons mais escuros para ler
/// bem sobre o branco. Categoria desconhecida cai em "Outros".
class VisualCategoria {
  const VisualCategoria(this.icone, this.cor);
  final IconData icone;
  final Color cor;
}

const _escuro = <String, VisualCategoria>{
  'Mercado': VisualCategoria(Icons.shopping_cart_outlined, Color(0xFF5CF0B0)),
  'Alimentação fora': VisualCategoria(Icons.restaurant_outlined, Color(0xFFFFB86B)),
  'Transporte': VisualCategoria(Icons.directions_car_outlined, Color(0xFF42E3C8)),
  'Moradia': VisualCategoria(Icons.home_outlined, Color(0xFFF5C35B)),
  'Assinaturas e planos': VisualCategoria(Icons.subscriptions_outlined, Color(0xFF9D8CFF)),
  'Saúde': VisualCategoria(Icons.favorite_border_rounded, Color(0xFFFF8FB1)),
  'Lazer': VisualCategoria(Icons.celebration_outlined, Color(0xFFE77BFF)),
  'Compras': VisualCategoria(Icons.shopping_bag_outlined, Color(0xFF6FD3FF)),
  'Estudos': VisualCategoria(Icons.school_outlined, Color(0xFF7E7BFF)),
  'Academia e suplementos': VisualCategoria(Icons.fitness_center_outlined, Color(0xFFB8F26B)),
  'Carro': VisualCategoria(Icons.directions_car_filled, Color(0xFFA3B8FF)),
  'Viagem': VisualCategoria(Icons.flight_takeoff_outlined, Color(0xFF8FE3A8)),
  'Presentes e doações': VisualCategoria(Icons.card_giftcard_outlined, Color(0xFFFF9F7A)),
  'Impostos e taxas': VisualCategoria(Icons.receipt_long_outlined, Color(0xFFC9C3A5)),
  'Pets': VisualCategoria(Icons.pets_outlined, Color(0xFFD9A7FF)),
  'Cuidados pessoais': VisualCategoria(Icons.spa_outlined, Color(0xFFFFB3C7)),
  'Serviços': VisualCategoria(Icons.handyman_outlined, Color(0xFF9BD1FF)),
  'Dívidas e juros': VisualCategoria(Icons.request_quote_outlined, Color(0xFFFF7A8A)),
  'Investimentos': VisualCategoria(Icons.savings_outlined, Color(0xFF8CF0D4)),
  'Outros': VisualCategoria(Icons.category_outlined, Color(0xFFA3A6C8)),
  // Legado: saíram do formulário, mas os lançamentos antigos continuam neles.
  'Educação': VisualCategoria(Icons.school_outlined, Color(0xFF7E7BFF)),
  'Salário': VisualCategoria(Icons.work_outline_rounded, Color(0xFF5CF0B0)),
  'Freela': VisualCategoria(Icons.laptop_mac_outlined, Color(0xFF42E3C8)),
  'Reembolso': VisualCategoria(Icons.assignment_return_outlined, Color(0xFF8FE3A8)),
  'Rendimentos': VisualCategoria(Icons.trending_up_rounded, Color(0xFFB8F26B)),
};

const _claro = <String, VisualCategoria>{
  'Mercado': VisualCategoria(Icons.shopping_cart_outlined, Color(0xFF0B8A5C)),
  'Alimentação fora': VisualCategoria(Icons.restaurant_outlined, Color(0xFFA85A00)),
  'Transporte': VisualCategoria(Icons.directions_car_outlined, Color(0xFF0A7C70)),
  'Moradia': VisualCategoria(Icons.home_outlined, Color(0xFF9A5B06)),
  'Assinaturas e planos': VisualCategoria(Icons.subscriptions_outlined, Color(0xFF5B45D6)),
  'Saúde': VisualCategoria(Icons.favorite_border_rounded, Color(0xFFC2335A)),
  'Lazer': VisualCategoria(Icons.celebration_outlined, Color(0xFFA8259A)),
  'Compras': VisualCategoria(Icons.shopping_bag_outlined, Color(0xFF0B6E99)),
  'Estudos': VisualCategoria(Icons.school_outlined, Color(0xFF3F3DB8)),
  'Academia e suplementos': VisualCategoria(Icons.fitness_center_outlined, Color(0xFF4F7A00)),
  'Carro': VisualCategoria(Icons.directions_car_filled, Color(0xFF3A4FA8)),
  'Viagem': VisualCategoria(Icons.flight_takeoff_outlined, Color(0xFF1E7A46)),
  'Presentes e doações': VisualCategoria(Icons.card_giftcard_outlined, Color(0xFFB34A1E)),
  'Impostos e taxas': VisualCategoria(Icons.receipt_long_outlined, Color(0xFF6B6444)),
  'Pets': VisualCategoria(Icons.pets_outlined, Color(0xFF6E2FA8)),
  'Cuidados pessoais': VisualCategoria(Icons.spa_outlined, Color(0xFF97244E)),
  'Serviços': VisualCategoria(Icons.handyman_outlined, Color(0xFF1C5C99)),
  'Dívidas e juros': VisualCategoria(Icons.request_quote_outlined, Color(0xFFA81E3C)),
  'Investimentos': VisualCategoria(Icons.savings_outlined, Color(0xFF0B7A6B)),
  'Outros': VisualCategoria(Icons.category_outlined, Color(0xFF55557A)),
  // Legado: saíram do formulário, mas os lançamentos antigos continuam neles.
  'Educação': VisualCategoria(Icons.school_outlined, Color(0xFF3F3DB8)),
  'Salário': VisualCategoria(Icons.work_outline_rounded, Color(0xFF0B8A5C)),
  'Freela': VisualCategoria(Icons.laptop_mac_outlined, Color(0xFF0A7C70)),
  'Reembolso': VisualCategoria(Icons.assignment_return_outlined, Color(0xFF1E7A46)),
  'Rendimentos': VisualCategoria(Icons.trending_up_rounded, Color(0xFF4F7A00)),
};

VisualCategoria visualDaCategoria(BuildContext context, String categoria) {
  final tabela = Theme.of(context).brightness == Brightness.dark ? _escuro : _claro;
  return tabela[categoria] ?? tabela['Outros']!;
}

/// Ícone e cor de cada grupo de gasto (quando o cartão soma por grupo).
const _gruposEscuro = <String, VisualCategoria>{
  'Alimentação': VisualCategoria(Icons.restaurant_menu_rounded, Color(0xFF5CF0B0)),
  'Casa e contas': VisualCategoria(Icons.chair_outlined, Color(0xFFF5C35B)),
  'Transporte': VisualCategoria(Icons.commute_outlined, Color(0xFF42E3C8)),
  'Saúde e treino': VisualCategoria(Icons.favorite_border_rounded, Color(0xFFFF8FB1)),
  'Pessoal': VisualCategoria(Icons.person_outline_rounded, Color(0xFF6FD3FF)),
  'Lazer e viagem': VisualCategoria(Icons.celebration_outlined, Color(0xFFE77BFF)),
  'Financeiro': VisualCategoria(Icons.account_balance_outlined, Color(0xFFC9C3A5)),
  'Outros': VisualCategoria(Icons.category_outlined, Color(0xFFA3A6C8)),
};

const _gruposClaro = <String, VisualCategoria>{
  'Alimentação': VisualCategoria(Icons.restaurant_menu_rounded, Color(0xFF0B8A5C)),
  'Casa e contas': VisualCategoria(Icons.chair_outlined, Color(0xFF9A5B06)),
  'Transporte': VisualCategoria(Icons.commute_outlined, Color(0xFF0A7C70)),
  'Saúde e treino': VisualCategoria(Icons.favorite_border_rounded, Color(0xFFC2335A)),
  'Pessoal': VisualCategoria(Icons.person_outline_rounded, Color(0xFF0B6E99)),
  'Lazer e viagem': VisualCategoria(Icons.celebration_outlined, Color(0xFFA8259A)),
  'Financeiro': VisualCategoria(Icons.account_balance_outlined, Color(0xFF6B6444)),
  'Outros': VisualCategoria(Icons.category_outlined, Color(0xFF55557A)),
};

VisualCategoria visualDoGrupo(BuildContext context, String grupo) {
  final tabela = Theme.of(context).brightness == Brightness.dark ? _gruposEscuro : _gruposClaro;
  return tabela[grupo] ?? tabela['Outros']!;
}

/// Usado pelos testes para garantir que toda categoria oferecida tem ícone e
/// cor nos dois temas (e que nenhuma nova ficou de fora).
bool categoriaTemVisual(String categoria) =>
    _escuro.containsKey(categoria) && _claro.containsKey(categoria);

/// O mesmo para os grupos de gasto.
bool grupoTemVisual(String grupo) =>
    _gruposEscuro.containsKey(grupo) && _gruposClaro.containsKey(grupo);
