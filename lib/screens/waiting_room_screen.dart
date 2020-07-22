import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:provider/provider.dart';

import 'package:exquisitecorpse/models.dart';
import 'package:exquisitecorpse/db.dart';
import 'package:exquisitecorpse/game_state.dart';
import 'package:exquisitecorpse/widgets/buttons.dart';
import 'package:exquisitecorpse/widgets/text_components.dart';
import 'package:exquisitecorpse/widgets/colors.dart';

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
    _stream = _db.streamGameRoom(roomCode: Provider.of<GameState>(context, listen: false).currentRoomCode).listen((room) {
      if (room != null && room.startedGame) {
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
      backgroundColor: paper,
      body: SafeArea(
        child: StreamBuilder<GameRoom>(
          stream: _db.streamGameRoom(roomCode: roomCode),
          builder: (context2, snapshot) {
            if (snapshot.data == null || _loading) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            return Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    LeaveGameButton(
                      onPressed: () {
                        setState(() {
                          _loading = true;
                        });
                        _db.leaveRoom(roomCode: roomCode).then((value) {
                          if (value) {
                            Navigator.of(context).pushReplacementNamed('/');
                          }
                        });
                      },
                    ),
                  ],
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      RoomCodeInfo(roomCode: snapshot.data.roomCode),
                      WaitingRoomText(playersReady: snapshot.data.activePlayers, isHost: snapshot.data.isHost),
                      if (snapshot.data.isHost && startGame(snapshot) != null)
                        Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: GreenGameButton(
                            label: "START GAME",
                            onPressed: startGame(snapshot),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
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
      if (!result) {
        assert(false, 'startGame failed!');

        ///TODO: Indicate that something went wrong? Or try again maybe?
      }
      setState(() {
        _loading = false;
      });
    };
  }
}
