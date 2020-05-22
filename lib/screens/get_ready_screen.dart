import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:exquisitecorpse/db.dart';
import 'package:exquisitecorpse/models.dart';
import 'package:exquisitecorpse/game_state.dart';
import 'package:exquisitecorpse/components/buttons.dart';
import 'package:exquisitecorpse/components/text_components.dart';
import 'package:exquisitecorpse/components/colors.dart';

class GetReadyScreen extends StatefulWidget {
  @override
  _GetReadyScreenState createState() => _GetReadyScreenState();
}

class _GetReadyScreenState extends State<GetReadyScreen> {
  String _firstInstruction =
      'Turn your phone this way! \n Everyone will make 3 drawings (top, middle, bottom parts). \n These will be stitched together to become monsters! \n The dashed lines indicates what part of your drawing will be visible to the next person when they continue the drawing.';
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

    return Scaffold(
      backgroundColor: paper,
      body: SafeArea(
        child: StreamBuilder<GameRoom>(
          stream: _db.streamWaitingRoom(roomCode: gameState.currentRoomCode),
          builder: (context, snapshot) {
            if (snapshot.data == null) {
              return Center(child: CircularProgressIndicator());
            }
            GameRoom room = snapshot.data;
            assert(!snapshot.data.allBottomDrawingsDone(), "Should not be on this screen if all drawings of the game are finised!");

            Widget instruction = !room.myTopDrawingDone()
                ? FirstInstructionText()
                : !room.myMidDrawingDone() ? SecondInstructionText() : ThirdInstructionText();

            String buttonLabel = !room.myTopDrawingDone() ? "DRAW TOP" : !room.myMidDrawingDone() ? "DRAW MIDDLE" : "DRAW BOTTOM";

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 8, right: 8, bottom: 20),
                    child: snapshot.data.haveAlreadySubmittedDrawing() ? WaitingForOtherPlayersToDrawText() : instruction,
                  ),
                  GreenGameButton(
                    label: buttonLabel,
                    onPressed: snapshot.data.haveAlreadySubmittedDrawing()
                        ? null
                        : () {
                            Navigator.of(context).pushReplacementNamed('/drawingScreen');
                          },
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
