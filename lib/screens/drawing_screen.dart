import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:drawing_animation/drawing_animation.dart';
import 'package:after_layout/after_layout.dart';
import 'package:provider/provider.dart';

import 'package:exquisitecorpse/game_state.dart';
import 'package:exquisitecorpse/painters.dart';
import 'package:exquisitecorpse/drawing_storage.dart';
import 'package:exquisitecorpse/models.dart';
import 'package:exquisitecorpse/db.dart';

class DrawingScreen extends StatefulWidget {
  DrawingScreen({Key key}) : super(key: key);

  @override
  _DrawingScreenState createState() => _DrawingScreenState();
}

class _DrawingScreenState extends State<DrawingScreen> {
  final _db = DatabaseService.instance;

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
      backgroundColor: const Color.fromRGBO(180, 180, 180, 1),
      body: SafeArea(
        bottom: false,
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider<DrawingState>(create: (_) => DrawingState()),
            ChangeNotifierProvider<DrawingStorage>(create: (_) => DrawingStorage()),
          ],
          child: StreamBuilder<GameRoom>(
            stream: _db.streamWaitingRoom(roomCode: gameState.currentRoomCode),
            builder: (context, snapshot) {
              final drawingState = Provider.of<DrawingState>(context);
              final myDrawing = Provider.of<DrawingStorage>(context);

              if (snapshot.data == null) {
                return Center(
                  child: CircularProgressIndicator(backgroundColor: Colors.purple),
                );
              }

              /*if (allTopDrawingsDone) {
                drawingState.otherPlayerDrawing = DrawingStorage.fromJson(jsonDecode(snapshot.data.topDrawings[3]), true);
              } */

              return Stack(
                alignment: AlignmentDirectional.bottomStart,
                children: <Widget>[
                  Flex(
                    direction: Axis.horizontal,
                    children: <Widget>[
                      Expanded(
                        child: drawingState.showAnimationCanvas ? AnimationCanvas() : DrawingCanvas(),
                      ),
                    ],
                  ),
                  Provider<GameRoom>.value(
                    value: snapshot.data,
                    child: DrawingControls(),
                  ),
                  if (drawingState.loadingHandIn)
                    Center(
                      child: CircularProgressIndicator(),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

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

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Column(
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
            children: <Widget>[
              Row(),
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

class AnimationCanvas extends StatefulWidget {
  AnimationCanvas({Key key}) : super(key: key);

  @override
  _AnimationCanvasState createState() => _AnimationCanvasState();
}

class _AnimationCanvasState extends State<AnimationCanvas> {
  bool _runAnimation = true;

  @override
  Widget build(BuildContext context) {
    final myDrawing = Provider.of<DrawingStorage>(context);

    return AspectRatio(
      aspectRatio: 0.6,
      child: Container(
        color: Colors.grey[200],
        child: AnimatedDrawing.paths(
          myDrawing.getPaths(),
          paints: myDrawing.getPaints(),
          run: this._runAnimation,
          scaleToViewport: false,
          duration: Duration(seconds: 1),
          onFinish: () => setState(() {
            this._runAnimation = false;
          }),
        ),
      ),
    );
  }
}

class DrawingCanvas extends StatefulWidget {
  DrawingCanvas({Key key}) : super(key: key);

  @override
  _DrawingCanvasState createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends State<DrawingCanvas> with AfterLayoutMixin<DrawingCanvas> {
  final canvasKey = GlobalKey();
  bool _lastPointOutOfBounds = false;
  bool _ignorePath = false;

  @override
  Widget build(BuildContext context) {
    final myDrawing = Provider.of<DrawingStorage>(context);
    final otherPlayerDrawing = Provider.of<DrawingState>(context, listen: false).otherPlayerDrawing;

    return AspectRatio(
      key: canvasKey,
      aspectRatio: 0.6,
      child: Container(
        color: Color.fromRGBO(255, 250, 235, 1),
        child: GestureDetector(
          onPanStart: (details) {
            if (_pointOutsideCanvas(details.localPosition.dy)) {
              _ignorePath = true;
              return;
            }

            myDrawing.startNewPath(details.localPosition.dx, details.localPosition.dy, myDrawing.paint, false);
            _lastPointOutOfBounds = false;
          },
          onPanUpdate: (details) {
            if (_pointOutsideCanvas(details.localPosition.dy)) {
              _lastPointOutOfBounds = true;
              return;
            }

            myDrawing.addPoint(details.localPosition.dx, details.localPosition.dy, _lastPointOutOfBounds, false);
            _lastPointOutOfBounds = false;
          },
          onPanEnd: (details) {
            if (_ignorePath) {
              return;
            }
            myDrawing.endPath();
          },
          child: CustomPaint(
            painter: MyPainter(myDrawing.getPaths(), myDrawing.getPaints()),
          ),
        ),
      ),
    );
  }

  /// TODO: Flytta in i DrawingStorage?
  bool _pointOutsideCanvas(double dy) {
    final myDrawing = Provider.of<DrawingStorage>(context, listen: false);
    return (dy > myDrawing.height - (myDrawing.paint.strokeWidth / 2) || dy < (myDrawing.paint.strokeWidth / 2));
  }

  @override
  void afterFirstLayout(BuildContext context) {
    final myDrawing = Provider.of<DrawingStorage>(context, listen: false);
    if (canvasKey.currentContext != null && (GameState.canvasHeight == null || GameState.canvasWidth == null)) {
      RenderBox renderBox = canvasKey.currentContext.findRenderObject();
      GameState.canvasHeight = renderBox.size.height;
      GameState.canvasWidth = renderBox.size.width;
      var result = myDrawing.updateSize();
      assert(result, 'update size failed');
      assert(GameState.canvasHeight != null && GameState.canvasWidth != null);
    }
  }
}
