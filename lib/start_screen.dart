import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

import 'waiting_room_screen.dart';
import 'db.dart';

class StartScreen extends StatefulWidget {
  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> with WidgetsBindingObserver {
  final _db = DatabaseService();
  var _loading = false;
  var _inputtingRoomCode = false;
  var _roomCodeController = TextEditingController();
  var _joinGameKey = GlobalKey();
  var _overlap = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color.fromRGBO(255, 250, 235, 1),
      body: Builder(
        builder: (context) => _loading
            ? Center(child: CircularProgressIndicator())
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!_inputtingRoomCode)
                      _button(
                        padding: 20,
                        color: Colors.greenAccent[200],
                        text: 'New Game',
                        onPressed: () async {
                          setState(() {
                            _loading = true;
                          });

                          Tuple2<bool, String> result = await _db.createNewRoom();

                          if (result.item1) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => WaitingRoomScreen(roomCode: result.item2)),
                            );
                          }
                        },
                      ),
                    if (_inputtingRoomCode)
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 150),
                        child: TextField(
                          controller: _roomCodeController,
                          textCapitalization: TextCapitalization.characters,
                          textAlign: TextAlign.center,
                          cursorColor: Colors.purple[200],
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                          maxLength: 4,
                          onSubmitted: (str) {
                            print('submitted');
                            _joinRoom(context);
                          },
                          decoration: InputDecoration(
                            counter: Container(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.purple[200],
                                width: 4,
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(20),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(8),
                              ),
                            ),
                            hintText: 'Enter Room Code',
                            hintStyle: TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    _button(
                      padding: _overlap,
                      color: Colors.blueAccent[100],
                      text: 'Join Game',
                      key: _inputtingRoomCode ? _joinGameKey : null,
                      onPressed: () => _joinRoom(context),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  void _joinRoom(BuildContext context) async {
    FocusScope.of(context).unfocus();

    if (!_inputtingRoomCode) {
      setState(() {
        _inputtingRoomCode = true;
      });
    } else {
      setState(() {
        _loading = true;
      });
      var success = await _db.joinRoom(roomCode: _roomCodeController.text);
      if (success) {
        print('SUCCESS!');
      } else {
        print('FAILIURE!');
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text("Something went wrong, perhaps the room code doesn't exist"),
          ),
        );
      }
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void didChangeMetrics() {
    if (_joinGameKey.currentContext == null) {
      return;
    }

    final _lowestPixel = MediaQuery.of(context).size.height - _joinGameKey.globalPaintBounds.bottom;
    final keyboardTopPixels = window.physicalSize.height - window.viewInsets.bottom;
    final keyboardTopPoints = MediaQuery.of(context).size.height - (keyboardTopPixels / window.devicePixelRatio);
    final overlap = keyboardTopPoints - _lowestPixel;

    if (overlap > 0) {
      setState(() {
        _overlap = overlap * 2;
      });
    } else {
      setState(() {
        _overlap = 0;
      });
    }
  }
}

Widget _button({
  @required Color color,
  @required String text,
  @required VoidCallback onPressed,
  GlobalKey key,
  double padding,
}) {
  return Padding(
    padding: EdgeInsets.only(bottom: padding ?? 0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: 0),
          child: FlatButton(
            key: key ?? GlobalKey(),
            color: color,
            child: Text(text),
            onPressed: onPressed,
          ),
        ),
      ],
    ),
  );
}

extension GlobalKeyEx on GlobalKey {
  Rect get globalPaintBounds {
    final renderObject = currentContext?.findRenderObject();
    var translation = renderObject?.getTransformTo(null)?.getTranslation();
    if (translation != null && renderObject.paintBounds != null) {
      return renderObject.paintBounds.shift(Offset(translation.x, translation.y));
    } else {
      return null;
    }
  }
}
