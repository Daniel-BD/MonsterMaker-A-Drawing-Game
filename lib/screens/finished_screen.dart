import 'package:exquisitecorpse/widgets/modal_message.dart';
import 'package:exquisitecorpse/drawing_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:drawing_animation/drawing_animation.dart';

import 'package:exquisitecorpse/models.dart';
import 'package:exquisitecorpse/game_state.dart';
import 'package:exquisitecorpse/db.dart';
import 'package:exquisitecorpse/widgets/buttons.dart';
import 'package:exquisitecorpse/widgets/text_components.dart';
import 'package:exquisitecorpse/widgets/colors.dart';

class FinishedScreen extends StatefulWidget {
  @override
  _FinishedScreenState createState() => _FinishedScreenState();
}

class _FinishedScreenState extends State<FinishedScreen> {
  final _db = DatabaseService.instance;
  GameRoom _room;

  bool _clearCanvas = true;

  //DrawingStorage _top;
  //DrawingStorage _mid;
  //DrawingStorage _bottom;

  int _hostIndex = 1;
  int _index = 1;

  int _topIndex = 1;
  int _midIndex = 2;
  int _bottomIndex = 3;

  bool _runTopAnimation = false;
  bool _runMidAnimation = false;
  bool _runBottomAnimation = false;

  var _duration = Duration(seconds: 2);
  PathOrder _pathOrder = PathOrders.original;

  final monsterKey = GlobalKey();
  Size monsterSize;

  double _outputWidth;
  double _outputHeight;

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

  void _calculate(Size size) {
    if (monsterKey.currentContext != null) {
      RenderBox renderBox = monsterKey.currentContext.findRenderObject();
      monsterSize = renderBox.size;

      _outputWidth = size.width - 20;
      _outputHeight = _outputWidth * (2 / 3);

      if (_outputHeight * (5 / 6) * 3 > monsterSize.height) {
        _outputHeight = monsterSize.height * (6 / 16);
        _outputWidth = monsterSize.height * (6 / 16) * (3 / 2);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final GameState gameState = Provider.of<GameState>(context);

    return Scaffold(
      backgroundColor: paper,
      body: SafeArea(
        child: StreamBuilder<GameRoom>(
          stream: _db.streamGameRoom(roomCode: gameState.currentRoomCode),
          builder: (context, snapshot) {
            if (snapshot.data == null) {
              return Center(child: CircularProgressIndicator());
            }

            GameRoom room = snapshot.data;
            //TODO: Byt ut detta mot provider eller liknande... skall inte vara en global variabel iaf
            _room = room;

            if (!room.allBottomDrawingsDone()) {
              return Center(
                child: LastWaitingScreen(),
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

            //_top = DrawingStorage.fromJson(jsonDecode(room.topDrawings[_topIndex]), true);
            //_mid = DrawingStorage.fromJson(jsonDecode(room.midDrawings[_midIndex]), true);
            //_bottom = DrawingStorage.fromJson(jsonDecode(room.bottomDrawings[_bottomIndex]), true);

            return Stack(
              children: <Widget>[
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    if (room.isHost) _controls(),
                    if (!room.isHost) GameHostControlsWhatYouSeeText(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[MonsterNumberText(number: _index)],
                    ),
                    if (_clearCanvas || monsterSize == null) _calculateWidget(),
                    if (!_clearCanvas && monsterSize != null) _monster(size),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        QuitButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => QuitGameModal(
                                onPressed: () {
                                  Navigator.of(context).pushReplacementNamed('/');
                                },
                              ),
                            );
                          },
                        ),
                        ShareButton(onPressed: () {
                          Navigator.of(context).pushNamed('/shareMonsterScreen');
                        }), //TODO: Implement share functionality
                      ],
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _calculateWidget() {
    final Size size = MediaQuery.of(context).size;
    _calculate(size);

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
              _room.monsterDrawing.top.getScaledPaths(outputHeight: _outputHeight),
              paints: _room.monsterDrawing.top.getScaledPaints(outputHeight: _outputHeight),
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
                _room.monsterDrawing.middle.getScaledPaths(outputHeight: _outputHeight),
                paints: _room.monsterDrawing.middle.getScaledPaints(outputHeight: _outputHeight),
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
                _room.monsterDrawing.bottom.getScaledPaths(outputHeight: _outputHeight),
                paints: _room.monsterDrawing.bottom.getScaledPaints(outputHeight: _outputHeight),
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
    final _db = DatabaseService.instance;
    final double padding = 4;
    final double edgePadding = 2;

    return FittedBox(
      child: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Container(width: edgePadding),
            PlayButton(
              onPressed: () async {
                await _db.setAnimation(false, room: _room);
                _db.setAnimation(true, room: _room);
              },
            ),
            Container(width: padding),
            StopButton(
              onPressed: () {
                _db.setAnimation(false, room: _room);
              },
            ),
            Container(width: padding),
            PreviousButton(
              onPressed: () {
                if (_hostIndex > 1) {
                  _hostIndex--;
                  _db.setMonsterIndex(_hostIndex, room: _room);
                }
              },
            ),
            Container(width: padding),
            NextButton(
              onPressed: () {
                if (_hostIndex < 3) {
                  _hostIndex++;
                  _db.setMonsterIndex(_hostIndex, room: _room);
                }
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
      _duration = Duration(seconds: 2);
      _runMidAnimation = true;
      _runBottomAnimation = true;
    } else {
      _duration = Duration(seconds: 1);
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
