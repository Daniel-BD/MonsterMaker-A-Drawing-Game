import 'package:exquisitecorpse/widgets/text_components.dart';
import 'package:flutter/material.dart';

import 'package:exquisitecorpse/constants.dart';
import 'package:exquisitecorpse/widgets/framed_monster.dart';
import 'package:exquisitecorpse/widgets/buttons.dart';
import 'package:provider/provider.dart';

import '../db.dart';
import '../game_state.dart';
import '../models.dart';
import '../widgets/modal_message.dart';

class ShareMonsterScreen extends StatefulWidget {
  @override
  _ShareMonsterScreenState createState() => _ShareMonsterScreenState();
}

class _ShareMonsterScreenState extends State<ShareMonsterScreen> {
  final _db = DatabaseService.instance;
  final List<TextEditingController> _nameControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  VoidCallback onControllerChanged;

  @override
  void initState() {
    onControllerChanged = () => setState(() {});

    super.initState();

    _nameControllers.forEach((controller) {
      controller.addListener(onControllerChanged);
    });
  }

  @override
  void dispose() {
    onControllerChanged = () {};
    _nameControllers.forEach((controller) {
      controller.removeListener(onControllerChanged);
    });

    super.dispose();
  }

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
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        FramedMonster(
                          drawing: room.monsterDrawing,
                          isSubmittableMonster: true,
                          nameController: _nameControllers[room.monsterIndex - 1],
                          giveMonsterNamePressed: () {
                            showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (_) => EnterMonsterNameGameModal(
                                nameController: _nameControllers[room.monsterIndex - 1],
                                onPressedDone: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            );
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            PreviousButton(
                              onPressed: () {
                                if (room.monsterIndex > 1) {
                                  _db.setMonsterIndex(room.monsterIndex - 1, room: room);
                                }
                              },
                            ),
                            MonsterNumberText(number: room.monsterIndex),
                            NextButton(
                              onPressed: () {
                                if (room.monsterIndex < 3) {
                                  _db.setMonsterIndex(room.monsterIndex + 1, room: room);
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SubmitMonsterButton(onPressed: () {
                    /// If the monster doesn't yet have a name
                    if (_nameControllers[room.monsterIndex - 1].text.isEmpty) {
                      showDialog(
                        context: context,
                        builder: (_) => GiveMonsterNameFirstGameModal(),
                      );
                    } else {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => AgreeToSubmitMonsterGameModal(
                          isHost: room.isHost,
                          monsterIndex: room.monsterIndex,
                          onContinuePressed: (userAgrees) {
                            // TODO: on continue pressed
                            debugPrint('user agrees: $userAgrees');
                          },
                        ),
                      );
                    }
                  }),
                ],
              );
            }),
      ),
    );
  }
}
