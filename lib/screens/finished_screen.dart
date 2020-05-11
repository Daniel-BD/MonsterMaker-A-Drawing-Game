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
  GameRoom _room;

  bool _clearCanvas = false;

  DrawingStorage _top;
  DrawingStorage _mid;
  DrawingStorage _bottom;

  int _index = 1;

  int _topIndex = 1;
  int _midIndex = 2;
  int _bottomIndex = 3;

  bool _runTopAnimation = false;
  bool _runMidAnimation = false;
  bool _runBottomAnimation = false;

  final _duration = Duration(seconds: 3);
  PathOrder _pathOrder = PathOrders.topToBottom;

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
            //TODO: Byt ut detta mot provider till controller osv...
            _room = room;

            if (!room.allBottomDrawingsDone()) {
              return Center(
                child: Text(
                  'Waiting for the other players to finish...',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                ),
              );
            }

            _top = DrawingStorage.fromJson(jsonDecode(room.topDrawings[_topIndex]), true);
            _mid = DrawingStorage.fromJson(jsonDecode(room.midDrawings[_midIndex]), true);
            _bottom = DrawingStorage.fromJson(jsonDecode(room.bottomDrawings[_bottomIndex]), true);

            final Size size = MediaQuery.of(context).size;

            return Stack(
              children: <Widget>[
                SingleChildScrollView(
                  physics: ClampingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      if (room.isHost) _controls(),
                      if (!room.isHost) _hostIsControlling(),
                      _monsterNumber(),
                      AspectRatio(
                        aspectRatio: 480 / 733, //TODO: Bör vara något snyggare siffror efter att det är 1/8 overlap istället för 1/7...
                        child: Stack(
                          children: <Widget>[
                            if (!_clearCanvas) ...[
                              AnimatedDrawing.paths(
                                _top.getScaledPaths(
                                  inputHeight: _top.height,
                                  outputHeight: size.width * (9 / 16),
                                  inputWidth: _top.width,
                                  outputWidth: size.width,
                                ),
                                paints: _top.getScaledPaints(
                                  inputHeight: _top.height,
                                  outputHeight: size.width * (9 / 16),
                                ),
                                run: _runTopAnimation,
                                animationOrder: _pathOrder,
                                scaleToViewport: false,
                                duration: _duration,
                                onFinish: () => setState(() {
                                  _runTopAnimation = false;
                                  _runMidAnimation = true;
                                }),
                              ),
                              Positioned(
                                top: (_mid.height * (9 / 16)) * 6 / 7,
                                child: AnimatedDrawing.paths(
                                  _mid.getScaledPaths(
                                    inputHeight: _mid.height,
                                    outputHeight: size.width * (9 / 16),
                                    inputWidth: _mid.width,
                                    outputWidth: size.width,
                                  ),
                                  paints: _mid.getScaledPaints(
                                    inputHeight: _mid.height,
                                    outputHeight: size.width * (9 / 16),
                                  ),
                                  run: _runMidAnimation,
                                  animationOrder: _pathOrder,
                                  scaleToViewport: false,
                                  duration: _duration,
                                  onFinish: () => setState(() {
                                    _runMidAnimation = false;
                                    _runBottomAnimation = true;
                                  }),
                                ),
                              ),
                              Positioned(
                                top: 2 * (_bottom.height * (9 / 16)) * 6 / 7,
                                child: AnimatedDrawing.paths(
                                  _bottom.getScaledPaths(
                                    inputHeight: _bottom.height,
                                    outputHeight: size.width * (9 / 16),
                                    inputWidth: _bottom.width,
                                    outputWidth: size.width,
                                  ),
                                  paints: _bottom.getScaledPaints(
                                    inputHeight: _bottom.height,
                                    outputHeight: size.width * (9 / 16),
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
                            ]
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Align(alignment: Alignment.bottomCenter, child: _exitButton()),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _exitButton() {
    return FlatButton(
      color: Colors.redAccent,
      textColor: Colors.white,
      child: Text('QUIT GAME'),
      onPressed: () {
        Provider.of<GameState>(context, listen: false).clearCurrentRoomCode();
        Navigator.of(context).pushReplacementNamed('/');
      },
    );
  }

  Widget _hostIsControlling() {
    return Text('The game host is controlling what everyone sees!');
  }

  Widget _monsterNumber() {
    return Text(
      'Exquisite Monster #$_index',
      style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
    );
  }

  Widget _controls() {
    final _db = DatabaseService.instance;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        FlatButton(
          child: Text('Start'),
          color: Colors.cyan,
          onPressed: () {
            _db.setAnimation(true, room: _room);
            _resetMonster();
          },
        ),
        FlatButton(
          child: Text('Next'),
          color: Colors.cyan,
          onPressed: () {
            _resetMonster();
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
            _resetMonster();
            setState(() {
              if (_index > 1) {
                _index--;
                indexHandler(_index);
              }
            });
          },
        ),
        FlatButton(
          child: Text('Reset'),
          color: Colors.cyan,
          onPressed: () {
            _resetMonster(doNotStartAnimating: true);
          },
        ),
      ],
    );
  }

  /// Vet inte riktigt vad jag håller på med här...
  void _resetMonsterFromDB() {
    _clearCanvas = true;
    _runTopAnimation = false;
    _runMidAnimation = false;
    _runBottomAnimation = false;

    Future.delayed(Duration(milliseconds: 50)).then((_) {
      setState(() {
        _clearCanvas = false;
        _runTopAnimation = true;
      });
    });
  }

  void _resetMonster({bool doNotStartAnimating}) {
    setState(() {
      _clearCanvas = true;
      _runTopAnimation = false;
      _runMidAnimation = false;
      _runBottomAnimation = false;
    });
    if (doNotStartAnimating == true) {
      return;
    }
    Future.delayed(Duration(milliseconds: 50)).then((_) {
      setState(() {
        _clearCanvas = false;
        _runTopAnimation = true;
      });
    });
  }
}
