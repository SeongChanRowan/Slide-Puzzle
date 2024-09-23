import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:slide_puzzle/board/exit_arrows.dart';
import 'package:slide_puzzle/board/info_display.dart';
import 'package:slide_puzzle/utils/board_config.dart';
import 'package:slide_puzzle/utils/game_state.dart';

class BoardDecoration extends StatefulWidget {
  final GameState gameState;
  final Widget child;

  const BoardDecoration({
    super.key,
    required this.gameState,
    required this.child,
  });

  @override
  _BoardDecorationState createState() => _BoardDecorationState();
}

class _BoardDecorationState extends State<BoardDecoration>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final unitSize = BoardConfig.of(context).unitSize;

    final thickBorder = BorderSide(
      color: const Color.fromRGBO(147, 66, 32, 1),
      width: unitSize,
    );
    final thinBorder = BorderSide(
      color: const Color.fromRGBO(147, 66, 32, 1),
      width: unitSize * 0.3,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(unitSize * 0.16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: thickBorder,
                  bottom: thinBorder,
                  left: thinBorder,
                  right: thinBorder,
                ),
              ),
              child: ClipRect(
                child: Padding(
                  padding: EdgeInsets.all(unitSize * 0.01),
                  child: widget.child,
                ),
              ),
            ),
            InfoDisplay(widget.gameState), // header
            Positioned(
              left: unitSize,
              right: unitSize,
              top: unitSize * 6,
              child: const ExitArrows(),
            ), // footer
          ],
        ),
      ),
    );
  }
}
