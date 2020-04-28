import 'package:exquisitecorpse/models.dart';
import 'package:flutter/material.dart';

import 'package:exquisitecorpse/db.dart';

class WaitingRoomScreen extends StatefulWidget {
  WaitingRoomScreen({Key key, @required this.roomCode}) : super(key: key);

  final String roomCode;

  @override
  _WaitingRoomScreenState createState() => _WaitingRoomScreenState();
}

class _WaitingRoomScreenState extends State<WaitingRoomScreen> {
  final _db = DatabaseService.instance;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<GameRoom>(
          stream: _db.streamWaitingRoom(roomCode: widget.roomCode),
          builder: (context, snapshot) {
            if (snapshot.data == null) {
              return Center(
                child: CircularProgressIndicator(backgroundColor: Colors.orange),
              );
            }

            if (snapshot.data.startedGame) {
              Navigator.of(context).pushReplacementNamed('/drawingScreen', arguments: snapshot.data);
            }

            return Center(
              child: _loading
                  ? CircularProgressIndicator(backgroundColor: Colors.green)
                  : Column(
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
                            onPressed: startGame(snapshot),
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

  VoidCallback startGame(AsyncSnapshot snapshot) {
    if (snapshot.data.activePlayers != 3) {
      return null;
    }
    return () async {
      setState(() {
        _loading = true;
      });
      bool result = await _db.startGame(room: snapshot.data);
      if (result) {
        Navigator.of(context).pushReplacementNamed('/drawingScreen', arguments: snapshot.data);
      }
      setState(() {
        _loading = false;
      });
    };
  }
}
