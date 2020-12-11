import 'dart:math';

import 'package:exquisitecorpse/models.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
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

class AskingSomePlayersToAgreeAgain extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _GameModal(
      borderColor: green,
      leftButton: Container(),
      label: 'Players who did not agree to share\nthe monster have been asked again',
      onlyTextAndOKButton: true,
    );
  }
}

class GameHostAgreeToSubmitMonsterGameModal extends StatefulWidget {
  final bool isHost;
  final int monsterIndex;
  final Function(bool) onContinuePressed;

  const GameHostAgreeToSubmitMonsterGameModal({
    Key key,
    @required this.isHost,
    @required this.monsterIndex,
    @required this.onContinuePressed,
  }) : super(key: key);

  @override
  _GameHostAgreeToSubmitMonsterGameModalState createState() => _GameHostAgreeToSubmitMonsterGameModalState();
}

class _GameHostAgreeToSubmitMonsterGameModalState extends State<GameHostAgreeToSubmitMonsterGameModal> {
  bool userAgrees;

  @override
  Widget build(BuildContext context) {
    return _GameModal(
      borderColor: green,
      leftButton: Container(),
      hideButton: true,
      label: 'Do you agree to share the drawing?',
      labelFontSize: 20,
      child: Column(
        children: [
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              widget.isHost
                  ? 'All players need to agree to submit.'
                  : 'The game host wants to submit monster #${widget.monsterIndex} to the Monster Gallery. All players need to agree to submit.',
              textAlign: widget.isHost ? TextAlign.center : null,
            ),
          ),
          SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: LicenceCheckbox(
              isAgreementBox: true,
              userAgrees: userAgrees,
              onTap: () => setState(() {
                userAgrees = true;
              }),
            ),
          ),
          SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: LicenceCheckbox(
              isAgreementBox: false,
              userAgrees: userAgrees,
              onTap: () => setState(() {
                userAgrees = false;
              }),
            ),
          ),
          SizedBox(height: 30),
          ModalBackGameButton(
            onPressed: userAgrees == null
                ? null
                : () {
                    widget.onContinuePressed(userAgrees);
                    Navigator.of(context).maybePop();
                  },
            buttonLabel: 'CONTINUE',
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

bool shouldBeChecked(bool isAgreementBox, bool userAgrees) {
  if (userAgrees == null) {
    return false;
  }
  return (isAgreementBox && userAgrees) || (!isAgreementBox && !userAgrees);
}

class LicenceCheckbox extends StatelessWidget {
  final bool isAgreementBox;
  final bool userAgrees;
  final VoidCallback onTap;

  const LicenceCheckbox({
    Key key,
    @required this.isAgreementBox,
    @required this.userAgrees,
    @required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              child: AnimatedPadding(
                duration: Duration(milliseconds: shouldBeChecked(isAgreementBox, userAgrees) ? 150 : 0),
                padding: EdgeInsets.all(shouldBeChecked(isAgreementBox, userAgrees) ? 4.0 : 36.0),
                child: Container(
                  color: Colors.black,
                ),
              ),
              height: 36.0,
              width: 36.0,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                  width: 4,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: isAgreementBox
              ? Wrap(
                  children: [
                    RichText(
                      text: TextSpan(
                        text: 'I accept that the image may be shared by MonsterMaker according to the',
                        style: DefaultTextStyle.of(context).style,
                        children: [
                          TextSpan(
                            text: ' license terms (press to read)',
                            style: TextStyle(color: CupertinoColors.activeBlue),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                debugPrint('SHOW LICENCE TERMS');
                                //TODO: Öppna licenceavtalet
                              },
                          ),
                        ],
                      ),
                    )
                  ],
                )
              : Text('I don’t agree to share the drawing'),
        ),
      ],
    );
  }
}

/// INTERNAL CLASSES
class _GameModal extends StatelessWidget {
  final Color borderColor;
  final Widget leftButton;
  final String label;
  final double labelFontSize;
  final Widget child;
  final bool onlyTextAndOKButton;
  final bool hideButton;

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
    this.hideButton = false,
    this.labelFontSize = 24,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Widget labelWidget = Text(
      label,
      textAlign: TextAlign.center,
      style: GoogleFonts.sniglet(
        color: monsterTextColor,
        fontSize: labelFontSize,
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
          width: min(MediaQuery.of(context).size.width * 0.9, 400),
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
                    FittedBox(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: labelWidget,
                      ),
                    ),
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
                      padding: const EdgeInsets.only(top: 20, left: 12, right: 12),
                      child: FittedBox(
                        child: labelWidget,
                      ),
                    ),
                    if (child != null) child,
                    if (child == null) SizedBox(height: 60),
                    if (!hideButton)
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
