import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'buttons.dart';
import '../constants.dart';
import 'game_text_field.dart';

/// MODALS
class QuitGameModal extends StatelessWidget {
  final GestureTapCallback onPressed;

  const QuitGameModal({
    Key key,
    @required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _GameModal(
      borderColor: warning,
      label: "Do you want to quit the game?",
      leftButton: ModalQuitGameButton(onPressed: onPressed),
    );
  }
}

class ClearDrawingGameModal extends StatelessWidget {
  final GestureTapCallback onPressed;

  const ClearDrawingGameModal({
    Key key,
    @required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _GameModal(
      borderColor: warning,
      label: "Do you want to clear your drawing?",
      leftButton: ModalClearGameButton(onPressed: onPressed),
    );
  }
}

class DoneDrawingGameModal extends StatelessWidget {
  final GestureTapCallback onPressed;

  const DoneDrawingGameModal({
    Key key,
    @required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _GameModal(
      borderColor: green,
      label: "Are you done with your drawing?",
      leftButton: ModalDoneGameButton(onPressed: onPressed),
    );
  }
}

class EnterMonsterNameGameModal extends StatefulWidget {
  final GestureTapCallback onPressedDone;
  final TextEditingController nameController;

  const EnterMonsterNameGameModal({
    Key key,
    @required this.onPressedDone,
    @required this.nameController,
  }) : super(key: key);

  @override
  _EnterMonsterNameGameModalState createState() => _EnterMonsterNameGameModalState();
}

class _EnterMonsterNameGameModalState extends State<EnterMonsterNameGameModal> {
  var monsterNameAtStart;

  @override
  void initState() {
    super.initState();
    monsterNameAtStart = widget.nameController.text;
  }

  @override
  Widget build(BuildContext context) {
    return _GameModal(
      borderColor: green,
      label: "Give your monster a name!",
      leftButton: ModalDoneGameButton(onPressed: widget.onPressedDone),
      onBackPressed: () {
        // When the user presses "BACK" instead of "DONE", we want to reset the monster name to what it was when the modal opened.
        widget.nameController.text = monsterNameAtStart;
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: GameTextField(
          controller: widget.nameController,
          fontSize: 20,
          hintText: 'Monster name...',
          isRoomCode: false,
        ),
      ),
    );
  }
}

class GiveMonsterNameFirstGameModal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _GameModal(
      borderColor: warning,
      leftButton: Container(),
      label: 'Give the monster a name first!',
      onlyTextAndOKButton: true,
    );
  }
}

/// INTERNAL CLASSES
class _GameModal extends StatelessWidget {
  final Color borderColor;
  final Widget leftButton;
  final String label;
  final Widget child;
  final bool onlyTextAndOKButton;

  /// Used for any cleanup that you may want to happen when the modal closes
  final onBackPressed;

  const _GameModal({
    Key key,
    @required this.borderColor,
    @required this.leftButton,
    @required this.label,
    this.child,
    this.onBackPressed,
    this.onlyTextAndOKButton = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Widget labelWidget = Text(
      label,
      textAlign: TextAlign.center,
      style: GoogleFonts.sniglet(
        color: monsterTextColor,
        fontSize: 24,
      ),
    );

    return Center(
      child: Material(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
        ),
        child: Container(
          //height: child == null ? 200 : null, //TODO: Testa om modals får konstig storlek
          width: /* child == null ? 300 : */ min(MediaQuery.of(context).size.width * 0.9, 400),
          decoration: BoxDecoration(
            color: textFieldBackground,
            borderRadius: BorderRadius.all(Radius.circular(20)),
            border: Border.all(width: 4, color: borderColor),
          ),
          child: onlyTextAndOKButton
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 20),
                    labelWidget,
                    SizedBox(height: 40),
                    ModalBackGameButton(
                      onPressed: Navigator.of(context).pop,
                      buttonLabel: 'OK',
                    ),
                    SizedBox(height: 20),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                      child: labelWidget,
                    ),
                    if (child != null) child,
                    if (child == null) SizedBox(height: 60), //TODO: Testa om modals får konstig storlek
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          leftButton,
                          ModalBackGameButton(
                            onPressed: () {
                              if (onBackPressed != null) {
                                onBackPressed();
                              }
                              Navigator.of(context).pop();
                            },
                          )
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
