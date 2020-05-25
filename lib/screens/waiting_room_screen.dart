import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:provider/provider.dart';

import 'package:exquisitecorpse/models.dart';
import 'package:exquisitecorpse/db.dart';
import 'package:exquisitecorpse/game_state.dart';
import 'package:exquisitecorpse/components/buttons.dart';
import 'package:exquisitecorpse/components/text_components.dart';
import 'package:exquisitecorpse/components/colors.dart';

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
      backgroundColor: paper,
      body: SafeArea(
        child: StreamBuilder<GameRoom>(
          stream: _db.streamWaitingRoom(roomCode: roomCode),
          builder: (context, snapshot) {
            if (snapshot.data == null) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            return _loading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: <Widget>[
                              LeaveGameButton(
                                onPressed: () {
                                  _db.leaveRoom(roomCode: snapshot.data.roomCode).then((value) {
                                    if (value) {
                                      Navigator.of(context).pushReplacementNamed('/');
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 12, bottom: 30),
                            child: RoomCodeInfo(roomCode: snapshot.data.roomCode),
                          ),
                          WaitingRoomText(playersReady: snapshot.data.activePlayers, isHost: snapshot.data.isHost),
                        ],
                      ),
                      if (snapshot.data.isHost && startGame(snapshot) != null)
                        Padding(
                          padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height / 4),
                          child: GreenGameButton(
                            label: "START GAME",
                            onPressed: startGame(snapshot),
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
      if (result) {
        Navigator.of(context).pushReplacementNamed('/getReadyScreen');
      }
      setState(() {
        _loading = false;
      });
    };
  }
}
