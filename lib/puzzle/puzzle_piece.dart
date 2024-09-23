import 'package:flutter/material.dart';
import 'package:slide_puzzle/utils/board_config.dart';
import 'package:slide_puzzle/utils/game_state.dart';

class PuzzlePiece extends StatefulWidget {
  final Piece piece;
  final bool disableGestures;
  final GameState? gameState;
  final VoidCallback? onMove;

  const PuzzlePiece(
      {super.key,
      required this.piece,
      this.disableGestures = false,
      this.gameState,
      this.onMove})
      : assert(gameState != null || disableGestures,
            'Must pass in game state to enable moving.');

  @override
  State<PuzzlePiece> createState() => _PuzzlePieceState();
}

class _PuzzlePieceState extends State<PuzzlePiece> {
  bool _dispatched = false;
  late Offset _dragStart;

  @override
  Widget build(BuildContext context) {
    final unitSize = BoardConfig.of(context).unitSize;
    final child = Container(
      width: unitSize * 0.99 + (widget.piece.width - 1) * unitSize,
      height: unitSize * 0.99 + (widget.piece.height - 1) * unitSize,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: widget.piece.id == 0
              ? [
                  BoardConfig.of(context).corePieceColor1,
                  BoardConfig.of(context).corePieceColor2,
                ]
              : [
                  BoardConfig.of(context).pieceColor1,
                  BoardConfig.of(context).pieceColor2,
                ],
        ),
        borderRadius: BorderRadius.circular(unitSize * 0.04),
      ),
    );

    if (widget.disableGestures) {
      return child;
    }

    return GestureDetector(
      onPanStart: (DragStartDetails details) {
        _dispatched = false;
        _dragStart = details.localPosition;
      },
      onPanUpdate: (DragUpdateDetails details) {
        if (_dispatched) return;

        final delta = details.localPosition - _dragStart;
        final direction = _getDirection(delta, 5);

        if (direction == null) return;
        if (widget.gameState!.canMove(widget.piece, direction.x, direction.y)) {
          widget.piece.move(direction.x, direction.y);
          widget.onMove?.call();
          _dispatched = true;
        }
      },
      child: child,
    );
  }

  Coordinates? _getDirection(Offset delta, [double minThreshold = 5.0]) {
    if (delta.dx.abs() < minThreshold && delta.dy.abs() < minThreshold) {
      return null;
    }
    if (delta.dx.abs() > delta.dy.abs()) {
      return Coordinates(delta.dx < 0 ? -1 : 1, 0);
    } else {
      return Coordinates(0, delta.dy < 0 ? -1 : 1);
    }
  }
}

class PuzzlePieceAttachment extends StatelessWidget {
  final Piece piece;

  const PuzzlePieceAttachment({
    Key? key,
    required this.piece,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final unitSize = BoardConfig.of(context).unitSize;

    final decoration = DecoratedBox(
      decoration: BoxDecoration(
        color: BoardConfig.of(context).pieceAttachmentColor,
        borderRadius: BorderRadius.circular(unitSize * 0.04),
      ),
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        SizedBox(
          width: piece.width * unitSize * 0.99,
          height: piece.height * unitSize * 0.99,
        ),
        Positioned(
          top: unitSize * -0.1,
          right: unitSize * 0.1,
          child: SizedBox(
            width: piece.width * unitSize * 0.8,
            height: piece.height * unitSize * 0.2,
            child: decoration,
          ),
        ),
        Positioned(
          top: unitSize * 0.1,
          right: unitSize * -0.1,
          child: SizedBox(
            width: piece.width * unitSize * 0.2,
            height: piece.height * unitSize * 0.8,
            child: decoration,
          ),
        ),
      ],
    );
  }
}

class PuzzlePieceShadow extends StatelessWidget {
  final Piece piece;

  const PuzzlePieceShadow({
    Key? key,
    required this.piece,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final unitSize = BoardConfig.of(context).unitSize;
    return Container(
      width: piece.width * unitSize * 0.99,
      height: unitSize * 1.05 + (piece.height - 1) * unitSize,
      decoration: BoxDecoration(
        color: BoardConfig.of(context).pieceShadowColor,
        borderRadius: BorderRadius.circular(unitSize * 0.04),
      ),
    );
  }
}
