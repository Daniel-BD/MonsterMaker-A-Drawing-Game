import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import 'package:exquisitecorpse/db.dart';
import 'package:exquisitecorpse/game_state.dart';

class StartScreen extends StatefulWidget {
  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  final _db = DatabaseService.instance;
  var _loading = false;
  var _inputtingRoomCode = false;
  var _roomCodeController = TextEditingController();
  var _joinGameKey = GlobalKey();
  var _overlap = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                      StartScreenButton(
                        padding: 20,
                        color: Colors.greenAccent[200],
                        text: 'New Game',
                        onPressed: () => _createNewGame(),
                      ),
                    if (_inputtingRoomCode)
                      RoomCodeTextField(
                        controller: _roomCodeController,
                        onSubmitted: (str) => _joinRoom(context),
                      ),
                    Padding(
                      padding: EdgeInsets.only(bottom: _overlap),
                      child: StartScreenButton(
                        color: Colors.blueAccent[100],
                        text: 'Join Game',
                        key: _joinGameKey,
                        onPressed: () => _joinRoom(context),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  void _createNewGame() async {
    setState(() {
      _loading = true;
    });

    Tuple2<bool, String> result = await _db.createNewRoom();

    if (result.item1) {
      Provider.of<GameState>(context, listen: false).currentRoomCode = result.item2;
      Navigator.of(context).pushReplacementNamed('/waitingRoom');
    } else {
      assert(false, 'creating new room failed');
      setState(() {
        _loading = false;
      });
    }
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

      String roomCode = _roomCodeController.text;
      var success = await _db.joinRoom(roomCode: roomCode);

      if (success) {
        Provider.of<GameState>(context, listen: false).currentRoomCode = roomCode;
        Navigator.of(context).pushReplacementNamed('/waitingRoom');
      } else {
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

class RoomCodeTextField extends StatefulWidget {
  RoomCodeTextField({
    Key key,
    @required this.controller,
    @required this.onSubmitted,
  })  : assert(controller != null),
        assert(onSubmitted != null),
        super(key: key);

  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;

  @override
  _RoomCodeTextFieldState createState() => _RoomCodeTextFieldState();
}

class _RoomCodeTextFieldState extends State<RoomCodeTextField> {
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 150),
      child: TextField(
        controller: widget.controller,
        textCapitalization: TextCapitalization.characters,
        textAlign: TextAlign.center,
        cursorColor: Colors.purple[200],
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        maxLength: 4,
        onSubmitted: widget.onSubmitted,
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
    );
  }
}

class StartScreenButton extends StatelessWidget {
  StartScreenButton({
    Key key,
    this.padding = 0,
    @required this.color,
    @required this.text,
    @required this.onPressed,
  })  : assert(color != null),
        assert(text != null),
        assert(onPressed != null),
        super(key: key);

  final Color color;
  final String text;
  final VoidCallback onPressed;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: padding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 0),
            child: FlatButton(
              color: color,
              child: Text(text),
              onPressed: onPressed,
            ),
          ),
        ],
      ),
    );
  }
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
