import 'package:flutter/widgets.dart';

class BoardConfig extends InheritedWidget {
  final Duration slideDuration = const Duration(milliseconds: 300);

  final double unitSize;
  final bool hideTexts;

  final Color corePieceColor1 = const Color.fromRGBO(235, 85, 55, 1);
  final Color corePieceColor2 = const Color.fromARGB(255, 191, 68, 44);

  final Color pieceColor1 = const Color.fromARGB(230, 200, 150, 1);
  final Color pieceColor2 = const Color.fromARGB(230, 142, 106, 1);

  final Color pieceAttachmentColor = const Color.fromARGB(230, 73, 55, 0);
  final Color pieceShadowColor = const Color.fromARGB(230, 39, 30, 1);

  final List<LayerLink> layerLinks = List.generate(10, (int i) => LayerLink());

  BoardConfig({
    super.key,
    required this.unitSize,
    required super.child,
    this.hideTexts = false,
  });

  static BoardConfig of(BuildContext context) {
    final config = context.dependOnInheritedWidgetOfExactType<BoardConfig>();
    assert(
      config != null,
      'BoardConfig.of() called with a context'
      'that does not contain a BoardConfig.',
    );
    return config!;
  }

  @override
  bool updateShouldNotify(BoardConfig oldWidget) {
    return unitSize != oldWidget.unitSize;
  }
}
