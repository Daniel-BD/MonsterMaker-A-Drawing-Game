import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:drawing_animation/drawing_animation.dart';
import 'package:after_layout/after_layout.dart';

import 'package:exquisitecorpse/painters.dart';
import 'package:exquisitecorpse/drawing_storage.dart';
import 'package:exquisitecorpse/models.dart';
import 'package:exquisitecorpse/db.dart';

class DrawingScreen extends StatefulWidget {
  DrawingScreen({
    Key key,
    @required this.room,
  })  : assert(room != null),
        super(key: key);

  final GameRoom room;

  @override
  _DrawingScreenState createState() => _DrawingScreenState();
}

class _DrawingScreenState extends State<DrawingScreen> {
  final _db = DatabaseService.instance;
  bool _showButtons = true;
  bool _showAnimationCanvas = false;

  bool _topDrawingBegun = false;
  bool _topDrawingsDone = false;
  bool _midDrawingBegun = false;
  bool _midDrawingsDone = false;
  bool _bottomDrawingBegun = false;
  bool _bottomDrawingsDone = false;
  bool _loadingHandIn = false;

  DrawingStorage _drawingStorage = DrawingStorage();

  StreamSubscription<GameRoom> _stream;

  @override
  initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    _stream = _db.streamWaitingRoom(roomCode: widget.room.roomCode).listen((room) {
      _topDrawingsDone = room.topDrawingsDone();
      _midDrawingsDone = room.midDrawingsDone();
      _bottomDrawingsDone = room.bottomDrawingsDone();
    });
  }

  @override
  void dispose() {
    _stream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(180, 180, 180, 1),
      body: SafeArea(
        child: StreamBuilder<GameRoom>(
            stream: _db.streamWaitingRoom(roomCode: widget.room.roomCode),
            builder: (context, snapshot) {
              if (snapshot.data == null) {
                return Center(
                  child: CircularProgressIndicator(backgroundColor: Colors.purple),
                );
              }

              return Stack(
                alignment: AlignmentDirectional.bottomStart,
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      _showAnimationCanvas
                          ? AnimationCanvas(drawingStorage: _drawingStorage)
                          : DrawingCanvas(drawingStorage: _drawingStorage),
                    ],
                  ),
                  _buttons(snapshot.data),
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
              );
            }),
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
              if (_drawingStorage.paint.strokeWidth > 40) {
                return;
              }
              setState(() {
                _drawingStorage.paint = Paint()
                  ..color = _drawingStorage.paint.color
                  ..strokeWidth = _drawingStorage.paint.strokeWidth + 4
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
            width: _drawingStorage.paint.strokeWidth,
            height: _drawingStorage.paint.strokeWidth,
            decoration: BoxDecoration(
              color: _drawingStorage.paint.color,
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
              if (_drawingStorage.paint.strokeWidth < 8) {
                return;
              }
              setState(() {
                _drawingStorage.paint = Paint()
                  ..color = _drawingStorage.paint.color
                  ..strokeWidth = _drawingStorage.paint.strokeWidth - 4
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

  Widget _buttons(GameRoom room) {
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
                      _showAnimationCanvas = !_showAnimationCanvas;
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: FlatButton(
                  color: Colors.green,
                  child: Text("DONE"),
                  onPressed: () async {
                    final db = DatabaseService.instance;
                    setState(() {
                      _loadingHandIn = true;
                    });
                    var result = await db.handInDrawing(room: room, drawing: jsonEncode(_drawingStorage.toJson()));
                    setState(() {
                      _loadingHandIn = false;
                    });

                    /*if (_drawingStorage.getPaths().isEmpty) {
                      return;
                    }

                    Map<String, dynamic> pathInfo = _drawingStorage.toJson();
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    await prefs.setString('drawing', jsonEncode(pathInfo));

                    Firestore.instance.collection('drawings').document('1').setData({'json': jsonEncode(pathInfo)}); */
                  },
                ),
              ),
              /* Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: FlatButton(
                  color: Colors.yellow,
                  child: Text("LOAD CLOUD"),
                  onPressed: () async {
                    /*var docs = await Firestore.instance.collection('drawings').getDocuments();
                    setState(() {
                      _drawingStorage = DrawingStorage.fromJson(
                          jsonDecode(docs.documents.first.data['json']), true, _drawingStorage.height, _drawingStorage.width);
                    }); */
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: FlatButton(
                  color: Colors.yellow,
                  child: Text("LOAD"),
                  onPressed: () async {
                    /*
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    String drawingInfo = prefs.getString('drawing');
                    setState(() {
                      _drawingStorage =
                          DrawingStorage.fromJson(jsonDecode(drawingInfo), false, _drawingStorage.height, _drawingStorage.width);
                    });*/
                  },
                ),
              ),*/
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

class AnimationCanvas extends StatefulWidget {
  AnimationCanvas({
    Key key,
    @required this.drawingStorage,
  }) : super(key: key);

  final DrawingStorage drawingStorage;

  @override
  _AnimationCanvasState createState() => _AnimationCanvasState();
}

class _AnimationCanvasState extends State<AnimationCanvas> {
  bool _runAnimation = true;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.6,
      child: Container(
        color: Colors.grey[200],
        child: AnimatedDrawing.paths(
          widget.drawingStorage.getPaths(),
          paints: widget.drawingStorage.getPaints(),
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
  DrawingCanvas({Key key, @required this.drawingStorage}) : super(key: key);

  final DrawingStorage drawingStorage;

  @override
  _DrawingCanvasState createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends State<DrawingCanvas> with AfterLayoutMixin<DrawingCanvas> {
  final canvasKey = GlobalKey();
  DrawingStorage _data;
  bool _lastPointOutOfBounds = false;
  bool _ignorePath = false;

  @override
  void initState() {
    super.initState();
    _data = widget.drawingStorage;
  }

  @override
  Widget build(BuildContext context) {
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

            setState(() {
              _data.startNewPath(details.localPosition.dx, details.localPosition.dy, _data.paint, false);
            });

            _lastPointOutOfBounds = false;
          },
          onPanUpdate: (details) {
            if (_pointOutsideCanvas(details.localPosition.dy)) {
              _lastPointOutOfBounds = true;
              return;
            }

            setState(() {
              _data.addPoint(details.localPosition.dx, details.localPosition.dy, _lastPointOutOfBounds, false);
            });

            _lastPointOutOfBounds = false;
          },
          onPanEnd: (details) {
            if (_ignorePath) {
              return;
            }
            _data.endPath();
          },
          child: CustomPaint(
            painter: MyPainter(_data.getPaths(), _data.getPaints()),
          ),
        ),
      ),
    );
  }

  bool _pointOutsideCanvas(double dy) {
    return (dy > _data.height - (_data.paint.strokeWidth / 2) || dy < (_data.paint.strokeWidth / 2));
  }

  @override
  void afterFirstLayout(BuildContext context) {
    if (canvasKey.currentContext != null && (_data.width == null || _data.height == null)) {
      RenderBox renderBox = canvasKey.currentContext.findRenderObject();
      _data.height = renderBox.size.height;
      _data.width = renderBox.size.width;
      assert(_data.height != null && _data.width != null);
    }
  }
}
