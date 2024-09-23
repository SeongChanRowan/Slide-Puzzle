import 'dart:math';

import 'package:flutter/material.dart';
import 'package:slide_puzzle/utils/board_config.dart';
import 'package:slide_puzzle/puzzle/puzzle_level.dart';

class Game extends StatefulWidget {
  const Game({super.key});

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> with TickerProviderStateMixin {
  int _currentLevel = 1;
  bool _hideTexts = false;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final unitSize = min(screenSize.width / 6, screenSize.height / 8);

    return Scaffold(
      body: BoardConfig(
        unitSize: unitSize,
        hideTexts: _hideTexts,
        child: Stack(
          children: [
            RepaintBoundary(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black,
              ),
            ),
            // if(_currentLevel == 0)
            // TutorialDialog
            // if (_currentLevel > 0)
            Center(
              child: PuzzleLevel(
                key: ValueKey(_currentLevel),
                level: _currentLevel,
                onWin: _onLevelCompleted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _advanceToNextLevel() {
    setState(() => _currentLevel++);
  }

  void _onLevelCompleted(int level, int steps) async {
    _advanceToNextLevel();
  }
}
