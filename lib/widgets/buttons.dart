import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_icons/flutter_icons.dart';

import '../constants.dart';

/// CANVAS CONTROL BUTTONS

class HideShowControlsButton extends StatelessWidget {
  final GestureTapCallback onPressed;
  final bool controlsVisible;

  const HideShowControlsButton({Key key, @required this.onPressed, @required this.controlsVisible}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _RoundGameButton(
      onPressed: onPressed,
      icon: controlsVisible ? Icons.visibility_off : Icons.visibility,
      buttonColor: blue,
    );
  }
}

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
    return _RoundGameButton(
      onPressed: onPressed,
      icon: color != paper ? Icons.brush : MaterialCommunityIcons.eraser,
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
      isMonsterControl: true,
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
      isMonsterControl: true,
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
      isMonsterControl: true,
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
      isMonsterControl: true,
    );
  }
}

/// ANIMATE ORDER BUTTON

/*class AnimateOrderButton extends StatelessWidget {
  final GestureTapCallback onPressed;
  final bool animatingOneByOne;
  final style = TextStyle(
    fontFamily: 'Gaegu',
    color: monsterTextColor,
    fontSize: 100,
  );

  AnimateOrderButton({
    Key key,
    this.onPressed,
    this.animatingOneByOne = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width / 3;

    return _GameButton(
      onPressed: onPressed,
      color: blue,
      height: width / 3,
      width: width,
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
} */

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
    return BigGameButton(
      onPressed: onPressed,
      label: label,
      color: onPressed != null ? green : disabled,
      textColor: onPressed != null ? monsterTextColor : disabledText,
    );
  }
}

class SubmitMonsterButton extends StatelessWidget {
  final GestureTapCallback onPressed;

  SubmitMonsterButton({
    @required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return BigGameButton(
      onPressed: onPressed,
      child: Column(
        children: [
          SizedBox(height: 4),
          Text(
            'SUBMIT',
            style: GoogleFonts.sniglet(color: monsterTextColor, fontSize: 24),
          ),
          Text(
            'TO MONSTER GALLERY',
            style: GoogleFonts.sniglet(color: monsterTextColor, fontSize: 16),
          ),
        ],
      ),
      color: onPressed != null ? green : disabled,
      textColor: onPressed != null ? monsterTextColor : disabledText,
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
    return BigGameButton(
      onPressed: onPressed,
      label: label,
      color: onPressed != null ? blue : disabled,
      textColor: onPressed != null ? monsterTextColor : disabledText,
    );
  }
}

/// BOTTOM CORNER BUTTONS

class ShareButton extends StatelessWidget {
  final GestureTapCallback onPressed;

  ShareButton({@required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return _TopCornerGameButton(
      onPressed: onPressed,
      color: galleryYellow,
      textColor: monsterTextColor,
      leftAligned: false,
      label: "Share to\nMonster Gallery",
      width: min(150.0, MediaQuery.of(context).size.width / 2),
    );
  }
}

class QuitButton extends StatelessWidget {
  final GestureTapCallback onPressed;

  QuitButton({@required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return _TopCornerGameButton(
      onPressed: onPressed,
      color: warning,
      textColor: onWarning,
      leftAligned: true,
      label: "QUIT",
      width: min(100.0, MediaQuery.of(context).size.width / 4),
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Text(
          "LEAVE GAME",
          style: TextStyle(
            color: onWarning,
            fontSize: 19,
          ),
        ),
      ),
    );
  }
}

class BackGameButton extends StatelessWidget {
  final GestureTapCallback onPressed;

  BackGameButton({@required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return _GameButton(
      onPressed: onPressed,
      height: 50,
      width: 110,
      color: backButtonColor,
      borderRadius: BorderRadius.horizontal(
        right: Radius.circular(16),
      ),
      child: Row(
        children: [
          SizedBox(width: 8),
          Icon(
            Icons.arrow_back,
            color: onWarning,
          ),
          SizedBox(width: 4),
          Text(
            "BACK",
            style: GoogleFonts.sniglet(
              color: onWarning,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }
}

/// MODAL MESSAGE BUTTONS

class ModalBackGameButton extends StatelessWidget {
  final GestureTapCallback onPressed;
  final String buttonLabel;

  ModalBackGameButton({
    @required this.onPressed,
    this.buttonLabel = 'BACK',
  });

  @override
  Widget build(BuildContext context) {
    return _ModalGameButton(
      onPressed: onPressed,
      label: buttonLabel,
      color: onPressed != null ? blue : disabled,
      textColor: onPressed != null ? monsterTextColor : disabledText,
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
  final String buttonLabel;

  ModalDoneGameButton({@required this.onPressed, this.buttonLabel});

  @override
  Widget build(BuildContext context) {
    return _ModalGameButton(
      onPressed: onPressed,
      label: "DONE",
      color: green,
      textColor: monsterTextColor,
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
      borderRadius: BorderRadius.circular(12.0),
      height: 50,
      width: 120,
      color: color,
      child: Text(
        label,
        style: GoogleFonts.sniglet(
          color: textColor,
          fontSize: 20,
        ),
      ),
    );
  }
}

class _TopCornerGameButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final GestureTapCallback onPressed;
  final double width;

  /// If this is true, then the button is shaped to be placed at the left edge of the screen,
  /// if false it's shaped to be placed at the right edge of the screen.
  final bool leftAligned;

  _TopCornerGameButton({
    @required this.onPressed,
    @required this.label,
    @required this.color,
    @required this.textColor,
    @required this.leftAligned,
    @required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return _GameButton(
      onPressed: onPressed,
      height: 50,
      width: width,
      color: color,
      borderRadius: BorderRadius.horizontal(
        left: leftAligned ? Radius.zero : Radius.circular(12),
        right: leftAligned ? Radius.circular(12) : Radius.zero,
      ),
      child: FittedBox(
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.sniglet(
              color: textColor,
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }
}

class _RoundGameButton extends StatelessWidget {
  final IconData icon;
  final Color buttonColor;
  final GestureTapCallback onPressed;
  final bool isMonsterControl;

  _RoundGameButton({
    @required this.onPressed,
    @required this.icon,
    @required this.buttonColor,
    this.isMonsterControl = false,
  });

  @override
  Widget build(BuildContext context) {
    final double luminance = buttonColor.computeLuminance();
    final Size size = MediaQuery.of(context).size;
    final double diameter = 50; //min(((size.height - 70) / 6), 50);
    // TODO: Testa storlek på iPad, iPhone 11

    return _GameButton(
      onPressed: onPressed,
      circular: true,
      height: diameter,
      width: diameter,
      color: buttonColor,
      shadowHeight: 2,
      child: Icon(
        icon,
        size: diameter * 0.7,
        color: luminance < 0.5 ? brightIcon : darkIcon,
      ),
    );
  }
}

class BigGameButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final GestureTapCallback onPressed;
  final Widget child;

  const BigGameButton({
    Key key,
    this.label,
    @required this.color,
    this.textColor = monsterTextColor,
    @required this.onPressed,
    this.child,
  })  : assert(label != null || child != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final buttonWidth = min(300.0, MediaQuery.of(context).size.width * 0.8);

    return _GameButton(
      onPressed: onPressed,
      color: color,
      height: 60,
      width: buttonWidth,
      borderRadius: BorderRadius.circular(12.0),
      child: child != null
          ? child
          : Text(
              label,
              style: GoogleFonts.sniglet(color: textColor, fontSize: 28),
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
    this.duration = 1,
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
    if (widget.onPressed != null) {
      widget.onPressed();
    }
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
