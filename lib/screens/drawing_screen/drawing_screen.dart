import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:home_indicator/home_indicator.dart';

import 'package:exquisitecorpse/game_state.dart';
import 'package:exquisitecorpse/painters.dart';
import 'package:exquisitecorpse/drawing_storage.dart';
import 'package:exquisitecorpse/models.dart';
import 'package:exquisitecorpse/db.dart';
import 'package:exquisitecorpse/screens/drawing_screen/drawing_controls.dart';
import 'package:exquisitecorpse/screens/drawing_screen/overlap_dashed_lines.dart';
import 'package:exquisitecorpse/widgets/colors.dart';

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
    HomeIndicator.deferScreenEdges([ScreenEdge.bottom, ScreenEdge.top, ScreenEdge.left, ScreenEdge.right]);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    HomeIndicator.deferScreenEdges([]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final GameState gameState = Provider.of<GameState>(context);

    return Scaffold(
      backgroundColor: Colors.grey[800],
      body: SafeArea(
        bottom: false,
        top: false,
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider<DrawingControlsState>(create: (_) => DrawingControlsState()),
            ChangeNotifierProvider<DrawingStorage>(create: (_) => DrawingStorage()),
          ],
          child: StreamBuilder<GameRoom>(
            stream: _db.streamGameRoom(roomCode: gameState.currentRoomCode),
            builder: (context, snapshot) {
              if (snapshot.data == null) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

              GameRoom room = snapshot.data;

              return Provider<GameRoom>.value(
                value: room,
                child: Stack(
                  alignment: AlignmentDirectional.topStart,
                  children: <Widget>[
                    Align(
                      alignment: Alignment.centerRight,
                      child: DrawingCanvas(),
                    ),
                    DrawingControls(),
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

class DrawingCanvas extends StatefulWidget {
  DrawingCanvas({Key key}) : super(key: key);

  @override
  _DrawingCanvasState createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends State<DrawingCanvas> {
  bool _lastPointOutOfBounds = false;
  bool _ignorePath = false;
  bool _brushControlsWasShownBefore = false;

  @override
  Widget build(BuildContext context) {
    final myDrawing = Provider.of<DrawingStorage>(context);
    final room = Provider.of<GameRoom>(context);
    final DrawingControlsState controlsState = Provider.of<DrawingControlsState>(context, listen: false);
    final Size size = MediaQuery.of(context).size;
    final drawingToContinueFrom = room.getDrawingToContinueFrom();

    if (myDrawing.originalWidth == null || myDrawing.originalHeight == null) {
      final screenWidth = size.width;
      final screenHeight = size.height;

      if (screenHeight * (16 / 9) <= screenWidth) {
        myDrawing.updateOriginalSize(screenHeight, screenHeight * (16 / 9));
      } else {
        myDrawing.updateOriginalSize(screenWidth * (9 / 16), screenWidth);
      }
    }

    return AspectRatio(
      aspectRatio: (16.0 / 9.0),
      child: Container(
        color: paper,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onPanStart: (details) {
            if (_pointOutsideCanvas(details.localPosition.dx)) {
              _ignorePath = true;
              return;
            }

            _brushControlsWasShownBefore = controlsState.showBrushSettings;
            controlsState.showBrushSettings = false;

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

            if (_brushControlsWasShownBefore) {
              Future.delayed(Duration(milliseconds: 300)).then((value) {
                controlsState.showBrushSettings = _brushControlsWasShownBefore;
              });
            }

            myDrawing.endPath();
          },
          child: Stack(
            children: <Widget>[
              if (drawingToContinueFrom != null)
                Positioned(
                  top: -(myDrawing.originalHeight * (5 / 6)),
                  child: Container(
                    width: size.width,
                    child: ClipRect(
                      child: CustomPaint(
                        size: Size(size.width, size.height),
                        painter: MyPainter(
                          drawingToContinueFrom.getScaledPaths(outputHeight: myDrawing.originalHeight),
                          drawingToContinueFrom.getScaledPaints(outputHeight: myDrawing.originalHeight),
                        ),
                      ),
                    ),
                  ),
                ),
              CustomPaint(
                painter: MyPainter(
                  myDrawing.getOriginalPaths(),
                  myDrawing.getOriginalPaints(),
                ),
              ),
              OverlapDashedLines(),
            ],
          ),
        ),
      ),
    );
  }

  /// TODO: Flytta in i DrawingStorage?
  bool _pointOutsideCanvas(double dx) {
    final myDrawing = Provider.of<DrawingStorage>(context, listen: false);
    return (dx > myDrawing.originalWidth - (myDrawing.paint.strokeWidth / 2) || dx < (myDrawing.paint.strokeWidth / 2));
  }

  /*@override
  void afterFirstLayout(BuildContext context) {
    debugPrint('after first layout');
    final myDrawing = Provider.of<DrawingStorage>(context, listen: false);
    debugPrint(
        'canvasKey: ${_canvasKey.currentContext} myDrawing.origHe: ${myDrawing.originalHeight} myDrawing.origWi: ${myDrawing.originalWidth}');
    if (_canvasKey.currentContext != null && (myDrawing.originalHeight == null || myDrawing.originalWidth == null)) {
      debugPrint('update drawing size');
      RenderBox renderBox = _canvasKey.currentContext.findRenderObject();
      myDrawing.updateOriginalSize(renderBox.size.height, renderBox.size.width);
      assert(myDrawing.originalHeight != null && myDrawing.originalWidth != null);
    }
  }*/
}
