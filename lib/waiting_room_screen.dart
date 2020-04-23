import 'package:exquisitecorpse/models.dart';
import 'package:flutter/material.dart';

import 'db.dart';

class WaitingRoomScreen extends StatefulWidget {
  final String roomCode;

  WaitingRoomScreen({Key key, @required this.roomCode}) : super(key: key);

  @override
  _WaitingRoomScreenState createState() => _WaitingRoomScreenState();
}

class _WaitingRoomScreenState extends State<WaitingRoomScreen> {
  final _db = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 250, 235, 1),
      body: SafeArea(
        child: StreamBuilder<WaitingRoom>(
          stream: _db.streamWaitingRoom(roomCode: widget.roomCode),
          builder: (context, snapshot) {
            if (snapshot.data == null) {
              return CircularProgressIndicator();
            }
            return Center(
              child: Column(
                children: [
                  Container(height: 10),
                  Text('Room Code'),
                  Text(
                    widget.roomCode,
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
                  ),
                  Text(
                    '${snapshot.data.activePlayers} player(s) in the room',
                    style: TextStyle(fontSize: 20),
                  ),
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
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
