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
  'Serviços': VisualCategoria(Icons.subscriptions_outlined, Color(0xFF9D8CFF)),
  'Transporte': VisualCategoria(Icons.directions_car_outlined, Color(0xFF42E3C8)),
  'Lazer': VisualCategoria(Icons.celebration_outlined, Color(0xFFE77BFF)),
  'Saúde': VisualCategoria(Icons.favorite_border_rounded, Color(0xFFFF8FB1)),
  'Educação': VisualCategoria(Icons.school_outlined, Color(0xFF7E7BFF)),
  'Moradia': VisualCategoria(Icons.home_outlined, Color(0xFFF5C35B)),
  'Salário': VisualCategoria(Icons.work_outline_rounded, Color(0xFF5CF0B0)),
  'Freela': VisualCategoria(Icons.laptop_mac_outlined, Color(0xFF42E3C8)),
  'Outros': VisualCategoria(Icons.category_outlined, Color(0xFFA3A6C8)),
};

const _claro = <String, VisualCategoria>{
  'Mercado': VisualCategoria(Icons.shopping_cart_outlined, Color(0xFF0B8A5C)),
  'Serviços': VisualCategoria(Icons.subscriptions_outlined, Color(0xFF5B45D6)),
  'Transporte': VisualCategoria(Icons.directions_car_outlined, Color(0xFF0A7C70)),
  'Lazer': VisualCategoria(Icons.celebration_outlined, Color(0xFFA8259A)),
  'Saúde': VisualCategoria(Icons.favorite_border_rounded, Color(0xFFC2335A)),
  'Educação': VisualCategoria(Icons.school_outlined, Color(0xFF3F3DB8)),
  'Moradia': VisualCategoria(Icons.home_outlined, Color(0xFF9A5B06)),
  'Salário': VisualCategoria(Icons.work_outline_rounded, Color(0xFF0B8A5C)),
  'Freela': VisualCategoria(Icons.laptop_mac_outlined, Color(0xFF0A7C70)),
  'Outros': VisualCategoria(Icons.category_outlined, Color(0xFF55557A)),
};

VisualCategoria visualDaCategoria(BuildContext context, String categoria) {
  final tabela = Theme.of(context).brightness == Brightness.dark ? _escuro : _claro;
  return tabela[categoria] ?? tabela['Outros']!;
}
