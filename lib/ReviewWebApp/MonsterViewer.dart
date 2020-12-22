import 'package:exquisitecorpse/drawing_storage.dart';
import 'package:exquisitecorpse/widgets/modal_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:drawing_animation/drawing_animation.dart';
import 'package:intl/intl.dart';

import 'package:exquisitecorpse/models.dart';
import 'package:exquisitecorpse/db.dart';
import 'package:exquisitecorpse/widgets/buttons.dart';
import 'package:exquisitecorpse/widgets/text_components.dart';
import 'package:exquisitecorpse/constants.dart';

class MonsterViewer extends StatefulWidget {
  final List<MonsterToReview> monstersToReview;

  const MonsterViewer({Key key, this.monstersToReview}) : super(key: key);

  @override
  _MonsterViewerState createState() => _MonsterViewerState();
}

class _MonsterViewerState extends State<MonsterViewer> {
  final _db = DatabaseService.instance;
  List<String> _roomCodesToReview;

  GameRoom _room;

  bool _clearCanvas = true;

  /// 1 is monster 1 etc
  int _monsterIndex = 1;

  bool _runTopAnimation = false;
  bool _runMidAnimation = false;
  bool _runBottomAnimation = false;

  var _duration = Duration(seconds: 2);
  PathOrder _pathOrder = PathOrders.topToBottom;

  double _monsterHeight;
  double _monsterWidth;
  double _monsterPartHeight;

  int _currentGameRoomIndex = 0;
  int _monsterSubmissionIndex = 0;

  /// If true, we are reviewing monster gallery submission, otherwise we are looking at all monsters in database
  bool reviewingSubmissions() => widget.monstersToReview?.isNotEmpty == true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    if (!reviewingSubmissions()) {
      getRoomCodesToReview();
    } else {
      updateSubmissionReview();
    }
  }

  Future<void> getRoomCodesToReview() async {
    _roomCodesToReview = await _db.gameRoomsToReview();
    _room = await _db.streamGameRoom(roomCode: _roomCodesToReview[_currentGameRoomIndex], isSpectator: true).first;
    setState(() {});
  }

  /// Run this after updating _monsterSubmissionIndex
  updateSubmissionReview() async {
    final monsterToReview = widget.monstersToReview[_monsterSubmissionIndex];
    _room = await _db.streamGameRoom(roomCode: monsterToReview.roomCode, isSpectator: true).first;
    _monsterIndex = monsterToReview.monsterIndex;
    setState(() {});
  }

  void nextOrPreviousGameRoom({next = true}) async {
    print("CURRENT ROOM: " + _roomCodesToReview[_currentGameRoomIndex]);

    if (next) {
      if (_currentGameRoomIndex >= _roomCodesToReview.length - 1) {
        return;
      }
      _room = await _db.streamGameRoom(roomCode: _roomCodesToReview[++_currentGameRoomIndex], isSpectator: true).first;
    } else {
      if (_currentGameRoomIndex <= 0) {
        return;
      }
      _room = await _db.streamGameRoom(roomCode: _roomCodesToReview[--_currentGameRoomIndex], isSpectator: true).first;
    }

    _monsterIndex = 1;
    _startAnimations();
  }

  @override
  Widget build(BuildContext context) {
    final unsafeArea = MediaQuery.of(context).viewPadding;

    _monsterHeight = MediaQuery.of(context).size.height - 100 - unsafeArea.bottom - unsafeArea.top;

    _monsterWidth = _monsterHeight * (2 / 3);
    _monsterPartHeight = _monsterWidth * (9 / 16);

    if (_monsterWidth > MediaQuery.of(context).size.width) {
      _monsterWidth = MediaQuery.of(context).size.width;
      _monsterPartHeight = _monsterWidth * (9 / 16);
    }

    if (_room == null) {
      debugPrint('room is null');
      return CircularProgressIndicator();
    }

    if (!_room.allBottomDrawingsDone()) {
      debugPrint('Room incomplete! ${_room.roomCode}, going to next');
      nextOrPreviousGameRoom(next: true);
      return CircularProgressIndicator();
    }

    String createdAtString = '';
    final roomCreatedAt = _room.createdAt;
    if (roomCreatedAt != null) {
      final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');
      createdAtString = formatter.format(_room.createdAt);
    }

    return Scaffold(
      backgroundColor: paper,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: _monsterHeight,
                  child: _clearCanvas ? Container() : _monster(context),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[Text('Created: $createdAtString, room: ${_room.roomCode},  index: $_monsterIndex')],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Name: ${_room.nameOfSubmittedMonster(_monsterIndex)}',
                      style: TextStyle(fontSize: 20),
                    )
                  ],
                ),
                if (reviewingSubmissions()) _submissionControls(),
                if (!reviewingSubmissions()) _allMonstersControls(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _monster(BuildContext context) {
    final leftPosition = 0.0;

    assert(_room.monsterDrawings[_monsterIndex - 1] != null, 'MonsterDrawing is null, this will crash the app...');

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
              _room.monsterDrawings[_monsterIndex - 1].top.getScaledPaths(outputHeight: _monsterPartHeight),
              paints: _room.monsterDrawings[_monsterIndex - 1].top.getScaledPaints(outputHeight: _monsterPartHeight),
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
              _room.monsterDrawings[_monsterIndex - 1].middle.getScaledPaths(outputHeight: _monsterPartHeight),
              paints: _room.monsterDrawings[_monsterIndex - 1].middle.getScaledPaints(outputHeight: _monsterPartHeight),
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
              _room.monsterDrawings[_monsterIndex - 1].bottom.getScaledPaths(outputHeight: _monsterPartHeight),
              paints: _room.monsterDrawings[_monsterIndex - 1].bottom.getScaledPaints(outputHeight: _monsterPartHeight),
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

  Widget _submissionControls() {
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
                if (_monsterSubmissionIndex > 0) {
                  _monsterSubmissionIndex--;
                  updateSubmissionReview();
                }
              },
            ),
            Container(width: padding),
            NextButton(
              onPressed: () {
                if (_monsterSubmissionIndex < widget.monstersToReview.length - 1) {
                  _monsterSubmissionIndex++;
                  updateSubmissionReview();
                }
              },
            ),
            SizedBox(width: 20),
            RaisedButton(
              color: green,
              child: Text('Accept'),
              onPressed: () {
                _confirmReviewChoice(context, true, () {
                  _db.acceptOrDenyMonsterSubmission(monster: MonsterToReview(_room.roomCode, _monsterIndex), isAccepted: true);
                });
              },
            ),
            SizedBox(width: 20),
            RaisedButton(
              color: warning,
              child: Text('Deny'),
              onPressed: () {
                _confirmReviewChoice(context, false, () {
                  _db.acceptOrDenyMonsterSubmission(monster: MonsterToReview(_room.roomCode, _monsterIndex), isAccepted: false);
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  _confirmReviewChoice(BuildContext context, bool accept, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (_) => Center(
        child: Material(
          child: Container(
            height: 200,
            width: 300,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  accept ? 'Accept to Monster Gallery?' : 'Deny submission?',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    RaisedButton(
                      onPressed: () {
                        onConfirm();
                        Navigator.of(context).maybePop();
                      },
                      color: accept ? green : warning,
                      child: Text(accept ? 'Accept' : 'Deny'),
                    ),
                    RaisedButton(
                      onPressed: () {
                        Navigator.of(context).maybePop();
                      },
                      color: blue,
                      child: Text('Back'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _allMonstersControls() {
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
                  _startAnimations();
                }
              },
            ),
            Container(width: padding),
            NextButton(
              onPressed: () {
                if (_monsterIndex < 3) {
                  _monsterIndex++;
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
      _duration = Duration(milliseconds: 800);
      _runMidAnimation = true;
      _runBottomAnimation = true;
    } else {
      _duration = Duration(milliseconds: 800);
      _runMidAnimation = false;
      _runBottomAnimation = false;
    }

    setState(() {});
  }
}
