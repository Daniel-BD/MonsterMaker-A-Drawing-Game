import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import 'dart:convert';

import 'package:exquisitecorpse/db.dart';
import 'drawing_storage.dart';

class MonsterDrawing {
  MonsterDrawing(this.top, this.middle, this.bottom);

  final DrawingStorage top;
  final DrawingStorage middle;
  final DrawingStorage bottom;
}

class GameRoom {
  GameRoom({
    @required this.roomCode,
    @required this.activePlayers,
    @required this.startedGame,
    @required this.isHost,
    @required this.playerIndex,
    @required this.startAnimation,
    @required this.animateAllAtOnce,
    @required this.monsterIndex,
    @required this.topDrawings,
    @required this.midDrawings,
    @required this.bottomDrawings,
    @required this.monsterSharingAgreements,
    this.monsterDrawings,
  })  : assert(roomCode != null),
        assert(activePlayers != null),
        assert(isHost != null),
        assert(startedGame != null),
        assert(playerIndex != null),
        assert(startAnimation != null),
        assert(animateAllAtOnce != null),
        assert(monsterIndex == 1 || monsterIndex == 2 || monsterIndex == 3),
        assert(topDrawings != null),
        assert(midDrawings != null),
        assert(bottomDrawings != null),
        assert(monsterSharingAgreements.length == 3),
        assert(monsterDrawings != null && monsterDrawings.length == 3 || monsterDrawings == null);

  /// The room code of the room
  final String roomCode;

  /// How many players are currently in the room
  final int activePlayers;

  /// Weather the current player is the host of this room or not
  final bool isHost;

  /// Weather the game has begun or is still waiting for host to start
  final bool startedGame;

  /// The player number the current player has, where 1 means first player, 2 means second player etc
  final int playerIndex;

  /// Weather to start the animation of the monster on the finished screen. Controlled by the room host.
  final bool startAnimation;

  /// Weather to animate all three drawings at once, or one at a time (top to bottom).
  final bool animateAllAtOnce;

  /// What monster to show on the finished screen. Controlled by the room host.
  final int monsterIndex;

  /// Maps of the drawings done so far. The player number is the key, the string is the drawing in json.
  final Map<int, String> topDrawings;
  final Map<int, String> midDrawings;
  final Map<int, String> bottomDrawings;

  /// List of maps of what users have agreed (or not) to share what monster drawings to the monster gallery.
  /// The map at index 0 is monster 1, index 1 is monster 2, etc.
  /// The map for each monster looks like this (example): {Player1 : true, Player 2 : false}, note that Player 3 isn't in the map, since
  /// player 3 hasn't responded yet.
  final List<Map<String, dynamic>> monsterSharingAgreements;

  /// A list of [MonsterDrawing] representation of alla drawings, index 0 is monster 1 etc, index 1 is monster 2 etc.
  final List<MonsterDrawing> monsterDrawings;

  /// A [MonsterDrawing] representation of the current monster according to [monsterIndex].
  MonsterDrawing currentMonsterDrawing() {
    if (monsterDrawings == null || monsterDrawings.length < monsterIndex - 1) {
      assert(false, 'monsterDrawings is null when it should not be!');
      return null;
    }

    return monsterDrawings[monsterIndex - 1];
  }

  bool allTopDrawingsDone() => topDrawings.length == 3;
  bool allMidDrawingsDone() => midDrawings.length == 3;
  bool allBottomDrawingsDone() => bottomDrawings.length == 3;

  bool myTopDrawingDone() => topDrawings[playerIndex] != null;
  bool myMidDrawingDone() => midDrawings[playerIndex] != null;
  bool myBottomDrawingDone() => bottomDrawings[playerIndex] != null;

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

  DrawingStorage getDrawingToContinueFrom() {
    debugPrint('Running getDrawingToContinueFrom in GameRoom in models.dart');
    //assert(allTopDrawingsDone(), 'All top drawings need to be done before this is accessed.');

    if (allTopDrawingsDone() && !allMidDrawingsDone()) {
      return DrawingStorage.fromJson(jsonDecode(topDrawings[_drawingIndex(playerIndex)]));
    } else if (allTopDrawingsDone() && allMidDrawingsDone()) {
      return DrawingStorage.fromJson(jsonDecode(midDrawings[_drawingIndex(playerIndex)]));
    } else {
      return null;
    }
  }

  /// Returns null if there's no prompt to show, otherwise returns an int with the index (int) and name (String) of the monster
  /// that the users needs to agree or not agree to share.
  Tuple2<int, String> showAgreeToShareMonsterPrompt() {
    for (int i = 1; i < 4; i++) {
      final monster = monsterSharingAgreements[i - 1];
      if (monster == null || monster.isEmpty || monster.containsKey('Player$playerIndex')) {
      } else if (monster.containsKey(monsterName)) {
        return Tuple2(i, monster[monsterName]);
      }
    }
    return null;
  }

  @override
  String toString() {
    return 'Room Code: $roomCode, active players: $activePlayers, game has started: $startedGame, current player is host: $isHost, player: $playerIndex, startAnimation: $startAnimation, animateAllAtOnce: $animateAllAtOnce, monsterIndex: $monsterIndex';
  }
}

int _drawingIndex(int playerIndex) {
  assert(playerIndex >= 1 && playerIndex <= 3);
  int index;

  switch (playerIndex) {
    case 1:
      index = 3;
      break;
    case 2:
      index = 1;
      break;
    case 3:
      index = 2;
      break;
    default:
      assert(false, 'player was not 1, 2 or 3...');
  }

  assert(index != null, 'index is null');
  return index;
}
