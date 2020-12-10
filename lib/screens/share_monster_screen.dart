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

              if (screenHeight - 210 < frameHeight) {
                frameHeight = screenHeight - 210;
              }

              /// How many players have not answered (yes or no) on agreeing to share the current monster
              final int nrPlayersNotAnswered = room.nrOfPlayersNotAnsweredToShareMonster(room.monsterIndex);

              return Column(
                children: [
                  Expanded(
                    child: Column(
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
                                    isSubmittableMonster: !room.isSubmittedToMonsterGallery(room.monsterIndex),
                                    monsterName: room.nameOfSubmittedMonster(room.monsterIndex),
                                    nameController: _nameControllers[room.monsterIndex - 1],
                                    giveMonsterNamePressed: () {
                                      showDialog(
                                        barrierDismissible: false,
                                        context: context,
                                        builder: (_) => EnterMonsterNameGameModal(
                                          nameController: _nameControllers[room.monsterIndex - 1],
                                          onPressedDone: () {
                                            _nameControllers[room.monsterIndex - 1].text =
                                                _nameControllers[room.monsterIndex - 1].text.trim();
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
                                width: 400,
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
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 100,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        nrPlayersNotAnswered == GameState.numberOfPlayersGameMode
                            ? SubmitButton(nameControllers: _nameControllers, room: room, db: _db)
                            : nrPlayersNotAnswered < GameState.numberOfPlayersGameMode && nrPlayersNotAnswered > 0
                                ? Expanded(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(
                                            backgroundColor: monsterTextColor,
                                            valueColor: AlwaysStoppedAnimation<Color>(playButtonColor),
                                          ),
                                        ),
                                        Text(
                                          'Waiting for response from $nrPlayersNotAnswered ' +
                                              (nrPlayersNotAnswered == 1 ? 'player' : 'players'),
                                        ),
                                        SizedBox(width: 24),
                                      ],
                                    ),
                                  )
                                : room.isSubmittedToMonsterGallery(room.monsterIndex)
                                    ? Expanded(
                                        child: Text(
                                          'Submitted for review!\nThe world’s leading monster experts will evaluate if it should hang in the Monster Gallery.\nCheck back in a few days and it might just be there!',
                                          textAlign: TextAlign.center,
                                        ),
                                      )
                                    : Column(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            'Not all players agreed to share the monster.\nPress SUBMIT below to ask again.',
                                            textAlign: TextAlign.center,
                                          ),
                                          SubmitButton(
                                            nameControllers: _nameControllers,
                                            room: room,
                                            db: _db,
                                          ), //TODO: Att fråga igen måste hanteras på rätt sätt
                                        ],
                                      ),
                        SizedBox(height: 4),
                      ],
                    ),
                  ),
                ],
              );
            }),
      ),
    );
  }
}

/// The submit button at the bottom of the screen, if the monster can be submitted to monster gallery.
class SubmitButton extends StatelessWidget {
  const SubmitButton({
    Key key,
    @required List<TextEditingController> nameControllers,
    @required this.room,
    @required DatabaseService db,
  })  : _nameControllers = nameControllers,
        _db = db,
        super(key: key);

  final List<TextEditingController> _nameControllers;
  final GameRoom room;
  final DatabaseService _db;

  @override
  Widget build(BuildContext context) {
    return SubmitMonsterButton(onPressed: () {
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
    });
  }
}
