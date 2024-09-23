import 'dart:collection';
import 'dart:convert' as convert;

import 'package:flutter/foundation.dart';
import 'package:slide_puzzle/utils/game_state.dart';

List<String> _computeSolve(List<String> pieces) {
  final rootState = GameState(
    level: 0,
    boardSize: const Coordinates(4, 5),
    pieces: pieces.map((s) => Piece.fromJson(convert.jsonDecode(s))).toList(),
  );
  final solution = Solver.solveSync(rootState);
  return solution.map((s) => convert.jsonEncode(s.toJson())).toList();
}

class Solver {
  static Future<List<Move>> solve(GameState rootState) async {
    assert(rootState.pieces.length == 10);
    assert(rootState.boardSize == const Coordinates(4, 5),
        'TODO: solver is not yet generalized to handle different board sizes.');
    final pieces = rootState.pieces.map((p) => convert.jsonEncode(p.toJson()));
    final solution = await compute(_computeSolve, pieces.toList());
    return solution.map((s) => Move.fromJson(convert.jsonDecode(s))).toList();
  }

  static List<Move> solveSync(GameState rootState) {
    final queue = Queue<_Step>();
    final visited = HashSet<String>();
    queue.addAll(_listLegalSteps(state: rootState, prevStep: null));

    while (queue.isNotEmpty) {
      final step = queue.removeFirst();
      if (step.state.hasWon()) {
        final result = <Move>[];
        _Step? s = step;
        while (s != null) {
          result.add(s.move);
          s = s.prevStep;
        }
        return result.reversed.toList();
      }
      final nextSteps = _listLegalSteps(state: step.state, prevStep: step);
      for (final _Step newStep in nextSteps) {
        final String gist = _snapshot(newStep.state);
        final unvisited = visited.add(gist);
        if (unvisited) {
          queue.add(newStep);
        }
      }
    }
    return [];
  }

  static String _snapshot(GameState state) {
    final List<List<int>> cells = _project(state.pieces);
    List<String> s = [];
    for (int i = 0; i < 5; i++) {
      for (int j = 0; j < 4; j++) {
        final type = cells[i][j] ~/ 10;
        s.add('$type');
      }
    }
    return s.join();
  }

  static List<List<int>> _project(List<Piece> pieces) {
    List<List<int>> cells = [
      for (int i = 0; i < 5; i++) [0, 0, 0, 0],
    ];

    for (int i = 0; i <= 9; i++) {
      final piece = pieces[i];
      int type;
      if (piece.id == 0) {
        type = 4;
      } else if (piece.id == 1) {
        type = 3;
      } else if (piece.id <= 5) {
        type = 2;
      } else {
        type = 1;
      }
      for (final loc in piece.locations) {
        cells[loc.y][loc.x] = type * 10 + piece.id;
      }
    }
    return cells;
  }

  static _listLegalSteps({required GameState state, required _Step? prevStep}) {
    final List<List<int>> cells = _project(state.pieces);
    final probableMoves = <Move>[];

    for (int i = 0; i < 5; i++) {
      for (int j = 0; j < 4; j++) {
        if (cells[i][j] == 0) {
          if (i > 0 && cells[i - 1][j] != 0) {
            final pieceId = cells[i - 1][j] % 10;
            probableMoves.add(Move(pieceId, 0, 1));
          }
          if (i < 5 - 1 && cells[i + 1][j] != 0) {
            final pieceId = cells[i + 1][j] % 10;
            probableMoves.add(Move(pieceId, 0, -1));
          }
          if (j > 0 && cells[i][j - 1] != 0) {
            final pieceId = cells[i][j - 1] % 10;
            probableMoves.add(Move(pieceId, 1, 0));
          }
          if (j < 4 - 1 && cells[i][j + 1] != 0) {
            final pieceId = cells[i][j + 1] % 10;
            probableMoves.add(Move(pieceId, -1, 0));
          }
        }
      }
    }

    final legalSteps = <_Step>[];
    for (final move in probableMoves) {
      final piece = state.pieces[move.pieceId];
      assert(piece.id == move.pieceId);
      if (!state.canMove(piece, move.x, move.y)) continue;
      final newState = state.copyWith(
        pieces: List.generate(10, (i) {
          if (i != piece.id) return state.pieces[i];
          return state.pieces[i].copyWith(
            x: piece.x + move.x,
            y: piece.y + move.y,
          );
        }),
      );
      legalSteps.add(_Step(prevStep, move, newState));
    }
    return legalSteps;
  }
}

class _Step {
  final _Step? prevStep;
  final Move move;
  final GameState state;

  _Step(this.prevStep, this.move, this.state);
}

class Move {
  final int pieceId;
  final int x;
  final int y;

  Move(this.pieceId, this.x, this.y);

  Move.fromJson(Map<String, dynamic> json)
      : pieceId = json['pieceId'] as int,
        x = json['x'] as int,
        y = json['y'] as int;

  Map<String, dynamic> toJson() => {
        'pieceId': pieceId,
        'x': x,
        'y': y,
      };
}
