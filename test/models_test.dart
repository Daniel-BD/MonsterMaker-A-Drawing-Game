//import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:exquisitecorpse/models.dart';

void main() {
  group('GameRoom', () {
    GameRoom gameRoom = GameRoom(
      roomCode: 'ABCD',
      activePlayers: 3,
      startedGame: true,
      isHost: true,
      playerIndex: 1,
      startAnimation: false,
      animateAllAtOnce: false,
      monsterIndex: 1,
      topDrawings: {},
      midDrawings: {},
      bottomDrawings: {},
    );

    test('allTopDrawingsDone() should return false', () {
      expect(gameRoom.allTopDrawingsDone(), false);
    });

    test('allMidDrawingsDone() should return false', () {
      expect(gameRoom.allMidDrawingsDone(), false);
    });

    test('allBottomDrawingsDone() should return false', () {
      expect(gameRoom.allBottomDrawingsDone(), false);
    });

    test('myTopDrawingDone() should return false', () {
      expect(gameRoom.myTopDrawingDone(), false);
    });

    test('myMidDrawingDone() should return false', () {
      expect(gameRoom.myMidDrawingDone(), false);
    });

    test('myBottomDrawingDone() should return false', () {
      expect(gameRoom.myBottomDrawingDone(), false);
    });

    test('haveAlreadySubmittedDrawing() should return false', () {
      expect(gameRoom.haveAlreadySubmittedDrawing(), false);
    });

    /*gameRoom = GameRoom(
      roomCode: 'ABCD',
      activePlayers: 3,
      startedGame: true,
      isHost: true,
      player: 1,
      startAnimation: false,
      animateAllAtOnce: false,
      monsterIndex: 1,
      topDrawings: {1: '{"replace with real data"}', 2: '{"replace with real data"}', 3: '{"replace with real data"}'},
      midDrawings: {},
      bottomDrawings: {},
    );*/

    /*

    test('haveAlreadySubmittedDrawing() should return true', () {
      expect(gameRoom.haveAlreadySubmittedDrawing(), true);
    });

    */
  });
}
