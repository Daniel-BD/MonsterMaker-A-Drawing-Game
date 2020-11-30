import 'dart:math';

import 'package:exquisitecorpse/widgets/modal_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  int _hostIndex = 1;
  int _index = 1;

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

  void _calculate() {
    if (monsterKey.currentContext != null) {
      RenderBox renderBox = monsterKey.currentContext.findRenderObject();
      monsterSize = renderBox.size;

      _outputWidth = monsterSize.width - 20;
      _outputHeight = _outputWidth * (9 / 16);

      if (_outputHeight * (16 / 6) > monsterSize.height) {
        _outputHeight = monsterSize.height * (6 / 16);
        _outputWidth = _outputHeight * (16 / 9);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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

            return Stack(
              children: <Widget>[
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
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
                        if (room.isHost)
                          ShareButton(onPressed: () {
                            Navigator.of(context).pushNamed('/shareMonsterScreen');
                          }),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[MonsterNumberText(number: _index)],
                    ),
                    if (_clearCanvas || monsterSize == null) _calculateWidget(),
                    if (!_clearCanvas && monsterSize != null) _monster(monsterSize),
                    if (room.isHost) _controls(context),
                    if (!room.isHost) GameHostControlsWhatYouSeeText(),
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
    _calculate();

    return Expanded(
      child: Container(
        key: monsterKey,
      ),
    );
  }

  Widget _monster(Size size) {
    final leftPosition = (monsterSize.width - _outputWidth - 20) / 2;

    return SizedBox(
      height: monsterSize.height,
      width: monsterSize.width - 20,
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: <Widget>[
          Positioned(
            top: 0.0,
            left: leftPosition,
            child: AnimatedDrawing.paths(
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
          ),
          Positioned(
            top: _outputHeight * (5 / 6),
            left: leftPosition,
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
            left: leftPosition,
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
    );
  }

  Widget _controls(BuildContext context) {
    final _db = DatabaseService.instance;
    final size = MediaQuery.of(context).size;

    return FittedBox(
      child: SizedBox(
        width: min(size.width, 300),
        child: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              PlayButton(
                onPressed: () async {
                  await _db.setAnimation(false, room: _room);
                  _db.setAnimation(true, room: _room);
                },
              ),
              StopButton(
                onPressed: () {
                  _db.setAnimation(false, room: _room);
                },
              ),
              PreviousButton(
                onPressed: () {
                  if (_hostIndex > 1) {
                    _hostIndex--;
                    _db.setMonsterIndex(_hostIndex, room: _room);
                  }
                },
              ),
              NextButton(
                onPressed: () {
                  if (_hostIndex < 3) {
                    _hostIndex++;
                    _db.setMonsterIndex(_hostIndex, room: _room);
                  }
                },
              ),
            ],
          ),
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
