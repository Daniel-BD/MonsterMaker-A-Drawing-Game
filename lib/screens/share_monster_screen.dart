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

              double frameWidth = monsterFrameWidth(context, true);
              double frameHeight = frameWidth * 1.5 + 7.5 * 5 + 28;
              double screenHeight = MediaQuery.of(context).size.height;

              if (screenHeight - 190 < frameHeight) {
                frameHeight = screenHeight - 190;
              }

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
                        SizedBox(
                          child: FittedBox(
                            child: FramedMonster(
                              drawing: room.currentMonsterDrawing(),
                              isSubmittableMonster: true,
                              nameController: _nameControllers[room.monsterIndex - 1],
                              giveMonsterNamePressed: () {
                                showDialog(
                                  barrierDismissible: false,
                                  context: context,
                                  builder: (_) => EnterMonsterNameGameModal(
                                    nameController: _nameControllers[room.monsterIndex - 1],
                                    onPressedDone: () {
                                      _nameControllers[room.monsterIndex - 1].text = _nameControllers[room.monsterIndex - 1].text.trim();
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                          height: frameHeight,
                        ),
                        SizedBox(
                          width: 400, //TODO: Testa på olika skärmstorlekar
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              SizedBox(width: 8),
                              PreviousButton(
                                onPressed: () {
                                  if (room.monsterIndex > 1) {
                                    _db.setMonsterIndex(room.monsterIndex - 1, room: room);
                                  }
                                },
                              ),
                              Expanded(
                                child: MonsterNumberText(number: room.monsterIndex),
                              ),
                              NextButton(
                                onPressed: () {
                                  if (room.monsterIndex < 3) {
                                    _db.setMonsterIndex(room.monsterIndex + 1, room: room);
                                  }
                                },
                              ),
                              SizedBox(width: 8),
                            ],
                          ),
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
                        builder: (_) => GameHostAgreeToSubmitMonsterGameModal(
                          isHost: room.isHost,
                          monsterIndex: room.monsterIndex,
                          onContinuePressed: (userAgrees) {
                            if (room.isHost && !userAgrees) {
                              /// If the host (which is the person that initiates a sharing of a monster) doesn't agree to share it,
                              /// then there's no point in having other players respond if they want to share it or not.
                              return;
                            }
                            _db.agreeToShareMonster(
                              monsterIndex: room.monsterIndex,
                              userAgrees: userAgrees,
                              room: room,
                              monsterName: _nameControllers[room.monsterIndex - 1].text.trim(),
                            );
                          },
                        ),
                      );
                    }
                  }),
                  SizedBox(height: 4),
                ],
              );
            }),
      ),
    );
  }
}
