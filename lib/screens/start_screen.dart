import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import 'package:exquisitecorpse/db.dart';
import 'package:exquisitecorpse/game_state.dart';
import 'package:exquisitecorpse/components/buttons.dart';
import 'package:exquisitecorpse/components/game_text_field.dart';
import 'package:exquisitecorpse/components/text_components.dart';
import 'package:exquisitecorpse/components/colors.dart';

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
      backgroundColor: paper,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: _inputtingRoomCode ? null : FittedBox(child: MonsterMakerLogo()),
        leading: _inputtingRoomCode
            ? IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: textColor,
                  size: 32,
                ),
                onPressed: () {
                  setState(() {
                    _inputtingRoomCode = false;
                    _roomCodeController.clear();
                  });
                },
              )
            : null,
      ),
      resizeToAvoidBottomInset: false,
      body: Builder(
        builder: (context) => _loading
            ? Center(child: CircularProgressIndicator())
            : SafeArea(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (!_inputtingRoomCode)
                        GreenGameButton(
                          onPressed: () => _createNewGame(context),
                          label: "NEW GAME",
                        ),
                      if (_inputtingRoomCode)
                        GameTextField(
                          controller: _roomCodeController,
                          onSubmitted: (str) => _joinRoom(context),
                        ),
                      Padding(
                        padding: EdgeInsets.only(bottom: _overlap, top: _inputtingRoomCode ? 30 : 40),
                        child: BlueGameButton(
                          label: "JOIN GAME",
                          onPressed: () => _joinRoom(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  void _createNewGame(BuildContext context) async {
    setState(() => _loading = true);

    Tuple2<bool, String> result = await _db.createNewRoom().timeout(Duration(seconds: 10), onTimeout: () => null);

    if (result?.item1 == true) {
      Provider.of<GameState>(context, listen: false).currentRoomCode = result.item2;
      Navigator.of(context).pushReplacementNamed('/waitingRoom');
    } else {
      assert(false, 'creating new room failed');
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text("Something went wrong... Check your internet connection or try again later"),
        ),
      );
      setState(() => _loading = false);
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

      String roomCode = _roomCodeController.text.toUpperCase();
      bool success = await _db.joinRoom(roomCode: roomCode).timeout(Duration(seconds: 10), onTimeout: () => null);

      if (success == true) {
        Provider.of<GameState>(context, listen: false).currentRoomCode = roomCode;
        Navigator.of(context).pushReplacementNamed('/waitingRoom');
      } else {
        assert(false, 'join room failed');
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text("Something went wrong... Check if the room code is correct and you have internet connection"),
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
