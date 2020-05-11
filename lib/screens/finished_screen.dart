import 'package:exquisitecorpse/drawing_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:drawing_animation/drawing_animation.dart';

import 'package:exquisitecorpse/models.dart';
import 'package:exquisitecorpse/game_state.dart';
import 'package:exquisitecorpse/db.dart';
import 'package:exquisitecorpse/painters.dart';

class FinishedScreen extends StatefulWidget {
  @override
  _FinishedScreenState createState() => _FinishedScreenState();
}

class _FinishedScreenState extends State<FinishedScreen> {
  final _db = DatabaseService.instance;

  int _index = 1;

  int _topIndex = 1;
  int _midIndex = 2;
  int _bottomIndex = 3;

  bool _runTopAnimation = false;
  bool _runMidAnimation = false;
  bool _runBottomAnimation = false;

  final _duration = Duration(seconds: 1);

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
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

  @override
  Widget build(BuildContext context) {
    final GameState gameState = Provider.of<GameState>(context);

    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<GameRoom>(
          stream: _db.streamWaitingRoom(roomCode: gameState.currentRoomCode),
          builder: (context, snapshot) {
            if (snapshot.data == null) {
              return CircularProgressIndicator();
            }

            GameRoom room = snapshot.data;

            DrawingStorage top = DrawingStorage.fromJson(jsonDecode(room.topDrawings[_topIndex]), true);
            DrawingStorage mid = DrawingStorage.fromJson(jsonDecode(room.midDrawings[_midIndex]), true);
            DrawingStorage bottom = DrawingStorage.fromJson(jsonDecode(room.bottomDrawings[_bottomIndex]), true);

            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _controls(),
                  Container(
                    color: Colors.green,
                    child: AspectRatio(
                      aspectRatio: 480 / 733,
                      child: Stack(
                        children: <Widget>[
                          Positioned(
                            top: -(top.height * (9 / 16)) * 6 / 7,
                            right: top.width / 8,
                            child: Transform.scale(
                              scale: 9 / 16,
                              child: AnimatedDrawing.paths(
                                top.getPaths(),
                                paints: top.getPaints(),
                                run: _runTopAnimation,
                                scaleToViewport: false,
                                duration: _duration,
                                onFinish: () => setState(() {
                                  _runTopAnimation = false;
                                  _runMidAnimation = true;
                                }),
                              ),
                            ),
                          ),
                          Positioned(
                            top: (mid.height * (9 / 16)) * 6 / 7,
                            child: Transform.scale(
                              scale: 9 / 16,
                              child: CustomPaint(
                                painter: MyPainter(mid.getPaths(), mid.getPaints()),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 2 * (bottom.height * (9 / 16)) * 6 / 7,
                            child: Transform.scale(
                              scale: 9 / 16,
                              child: CustomPaint(
                                painter: MyPainter(bottom.getPaths(), bottom.getPaints()),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _controls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        FlatButton(
          child: Text('Start'),
          color: Colors.cyan,
          onPressed: () {
            setState(() {
              _runTopAnimation = true;
            });
          },
        ),
        FlatButton(
          child: Text('Next'),
          color: Colors.cyan,
          onPressed: () {
            setState(() {
              if (_index < 3) {
                _index++;
                indexHandler(_index);
              }
            });
          },
        ),
        FlatButton(
          child: Text('Previous'),
          color: Colors.cyan,
          onPressed: () {
            setState(() {
              if (_index > 1) {
                _index--;
                indexHandler(_index);
              }
            });
          },
        ),
      ],
    );
  }
}
