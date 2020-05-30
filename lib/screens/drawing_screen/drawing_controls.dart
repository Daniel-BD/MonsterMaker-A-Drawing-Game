import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:exquisitecorpse/game_state.dart';
import 'package:exquisitecorpse/drawing_storage.dart';
import 'package:exquisitecorpse/models.dart';
import 'package:exquisitecorpse/db.dart';

import 'package:exquisitecorpse/components/buttons.dart';
import 'package:exquisitecorpse/components/color_picker.dart';
import 'package:exquisitecorpse/components/brush_size_slider.dart';
import 'package:exquisitecorpse/components/modal_message.dart';

/// This widget is messy by design, it's temporary and will be redesigned later on
class DrawingControls extends StatefulWidget {
  DrawingControls({Key key}) : super(key: key);

  @override
  _DrawingControlsState createState() => _DrawingControlsState();
}

class _DrawingControlsState extends State<DrawingControls> {
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
                FittedBox(
                  child: Column(
                    mainAxisAlignment: drawingState.showButtons ? MainAxisAlignment.center : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(height: 10),
                      HideShowControlsButton(
                        onPressed: () => drawingState.showButtons = !drawingState.showButtons,
                        controlsVisible: drawingState.showButtons,
                      ),
                      if (drawingState.showButtons) ...[
                        Container(height: 10),
                        BrushButton(
                          onPressed: () => drawingState.showBrushSettings = !drawingState.showBrushSettings,
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
                    ],
                  ),
                ),
                if (drawingState.showBrushSettings) BrushControls(),
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
    final Size size = MediaQuery.of(context).size;
    final myDrawing = Provider.of<DrawingStorage>(context);

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          GameColorPicker(
            onTap: (color) {
              myDrawing.paint = Paint()
                ..color = color
                ..strokeWidth = myDrawing.paint.strokeWidth
                ..strokeCap = myDrawing.paint.strokeCap
                ..strokeJoin = myDrawing.paint.strokeJoin
                ..style = myDrawing.paint.style;
            },
          ),
          Padding(
            padding: EdgeInsets.only(left: 20 + ((size.height - 70) / 6) / 4),
            child: BrushSizeSlider(),
          ),
        ],
      ),
    );
  }
}
