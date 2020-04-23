import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:drawing_animation/drawing_animation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'painters.dart';
import 'drawing_storage.dart';
import 'dart:math' as math;

class DrawingScreen extends StatefulWidget {
  @override
  _DrawingScreenState createState() => _DrawingScreenState();
}

class _DrawingScreenState extends State<DrawingScreen> {
  bool _showButtons = true;

  GlobalKey _canvasKey = GlobalKey();

  bool _needToCalculateSize = false;
  bool _hasCalculatedSize = false;
  bool _runAnimation = true;
  bool _showAnimationCanvas = false;
  bool _lastPointOutOfBounds = false;
  bool _ignorePath = false;

  DrawingStorage _drawingStorage = DrawingStorage();

  Paint _paint = Paint()
    ..color = Colors.orange
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
      _drawingStorage.height = renderBox.size.height;
      _drawingStorage.width = renderBox.size.width;
      _hasCalculatedSize = true;
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
              ],
            ),
            _buttons(),
            if (_showButtons)
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

  bool _pointOutsideCanvas(double dy) {
    return (dy > _drawingStorage.height - (_paint.strokeWidth / 2) || dy < (_paint.strokeWidth / 2));
  }

  Widget _drawingCanvas() {
    if (!_hasCalculatedSize) {
      _needToCalculateSize = true;
    }

    return AspectRatio(
      key: _canvasKey,
      aspectRatio: 0.6,
      child: Container(
        color: Color.fromRGBO(255, 250, 235, 1),
        child: GestureDetector(
          onPanStart: (details) {
            if (_pointOutsideCanvas(details.localPosition.dy)) {
              _ignorePath = true;
              return;
            }

            setState(() {
              _drawingStorage.startNewPath(details.localPosition.dx, details.localPosition.dy, _paint, false);
            });

            _lastPointOutOfBounds = false;
          },
          onPanUpdate: (details) {
            if (_pointOutsideCanvas(details.localPosition.dy)) {
              _lastPointOutOfBounds = true;
              return;
            }

            setState(() {
              _drawingStorage.addPoint(details.localPosition.dx, details.localPosition.dy, _lastPointOutOfBounds, false);
            });

            _lastPointOutOfBounds = false;
          },
          onPanEnd: (details) {
            if (_ignorePath) {
              return;
            }
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
        if (_showButtons)
          Wrap(
            direction: Axis.horizontal,
            alignment: WrapAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: FlatButton(
                  color: Colors.redAccent,
                  child: Text("CLEAR"),
                  onPressed: () {
                    setState(() {
                      _drawingStorage.clearDrawing();
                      _showAnimationCanvas = false;
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: FlatButton(
                  color: Colors.deepOrange,
                  child: Text("UNDO"),
                  onPressed: () {
                    setState(() {
                      _drawingStorage.undoLastPath();
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: FlatButton(
                  color: Colors.greenAccent,
                  child: Text("REDO"),
                  onPressed: () {
                    setState(() {
                      _drawingStorage.redoLastUndonePath();
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: FlatButton(
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
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: FlatButton(
                  color: Colors.green,
                  child: Text("SAVE"),
                  onPressed: () async {
                    if (_drawingStorage.getPaths().isEmpty) {
                      return;
                    }

                    Map<String, dynamic> pathInfo = _drawingStorage.toJson();
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    await prefs.setString('drawing', jsonEncode(pathInfo));

                    Firestore.instance.collection('drawings').document('1').setData({'json': jsonEncode(pathInfo)});
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: FlatButton(
                  color: Colors.yellow,
                  child: Text("LOAD CLOUD"),
                  onPressed: () async {
                    var docs = await Firestore.instance.collection('drawings').getDocuments();
                    setState(() {
                      _drawingStorage = DrawingStorage.fromJson(
                          jsonDecode(docs.documents.first.data['json']), true, _drawingStorage.height, _drawingStorage.width);
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: FlatButton(
                  color: Colors.yellow,
                  child: Text("LOAD"),
                  onPressed: () async {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    String drawingInfo = prefs.getString('drawing');
                    setState(() {
                      _drawingStorage =
                          DrawingStorage.fromJson(jsonDecode(drawingInfo), false, _drawingStorage.height, _drawingStorage.width);
                    });
                  },
                ),
              ),
            ],
          ),
        FlatButton(
          color: Colors.purpleAccent,
          child: Text(_showButtons ? 'Hide buttons' : 'Show buttons'),
          onPressed: () {
            setState(() {
              _showButtons = !_showButtons;
            });
          },
        ),
      ],
    );
  }
}
