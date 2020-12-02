import 'package:exquisitecorpse/drawing_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:drawing_animation/drawing_animation.dart';

import 'package:exquisitecorpse/models.dart';
import 'package:exquisitecorpse/db.dart';
import 'package:exquisitecorpse/widgets/buttons.dart';
import 'package:exquisitecorpse/widgets/text_components.dart';
import 'package:exquisitecorpse/constants.dart';

class MonsterViewer extends StatefulWidget {
  @override
  _MonsterViewerState createState() => _MonsterViewerState();
}

class _MonsterViewerState extends State<MonsterViewer> {
  final _db = DatabaseService.instance;
  List<String> _roomCodesToReview;

  GameRoom _room;

  bool _clearCanvas = true;

  DrawingStorage _top;
  DrawingStorage _mid;
  DrawingStorage _bottom;

  int _monsterIndex = 1;

  int _topIndex = 1;
  int _midIndex = 2;
  int _bottomIndex = 3;

  bool _runTopAnimation = false;
  bool _runMidAnimation = false;
  bool _runBottomAnimation = false;

  var _duration = Duration(seconds: 2);
  PathOrder _pathOrder = PathOrders.topToBottom;

  final monsterKey = GlobalKey();
  Size monsterSize;

  double _outputWidth;
  double _outputHeight;

  int currentGameRoomIndex = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    getRoomCodesToReview();
  }

  Future<void> getRoomCodesToReview() async {
    _roomCodesToReview = await _db.gameRoomsToReview();
    _room = await _db.roomToReviewFromCode(roomCode: _roomCodesToReview[currentGameRoomIndex]).first;
    setState(() {});
  }

  void nextOrPreviousGameRoom({next = true}) async {
    print("CURRENT ROOM: " + _roomCodesToReview[currentGameRoomIndex]);

    if (next) {
      if (currentGameRoomIndex >= _roomCodesToReview.length - 1) {
        return;
      }
      _room = await _db.roomToReviewFromCode(roomCode: _roomCodesToReview[++currentGameRoomIndex]).first;
    } else {
      if (currentGameRoomIndex <= 0) {
        return;
      }
      _room = await _db.roomToReviewFromCode(roomCode: _roomCodesToReview[--currentGameRoomIndex]).first;
    }

    _monsterIndex = 1;
    indexHandler(_monsterIndex);
    _startAnimations();
  }

  void indexHandler(int index) {
    assert(index == 1 || index == 2 || index == 3, 'Index is not a valid number');
    if (index == 1) {
      _topIndex = index;
      _midIndex = 2;
      _bottomIndex = 3;
    } else if (index == 2) {
      _topIndex = index;
      _midIndex = 3;
      _bottomIndex = 1;
    } else if (index == 3) {
      _topIndex = index;
      _midIndex = 1;
      _bottomIndex = 2;
    }
  }

  void _calculate() {
    if (monsterKey.currentContext != null) {
      RenderBox renderBox = monsterKey.currentContext.findRenderObject();
      monsterSize = renderBox.size;

      _outputHeight = 300;
      _outputWidth = _outputHeight * 0.75;
      //_outputWidth = 300; //size.width - 20;
      //_outputHeight = _outputWidth * (2 / 3);

      if (_outputHeight * (5 / 6) * 3 > monsterSize.height) {
        _outputHeight = monsterSize.height * (6 / 16);
        _outputWidth = monsterSize.height * (6 / 16) * (3 / 2);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    //GameState.canvasHeight = MediaQuery.of(context).size.height / 2;
    //GameState.canvasWidth = MediaQuery.of(context).size.width / 2;

    final Size size = Size(300, 300); //MediaQuery.of(context).size;
    //final Size size = MediaQuery.of(context).size;

    if (_room == null) {
      return CircularProgressIndicator();
    }

    if (!_room.allBottomDrawingsDone()) {
      return Center(
        child: LastWaitingScreen(),
      );
    }

    _top = DrawingStorage.fromJson(jsonDecode(_room.topDrawings[_topIndex]));
    _mid = DrawingStorage.fromJson(jsonDecode(_room.midDrawings[_midIndex]));
    _bottom = DrawingStorage.fromJson(jsonDecode(_room.bottomDrawings[_bottomIndex]));

    return Scaffold(
      backgroundColor: paper,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                _controls(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[MonsterNumberText(number: _monsterIndex)],
                ),
                if (_clearCanvas || monsterSize == null) _calculateWidget(),
                if (!_clearCanvas && monsterSize != null) _monster(size)
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(),
                  //ShareButton(onPressed: () {}), //TODO: Implement share functionality
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _calculateWidget() {
    _calculate();

    return Expanded(
      child: Container(
        key: monsterKey,
      ),
    );
  }

  Widget _monster(Size size) {
    return Padding(
      padding: EdgeInsets.only(left: (size.width - _outputWidth) / 2),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: monsterSize.width, maxHeight: monsterSize.height),
        child: Stack(
          children: <Widget>[
            AnimatedDrawing.paths(
              _top.getScaledPaths(
                outputHeight: _outputHeight,
              ),
              paints: _top.getScaledPaints(
                outputHeight: _outputHeight,
              ),
              run: _runTopAnimation,
              animationOrder: _pathOrder,
              scaleToViewport: false,
              duration: _duration,
              onFinish: () => setState(() {
                _runTopAnimation = false;
                if (!_room.animateAllAtOnce) {
                  _runMidAnimation = true;
                }
              }),
            ),
            Positioned(
              top: _outputHeight * (5 / 6),
              child: AnimatedDrawing.paths(
                _mid.getScaledPaths(
                  outputHeight: _outputHeight,
                ),
                paints: _mid.getScaledPaints(
                  outputHeight: _outputHeight,
                ),
                run: _runMidAnimation,
                animationOrder: _pathOrder,
                scaleToViewport: false,
                duration: _duration,
                onFinish: () => setState(() {
                  _runMidAnimation = false;
                  if (!_room.animateAllAtOnce) {
                    _runBottomAnimation = true;
                  }
                }),
              ),
            ),
            Positioned(
              top: 2 * _outputHeight * (5 / 6),
              child: AnimatedDrawing.paths(
                _bottom.getScaledPaths(
                  outputHeight: _outputHeight,
                ),
                paints: _bottom.getScaledPaints(
                  outputHeight: _outputHeight,
                ),
                run: _runBottomAnimation,
                animationOrder: _pathOrder,
                scaleToViewport: false,
                duration: _duration,
                onFinish: () => setState(() {
                  _runBottomAnimation = false;
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _controls() {
    const double padding = 4;
    const double edgePadding = 2;

    return FittedBox(
      child: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Container(width: edgePadding),
            PlayButton(
              onPressed: () {
                _startAnimations();
              },
            ),
            Container(width: padding),
            PreviousButton(
              onPressed: () {
                if (_monsterIndex > 1) {
                  _monsterIndex--;
                  indexHandler(_monsterIndex);
                  _startAnimations();
                }
              },
            ),
            Container(width: padding),
            NextButton(
              onPressed: () {
                if (_monsterIndex < 3) {
                  _monsterIndex++;
                  indexHandler(_monsterIndex);
                  _startAnimations();
                }
              },
            ),
            Container(width: padding),
            PreviousButton(
              onPressed: () {
                nextOrPreviousGameRoom(next: false);
              },
            ),
            Container(width: padding),
            NextButton(
              onPressed: () {
                nextOrPreviousGameRoom();
              },
            ),
            Container(width: edgePadding),
          ],
        ),
      ),
    );
  }

  void _startAnimations() {
    _clearCanvas = false;
    _runTopAnimation = true;
    if (_room.animateAllAtOnce) {
      _duration = Duration(milliseconds: 100);
      _runMidAnimation = true;
      _runBottomAnimation = true;
    } else {
      _duration = Duration(milliseconds: 100);
      _runMidAnimation = false;
      _runBottomAnimation = false;
    }

    setState(() {});
  }
}
