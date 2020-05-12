import 'package:exquisitecorpse/drawing_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:drawing_animation/drawing_animation.dart';

import 'package:exquisitecorpse/models.dart';
import 'package:exquisitecorpse/game_state.dart';
import 'package:exquisitecorpse/db.dart';
import 'package:exquisitecorpse/constants.dart';

class FinishedScreen extends StatefulWidget {
  @override
  _FinishedScreenState createState() => _FinishedScreenState();
}

class _FinishedScreenState extends State<FinishedScreen> {
  final _db = DatabaseService.instance;
  GameRoom _room;

  bool _clearCanvas = true;

  DrawingStorage _top;
  DrawingStorage _mid;
  DrawingStorage _bottom;

  int _hostIndex = 1;
  int _index = 1;

  int _topIndex = 1;
  int _midIndex = 2;
  int _bottomIndex = 3;

  bool _runTopAnimation = false;
  bool _runMidAnimation = false;
  bool _runBottomAnimation = false;

  var _duration = Duration(seconds: 2);
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
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: StreamBuilder<GameRoom>(
          stream: _db.streamWaitingRoom(roomCode: gameState.currentRoomCode),
          builder: (context, snapshot) {
            if (snapshot.data == null) {
              return Center(child: CircularProgressIndicator());
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

            if (_clearCanvas && room.startAnimation) {
              _startAnimations();
            }

            _clearCanvas = !room.startAnimation;

            if (room.monsterIndex != _index) {
              _index = room.monsterIndex;
              _readyNextMonster();
            }

            indexHandler(room.monsterIndex);

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
                                  if (!_room.animateAllAtOnce) {
                                    _runMidAnimation = true;
                                  }
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
                                    if (!_room.animateAllAtOnce) {
                                      _runBottomAnimation = true;
                                    }
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
                      _exitButton(),
                    ],
                  ),
                ),
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
    return Text(
      'The game host controls what you see!',
      textAlign: TextAlign.center,
    );
  }

  Widget _monsterNumber() {
    return Text(
      'Exquisite Monster #$_index',
      style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
    );
  }

  Widget _controls() {
    final _db = DatabaseService.instance;

    return SingleChildScrollView(
      physics: ClampingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          FlatButton(
            child: Text('START'),
            textColor: Colors.white,
            color: Colors.green,
            onPressed: () {
              _db.setAnimation(true, room: _room);
            },
          ),
          Container(width: 10),
          IconButton(
            icon: Icon(Icons.skip_previous),
            color: Colors.blue,
            iconSize: 32,
            onPressed: () {
              if (_hostIndex > 1) {
                _hostIndex--;
                _db.setMonsterIndex(_hostIndex, room: _room);
              }
            },
          ),
          Container(width: 6),
          IconButton(
            icon: Icon(Icons.skip_next),
            color: Colors.blue,
            iconSize: 32,
            onPressed: () {
              if (_hostIndex < 3) {
                _hostIndex++;
                _db.setMonsterIndex(_hostIndex, room: _room);
              }
            },
          ),
          Container(width: 10),
          FlatButton(
            child: Text('CLEAR'),
            textColor: Colors.white,
            color: Colors.redAccent,
            onPressed: () {
              _db.setAnimation(false, room: _room);
            },
          ),
          Container(width: 10),
          FlatButton(
            child: Text(_room.animateAllAtOnce ? 'One By One' : 'All At Once'),
            textColor: Colors.white,
            color: Colors.deepPurpleAccent,
            onPressed: () {
              _db.setAnimateAllAtOnce(!_room.animateAllAtOnce, room: _room);
            },
          ),
        ],
      ),
    );
  }

  void _startAnimations() {
    _clearCanvas = false;
    _runTopAnimation = true;
    if (_room.animateAllAtOnce) {
      _runMidAnimation = true;
      _runBottomAnimation = true;
    } else {
      _runMidAnimation = false;
      _runBottomAnimation = false;
    }
  }

  void _readyNextMonster() {
    _clearCanvas = true;
    _runTopAnimation = false;
    _runMidAnimation = false;
    _runBottomAnimation = false;
    Future.delayed(Duration(milliseconds: 50)).then((_) {
      setState(() {
        _startAnimations();
      });
    });
  }
}
