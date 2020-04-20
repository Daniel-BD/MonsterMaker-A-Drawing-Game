import 'package:flutter/material.dart';
//import 'dart:ui' as ui;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:drawing_animation/drawing_animation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'painters.dart';
import 'drawing_storage.dart';
import 'dart:math' as math;
//print('IN CANVAS 6. ${_drawingStorage.paths.length}, ${_drawingStorage.paints.length}');
//print("PAN UPDATE: global pos: ${details.globalPosition}, local pos: ${details.localPosition}");
//print("${paths.last. .toString()}");

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drawing Game',
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GlobalKey _canvasKey = GlobalKey();
  GlobalKey _smallCanvasKey = GlobalKey();

  bool _needToCalculateSize = false;
  bool _hasCalculatedSize = false;
  double _canvasDY = 0;
  bool _runAnimation = true;
  bool _showAnimationCanvas = false;
  bool _lastPointOutOfBounds = false;

  DrawingStorage _drawingStorage = DrawingStorage();

  Paint _paint = Paint()
    ..color = Colors.black
    ..strokeWidth = 12
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..style = PaintingStyle.stroke;

  @override
  initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    if (_needToCalculateSize && !_hasCalculatedSize) {
      RenderBox renderBox = _canvasKey.currentContext.findRenderObject();
      _canvasDY = renderBox.size.height - 2;
      _hasCalculatedSize = true;

      print('Size: ${renderBox.size.toString()}');

      renderBox = _smallCanvasKey.currentContext.findRenderObject();
      print('Size: ${renderBox.size.toString()}');
    }

    return Scaffold(
      backgroundColor: Color.fromRGBO(180, 180, 180, 1),
      body: SafeArea(
        child: Stack(
          alignment: AlignmentDirectional.bottomStart,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                _showAnimationCanvas ? _animationCanvas() : _drawingCanvas(),
                _smallerCanvas(),
              ],
            ),
            _buttons(),
            Container(
              color: Colors.lightGreen.withOpacity(0.5),
              child: Padding(
                padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    _thicknessButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _thicknessButton() {
    return Column(
      children: <Widget>[
        Container(height: 10, width: 10),
        Transform.rotate(
          angle: math.pi / 2,
          child: IconButton(
            iconSize: 40,
            icon: Icon(Icons.add_circle_outline),
            onPressed: () {
              if (_paint.strokeWidth > 40) {
                return;
              }
              setState(() {
                _paint = Paint()
                  ..color = _paint.color
                  ..strokeWidth = _paint.strokeWidth + 4
                  ..strokeCap = StrokeCap.round
                  ..strokeJoin = StrokeJoin.round
                  ..style = PaintingStyle.stroke;
              });
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          child: Container(
            width: _paint.strokeWidth,
            height: _paint.strokeWidth,
            decoration: BoxDecoration(
              color: _paint.color,
              shape: BoxShape.circle,
            ),
          ),
        ),
        Transform.rotate(
          angle: math.pi / 2,
          child: IconButton(
            iconSize: 40,
            icon: Icon(Icons.remove_circle_outline),
            onPressed: () {
              if (_paint.strokeWidth < 8) {
                return;
              }
              setState(() {
                _paint = Paint()
                  ..color = _paint.color
                  ..strokeWidth = _paint.strokeWidth - 4
                  ..strokeCap = StrokeCap.round
                  ..strokeJoin = StrokeJoin.round
                  ..style = PaintingStyle.stroke;
              });
            },
          ),
        ),
        Container(height: 10, width: 10),
      ],
    );
  }

  Widget _animationCanvas() {
    return AspectRatio(
      aspectRatio: 0.6,
      child: Container(
        color: Colors.grey[200],
        child: AnimatedDrawing.paths(
          _drawingStorage.getPaths(),
          paints: _drawingStorage.getPaints(),
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

  Widget _smallerCanvas() {
    return SizedBox(
      height: 100,
      child: AspectRatio(
        key: _smallCanvasKey,
        aspectRatio: 1.2,
        child: Container(
          color: Colors.orange,
          child: CustomPaint(
            painter: MyPainter(_drawingStorage.scaledPaths(inputHeight: 345.0, inputWidth: 414.0, outputHeight: 100.0, outputWidth: 120.0),
                _drawingStorage.scaledPaints(inputHeight: 345.0, outputHeight: 100.0)),
          ),
        ),
      ),
    );
  }

  Widget _drawingCanvas() {
    if (!_hasCalculatedSize) {
      _needToCalculateSize = true;
    }

    return AspectRatio(
      key: _canvasKey,
      aspectRatio: 1.2,
      child: Container(
        color: Color.fromRGBO(255, 250, 235, 1),
        child: GestureDetector(
          onPanStart: (details) {
            setState(() {
              _drawingStorage.startNewPath(details.localPosition.dx, details.localPosition.dy, _paint, false);
            });

            _lastPointOutOfBounds = false;
          },
          onPanUpdate: (details) {
            if (details.localPosition.dy > _canvasDY || details.localPosition.dy < 2) {
              _lastPointOutOfBounds = true;
              return;
            }

            setState(() {
              _drawingStorage.addPoint(details.localPosition.dx, details.localPosition.dy, _lastPointOutOfBounds, false);
            });

            _lastPointOutOfBounds = false;
          },
          onPanEnd: (details) {
            _drawingStorage.endPath();
          },
          child: CustomPaint(
            painter: MyPainter(_drawingStorage.getPaths(), _drawingStorage.getPaints()),
          ),
        ),
      ),
    );
  }

  Widget _buttons() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            FlatButton(
              color: Colors.redAccent,
              child: Text("CLEAR"),
              onPressed: () {
                setState(() {
                  _drawingStorage.clearDrawing();
                  _showAnimationCanvas = false;
                });
              },
            ),
            FlatButton(
              color: Colors.deepOrange,
              child: Text("UNDO"),
              onPressed: () {
                setState(() {
                  _drawingStorage.undoLastPath();
                });
              },
            ),
            FlatButton(
              color: Colors.greenAccent,
              child: Text("REDO"),
              onPressed: () {
                setState(() {
                  _drawingStorage.redoLastUndonePath();
                });
              },
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            FlatButton(
              color: Colors.blue,
              child: Text("SWITCH"),
              onPressed: () {
                if (_drawingStorage.getPaths().isEmpty) {
                  return;
                }

                setState(() {
                  this._runAnimation = true;
                  _showAnimationCanvas = !_showAnimationCanvas;
                });
              },
            ),
            FlatButton(
              color: Colors.green,
              child: Text("SAVE"),
              onPressed: () async {
                if (_drawingStorage.getPaths().isEmpty) {
                  return;
                }

                Map<String, dynamic> pathInfo = _drawingStorage.toJson();
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setString('drawing', jsonEncode(pathInfo));
              },
            ),
            FlatButton(
              color: Colors.yellow,
              child: Text("LOAD"),
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                String drawingInfo = prefs.getString('drawing');
                setState(() {
                  _drawingStorage = DrawingStorage.fromJson(jsonDecode(drawingInfo));
                });
              },
            ),
          ],
        ),
      ],
    );
  }
}
