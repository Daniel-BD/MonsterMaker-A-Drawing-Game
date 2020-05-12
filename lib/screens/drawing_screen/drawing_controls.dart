import 'dart:convert';

import 'package:flutter/material.dart';
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
        if (drawingState.loadingHandIn)
          Center(
            child: CircularProgressIndicator(),
          ),
        if (!drawingState.loadingHandIn)
          Column(
            children: <Widget>[
              Wrap(
                direction: Axis.horizontal,
                alignment: WrapAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: FlatButton(
                      color: Colors.blue,
                      textColor: Colors.white,
                      child: Text((drawingState.showButtons ? 'HIDE' : 'SHOW') + ' BUTTONS'),
                      onPressed: () {
                        drawingState.showButtons = !drawingState.showButtons;
                      },
                    ),
                  ),
                  if (drawingState.showButtons) ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: FlatButton.icon(
                        color: Colors.red,
                        textColor: Colors.white,
                        label: Text("CLEAR"),
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          myDrawing.clearDrawing();
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: FlatButton.icon(
                        color: Colors.red,
                        textColor: Colors.white,
                        label: Text("UNDO"),
                        icon: Icon(Icons.undo),
                        onPressed: () {
                          myDrawing.undoLastPath();
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: FlatButton.icon(
                        color: Colors.green,
                        textColor: Colors.white,
                        label: Text("REDO"),
                        icon: Icon(Icons.redo),
                        onPressed: () {
                          myDrawing.redoLastUndonePath();
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: FlatButton.icon(
                        color: Colors.green,
                        textColor: Colors.white,
                        label: Text("SUBMIT"),
                        icon: Icon(Icons.cloud_upload),
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
                            /// Setting this property to null, since we don't want to use the drawing downloaded last anymore
                            Provider.of<OtherPlayerDrawing>(context, listen: false).drawing = null;
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
              if (drawingState.showButtons)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      color: Colors.white,
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
                    ColorPicker(),
                  ],
                ),
            ],
          ),
      ],
    );
  }
}

class ColorPicker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final myDrawing = Provider.of<DrawingStorage>(context);

    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width * 0.8,
      child: Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 16),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            _circleColor(Colors.black, context),
            _circleColor(Colors.brown[500], context),
            _circleColor(Colors.red[500], context),
            _circleColor(Colors.pink[200], context),
            _circleColor(Colors.orange[500], context),
            _circleColor(Colors.yellow[500], context),
            _circleColor(Colors.purple[500], context),
            _circleColor(Colors.blue[500], context),
            _circleColor(Colors.cyan[500], context),
            _circleColor(Colors.green[500], context),
            _circleColor(Colors.lightGreenAccent[200], context),
          ],
        ),
      ),
    );
  }

  Widget _circleColor(Color color, BuildContext context) {
    final myDrawing = Provider.of<DrawingStorage>(context, listen: false);

    return CircleColor(
      color: color,
      isSelected: color == myDrawing.paint.color,
      onColorChoose: () {
        myDrawing.paint = Paint()
          ..color = color
          ..strokeWidth = myDrawing.paint.strokeWidth
          ..strokeCap = myDrawing.paint.strokeCap
          ..strokeJoin = myDrawing.paint.strokeJoin
          ..style = myDrawing.paint.style;
      },
    );
  }
}

class CircleColor extends StatelessWidget {
  final double circleSize = 60;
  final bool isSelected;
  final Color color;
  final VoidCallback onColorChoose;

  const CircleColor({
    Key key,
    @required this.color,
    this.onColorChoose,
    this.isSelected = false,
  })  : assert(color != null, "You must provide a not null Color"),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final brightness = ThemeData.estimateBrightnessForColor(color);
    final icon = brightness == Brightness.light ? Colors.black : Colors.white;

    return GestureDetector(
      onTap: onColorChoose,
      child: Material(
        elevation: 2,
        shape: const CircleBorder(),
        child: CircleAvatar(
          radius: circleSize / 2,
          backgroundColor: color,
          child: isSelected ? Icon(Icons.check, color: icon) : null,
        ),
      ),
    );
  }
}
