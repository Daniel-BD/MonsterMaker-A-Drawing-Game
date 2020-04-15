import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:drawing_animation/drawing_animation.dart';
import 'package:tuple/tuple.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  final ui.PictureRecorder recorder = ui.PictureRecorder();

  bool _needToCalculateSize = false;
  bool _hasCalculatedSize = false;
  double _canvasDY = 0;
  bool _runAnimation = true;
  bool _showAnimation = false;
  bool _lastPointOutOfBounds = false;

  List<Path> paths = [];
  List<Paint> paints = [];

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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                FlatButton(
                  color: Colors.blue,
                  child: Text("SWITCH"),
                  onPressed: () {
                    if (paths.isEmpty) {
                      return;
                    }

                    setState(() {
                      this._runAnimation = true;
                      _showAnimation = !_showAnimation;
                    });
                  },
                ),
                FlatButton(
                  color: Colors.green,
                  child: Text("SAVE"),
                  onPressed: () async {
                    if (paths.isEmpty) {
                      return;
                    }

                    Map<String, dynamic> pathInfo = _pathStorage.toJson();
                    /*print(pathInfo.toString());
                    print("---");
                    print(jsonEncode(pathInfo));
                    print("---");
                    print(jsonDecode(jsonEncode(pathInfo)));*/

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
                    });

                    print(pathInfo);
                  },
                ),
                FlatButton(
                  color: Colors.redAccent,
                  child: Text("CLEAR"),
                  onPressed: () {
                    setState(() {
                      paths.clear();
                      paints.clear();
                      _showAnimation = false;
                    });
                  },
                ),
              ],
            ),
            _showAnimation
                ? AspectRatio(
                    aspectRatio: 0.5625,
                    child: Container(
                      color: Colors.green,
                      child: AnimatedDrawing.paths(
                        paths,
                        paints: paints,
                        run: this._runAnimation,
                        scaleToViewport: false,
                        duration: new Duration(seconds: 3),
                        onFinish: () => setState(() {
                          this._runAnimation = false;
                        }),
                      ),
                    ),
                  )
                : Column(
                    children: <Widget>[
                      _myPainter(),
                      _test(),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _myPainter() {
    if (!_hasCalculatedSize) {
      _needToCalculateSize = true;
    }

    return AspectRatio(
      key: _canvasKey,
      aspectRatio: 1.3, //0.5625,
      child: Container(
        color: Color.fromRGBO(255, 250, 235, 1),
        child: GestureDetector(
          onPanStart: (details) {
            setState(() {
              paths.add(Path()..moveTo(details.localPosition.dx, details.localPosition.dy));
              paths.last.lineTo(details.localPosition.dx, details.localPosition.dy);
            });

            _pathStorage.startNewPath(Tuple2<double, double>(details.localPosition.dx, details.localPosition.dy));

            paints.add(_defaultPaint);
            _lastPointOutOfBounds = false;
          },
          onPanUpdate: (details) {
            if (details.localPosition.dy > _canvasDY || details.localPosition.dy < 2) {
              _lastPointOutOfBounds = true;
              return;
            }

            setState(() {
              if (_lastPointOutOfBounds) {
                paths.last.moveTo(details.localPosition.dx, details.localPosition.dy);
              }
              paths.last.lineTo(details.localPosition.dx, details.localPosition.dy);
            });

            _pathStorage.addPoint(Tuple2<double, double>(details.localPosition.dx, details.localPosition.dy));

            _lastPointOutOfBounds = false;

            //print("PAN UPDATE: global pos: ${details.globalPosition}, local pos: ${details.localPosition}");
            //print("${paths.last. .toString()}");
          },
          child: CustomPaint(
            painter: MyPainter(paths),
          ),
        ),
      ),
    );
  }

  Widget _test() {
    return AspectRatio(
      aspectRatio: 1.3, //0.5625,
      child: Container(
        color: Colors.orange,
        child: CustomPaint(
          painter: StoragePainter(_pathStorage),
        ),
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  List<Path> paths;

  MyPainter(List<Path> paths) {
    this.paths = paths;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    paths.forEach((path) {
      canvas.drawPath(path, paint);
    });
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class StoragePainter extends CustomPainter {
  PathStorage pathStorage;
  List<Path> paths = [];

  StoragePainter(PathStorage pathStorage) {
    this.pathStorage = pathStorage;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    pathStorage.paths.forEach((fakePath) {
      paths.add(Path()
        ..moveTo(fakePath.first.item1, fakePath.first.item2)
        ..lineTo(fakePath.first.item1, fakePath.first.item2));

      for (int i = 1; i < fakePath.length; i++) {
        paths.last.lineTo(fakePath[i].item1, fakePath[i].item2);
      }
    });

    paths.forEach((path) {
      canvas.drawPath(path, paint);
    });
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class PathStorage {
  /// This is essentially a list of paths, even though it may be hard to see. The inner list is a list of points (dx dy),
  /// which is the same thing as a path really. The outer list is a list of those, meaning a list of paths.
  List<List<Tuple2<double, double>>> paths = [];

  void startNewPath(Tuple2<double, double> dxDy) {
    paths.add([dxDy]);
  }

  void addPoint(Tuple2<double, double> dxDy) {
    paths.last.add(dxDy);
  }

  PathStorage();

  PathStorage.fromJson(Map<String, dynamic> json) {
    List<List<Tuple2<double, double>>> paths = [];

    String pathsString = json['paths'];

    print(json);
    print("ooooo");
    print(json['paths'].toString());

    List<String> pathList = pathsString.split(':');

    for (var path in pathList) {
      List<Tuple2<double, double>> coordinates = [];
      List<String> coordinatesString = path.split(',');

      for (var i = 0; i < coordinatesString.length; i += 2) {
        coordinates.add(Tuple2(double.parse(coordinatesString[i]), double.parse(coordinatesString[i + 1])));
      }

      paths.add(coordinates);
    }

    this.paths = paths;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    StringBuffer pathsString = StringBuffer();

    /// For every path
    for (var i = 0; i < paths.length; i++) {
      /// Go through every coordinate in that path
      for (var j = 0; j < paths[i].length; j++) {
        /// Write down the X and Y coordinate, separated with a comma
        pathsString.write('${paths[i][j].item1},${paths[i][j].item2}');

        /// Don't write a comma after the last coordinate
        if (j < paths[i].length - 1) {
          pathsString.write(',');
        }
      }

      /// Separate every path with a colon, but don't write a colon after the last path
      if (i < paths.length - 1) {
        pathsString.write(':');
      }
    }

    json['paths'] = pathsString.toString();

    return json;
  }
}
