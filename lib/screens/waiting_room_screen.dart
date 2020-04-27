import 'package:exquisitecorpse/models.dart';
import 'package:flutter/material.dart';

import 'package:exquisitecorpse/db.dart';

class WaitingRoomScreen extends StatefulWidget {
  final String roomCode;

  WaitingRoomScreen({Key key, @required this.roomCode}) : super(key: key);

  @override
  _WaitingRoomScreenState createState() => _WaitingRoomScreenState();
}

class _WaitingRoomScreenState extends State<WaitingRoomScreen> {
  final _db = DatabaseService.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<WaitingRoom>(
          stream: _db.streamWaitingRoom(roomCode: widget.roomCode),
          builder: (context, snapshot) {
            if (snapshot.data == null) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            return Center(
              child: Column(
                children: [
                  Container(height: 10),
                  Text('Room Code'),
                  Text(
                    snapshot.data.roomCode,
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
                  ),
                  Text(
                    '${snapshot.data.activePlayers} player(s) in the room',
                    style: TextStyle(fontSize: 20),
                  ),
                  if (snapshot.data.isHost)
                    FlatButton(
                      child: Text('START GAME'),
                      color: Colors.green,
                      disabledColor: Colors.grey[300],
                      onPressed: snapshot.data.activePlayers != 3
                          ? null
                          : () {
                              print("STARTING GAME!");
                            },
                    ),
                  if (!snapshot.data.isHost && snapshot.data.startedGame == false) Text('Waiting for the host to start the game'),
                  if (snapshot.data.startedGame == true) Text('The game has started!!'),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
