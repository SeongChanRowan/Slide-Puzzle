import 'dart:async';

import 'package:flutter/material.dart';
import 'package:slide_puzzle/board/boared_decoration.dart';
import 'package:slide_puzzle/hint/hint.dart';
import 'package:slide_puzzle/utils/board_config.dart';
import 'package:slide_puzzle/utils/game_state.dart';
import 'package:slide_puzzle/puzzle/puzzle_piece.dart';

class PuzzleLevel extends StatefulWidget {
  final int level;
  final void Function(int level, int steps) onWin;

  const PuzzleLevel({super.key, required this.level, required this.onWin});

  @override
  State<PuzzleLevel> createState() => _PuzzleLevelState();
}

class _PuzzleLevelState extends State<PuzzleLevel>
    with SingleTickerProviderStateMixin {
  late final GameState _gameState = GameState.level(widget.level);
  Timer? _hintTimer;

  @override
  void initState() {
    super.initState();
    _gameState.stepCounter.addListener(() {
      if (_gameState.stepCounter.value == 0) {
        setState(() {});
      }
      _hintTimer?.cancel();
    });

    if (widget.level == 1) {
      _hintTimer ??= Timer.periodic(const Duration(seconds: 2), (_) {
        Hint.show(context, _gameState);
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _hintTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final unitSize = BoardConfig.of(context).unitSize;

    final puzzlePieces = Stack(
      clipBehavior: Clip.none,
      children: [
        SizedBox(
          width: unitSize * _gameState.boardSize.x,
          height: unitSize * _gameState.boardSize.y,
        ),
        for (final p in _gameState.pieces)
          _AnimatedPieceComponent(
            piece: p,
            child: PuzzlePieceShadow(piece: p),
          ),
        for (final p in _gameState.pieces)
          _AnimatedPieceComponent(
            piece: p,
            child: PuzzlePieceAttachment(piece: p),
          ),
        for (final p in _gameState.pieces)
          _AnimatedPieceComponent(
            piece: p,
            child: CompositedTransformTarget(
              link: BoardConfig.of(context).layerLinks[p.id],
              child: PuzzlePiece(
                piece: p,
                gameState: _gameState,
                onMove: _onMove,
              ),
            ),
          ),
      ],
    );

    return BoardDecoration(
      gameState: _gameState,
      child: puzzlePieces,
    );
  }

  void _onMove() async {
    _gameState.stepCounter.value += 1;
    if (_gameState.hasWon()) {
      await Future.delayed(const Duration(milliseconds: 300));
      widget.onWin(_gameState.level, _gameState.stepCounter.value);
      _gameState.pieces.singleWhere((p) => p.id == 0).move(0, 1000);
    }
  }
}

class _AnimatedPieceComponent extends StatefulWidget {
  final Piece piece;
  final Widget child;

  const _AnimatedPieceComponent({
    Key? key,
    required this.piece,
    required this.child,
  }) : super(key: key);

  @override
  State<_AnimatedPieceComponent> createState() =>
      _AnimatedPieceComponentState();
}

class _AnimatedPieceComponentState extends State<_AnimatedPieceComponent> {
  Size? _size;

  @override
  Widget build(BuildContext context) {
    final unitSize = BoardConfig.of(context).unitSize;

    return ValueListenableBuilder(
      valueListenable: widget.piece.coordinates,
      builder: (BuildContext context, Coordinates value, Widget? child) {
        final size = MediaQuery.of(context).size;
        final duration = size != _size
            ? Duration.zero
            : BoardConfig.of(context).slideDuration;
        _size = size;
        return AnimatedPositioned(
          duration: duration,
          curve: Curves.easeOut,
          left: value.x * unitSize,
          top: value.y * unitSize,
          child: widget.child,
        );
      },
    );
  }
}
