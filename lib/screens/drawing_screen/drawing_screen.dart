import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:after_layout/after_layout.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

import 'package:exquisitecorpse/game_state.dart';
import 'package:exquisitecorpse/painters.dart';
import 'package:exquisitecorpse/drawing_storage.dart';
import 'package:exquisitecorpse/models.dart';
import 'package:exquisitecorpse/db.dart';
import 'package:exquisitecorpse/screens/drawing_screen/drawing_controls.dart';
import 'package:exquisitecorpse/screens/drawing_screen/overlap_dashed_lines.dart';

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

              GameRoom room = snapshot.data;

              if (room.allTopDrawingsDone() && !room.allMidDrawingsDone()) {
                print('fetching top drawing');
                drawingState.otherPlayerDrawing = DrawingStorage.fromJson(jsonDecode(room.topDrawings[_drawingIndex(room)]), true);
              } else if (room.allTopDrawingsDone() && room.allMidDrawingsDone()) {
                print('fetching mid drawing');
                drawingState.otherPlayerDrawing = DrawingStorage.fromJson(jsonDecode(room.midDrawings[_drawingIndex(room)]), true);
              }

              return Provider<GameRoom>.value(
                value: room,
                child: Stack(
                  alignment: AlignmentDirectional.bottomStart,
                  children: <Widget>[
                    Center(
                      child: DrawingCanvas(),
                    ),
                    DrawingControls(),
                    if (drawingState.loadingHandIn)
                      Center(
                        child: CircularProgressIndicator(),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

int _drawingIndex(GameRoom room) {
  int index;

  /// Fetch the top or middle drawing of another player
  /// TODO: You could change so that player 1 fetches from player 2 etc, this could be randomly chosen at the start of the game maybe?
  /// So that, if you join in the same order in a new game, you might not get to continue drawing the same persons drawing again...
  if (room.allTopDrawingsDone()) {
    switch (room.player) {
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
        assert(true, 'player was not 1,2 or 3...');
    }
  }

  assert(index != null, 'index is null');
  return index;
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
    final DrawingStorage otherPlayerDrawing = Provider.of<DrawingState>(context, listen: false).otherPlayerDrawing;

    final Size size = MediaQuery.of(context).size;

    return AspectRatio(
      key: canvasKey,
      aspectRatio: (16.0 / 9.0),
      child: Container(
        color: Color.fromRGBO(255, 250, 235, 1),
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onPanStart: (details) {
            if (_pointOutsideCanvas(details.localPosition.dx)) {
              _ignorePath = true;
              return;
            }
            myDrawing.startNewPath(details.localPosition.dx, details.localPosition.dy, myDrawing.paint, false);
            _lastPointOutOfBounds = false;
          },
          onPanUpdate: (details) {
            if (_pointOutsideCanvas(details.localPosition.dx)) {
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
          child: Stack(
            children: <Widget>[
              CustomPaint(
                painter: MyPainter(myDrawing.getPaths(), myDrawing.getPaints()),
              ),
              OverlapDashedLines(),
              if (otherPlayerDrawing != null)
                Positioned(
                  top: -size.height * (6 / 7),
                  child: Container(
                    width: size.width,
                    child: ClipRect(
                      child: CustomPaint(
                        size: Size(double.infinity, double.infinity),
                        painter: MyPainter(
                          otherPlayerDrawing.getPaths(),
                          otherPlayerDrawing.getPaints(),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// TODO: Flytta in i DrawingStorage?
  bool _pointOutsideCanvas(double dx) {
    final myDrawing = Provider.of<DrawingStorage>(context, listen: false);
    return (dx > myDrawing.width - (myDrawing.paint.strokeWidth / 2) || dx < (myDrawing.paint.strokeWidth / 2));
  }

  @override
  void afterFirstLayout(BuildContext context) {
    final myDrawing = Provider.of<DrawingStorage>(context, listen: false);
    final gameState = Provider.of<GameState>(context, listen: false);
    if (canvasKey.currentContext != null && (GameState.canvasHeight == null || GameState.canvasWidth == null)) {
      RenderBox renderBox = canvasKey.currentContext.findRenderObject();
      GameState.canvasHeight = renderBox.size.height;
      GameState.canvasWidth = renderBox.size.width;
      var result = myDrawing.updateSize();
      gameState.notify();
      assert(result, 'update size failed');
      assert(GameState.canvasHeight != null && GameState.canvasWidth != null);
    }
  }
}
