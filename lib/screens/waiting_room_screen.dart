import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:provider/provider.dart';

import 'package:exquisitecorpse/models.dart';
import 'package:exquisitecorpse/db.dart';
import 'package:exquisitecorpse/game_state.dart';

class WaitingRoomScreen extends StatefulWidget {
  WaitingRoomScreen({Key key}) : super(key: key);

  @override
  _WaitingRoomScreenState createState() => _WaitingRoomScreenState();
}

class _WaitingRoomScreenState extends State<WaitingRoomScreen> {
  final _db = DatabaseService.instance;
  bool _loading = false;
  StreamSubscription<GameRoom> _stream;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _stream = _db.streamWaitingRoom(roomCode: Provider.of<GameState>(context, listen: false).currentRoomCode).listen((room) {
      if (room.startedGame) {
        Navigator.of(context).pushReplacementNamed('/getReadyScreen');
      }
    });
  }

  @override
  void dispose() {
    _stream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String roomCode = Provider.of<GameState>(context).currentRoomCode;

    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<GameRoom>(
          stream: _db.streamWaitingRoom(roomCode: roomCode),
          builder: (context, snapshot) {
            if (snapshot.data == null) {
              return Center(
                child: CircularProgressIndicator(backgroundColor: Colors.orange),
              );
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
    /// TODO: Skall vara 3 personer
    if (snapshot.data.activePlayers != 3) {
      return null;
    }
    return () async {
      setState(() {
        _loading = true;
      });
      bool result = await _db.startGame(room: snapshot.data);
      if (result) {
        Navigator.of(context).pushReplacementNamed('/getReadyScreen');
      }
      setState(() {
        _loading = false;
      });
    };
  }
}
