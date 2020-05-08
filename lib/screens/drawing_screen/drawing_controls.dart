import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:provider/provider.dart';

import 'package:exquisitecorpse/game_state.dart';
import 'package:exquisitecorpse/drawing_storage.dart';
import 'package:exquisitecorpse/models.dart';
import 'package:exquisitecorpse/db.dart';

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
    final String roomCode = Provider.of<GameState>(context).currentRoomCode;
    final gameRoom = Provider.of<GameRoom>(context);

    return Stack(
      children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Row(),
            Wrap(
              direction: Axis.horizontal,
              alignment: WrapAlignment.start,
              children: <Widget>[
                FlatButton(
                  color: Colors.purpleAccent,
                  child: Text((drawingState.showButtons ? 'hide' : 'show') + ' buttons'),
                  onPressed: () {
                    drawingState.showButtons = !drawingState.showButtons;
                  },
                ),
                if (drawingState.showButtons) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: FlatButton(
                      color: Colors.redAccent,
                      child: Text("CLEAR"),
                      onPressed: () {
                        myDrawing.clearDrawing();
                        drawingState.showAnimationCanvas = false;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: FlatButton(
                      color: Colors.deepOrange,
                      child: Text("UNDO"),
                      onPressed: () {
                        myDrawing.undoLastPath();
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: FlatButton(
                      color: Colors.greenAccent,
                      child: Text("REDO"),
                      onPressed: () {
                        myDrawing.redoLastUndonePath();
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: FlatButton(
                      color: Colors.blue,
                      child: Text("SWITCH"),
                      onPressed: () {
                        if (myDrawing.getPaths().isEmpty) {
                          return;
                        }
                        drawingState.showAnimationCanvas = !drawingState.showAnimationCanvas;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: FlatButton(
                      color: Colors.green,
                      child: Text("DONE"),
                      onPressed: () async {
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
                          if (gameRoom.allMidDrawingsDone()) {
                            Navigator.of(context).pushReplacementNamed('/finishedScreen');
                          } else {
                            myDrawing.clearDrawing();
                            Navigator.of(context).pushReplacementNamed('/getReadyScreen');
                          }
                        }
                      },
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        if (drawingState.showButtons)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                color: Colors.lightGreen.withOpacity(0.5),
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Container(height: 10, width: 10),
                          IconButton(
                            iconSize: 40,
                            icon: Icon(Icons.add_circle_outline),
                            onPressed: () {
                              if (myDrawing.paint.strokeWidth > 40) {
                                return;
                              }

                              myDrawing.paint = Paint()
                                ..color = myDrawing.paint.color
                                ..strokeWidth = myDrawing.paint.strokeWidth + 4
                                ..strokeCap = StrokeCap.round
                                ..strokeJoin = StrokeJoin.round
                                ..style = PaintingStyle.stroke;
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10, bottom: 10),
                            child: Container(
                              width: myDrawing.paint.strokeWidth,
                              height: myDrawing.paint.strokeWidth,
                              decoration: BoxDecoration(
                                color: myDrawing.paint.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          IconButton(
                            iconSize: 40,
                            icon: Icon(Icons.remove_circle_outline),
                            onPressed: () {
                              if (myDrawing.paint.strokeWidth < 8) {
                                return;
                              }
                              myDrawing.paint = Paint()
                                ..color = myDrawing.paint.color
                                ..strokeWidth = myDrawing.paint.strokeWidth - 4
                                ..strokeCap = StrokeCap.round
                                ..strokeJoin = StrokeJoin.round
                                ..style = PaintingStyle.stroke;
                            },
                          ),
                          Container(height: 10, width: 10),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
