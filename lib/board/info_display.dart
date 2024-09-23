import 'package:flutter/material.dart';
import 'package:slide_puzzle/board/animated_flip_counter.dart';
import 'package:slide_puzzle/utils/board_config.dart';
import 'package:slide_puzzle/utils/game_state.dart';
import 'package:slide_puzzle/hint/hint.dart';

class InfoDisplay extends StatelessWidget {
  final GameState gameState;

  const InfoDisplay(this.gameState, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final unitSize = BoardConfig.of(context).unitSize;
    final textStyle = TextStyle(
      fontSize: unitSize * 0.35,
      color: Colors.white,
      fontWeight: FontWeight.bold,
      shadows: [
        BoxShadow(
          color: Colors.black26,
          blurRadius: unitSize * 0.02,
          offset: Offset(unitSize * 0.02, unitSize * 0.02),
        ),
      ],
    );

    return Positioned(
      top: unitSize * 0.1,
      height: unitSize * 0.8,
      left: unitSize * 0.3,
      right: unitSize * 0.3,
      child: Row(
        children: [
          // Level display
          Expanded(
            child: _buildBorder(
              context: context,
              unitSize: unitSize,
              child: AnimatedFlipCounter(
                value: gameState.level,
                prefix: 'Lv. ',
                textStyle: textStyle,
                mainAxisAlignment: MainAxisAlignment.start,
              ),
            ),
          ),

          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _IconButton(
                  onPressed: () async {
                    if (gameState.stepCounter.value != 0) {
                      gameState.reset();
                      final duration = BoardConfig.of(context).slideDuration;
                      await Future.delayed(duration);
                    }
                  },
                  child: Icon(
                    Icons.refresh,
                    color: Colors.white,
                    size: unitSize * 0.35,
                    semanticLabel: 'Reset Button',
                  ),
                ),
                _IconButton(
                  onPressed: () => Hint.show(context, gameState),
                  child: Icon(
                    Icons.lightbulb_outline,
                    color: Colors.white,
                    size: unitSize * 0.35,
                    semanticLabel: 'Hint Button',
                  ),
                ),
              ],
            ),
          ),

          // Step counter
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: gameState.stepCounter,
              builder: (BuildContext context, int value, Widget? child) {
                return _buildBorder(
                  context: context,
                  unitSize: unitSize,
                  child: AnimatedFlipCounter(
                    curve: Curves.bounceOut,
                    value: value,
                    wholeDigits: 3,
                    textStyle: textStyle,
                    mainAxisAlignment: MainAxisAlignment.end,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBorder({
    required BuildContext context,
    required double unitSize,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            BoardConfig.of(context).pieceColor1.withOpacity(0.5),
            BoardConfig.of(context).pieceColor2.withOpacity(0.5),
          ],
        ),
        border: Border.all(
          color: BoardConfig.of(context).corePieceColor1.withOpacity(0.5),
          width: unitSize * 0.01,
        ),
        borderRadius: BorderRadius.circular(unitSize * 0.12),
      ),
      padding: EdgeInsets.symmetric(horizontal: unitSize * 0.12),
      child: child,
    );
  }
}

class _IconButton extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onPressed;

  const _IconButton({Key? key, required this.child, required this.onPressed})
      : super(key: key);

  @override
  _IconButtonState createState() => _IconButtonState();
}

class _IconButtonState extends State<_IconButton> {
  bool _hovering = false;
  bool _pressed = false;
  bool _running = false;

  @override
  Widget build(BuildContext context) {
    final unitSize = BoardConfig.of(context).unitSize;

    final button = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.all(
        unitSize < 80 ? unitSize * 0.12 : unitSize * 0.04,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(unitSize * 0.4),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _hovering
              ? [
                  BoardConfig.of(context).corePieceColor1.withOpacity(0.5),
                  BoardConfig.of(context).corePieceColor2.withOpacity(0.5),
                ]
              : [
                  BoardConfig.of(context).pieceColor1.withOpacity(0.5),
                  BoardConfig.of(context).pieceColor2.withOpacity(0.5),
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black54,
            blurRadius: unitSize * 0.02,
            offset: _pressed ? Offset.zero : Offset(0, unitSize * 0.04),
          ),
        ],
      ),
      child: widget.child,
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AbsorbPointer(
        absorbing: _running,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          onTap: () async {
            setState(() {
              _running = true;
              _pressed = true;
            });
            await widget.onPressed();
            setState(() {
              _running = false;
              _pressed = false;
            });
          },
          child: Opacity(
            opacity: _pressed ? 0.5 : 1.0,
            child: button,
          ),
        ),
      ),
    );
  }
}
