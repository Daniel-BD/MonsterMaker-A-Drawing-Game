import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../db.dart';
import '../game_state.dart';
import '../constants.dart';
import '../widgets/buttons.dart';
import '../widgets/game_text_field.dart';

class PlayModesScreen extends StatefulWidget {
  @override
  _PlayModesScreenState createState() => _PlayModesScreenState();
}

class _PlayModesScreenState extends State<PlayModesScreen> {
  bool _loading = false;
  bool _inputtingRoomCode = false;
  final _db = DatabaseService.instance;
  final _roomCodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: paper,
      body: Builder(builder: (context) {
        return SafeArea(
          child: Column(
            children: [
              Row(
                children: [
                  BackGameButton(
                    onPressed: () {
                      /// If the text input is showing, hide it
                      if (_inputtingRoomCode) {
                        setState(() {
                          _inputtingRoomCode = false;
                          _roomCodeController.clear();
                          FocusScope.of(context).unfocus();
                        });
                      }

                      /// else, pop the route
                      else {
                        Navigator.of(context).maybePop();
                      }
                    },
                  ),
                ],
              ),
              if (_loading)
                Expanded(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              if (!_loading)
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!_inputtingRoomCode)
                        BigGameButton(
                          onPressed: () => _createNewGame(context),
                          label: "NEW GAME",
                          color: green,
                        ),
                      if (_inputtingRoomCode)
                        GameTextField(
                          controller: _roomCodeController,
                          onSubmitted: (str) => _joinRoom(context),
                        ),
                      SizedBox(height: 40),
                      BigGameButton(
                        label: 'JOIN GAME',
                        color: blueButton,
                        onPressed: () => _joinRoom(context),
                      )
                    ],
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  void _createNewGame(BuildContext context) async {
    setState(() => _loading = true);

    String roomCode = await _db.createNewRoom().timeout(Duration(seconds: 10), onTimeout: () => null);

    if (roomCode != null) {
      Provider.of<GameState>(context, listen: false).currentRoomCode = roomCode;
      Navigator.of(context).pushReplacementNamed('/waitingRoom');
    } else {
      assert(false, 'creating new room failed...');
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
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text("Something went wrong... Check if the room code is correct and you have internet connection"),
          ),
        );
        //assert(false, 'join room failed');
      }
      setState(() {
        _loading = false;
      });
    }
  }
}
