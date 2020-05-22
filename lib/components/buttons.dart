import 'package:flutter/material.dart';
import 'dart:ui';

import 'colors.dart';

/// CANVAS CONTROL BUTTONS

class UndoButton extends StatelessWidget {
  final GestureTapCallback onPressed;

  UndoButton({@required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return _RoundGameButton(
      onPressed: onPressed,
      icon: Icons.undo,
      buttonColor: blue,
    );
  }
}

class RedoButton extends StatelessWidget {
  final GestureTapCallback onPressed;

  RedoButton({@required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return _RoundGameButton(
      onPressed: onPressed,
      icon: Icons.redo,
      buttonColor: blue,
    );
  }
}

class DeleteButton extends StatelessWidget {
  final GestureTapCallback onPressed;

  DeleteButton({@required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return _RoundGameButton(
      onPressed: onPressed,
      icon: Icons.delete,
      buttonColor: warning,
    );
  }
}

class DoneButton extends StatelessWidget {
  final GestureTapCallback onPressed;

  DoneButton({@required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return _RoundGameButton(
      onPressed: onPressed,
      icon: Icons.check,
      buttonColor: green,
    );
  }
}

class BrushButton extends StatelessWidget {
  final Color color;
  final GestureTapCallback onPressed;

  BrushButton({
    @required this.onPressed,
    this.color = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    print(color.toString());

    return _RoundGameButton(
      onPressed: onPressed,
      icon: Icons.brush,
      buttonColor: color,
    );
  }
}

/// MONSTER PLAYBACK BUTTONS

class PlayButton extends StatelessWidget {
  final GestureTapCallback onPressed;

  PlayButton({@required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return _RoundGameButton(
      onPressed: onPressed,
      icon: Icons.play_arrow,
      buttonColor: green,
    );
  }
}

class StopButton extends StatelessWidget {
  final GestureTapCallback onPressed;

  StopButton({@required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return _RoundGameButton(
      onPressed: onPressed,
      icon: Icons.stop,
      buttonColor: blue,
    );
  }
}

class PreviousButton extends StatelessWidget {
  final GestureTapCallback onPressed;

  PreviousButton({@required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return _RoundGameButton(
      onPressed: onPressed,
      icon: Icons.skip_previous,
      buttonColor: blue,
    );
  }
}

class NextButton extends StatelessWidget {
  final GestureTapCallback onPressed;

  NextButton({@required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return _RoundGameButton(
      onPressed: onPressed,
      icon: Icons.skip_next,
      buttonColor: blue,
    );
  }
}

/// ANIMATE ORDER BUTTON

class AnimateOrderButton extends StatelessWidget {
  final GestureTapCallback onPressed;
  final bool animatingOneByOne;
  final style = TextStyle(
    fontFamily: 'Gaegu',
    color: textColor,
    fontSize: 16,
  );

  AnimateOrderButton({
    Key key,
    this.onPressed,
    this.animatingOneByOne = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _GameButton(
      onPressed: onPressed,
      color: blue,
      height: 40,
      width: 150,
      child: FittedBox(
        child: Column(
          children: <Widget>[
            Text(
              'ANIMATE',
              style: style,
            ),
            Text(
              animatingOneByOne ? "ALL AT ONCE" : "ONE BY ONE",
              style: style,
            ),
          ],
        ),
      ),
    );
  }
}

/// BIG GAME BUTTONS

class GreenGameButton extends StatelessWidget {
  final GestureTapCallback onPressed;
  final String label;

  GreenGameButton({
    @required this.onPressed,
    @required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return _BigGameButton(
      onPressed: onPressed,
      label: label,
      color: green,
    );
  }
}

class BlueGameButton extends StatelessWidget {
  final GestureTapCallback onPressed;
  final String label;

  BlueGameButton({
    @required this.onPressed,
    @required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return _BigGameButton(
      onPressed: onPressed,
      label: label,
      color: blue,
    );
  }
}

/// BOTTOM CORNER BUTTONS

class ShareButton extends StatelessWidget {
  final GestureTapCallback onPressed;

  ShareButton({@required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return _BottomCornerGameButton(
      onPressed: onPressed,
      color: blue,
      textColor: textColor,
      leftAligned: false,
      label: "SHARE",
    );
  }
}

class QuitButton extends StatelessWidget {
  final GestureTapCallback onPressed;

  QuitButton({@required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return _BottomCornerGameButton(
      onPressed: onPressed,
      color: warning,
      textColor: onWarning,
      leftAligned: true,
      label: "QUIT",
    );
  }
}

/// TOP CORNER BUTTONS

class LeaveGameButton extends StatelessWidget {
  final GestureTapCallback onPressed;

  LeaveGameButton({@required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return _GameButton(
      onPressed: onPressed,
      height: 50,
      width: 120,
      color: warning,
      borderRadius: BorderRadius.horizontal(
        right: Radius.circular(16),
      ),
      child: Text(
        "LEAVE GAME",
        style: TextStyle(
          fontFamily: 'Gaegu',
          color: onWarning,
          fontSize: 20,
        ),
      ),
    );
  }
}

/// MODAL MESSAGE BUTTONS

class ModalBackGameButton extends StatelessWidget {
  final GestureTapCallback onPressed;

  ModalBackGameButton({@required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return _ModalGameButton(
      onPressed: onPressed,
      label: "BACK",
      color: blue,
      textColor: textColor,
    );
  }
}

class ModalClearGameButton extends StatelessWidget {
  final GestureTapCallback onPressed;

  ModalClearGameButton({@required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return _ModalGameButton(
      onPressed: onPressed,
      label: "CLEAR",
      color: warning,
      textColor: onWarning,
    );
  }
}

class ModalDoneGameButton extends StatelessWidget {
  final GestureTapCallback onPressed;

  ModalDoneGameButton({@required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return _ModalGameButton(
      onPressed: onPressed,
      label: "DONE",
      color: green,
      textColor: textColor,
    );
  }
}

class ModalQuitGameButton extends StatelessWidget {
  final GestureTapCallback onPressed;

  ModalQuitGameButton({@required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return _ModalGameButton(
      onPressed: onPressed,
      label: "QUIT",
      color: warning,
      textColor: onWarning,
    );
  }
}

/// INTERNAL CLASSES

class _ModalGameButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final GestureTapCallback onPressed;

  _ModalGameButton({
    @required this.onPressed,
    @required this.label,
    @required this.color,
    @required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return _GameButton(
      onPressed: onPressed,
      height: 50,
      width: 120,
      color: color,
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Gaegu',
          color: textColor,
          fontSize: 20,
        ),
      ),
    );
  }
}

class _BottomCornerGameButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final GestureTapCallback onPressed;

  /// If this is true, then the button is shaped to be placed at the left edge of the screen,
  /// if false it's shaped to be placed at the right edge of the screen.
  final bool leftAligned;

  _BottomCornerGameButton({
    @required this.onPressed,
    @required this.label,
    @required this.color,
    @required this.textColor,
    @required this.leftAligned,
  });

  @override
  Widget build(BuildContext context) {
    return _GameButton(
      onPressed: onPressed,
      height: 50,
      width: 70,
      color: color,
      borderRadius: BorderRadius.horizontal(
        left: leftAligned ? Radius.zero : Radius.circular(16),
        right: leftAligned ? Radius.circular(16) : Radius.zero,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Gaegu',
          color: textColor,
          fontSize: 20,
        ),
      ),
    );
  }
}

class _RoundGameButton extends StatelessWidget {
  final IconData icon;
  final Color buttonColor;
  final GestureTapCallback onPressed;

  _RoundGameButton({
    @required this.onPressed,
    @required this.icon,
    @required this.buttonColor,
  });

  @override
  Widget build(BuildContext context) {
    final double luminance = buttonColor.computeLuminance();

    return _GameButton(
      onPressed: onPressed,
      circular: true,
      height: 40,
      width: 40,
      color: buttonColor,
      shadowHeight: 2,
      child: Icon(
        icon,
        size: 30,
        color: luminance < 0.5 ? brightIcon : darkIcon,
      ),
    );
  }
}

class _BigGameButton extends StatelessWidget {
  final String label;
  final Color color;
  final GestureTapCallback onPressed;

  _BigGameButton({
    @required this.onPressed,
    @required this.label,
    @required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return _GameButton(
      onPressed: onPressed,
      color: color,
      height: 50,
      width: 200,
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Gaegu',
          color: textColor,
          fontSize: 24,
        ),
      ),
    );
  }
}

class _GameButton extends StatelessWidget {
  final GestureTapCallback onPressed;
  final Color color;
  final double width;
  final double height;
  final Widget child;
  final bool circular;
  final BorderRadiusGeometry borderRadius;
  final double shadowHeight;

  _GameButton({
    @required this.onPressed,
    @required this.color,
    @required this.width,
    @required this.height,
    @required this.child,
    this.circular = false,
    this.borderRadius,
    this.shadowHeight = 4,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedButton(
      onPressed: onPressed,
      height: height,
      width: width,
      color: color,
      shadowDegree: ShadowDegree.dark,
      child: child,
      circular: circular,
      borderRadius: borderRadius,
    );
  }
}

/// Using [ShadowDegree] with values [ShadowDegree.dark] or [ShadowDegree.light]
/// to get a darker version of the used color.
/// [duration] in milliseconds
///
class AnimatedButton extends StatefulWidget {
  final GestureTapCallback onPressed;
  final Widget child;
  final bool enabled;
  final Color color;
  final double height;
  final double width;
  final ShadowDegree shadowDegree;
  final int duration;
  final BorderRadiusGeometry borderRadius;
  final bool circular;
  final double shadowHeight;

  const AnimatedButton({
    Key key,
    @required this.onPressed,
    @required this.child,
    this.enabled = true,
    this.color = Colors.blue,
    this.height = 64,
    this.shadowDegree = ShadowDegree.light,
    this.width = 200,
    this.duration = 70,
    this.borderRadius,
    this.circular = false,
    this.shadowHeight = 4,
  })  : assert(child != null),
        super(key: key);

  @override
  _AnimatedButtonState createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> {
  static const Curve _curve = Curves.easeIn;
  double _position;

  @override
  void initState() {
    super.initState();
    _position = widget.shadowHeight;
  }

  @override
  Widget build(BuildContext context) {
    final double _height = widget.height - widget.shadowHeight;

    return GestureDetector(
      // width here is required for centering the button in parent
      child: Container(
        width: widget.width,
        height: _height + widget.shadowHeight,
        child: Stack(
          children: <Widget>[
            // background shadow serves as drop shadow
            // width is necessary for bottom shadow
            Positioned(
              bottom: 0,
              child: Container(
                height: _height,
                width: widget.width,
                decoration: BoxDecoration(
                  color: widget.enabled ? darken(widget.color, widget.shadowDegree) : darken(Colors.grey, widget.shadowDegree),
                  borderRadius: widget.circular ? null : widget.borderRadius ?? BorderRadius.all(Radius.circular(30)),
                  shape: widget.circular ? BoxShape.circle : BoxShape.rectangle,
                ),
              ),
            ),
            AnimatedPositioned(
              curve: _curve,
              duration: Duration(milliseconds: widget.duration),
              bottom: _position,
              child: Container(
                height: _height,
                width: widget.width,
                decoration: BoxDecoration(
                  color: widget.enabled ? widget.color : Colors.grey,
                  borderRadius: widget.circular ? null : widget.borderRadius ?? BorderRadius.all(Radius.circular(30)),
                  shape: widget.circular ? BoxShape.circle : BoxShape.rectangle,
                ),
                child: Center(
                  child: widget.child,
                ),
              ),
            ),
          ],
        ),
      ),
      onTapDown: widget.enabled ? _pressed : null,
      onTapUp: widget.enabled ? _unPressedOnTapUp : null,
      onTapCancel: widget.enabled ? _unPressed : null,
    );
  }

  void _pressed(_) {
    setState(() {
      _position = 0;
    });
  }

  void _unPressedOnTapUp(_) => _unPressed();

  void _unPressed() {
    setState(() {
      _position = widget.shadowHeight;
    });
    widget.onPressed();
  }
}

// Get a darker color from any entered color.
// Thanks to @NearHuscarl on StackOverflow
Color darken(Color color, ShadowDegree degree) {
  double amount = degree == ShadowDegree.dark ? 0.3 : 0.12;
  final hsl = HSLColor.fromColor(color);
  final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

  return hslDark.toColor();
}

enum ShadowDegree { light, dark }
