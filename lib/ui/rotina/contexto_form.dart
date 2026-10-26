import 'package:flutter/material.dart';

/// O que a folha única da Rotina passa ao formulário de cada tipo: o seletor
/// de tipo no topo, o título (que sobrevive à troca de tipo), a data e a hora
/// iniciais e o que fazer depois de salvar quando é uma conversão.
class ContextoForm {
  const ContextoForm({
    this.cabecalho,
    this.titulo,
    this.data,
    this.hora,
    this.tituloFolha,
    this.aoSalvo,
    this.marcado,
  });

  /// Seletor de tipo (vai como primeiro campo).
  final Widget? cabecalho;

  /// Campo de título compartilhado entre os tipos; quem cria é quem descarta.
  final TextEditingController? titulo;
  final DateTime? data;
  final TimeOfDay? hora;

  /// Troca o título da folha ("Converter em hábito").
  final String? tituloFolha;

  /// Chamado com o id do item salvo, antes de fechar (conversão: apaga o antigo).
  final Future<void> Function(String id)? aoSalvo;

  /// Dias com compromisso (pontinho no calendário da data).
  final bool Function(DateTime dia)? marcado;
}
