import 'package:flutter/material.dart';

class WaitingRoom {
  WaitingRoom({
    @required this.roomCode,
    @required this.activePlayers,
    @required this.startedGame,
    @required this.isHost,
  })  : assert(roomCode != null),
        assert(activePlayers != null),
        assert(isHost != null),
        assert(startedGame != null);

  final String roomCode;
  final int activePlayers;
  final bool isHost;
  final bool startedGame;
}
