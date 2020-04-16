import 'package:flutter/material.dart';
//import 'dart:ui' as ui;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:drawing_animation/drawing_animation.dart';
import 'package:tuple/tuple.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'painters.dart';
import 'path_storage.dart';

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

  List<Path> _paths = [];
  List<Paint> _paints = [];
  PathStorage _pathStorage = PathStorage();

  Paint _defaultPaint = Paint()
    ..color = Colors.black
    ..strokeWidth = 4
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
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                _buttons(),
                _showAnimationCanvas ? _animationCanvas() : _drawingCanvas(),
              ],
            ),
          ],
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
          duration: Duration(seconds: 3),
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
            setState(() {
              _paths.add(Path()..moveTo(details.localPosition.dx, details.localPosition.dy));
              _paths.last.lineTo(details.localPosition.dx, details.localPosition.dy);
            });

            _pathStorage.startNewPath(Tuple2<double, double>(details.localPosition.dx, details.localPosition.dy));

            _paints.add(_defaultPaint);
            _lastPointOutOfBounds = false;
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

            _pathStorage.addPoint(Tuple2<double, double>(details.localPosition.dx, details.localPosition.dy));

            _lastPointOutOfBounds = false;

            //print("PAN UPDATE: global pos: ${details.globalPosition}, local pos: ${details.localPosition}");
            //print("${paths.last. .toString()}");
          },
          child: CustomPaint(
            painter: MyPainter(_paths),
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

            Map<String, dynamic> pathInfo = _pathStorage.toJson();

            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('drawing', jsonEncode(pathInfo));
            print(prefs.getString('drawing'));
          },
        ),
        FlatButton(
          color: Colors.yellow,
          child: Text("LOAD"),
          onPressed: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            String pathInfo = prefs.getString('drawing');
            setState(() {
              _pathStorage = PathStorage.fromJson(jsonDecode(pathInfo));
              _paths = PathStorage.fromJson(jsonDecode(pathInfo)).getListOfPaths();
              _paints.clear();

              /// TODO: Här skall de riktiga paint inställningarna laddas in framöver
              for (var _ in _paths) {
                _paints.add(_defaultPaint);
              }
            });

            print(pathInfo);
          },
        ),
        FlatButton(
          color: Colors.redAccent,
          child: Text("CLEAR"),
          onPressed: () {
            setState(() {
              _paths.clear();
              _paints.clear();
              _pathStorage = PathStorage();
              _showAnimationCanvas = false;
            });
          },
        ),
      ],
    );
  }
}
