import 'package:drawing_animation/drawing_animation.dart';
import 'package:exquisitecorpse/widgets/buttons.dart';
import 'package:exquisitecorpse/widgets/color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'db.dart';
import 'models.dart';
import 'game_state.dart';
import 'route_generator.dart';
import 'widgets/colors.dart';
import 'drawing_storage.dart';
import 'painters.dart';

class StateHolder {
  static DrawingStorage myDrawing = DrawingStorage();
  static final DrawingState controlsState = DrawingState();
  static bool animate = false;
  static VoidCallback play;
}

class TestApp extends StatefulWidget {
  @override
  _TestAppState createState() => _TestAppState();
}

class _TestAppState extends State<TestApp> {
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
    return MaterialApp(
      title: 'MonsterMaker',
      debugShowCheckedModeBanner: false,
      home: DrawingCanvasTest(),
    );
  }
}

class DrawingCanvasTest extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: paper,
      body: Row(
        children: [
          SizedBox(
            width: screenWidth / 2,
            height: screenHeight,
            child: TestDrawingScreen(),
          ),
          SizedBox(
            width: screenWidth / 2,
            height: screenHeight,
            child: TestAnimatedPath(),
          ),
        ],
      ),
    );
  }
}

class TestDrawingScreen extends StatefulWidget {
  TestDrawingScreen({Key key}) : super(key: key);

  @override
  _TestDrawingScreenState createState() => _TestDrawingScreenState();
}

class _TestDrawingScreenState extends State<TestDrawingScreen> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      color: Colors.blue,
      child: Stack(
        alignment: AlignmentDirectional.topStart,
        children: <Widget>[
          SizedBox(
            width: screenWidth / 2,
            height: screenHeight,
            child: Container(
              child: TestDrawingCanvas(),
              color: Colors.orange,
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: screenWidth / 2,
              height: screenHeight,
              child: Container(
                child: DrawingControls(),
                //color: Colors.pink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TestDrawingCanvas extends StatefulWidget {
  TestDrawingCanvas({Key key}) : super(key: key);

  @override
  _TestDrawingCanvasState createState() => _TestDrawingCanvasState();
}

class _TestDrawingCanvasState extends State<TestDrawingCanvas> {
  bool _lastPointOutOfBounds = false;
  bool _ignorePath = false;
  bool _brushControlsWasShownBefore = false;

  @override
  Widget build(BuildContext context) {
    final DrawingStorage myDrawing = StateHolder.myDrawing;
    final DrawingState controlsState = StateHolder.controlsState;
    final screenWidth = MediaQuery.of(context).size.width / 2;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      color: paper,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanStart: (details) {
          _brushControlsWasShownBefore = controlsState.showBrushSettings;
          controlsState.showBrushSettings = false;

          myDrawing.startNewPath(details.localPosition.dx, details.localPosition.dy, myDrawing.paint, false);
          _lastPointOutOfBounds = false;
          setState(() {});
        },
        onPanUpdate: (details) {
          myDrawing.addPoint(details.localPosition.dx, details.localPosition.dy, _lastPointOutOfBounds, false);
          _lastPointOutOfBounds = false;
          setState(() {});
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
          setState(() {});
        },
        child: Stack(
          children: <Widget>[
            CustomPaint(
              painter: MyPainter(
                myDrawing.getScaledPaths(
                  inputHeight: screenHeight,
                  outputHeight: screenHeight,
                  inputWidth: screenWidth,
                  outputWidth: screenWidth,
                ),
                myDrawing.getScaledPaints(
                  inputHeight: screenHeight,
                  outputHeight: screenHeight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DrawingControls extends StatefulWidget {
  DrawingControls({Key key}) : super(key: key);

  @override
  _DrawingControlsState createState() => _DrawingControlsState();
}

class _DrawingControlsState extends State<DrawingControls> {
  @override
  void initState() {
    super.initState();
    final myDrawing = StateHolder.myDrawing;
    final i = 1;
    myDrawing.paint = Paint()
      ..color = brushColors[i]
      ..strokeWidth = myDrawing.paint.strokeWidth
      ..strokeCap = myDrawing.paint.strokeCap
      ..strokeJoin = myDrawing.paint.strokeJoin
      ..style = myDrawing.paint.style;
  }

  @override
  Widget build(BuildContext context) {
    final drawingState = StateHolder.controlsState;
    final myDrawing = StateHolder.myDrawing;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Column(
          mainAxisAlignment: drawingState.showButtons ? MainAxisAlignment.center : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(height: 10),
            HideShowControlsButton(
              onPressed: () {
                drawingState.showButtons = !drawingState.showButtons;
                setState(() {});
              },
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
                    onPressed: () {
                      drawingState.showBrushSettings = !drawingState.showBrushSettings;
                      setState(() {});
                    },
                    color: myDrawing.paint.color,
                  ),
                  Container(height: 10),
                  UndoButton(
                    onPressed: () {
                      myDrawing.undoLastPath();
                      setState(() {});
                    },
                  ),
                  Container(height: 10),
                  RedoButton(
                    onPressed: () {
                      myDrawing.redoLastUndonePath();
                      setState(() {});
                    },
                  ),
                  Container(height: 10),
                  DeleteButton(
                    onPressed: () {
                      myDrawing.clearDrawing();
                      setState(() {});
                    },
                  ),
                  Container(height: 10),
                  SizedBox(
                    height: 40,
                    width: 40,
                    child: FittedBox(
                      child: PlayButton(
                        onPressed: () {
                          StateHolder.animate = true;
                          StateHolder.play();
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                  Container(height: 10),
                  SizedBox(
                    height: 40,
                    width: 40,
                    child: FittedBox(
                      child: StopButton(
                        onPressed: () {
                          DatabaseService.instance.getMonsterFromRoomCode('BQCZ', 1).then((value) {
                            debugPrint('Fetched Monster');
                            StateHolder.myDrawing = value.top;
                            setState(() {});
                          });
                        },
                      ),
                    ),
                  ),
                  Container(height: 10),
                  SizedBox(
                    height: 40,
                    width: 40,
                    child: FittedBox(
                      child: PreviousButton(
                        onPressed: () {
                          final jsonMonster = StateHolder.myDrawing.toJson();
                          debugPrint('JsonMonster: ${jsonMonster}');
                        },
                      ),
                    ),
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
    );
  }
}

/*
_db.getMonsterFromRoomCode('BQCZ', 1).then((value) {
      drawing = value;
      setState(() {});
    });
 */

class BrushControls extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final myDrawing = StateHolder.myDrawing;

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

class BrushSizeSlider extends StatefulWidget {
  @override
  _BrushSizeSliderState createState() => _BrushSizeSliderState();
}

class _BrushSizeSliderState extends State<BrushSizeSlider> {
  @override
  Widget build(BuildContext context) {
    final myDrawing = StateHolder.myDrawing;
    double paintSize = myDrawing.paint.strokeWidth;

    return RotatedBox(
      quarterTurns: 0,
      child: Container(
        height: 60,
        //width: 234,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: <Widget>[
            Container(width: 30),
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: Colors.white,
                inactiveTrackColor: Colors.white.withOpacity(0.25),
                overlayShape: RoundSliderOverlayShape(overlayRadius: 0.0),
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 16.0),
                thumbColor: Colors.white,
              ),
              child: Slider(
                min: 5,
                max: 40,
                onChanged: (value) {
                  setState(
                    () {
                      myDrawing.paint = Paint()
                        ..color = myDrawing.paint.color
                        ..strokeWidth = num.parse(value.toStringAsFixed(4))
                        ..strokeCap = myDrawing.paint.strokeCap
                        ..strokeJoin = myDrawing.paint.strokeJoin
                        ..style = myDrawing.paint.style;
                    },
                  );
                },
                value: myDrawing.paint.strokeWidth,
              ),
            ),
            Container(
              height: 40,
              width: 40,
              child: Center(
                child: Container(
                  height: paintSize,
                  width: paintSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: myDrawing.paint.color,
                  ),
                ),
              ),
            ),
            Container(width: 10),
          ],
        ),
      ),
    );
  }
}

class TestAnimatedPath extends StatefulWidget {
  @override
  _TestAnimatedPathState createState() => _TestAnimatedPathState();
}

class _TestAnimatedPathState extends State<TestAnimatedPath> {
  @override
  void initState() {
    super.initState();
    StateHolder.play = () => setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final DrawingStorage myDrawing = StateHolder.myDrawing;
    final screenWidth = MediaQuery.of(context).size.width / 2;
    final screenHeight = MediaQuery.of(context).size.height;

    return AnimatedDrawing.paths(
      myDrawing.getScaledPaths(
        inputHeight: screenHeight,
        outputHeight: screenHeight,
        inputWidth: screenWidth,
        outputWidth: screenWidth,
      ),
      paints: myDrawing.getScaledPaints(
        inputHeight: screenHeight,
        outputHeight: screenHeight,
      ),
      run: StateHolder.animate,
      animationOrder: PathOrders.topToBottom,
      scaleToViewport: false,
      duration: Duration(milliseconds: 2000),
      onFinish: () => setState(() {
        StateHolder.animate = false;
      }),
    );
  }
}
