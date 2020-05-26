import 'package:flutter/material.dart';

import 'buttons.dart';
import 'colors.dart';

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

/// INTERNAL CLASSES
class _GameModal extends StatelessWidget {
  final Color borderColor;
  final Widget leftButton;
  final String label;

  const _GameModal({
    Key key,
    @required this.borderColor,
    @required this.leftButton,
    @required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
        ),
        child: Container(
          height: 200,
          width: 300,
          decoration: BoxDecoration(
            color: textFieldBackground,
            borderRadius: BorderRadius.all(Radius.circular(20)),
            border: Border.all(width: 4, color: borderColor),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Gaegu',
                    color: textColor,
                    fontSize: 26,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    leftButton,
                    ModalBackGameButton(
                      onPressed: () => Navigator.of(context).pop(),
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
