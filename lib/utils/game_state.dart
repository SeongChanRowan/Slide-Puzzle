import 'package:flutter/foundation.dart';
import 'package:slide_puzzle/utils/level_data.dart';

class GameState {
  final int level;
  final Coordinates boardSize;

  late List<Piece> pieces;

  ValueNotifier<int> stepCounter = ValueNotifier(0);

  GameState({
    required this.level,
    required this.boardSize,
    required this.pieces,
  });

  GameState.level(this.level)
      : boardSize = const Coordinates(4, 5),
        pieces = LevelData.load(level);

  GameState copyWith({List<Piece>? pieces}) {
    return GameState(
      level: level,
      boardSize: boardSize,
      pieces: pieces ?? this.pieces,
    );
  }

  bool canMove(Piece piece, int dx, int dy) {
    final destX = piece.x + dx;
    final destY = piece.y + dy;

    if (destX < 0 ||
        destX + (piece.width - 1) >= boardSize.x ||
        destY < 0 ||
        destY + (piece.height - 1) >= boardSize.y) {
      return false;
    }

    final dest = Piece.occupies(destX, destY, piece.width, piece.height);

    List<Coordinates> others = pieces
        .where((p) => p.id != piece.id)
        .map((p) => p.locations)
        .expand((i) => i)
        .toList();

    final collision = dest.any(others.contains);

    if (collision) {
      return false;
    }

    return true;
  }

  bool hasWon() {
    final cc = pieces.singleWhere((p) => p.id == 0);
    return cc.x == 1 && cc.y == 3;
  }

  void reset() {
    stepCounter.value = 0;
    print(level);
    pieces = LevelData.load(level);
  }
}

class Piece {
  final int id;
  final int width;
  final int height;
  late ValueNotifier<Coordinates> coordinates;

  int get x => coordinates.value.x;
  int get y => coordinates.value.y;

  Piece(
    this.id, {
    required this.width,
    required this.height,
    required x,
    required y,
  }) : coordinates = ValueNotifier(Coordinates(x, y));

  Piece.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        width = json['width'],
        height = json['height'],
        coordinates = ValueNotifier(Coordinates(json['x'], json['y']));

  Piece copyWith({int? x, int? y}) => Piece(
        id,
        width: width,
        height: height,
        x: x ?? this.x,
        y: y ?? this.y,
      );

  void move(int dx, int dy) => coordinates.value = Coordinates(x + dx, y + dy);

  List<Coordinates> get locations => occupies(x, y, width, height);

  static List<Coordinates> occupies(int x, int y, int width, int height) => [
        for (int i = 0; i < width; i++)
          for (int j = 0; j < height; j++) Coordinates(x + i, y + j)
      ];

  Map<String, dynamic> toJson() => {
        'id': id,
        'width': width,
        'height': height,
        'x': x,
        'y': y,
      };
}

class Coordinates {
  final int x;
  final int y;

  const Coordinates(this.x, this.y);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Coordinates &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y;

  @override
  String toString() => 'Coordinate($x, $y)';

  @override
  int get hashCode => '$x, $y'.hashCode;
}
