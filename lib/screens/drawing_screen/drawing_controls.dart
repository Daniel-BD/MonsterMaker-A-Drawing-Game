import 'dart:convert';

import 'package:exquisitecorpse/widgets/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';

import 'package:exquisitecorpse/game_state.dart';
import 'package:exquisitecorpse/drawing_storage.dart';
import 'package:exquisitecorpse/models.dart';
import 'package:exquisitecorpse/db.dart';

import 'package:exquisitecorpse/widgets/buttons.dart';
import 'package:exquisitecorpse/widgets/color_picker.dart';
import 'package:exquisitecorpse/widgets/brush_size_slider.dart';
import 'package:exquisitecorpse/widgets/modal_message.dart';

class DrawingControls extends StatefulWidget {
  DrawingControls({Key key}) : super(key: key);

  @override
  _DrawingControlsState createState() => _DrawingControlsState();
}

class _DrawingControlsState extends State<DrawingControls> {
  @override
  void initState() {
    super.initState();
    final myDrawing = Provider.of<DrawingStorage>(context, listen: false);
    final i = Random().nextInt(brushColors.length);
    myDrawing.paint = Paint()
      ..color = brushColors[i]
      ..strokeWidth = myDrawing.paint.strokeWidth
      ..strokeCap = myDrawing.paint.strokeCap
      ..strokeJoin = myDrawing.paint.strokeJoin
      ..style = myDrawing.paint.style;
  }

  @override
  Widget build(BuildContext context) {
    final drawingState = Provider.of<DrawingState>(context);
    final myDrawing = Provider.of<DrawingStorage>(context);

    return Stack(
      children: <Widget>[
        if (drawingState.loadingHandIn)
          Center(
            child: CircularProgressIndicator(),
          ),
        if (!drawingState.loadingHandIn)
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Column(
                  mainAxisAlignment: drawingState.showButtons ? MainAxisAlignment.center : MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(height: 10),
                    HideShowControlsButton(
                      onPressed: () => drawingState.showButtons = !drawingState.showButtons,
                      controlsVisible: drawingState.showButtons,
                    ),
                    Visibility(
                      visible: drawingState.showButtons,
                      maintainSize: true,
                      maintainAnimation: true,
                      maintainState: true,
                      child: Column(
                        children: <Widget>[
                          Container(height: 10),
                          BrushButton(
                            onPressed: () => drawingState.showBrushSettings = !drawingState.showBrushSettings,
                            color: myDrawing.paint.color,
                          ),
                          Container(height: 10),
                          UndoButton(
                            onPressed: () => myDrawing.undoLastPath(),
                          ),
                          Container(height: 10),
                          RedoButton(
                            onPressed: () => myDrawing.redoLastUndonePath(),
                          ),
                          Container(height: 10),
                          DeleteButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => ClearDrawingGameModal(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    myDrawing.clearDrawing();
                                  },
                                ),
                              );
                            },
                          ),
                          Container(height: 10),
                          DoneButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => DoneDrawingGameModal(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    _submitDrawing();
                                  },
                                ),
                              );
                            },
                          ),
                          Container(height: 10),
                        ],
                      ),
                    ),
                  ],
                ),
                if (drawingState.showBrushSettings)
                  Expanded(
                    child: BrushControls(),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  void _submitDrawing() async {
    final String roomCode = Provider.of<GameState>(context, listen: false).currentRoomCode;
    final gameRoom = Provider.of<GameRoom>(context, listen: false);
    final drawingState = Provider.of<DrawingState>(context, listen: false);
    final myDrawing = Provider.of<DrawingStorage>(context, listen: false);

    if (myDrawing.getPaths().isEmpty) {
      /// TODO: Felmeddelande om man försöker lämna in en tom ritning
      return;
    }
    final db = DatabaseService.instance;
    drawingState.loadingHandIn = true;
    var success = await db.handInDrawing(roomCode: roomCode, drawing: jsonEncode(myDrawing.toJson()));
    var retries = 0;

    /// Doing 10 retries when handing in drawing fails
    while (!success) {
      if (retries > 10) {
        break;
      }
      await Future.delayed(Duration(milliseconds: 400));
      success = await db.handInDrawing(roomCode: roomCode, drawing: jsonEncode(myDrawing.toJson()));
      retries++;
    }
    assert(success, 'Could not hand in drawing!');

    /// TODO: Felmeddelande om man det misslyckas...
    drawingState.loadingHandIn = false;
    if (success) {
      /// Setting this property to null, since we don't want to use the drawing downloaded last anymore
      Provider.of<OtherPlayerDrawing>(context, listen: false).drawing = null;
      if (gameRoom.allMidDrawingsDone()) {
        Navigator.of(context).pushReplacementNamed('/finishedScreen');
      } else {
        myDrawing.clearDrawing();
        Navigator.of(context).pushReplacementNamed('/getReadyScreen');
      }
    }
  }
}

class BrushControls extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final myDrawing = Provider.of<DrawingStorage>(context);

    return Padding(
      padding: EdgeInsets.only(left: 20, top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: GameColorPicker(
              onTap: (color) {
                myDrawing.paint = Paint()
                  ..color = color
                  ..strokeWidth = myDrawing.paint.strokeWidth
                  ..strokeCap = myDrawing.paint.strokeCap
                  ..strokeJoin = myDrawing.paint.strokeJoin
                  ..style = myDrawing.paint.style;
              },
            ),
          ),
          Row(
            children: <Widget>[
              BrushSizeSlider(),
            ],
          ),
        ],
      ),
    );
  }
}
