import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

import 'waiting_room_screen.dart';
import 'db.dart';

class StartScreen extends StatefulWidget {
  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  final _db = DatabaseService();
  var _loading = false;
  var _inputtingRoomCode = false;
  var _roomCodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 250, 235, 1),
      body: SafeArea(
        child: _loading
            ? Center(child: CircularProgressIndicator())
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (!_inputtingRoomCode)
                    _button(
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
                    TextField(
                      controller: _roomCodeController,
                    ),
                  _button(
                    color: Colors.blueAccent[100],
                    text: 'Join Game',
                    onPressed: () async {
                      if (!_inputtingRoomCode) {
                        setState(() {
                          _inputtingRoomCode = true;
                        });
                      } else {
                        print(_roomCodeController.text);
                      }
                      //bool result = await _db.joinRoom();
                    },
                  )
                ],
              ),
      ),
    );
  }

  Widget _button({@required Color color, @required String text, @required VoidCallback onPressed}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: FlatButton(
            color: color,
            child: Text(text),
            onPressed: onPressed,
          ),
        ),
      ],
    );
  }
}
