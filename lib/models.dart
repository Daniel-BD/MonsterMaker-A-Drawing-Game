import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

class GameRoom {
  GameRoom({
    @required this.roomCode,
    @required this.activePlayers,
    @required this.startedGame,
    @required this.isHost,
    @required this.player,
    //@required this.drawings,
    @required this.topDrawings,
    @required this.midDrawings,
    @required this.bottomDrawings,
  })  : assert(roomCode != null),
        assert(activePlayers != null),
        assert(isHost != null),
        assert(startedGame != null),
        assert(player != null),
        assert(topDrawings != null),
        assert(midDrawings != null),
        assert(bottomDrawings != null);
  //assert(drawings != null);

  /// The room code of the room
  final String roomCode;

  /// How many players are currently in the room
  final int activePlayers;

  /// Weather the current player is the host of this room or not
  final bool isHost;

  /// Weather the game has begun or is still waiting for host to start
  final bool startedGame;

  /// The player number the current player has, where 1 means first player, 2 means second player etc
  final int player;

  /// A list of the drawings done in the game so far. The outer list holds 'top', 'mid', 'bottom' drawings, and should only be between 0-3 long.
  /// The inner list holds the drawings withing each part (top, mid, bottom), where item1 (int) is the players number and item2 (String) is the drawing info.
  //final List<List<Tuple2<int, String>>> drawings;

  final Map<int, String> topDrawings;
  final Map<int, String> midDrawings;
  final Map<int, String> bottomDrawings;

  bool allTopDrawingsDone() => topDrawings.length == 3;
  bool allMidDrawingsDone() => midDrawings.length == 3;
  bool allBottomDrawingsDone() => bottomDrawings.length == 3;

  bool myTopDrawingDone() => topDrawings[player] != null;
  bool myMidDrawingDone() => midDrawings[player] != null;
  bool myBottomDrawingDone() => bottomDrawings[player] != null;

  /// Returns true if the current player has already submitted a drawing in the current phase (top, mid, bottom).
  /// [phase] is expected to be 0, 1 or 2 to represent top, mid, bottom respectively.
  bool haveAlreadySubmittedDrawing() {
    if (!allTopDrawingsDone() && !myTopDrawingDone()) {
      return false;
    } else if (allTopDrawingsDone() && !allMidDrawingsDone() && !myMidDrawingDone()) {
      return false;
    }
    if (allTopDrawingsDone() && allMidDrawingsDone() && !allBottomDrawingsDone() && !myBottomDrawingDone()) {
      return false;
    }

    return true;
  }

  @override
  String toString() {
    return 'Room Code: $roomCode, active players: $activePlayers, game has started: $startedGame, current player is host: $isHost, player: $player';
  }
}
