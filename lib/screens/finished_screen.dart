import 'dart:math';

import 'package:exquisitecorpse/widgets/framed_monster.dart';
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
import 'package:exquisitecorpse/constants.dart';
import 'package:tuple/tuple.dart';

class FinishedScreen extends StatefulWidget {
  @override
  _FinishedScreenState createState() => _FinishedScreenState();
}

class _FinishedScreenState extends State<FinishedScreen> {
  bool showingAgreePrompt = false;

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
              debugPrint('FinishedScreen snapshot is null ');
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

            final Tuple2<int, String> monsterSharePromptData = room.showAgreeToShareMonsterPrompt();
            debugPrint('monsterShareData: ${monsterSharePromptData.toString()}');
            debugPrint('roomCode: ${room.roomCode}');
            if (monsterSharePromptData != null && showingAgreePrompt == false) {
              return AgreeToShareMonsterScreen(
                monsterDrawing: room.monsterDrawings[monsterSharePromptData.item1 - 1],
                monsterIndexAndName: monsterSharePromptData,
                room: room,
              );
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

    assert(_room.currentMonsterDrawing() != null, 'current MonsterDrawing is null, this will crash the app...');

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
              _room.currentMonsterDrawing().top.getScaledPaths(outputHeight: _outputHeight),
              paints: _room.currentMonsterDrawing().top.getScaledPaints(outputHeight: _outputHeight),
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
              _room.currentMonsterDrawing().middle.getScaledPaths(outputHeight: _outputHeight),
              paints: _room.currentMonsterDrawing().middle.getScaledPaints(outputHeight: _outputHeight),
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
              _room.currentMonsterDrawing().bottom.getScaledPaths(outputHeight: _outputHeight),
              paints: _room.currentMonsterDrawing().bottom.getScaledPaints(outputHeight: _outputHeight),
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

class AgreeToShareMonsterScreen extends StatefulWidget {
  final MonsterDrawing monsterDrawing;
  final Tuple2<int, String> monsterIndexAndName;
  final GameRoom room;

  AgreeToShareMonsterScreen({
    Key key,
    @required this.monsterDrawing,
    @required this.monsterIndexAndName,
    @required this.room,
  })  : assert(monsterIndexAndName.item1 > 0 && monsterIndexAndName.item1 < 4, 'invalid monster index in AgreeToShareMonsterScreen'),
        super(key: key);

  @override
  _AgreeToShareMonsterScreenState createState() => _AgreeToShareMonsterScreenState();
}

class _AgreeToShareMonsterScreenState extends State<AgreeToShareMonsterScreen> {
  int monsterIndex;

  /// A list of bools for if the user agrees to share the monster of the respective index (index 0 is monster 1 etc)
  final List<bool> userAgreesList = [null, null, null];

  final _db = DatabaseService.instance;

  @override
  Widget build(BuildContext context) {
    monsterIndex = widget.monsterIndexAndName.item1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 10),
                FittedBox(
                  child: Text(
                    'Do you agree to share the drawing?',
                    style: TextStyle(
                      color: monsterTextColor,
                      fontSize: 30,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'The game host wants to submit this drawing to Monster Gallery. All players need to agree to submit.',
                  style: TextStyle(
                    color: monsterTextColor,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: FittedBox(
                    child: FramedMonster(
                      drawing: widget.monsterDrawing,
                      monsterName: widget.monsterIndexAndName.item2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 280,
            child: Column(
              children: [
                SizedBox(height: 20),
                LicenceCheckbox(
                  isAgreementBox: true,
                  userAgrees: userAgreesList[monsterIndex - 1],
                  onTap: () => setState(() {
                    userAgreesList[monsterIndex - 1] = true;
                  }),
                ),
                SizedBox(height: 30),
                LicenceCheckbox(
                  isAgreementBox: false,
                  userAgrees: userAgreesList[monsterIndex - 1],
                  onTap: () => setState(() {
                    userAgreesList[monsterIndex - 1] = false;
                  }),
                ),
                SizedBox(height: 30),
                ModalBackGameButton(
                  onPressed: userAgreesList[monsterIndex - 1] == null
                      ? null
                      : () {
                          _db.agreeToShareMonster(
                            monsterIndex: widget.monsterIndexAndName.item1,
                            userAgrees: userAgreesList[monsterIndex - 1],
                            room: widget.room,
                          );
                        },
                  buttonLabel: 'CONTINUE',
                ),
                SizedBox(height: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
