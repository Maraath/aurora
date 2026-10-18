import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/tema.dart';
import '../../data/catalogo_taco.dart';
import '../ceu_estrelado.dart';
import '../componentes.dart';

/// E-mail para pedidos sobre dados (LGPD) e dúvidas dos termos. Entra no lugar
/// de {{CONTATO}} nos textos de assets/legal. Vazio = ainda não definido (os
/// scripts de publicação param até ser preenchido).
const contatoLegal = 'contato@exemplo.com';

enum DocumentoLegal {
  privacidade('Política de privacidade', 'assets/legal/privacidade.md'),
  termos('Termos de uso', 'assets/legal/termos.md');

  const DocumentoLegal(this.titulo, this.arquivo);
  final String titulo;
  final String arquivo;

  Future<void> abrir(BuildContext context) => Navigator.of(context).push(
        MaterialPageRoute<void>(fullscreenDialog: true, builder: (_) => LegalPage(this)),
      );
}

/// Lê um texto de assets/legal (markdown simples: #, ##, "- " e **negrito**).
class LegalPage extends StatelessWidget {
  const LegalPage(this.documento, {super.key});
  final DocumentoLegal documento;

  @override
  Widget build(BuildContext context) {
    final largo = MediaQuery.sizeOf(context).width >= 600;
    return Scaffold(
      body: CeuEstrelado(
        child: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: FutureBuilder<String>(
                future: rootBundle.loadString(documento.arquivo),
                builder: (context, texto) => ListView(
                  padding: largo
                      ? const EdgeInsets.fromLTRB(Espaco.xl, Espaco.lg, Espaco.xl, Espaco.xxl)
                      : const EdgeInsets.fromLTRB(20, Espaco.md, 20, Espaco.xl),
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: BotaoRedondo(
                        icone: Icons.close_rounded,
                        dica: 'Fechar',
                        aoTocar: () => Navigator.of(context).pop(),
                      ),
                    ),
                    if (texto.hasData) ...blocosLegais(context, texto.data!),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Transforma o markdown dos textos legais em widgets.
List<Widget> blocosLegais(BuildContext context, String markdown) {
  final c = context.cores;
  const contato = contatoLegal;
  final blocos = <Widget>[];
  for (final bruto in markdown.replaceAll('{{CONTATO}}', contato).split('\n')) {
    final linha = bruto.trimRight();
    if (linha.isEmpty) continue;
    if (linha.startsWith('# ')) {
      blocos.add(Text(linha.substring(2), style: sora(26)));
      blocos.add(const SizedBox(height: Espaco.xs));
    } else if (linha.startsWith('## ')) {
      blocos.add(const SizedBox(height: Espaco.lg));
      blocos.add(Text(linha.substring(3), style: sora(17)));
      blocos.add(const SizedBox(height: Espaco.sm));
    } else if (linha.startsWith('- ')) {
      blocos.add(Padding(
        padding: const EdgeInsets.only(left: Espaco.sm, bottom: Espaco.sm),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.only(top: 8, right: 10),
            child: Container(width: 5, height: 5, decoration: BoxDecoration(color: c.accent, shape: BoxShape.circle)),
          ),
          Expanded(child: _paragrafo(c, linha.substring(2))),
        ]),
      ));
    } else if (linha.startsWith('Última atualização')) {
      blocos.add(Text(linha, style: manrope(13, cor: c.muted)));
      blocos.add(const SizedBox(height: Espaco.md));
    } else {
      blocos.add(Padding(padding: const EdgeInsets.only(bottom: Espaco.md), child: _paragrafo(c, linha)));
    }
  }
  return blocos;
}

/// Parágrafo com **negrito**.
Widget _paragrafo(AuroraCores c, String texto) {
  final partes = texto.split('**');
  return Text.rich(
    TextSpan(children: [
      for (var i = 0; i < partes.length; i++)
        TextSpan(
          text: partes[i],
          style: i.isOdd ? const TextStyle(fontWeight: FontWeight.w700) : null,
        ),
    ]),
    style: manrope(14.5, cor: c.text, altura: 1.6),
  );
}

/// "Ao criar a conta, você concorda com os Termos de uso e a Política de
/// privacidade", com os dois nomes tocáveis.
class AvisoAceite extends StatelessWidget {
  const AvisoAceite({super.key, this.prefixo = 'Ao criar a conta, você concorda com os '});
  final String prefixo;

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    TextSpan link(DocumentoLegal d) => TextSpan(
          text: d.titulo,
          style: TextStyle(color: c.accent, fontWeight: FontWeight.w700),
          recognizer: TapGestureRecognizer()..onTap = () => d.abrir(context),
        );
    return Text.rich(
      TextSpan(children: [
        TextSpan(text: prefixo),
        link(DocumentoLegal.termos),
        const TextSpan(text: ' e com a '),
        link(DocumentoLegal.privacidade),
        const TextSpan(text: ', inclusive o envio dos dados de saúde que você registrar para a nuvem.'),
      ]),
      style: manrope(12.5, cor: c.muted, altura: 1.5),
    );
  }
}

/// Links para os dois textos (tela de Conta e boas-vindas).
class LinksLegais extends StatelessWidget {
  const LinksLegais({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Wrap(spacing: Espaco.md, children: [
      for (final d in DocumentoLegal.values)
        TextButton(
          onPressed: () => d.abrir(context),
          style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 4)),
          child: Text(d.titulo, style: manrope(13, peso: FontWeight.w600, cor: c.muted)),
        ),
      TextButton(
        onPressed: () => showLicensePage(
          context: context,
          applicationName: 'Aurora',
          applicationLegalese: 'Alimentos: $fonteTaco.',
        ),
        style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 4)),
        child: Text('Licenças', style: manrope(13, peso: FontWeight.w600, cor: c.muted)),
      ),
    ]);
  }
}
