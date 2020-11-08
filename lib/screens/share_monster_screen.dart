import 'package:flutter/material.dart';

import 'package:exquisitecorpse/widgets/colors.dart';
import 'package:exquisitecorpse/widgets/MonsterFrameWidgets.dart';
import 'package:exquisitecorpse/widgets/buttons.dart';
import 'package:provider/provider.dart';

import '../db.dart';
import '../game_state.dart';
import '../models.dart';

class ShareMonsterScreen extends StatefulWidget {
  @override
  _ShareMonsterScreenState createState() => _ShareMonsterScreenState();
}

class _ShareMonsterScreenState extends State<ShareMonsterScreen> {
  final _db = DatabaseService.instance;
  MonsterDrawing drawing;
  bool fetching = false;

  @override
  Widget build(BuildContext context) {
    final GameState gameState = Provider.of<GameState>(context);

    return Scaffold(
      backgroundColor: paper,
      body: SafeArea(
        child: StreamBuilder<GameRoom>(
            stream: _db.streamGameRoom(roomCode: gameState.currentRoomCode),
            builder: (context, snapshot) {
              if (snapshot.data == null) {
                return Center(child: CircularProgressIndicator());
              }

              GameRoom room = snapshot.data;

              return Column(
                children: [
                  Row(
                    children: [
                      BackGameButton(
                        onPressed: () {
                          Navigator.of(context).maybePop();
                        },
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      MonsterFrame(
                        drawing: room.monsterDrawing,
                        //frameHeight: 200, //TODO: rätt storlek
                      ),
                    ],
                  ),
                ],
              );
            }),
      ),
    );
  }
}
