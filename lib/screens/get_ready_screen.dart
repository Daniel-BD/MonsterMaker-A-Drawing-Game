import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:exquisitecorpse/db.dart';
import 'package:exquisitecorpse/models.dart';
import 'package:exquisitecorpse/game_state.dart';

class GetReadyScreen extends StatefulWidget {
  @override
  _GetReadyScreenState createState() => _GetReadyScreenState();
}

class _GetReadyScreenState extends State<GetReadyScreen> {
  String _firstInstruction =
      "Turn your screen so you can read this! \n\n All players will draw three drawings that will be combined into three 'exquisite monsters'. First you will draw the top, then the middle and lastly the bottom part of the monster. \n\n Now let's get to it! Draw the top part! ";
  String _secondInstruction =
      "Now you will draw a middle part to continue the top drawing of another player, you will only see a small sliver of their drawing, but make sure you connect your drawings!";
  String _thirdInstruction = "Now it's time for the last drawing! Draw the bottom and finish this monster!";

  final _db = DatabaseService.instance;
  bool _allTopDrawingsDone = false;
  bool _allMidDrawingsDone = false;

  @override
  initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final GameState gameState = Provider.of<GameState>(context);

    String instruction = !_allTopDrawingsDone ? _firstInstruction : !_allMidDrawingsDone ? _secondInstruction : _thirdInstruction;

    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<GameRoom>(
          stream: _db.streamWaitingRoom(roomCode: gameState.currentRoomCode),
          builder: (context, snapshot) {
            if (snapshot.data == null) {
              return Center(
                child: CircularProgressIndicator(backgroundColor: Colors.green),
              );
            }
            _allTopDrawingsDone = snapshot.data.allTopDrawingsDone();
            _allMidDrawingsDone = snapshot.data.allMidDrawingsDone();
            assert(!snapshot.data.allBottomDrawingsDone(), "Should not be on this screen if all drawings of the game are finised!");

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width / 2,
                    child: Text(
                      instruction,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(height: 20),
                  FlatButton(
                    color: Colors.lightBlueAccent,
                    onPressed: snapshot.data.haveAlreadySubmittedDrawing()
                        ? null
                        : () {
                            Navigator.of(context).pushReplacementNamed('/drawingScreen');
                          },
                    child: Text('Start Drawing'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
