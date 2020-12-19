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
  final _db = DatabaseService.instance;
  GameRoom _room;

  bool _clearCanvas = true;

  /// The index of the monster in the last GameRoom received,
  /// used to know if the monster index has changed by comparing this to the newest GameRoom.monsterIndex
  int _lastMonsterIndex = 1;

  bool _runTopAnimation = false;
  bool _runMidAnimation = false;
  bool _runBottomAnimation = false;

  var _duration = Duration(seconds: 2);
  PathOrder _pathOrder = PathOrders.original;

  double _monsterHeight;
  double _monsterWidth;
  double _monsterPartHeight;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final unsafeArea = MediaQuery.of(context).viewPadding;

    _monsterHeight = MediaQuery.of(context).size.height - 50.0 - 50.0 - 30.0 - 10.0 - unsafeArea.bottom - unsafeArea.top;

    _monsterWidth = _monsterHeight * (2 / 3);
    _monsterPartHeight = _monsterWidth * (9 / 16);

    /*
    debugPrint('before: monsterPart width $_monsterPartWidth');
    debugPrint('before: monsterPart height $_monsterPartHeight');
    */

    if (_monsterWidth > MediaQuery.of(context).size.width) {
      _monsterWidth = MediaQuery.of(context).size.width;
      _monsterPartHeight = _monsterWidth * (9 / 16);
    }

    /*
   debugPrint(
        'viewPadding: ${MediaQuery.of(context).viewPadding}, padding: ${MediaQuery.of(context).padding}, viewInsets: ${MediaQuery.of(context).viewInsets}');

    debugPrint('screen size: ${MediaQuery.of(context).size.toString()}');
    debugPrint('monster height: $_monsterHeight');
    debugPrint('monsterPart width $_monsterPartWidth');
    debugPrint('monsterPart height $_monsterPartHeight');
    */

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

            if (room.monsterIndex != _lastMonsterIndex) {
              _lastMonsterIndex = room.monsterIndex;
              _readyNextMonster();
            }

            final Tuple2<int, String> monsterSharePromptData = room.showAgreeToShareMonsterPrompt();
            if (monsterSharePromptData != null) {
              return AgreeToShareMonsterScreen(
                monsterDrawing: room.monsterDrawings[monsterSharePromptData.item1 - 1],
                monsterIndexAndName: monsterSharePromptData,
                room: room,
                onDone: _startAnimations,
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
                      children: <Widget>[MonsterNumberText(number: _lastMonsterIndex)],
                    ),
                    //if (_clearCanvas || monsterSize == null) _calculateWidget(),
                    SizedBox(
                      height: _monsterHeight,
                      child: _clearCanvas ? Container() : _monster(context), //Monster(monsterHeight: _monsterHeight, room: _room),
                    ),
                    //if (!_clearCanvas /*&& monsterSize != null*/) _monster(context),
                    if (room.isHost) _controls(context, room),
                    if (!room.isHost) GameHostControlsWhatYouSeeText(),
                    SizedBox(height: 4),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _monster(BuildContext context) {
    final leftPosition = 0.0; //(MediaQuery.of(context).size.width - _monsterPartWidth - 20) / 2;

    assert(_room.currentMonsterDrawing() != null, 'current MonsterDrawing is null, this will crash the app...');

    return SizedBox(
      height: _monsterHeight,
      width: _monsterWidth,
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: <Widget>[
          Positioned(
            top: 0.0,
            left: leftPosition,
            child: AnimatedDrawing.paths(
              _room.currentMonsterDrawing().top.getScaledPaths(outputHeight: _monsterPartHeight),
              paints: _room.currentMonsterDrawing().top.getScaledPaints(outputHeight: _monsterPartHeight),
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
            top: _monsterPartHeight * (5 / 6),
            left: leftPosition,
            child: AnimatedDrawing.paths(
              _room.currentMonsterDrawing().middle.getScaledPaths(outputHeight: _monsterPartHeight),
              paints: _room.currentMonsterDrawing().middle.getScaledPaints(outputHeight: _monsterPartHeight),
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
            top: 2 * _monsterPartHeight * (5 / 6),
            left: leftPosition,
            child: AnimatedDrawing.paths(
              _room.currentMonsterDrawing().bottom.getScaledPaths(outputHeight: _monsterPartHeight),
              paints: _room.currentMonsterDrawing().bottom.getScaledPaints(outputHeight: _monsterPartHeight),
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

  Widget _controls(BuildContext context, GameRoom room) {
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
                  if (room.monsterIndex > 1) {
                    _db.setMonsterIndex(room.monsterIndex - 1, room: _room);
                  }
                },
              ),
              NextButton(
                onPressed: () {
                  if (room.monsterIndex < 3) {
                    _db.setMonsterIndex(room.monsterIndex + 1, room: _room);
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
  final VoidCallback onDone;

  AgreeToShareMonsterScreen({
    Key key,
    @required this.monsterDrawing,
    @required this.monsterIndexAndName,
    @required this.room,
    this.onDone,
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
                          /// TODO: hantera om detta failar, tex pga dåligt internet - visa felmeddelande?
                          /// gör en metod av snackbar som visas när man skriver in fel rumskod,
                          /// så man kan mata in context, felmeddelnade och hur länge den ska visas, så kan man enkelt ha det överallt
                          _db.agreeToShareMonster(
                            monsterIndex: widget.monsterIndexAndName.item1,
                            userAgrees: userAgreesList[monsterIndex - 1],
                            room: widget.room,
                          );
                          widget.onDone();
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

/*
class Monster extends StatefulWidget {
  final double monsterHeight;
  final GameRoom room;

  const Monster({
    Key key,
    this.monsterHeight,
    this.room,
  }) : super(key: key);

  @override
  _MonsterState createState() => _MonsterState();
}

class _MonsterState extends State<Monster> {
  @override
  void initState() {
    super.initState();
    assert(widget.room.currentMonsterDrawing() != null, 'current MonsterDrawing is null, this will crash the app...');
  }

  bool _runTopAnimation = false;
  bool _runMidAnimation = false;
  bool _runBottomAnimation = false;
  var _duration = Duration(seconds: 2);
  PathOrder _pathOrder = PathOrders.original;
  final leftPosition = 0.0;
  double _monsterWidth;
  double _monsterPartHeight;

  @override
  Widget build(BuildContext context) {
    _monsterWidth = widget.monsterHeight * (2 / 3);
    _monsterPartHeight = _monsterWidth * (9 / 16);

    /*
    debugPrint('before: monsterPart width $_monsterPartWidth');
    debugPrint('before: monsterPart height $_monsterPartHeight');
    */

    if (_monsterWidth > MediaQuery.of(context).size.width) {
      _monsterWidth = MediaQuery.of(context).size.width;
      _monsterPartHeight = _monsterWidth * (9 / 16);
    }

    /*
   debugPrint(
        'viewPadding: ${MediaQuery.of(context).viewPadding}, padding: ${MediaQuery.of(context).padding}, viewInsets: ${MediaQuery.of(context).viewInsets}');

    debugPrint('screen size: ${MediaQuery.of(context).size.toString()}');
    debugPrint('monster height: $_monsterHeight');
    debugPrint('monsterPart width $_monsterPartWidth');
    debugPrint('monsterPart height $_monsterPartHeight');
    */

    return Container(
      color: Colors.blue,
      child: SizedBox(
        height: widget.monsterHeight,
        width: _monsterWidth,
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: <Widget>[
            Positioned(
              top: 0.0,
              left: leftPosition,
              child: AnimatedDrawing.paths(
                widget.room.currentMonsterDrawing().top.getScaledPaths(outputHeight: _monsterPartHeight),
                paints: widget.room.currentMonsterDrawing().top.getScaledPaints(outputHeight: _monsterPartHeight),
                run: _runTopAnimation,
                animationOrder: _pathOrder,
                scaleToViewport: false,
                duration: _duration,
                onFinish: () => setState(() {
                  _runTopAnimation = false;
                  if (!widget.room.animateAllAtOnce) {
                    _runMidAnimation = true;
                  }
                }),
              ),
            ),
            Positioned(
              top: _monsterPartHeight * (5 / 6),
              left: leftPosition,
              child: AnimatedDrawing.paths(
                widget.room.currentMonsterDrawing().middle.getScaledPaths(outputHeight: _monsterPartHeight),
                paints: widget.room.currentMonsterDrawing().middle.getScaledPaints(outputHeight: _monsterPartHeight),
                run: _runMidAnimation,
                animationOrder: _pathOrder,
                scaleToViewport: false,
                duration: _duration,
                onFinish: () => setState(() {
                  _runMidAnimation = false;
                  if (!widget.room.animateAllAtOnce) {
                    _runBottomAnimation = true;
                  }
                }),
              ),
            ),
            Positioned(
              top: 2 * _monsterPartHeight * (5 / 6),
              left: leftPosition,
              child: AnimatedDrawing.paths(
                widget.room.currentMonsterDrawing().bottom.getScaledPaths(outputHeight: _monsterPartHeight),
                paints: widget.room.currentMonsterDrawing().bottom.getScaledPaints(outputHeight: _monsterPartHeight),
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
}
*/
