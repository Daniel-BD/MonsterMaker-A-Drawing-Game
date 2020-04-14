import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:painter2/painter2.dart';
import 'package:drawing_animation/drawing_animation.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GlobalKey _canvasKey = GlobalKey();
  GlobalKey _animKey = GlobalKey();

  bool _calculateSize = false;
  bool _hasCalculatedSize = false;

  double _canvasDY = 0;
  Paint _defaultPaint = Paint()
    ..color = Colors.black
    ..strokeWidth = 4
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;

  PainterController _controller = PainterController();

  bool run = true;

  bool _showAnimation = false;

  @override
  initState() {
    super.initState();

    _controller.thickness = 5.0;
    _controller.backgroundColor = Colors.green;

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  List<Path> paths = [];
  List<Paint> paints = [];

  double animHeight = 0;
  double animWidth = 0;

  @override
  Widget build(BuildContext context) {
    if (_calculateSize && !_hasCalculatedSize) {
      final RenderBox renderBox = _canvasKey.currentContext.findRenderObject();
      _canvasDY = renderBox.size.height;
      _hasCalculatedSize = true;
    }

    return Scaffold(
      body: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                FlatButton(
                  color: Colors.blue,
                  child: Text("SWITCH"),
                  onPressed: () {
                    if (paths.isEmpty) {
                      return;
                    }

                    Path temp = Path();
                    paths.forEach((element) {
                      temp.addPath(element, Offset(0, 0));
                    });

                    double height = temp.getBounds().height;
                    double width = temp.getBounds().width;

                    animHeight = height;
                    animWidth = width;

                    setState(() {
                      this.run = true;
                      _showAnimation = !_showAnimation;
                    });
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
                    key: _animKey,
                    aspectRatio: 0.5625,
                    child: Container(
                      color: Colors.green,
                      child: AnimatedDrawing.paths(
                        paths,
                        paints: paints,
                        run: this.run,
                        scaleToViewport: false,
                        duration: new Duration(seconds: 3),
                        onFinish: () => setState(() {
                          this.run = false;
                        }),
                      ),
                    ),
                  )
                : _myPainter(),
          ],
        ),
      ),
    );
  }

  Widget _myPainter() {
    if (!_hasCalculatedSize) {
      _calculateSize = true;
    }

    return AspectRatio(
      key: _canvasKey,
      aspectRatio: 16 / 9,
      child: Container(
        color: Colors.orange,
        child: GestureDetector(
          onPanStart: (details) {
            setState(() {
              paths.add(Path()..moveTo(details.localPosition.dx, details.localPosition.dy));
              paths.last.lineTo(details.localPosition.dx, details.localPosition.dy);
            });
            paints.add(_defaultPaint);
            //print("PAN START: global pos: ${details.globalPosition}, local pos: ${details.localPosition}");
          },
          onPanUpdate: (details) {
            if (/*details.localPosition.dx > 500 ||*/
                details.localPosition.dy > 800 || details.localPosition.dx < 0 || details.localPosition.dy < 0) return;
            setState(() {
              paths.last.lineTo(details.localPosition.dx, details.localPosition.dy);
            });
            //print("PAN UPDATE: global pos: ${details.globalPosition}, local pos: ${details.localPosition}");
          },
          onPanEnd: (details) {
            //print("PAN END");
          },
          child: CustomPaint(
            painter: MyPainter(paths),
          ),
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

/*
AspectRatio(
              aspectRatio: 1.0,
              child: Painter(controller),
            ),
 */
