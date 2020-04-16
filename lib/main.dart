import 'package:flutter/material.dart';
//import 'dart:ui' as ui;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:drawing_animation/drawing_animation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'painters.dart';
import 'drawing_storage.dart';

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

  //final ui.PictureRecorder recorder = ui.PictureRecorder();

  bool _needToCalculateSize = false;
  bool _hasCalculatedSize = false;
  double _canvasDY = 0;
  bool _runAnimation = true;
  bool _showAnimationCanvas = false;
  bool _lastPointOutOfBounds = false;

  //List<Path> _paths = [];
  //List<Paint> _paints = [];
  DrawingStorage _drawingStorage = DrawingStorage();

  Paint _paint = Paint()
    ..color = Colors.black
    ..strokeWidth = 5
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;

  @override
  initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      //DeviceOrientation.landscapeLeft,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    if (_needToCalculateSize && !_hasCalculatedSize) {
      final RenderBox renderBox = _canvasKey.currentContext.findRenderObject();
      _canvasDY = renderBox.size.height - 2;
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
                _buttons(),
                _showAnimationCanvas ? _animationCanvas() : _drawingCanvas(),
              ],
            ),
            Container(
              color: Colors.lightGreen,
              child: Padding(
                padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    _thicknessButton(30),
                    _thicknessButton(20),
                    _thicknessButton(10),
                    _thicknessButton(5),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _thicknessButton(double thickness) {
    return GestureDetector(
      onTap: () {
        _paint = Paint()
          ..color = Colors.black
          ..strokeWidth = thickness
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;
      },
      child: Padding(
        padding: EdgeInsets.only(bottom: 10),
        child: Container(
          width: thickness,
          height: thickness,
          decoration: BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Widget _animationCanvas() {
    return AspectRatio(
      aspectRatio: 0.5625,
      child: Container(
        color: Colors.green,
        child: AnimatedDrawing.paths(
          _paths,
          paints: _paints,
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

  Widget _drawingCanvas() {
    if (!_hasCalculatedSize) {
      _needToCalculateSize = true;
    }

    return AspectRatio(
      key: _canvasKey,
      aspectRatio: 0.5625,
      child: Container(
        color: Color.fromRGBO(255, 250, 235, 1),
        child: GestureDetector(
          onPanStart: (details) {
            print('IN CANVAS 1. ${_paths.length}, ${_paints.length}');
            setState(() {
              print('IN CANVAS 2. ${_paths.length}, ${_paints.length}');
              _paths.add(Path()..moveTo(details.localPosition.dx, details.localPosition.dy));
              print('IN CANVAS 3. ${_paths.length}, ${_paints.length}');
              _paths.last.lineTo(details.localPosition.dx, details.localPosition.dy);
              print('IN CANVAS 4. ${_paths.length}, ${_paints.length}');
            });

            _drawingStorage.startNewPath(details.localPosition.dx, details.localPosition.dy, _paint);
            print('IN CANVAS 5. ${_paths.length}, ${_paints.length}');

            //_paints.add(_paint);
            _lastPointOutOfBounds = false;

            print('IN CANVAS 6. ${_paths.length}, ${_paints.length}');
          },
          onPanUpdate: (details) {
            if (details.localPosition.dy > _canvasDY || details.localPosition.dy < 2) {
              _lastPointOutOfBounds = true;
              return;
            }

            setState(() {
              if (_lastPointOutOfBounds) {
                _paths.last.moveTo(details.localPosition.dx, details.localPosition.dy);
              }
              _paths.last.lineTo(details.localPosition.dx, details.localPosition.dy);
            });

            _drawingStorage.addPoint(details.localPosition.dx, details.localPosition.dy);

            _lastPointOutOfBounds = false;

            //print("PAN UPDATE: global pos: ${details.globalPosition}, local pos: ${details.localPosition}");
            //print("${paths.last. .toString()}");
          },
          child: CustomPaint(
            painter: MyPainter(_paths, _paints),
          ),
        ),
      ),
    );
  }

  Widget _buttons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        FlatButton(
          color: Colors.blue,
          child: Text("SWITCH"),
          onPressed: () {
            if (_paths.isEmpty) {
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
            if (_paths.isEmpty) {
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
              _paths = _drawingStorage.getListOfPaths();
              _paints = _drawingStorage.paints;
            });
          },
        ),
        FlatButton(
          color: Colors.redAccent,
          child: Text("CLEAR"),
          onPressed: () {
            setState(() {
              _paths.clear();
              _paints.clear();
              _drawingStorage = DrawingStorage();
              _showAnimationCanvas = false;
            });
          },
        ),
      ],
    );
  }
}
