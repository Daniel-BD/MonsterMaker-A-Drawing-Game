import 'package:flutter/material.dart';

import 'package:exquisitecorpse/components/colors.dart';
import 'package:flutter/services.dart';

class Components extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: paper,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            GreenGameButton(
              label: "BUTTON",
            ),
            Container(height: 40),
            BlueGameButton(
              label: "BUTTON",
            ),
            Container(height: 40),
            AnimateOrderButton(
              label: "ONE BY ONE",
            ),
            Container(height: 40),
            GameTextField(
              controller: TextEditingController(),
            ),
          ],
        ),
      ),
    );
  }
}

class GameTextField extends StatefulWidget {
  final TextEditingController controller;

  GameTextField({@required this.controller});

  @override
  _GameTextFieldState createState() => _GameTextFieldState();
}

class _GameTextFieldState extends State<GameTextField> {
  final focus = FocusNode();
  final controller = TextEditingController();

  final style = TextStyle(
    fontFamily: 'Gaegu',
    color: textColor,
    fontSize: 40,
    fontWeight: FontWeight.w700,
  );

  final hintStyle = TextStyle(
    fontFamily: 'Gaegu',
    color: textColor,
    fontSize: 22,
  );

  final unFocusedBorder = OutlineInputBorder(
    borderRadius: const BorderRadius.all(
      const Radius.circular(8),
    ),
    borderSide: BorderSide(
      width: 2.0,
      color: textColor,
    ),
  );

  final focusedBorder = OutlineInputBorder(
    borderRadius: const BorderRadius.all(
      const Radius.circular(20),
    ),
    borderSide: BorderSide(
      width: 4.0,
      color: focused,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      height: 60,
      width: 200,
      duration: Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: textFieldBackground,
        borderRadius: BorderRadius.all(
          Radius.circular(focus.hasFocus ? 20 : 8),
        ),
      ),
      child: TextField(
        focusNode: focus,
        controller: controller,
        textAlign: TextAlign.center,
        textAlignVertical: TextAlignVertical(y: 1.0),
        cursorColor: focused,
        style: controller.text.isEmpty ? hintStyle : style,
        textCapitalization: TextCapitalization.characters,
        onTap: () => setState(() {}),
        inputFormatters: [
          LengthLimitingTextInputFormatter(4),
        ],
        onChanged: (_) {
          if (controller.text.isNotEmpty) {
            Future.delayed(Duration(milliseconds: 100)).then((value) => setState(() {}));
          } else {
            setState(() {});
          }
        },
        decoration: InputDecoration(
          hintStyle: controller.text.isEmpty ? hintStyle : style,
          hintText: 'Enter Room Code',
          enabledBorder: unFocusedBorder,
          focusedBorder: focusedBorder,
        ),
      ),
    );
  }
}

class AnimateOrderButton extends StatelessWidget {
  final String label;
  final style = TextStyle(
    fontFamily: 'Gaegu',
    color: textColor,
    fontSize: 16,
  );

  AnimateOrderButton({@required this.label});

  @override
  Widget build(BuildContext context) {
    return _GameButton(
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
              label,
              style: style,
            ),
          ],
        ),
      ),
    );
  }
}

class GreenGameButton extends StatelessWidget {
  final String label;

  GreenGameButton({@required this.label});

  @override
  Widget build(BuildContext context) {
    return _GameButton(
      color: green,
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

class BlueGameButton extends StatelessWidget {
  final String label;

  BlueGameButton({@required this.label});

  @override
  Widget build(BuildContext context) {
    return _GameButton(
      color: blue,
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
  final Color color;
  final double width;
  final double height;
  final Widget child;

  _GameButton({
    @required this.color,
    @required this.width,
    @required this.height,
    @required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedButton(
      onPressed: () {},
      height: height,
      width: width,
      color: color,
      shadowDegree: ShadowDegree.dark,
      child: child,
    );
  }
}

class GameButton2 extends StatelessWidget {
  final String label;
  final Color color;

  GameButton2({@required this.label, @required this.color});

  @override
  Widget build(BuildContext context) {
    return ButtonTheme(
      minWidth: 200,
      height: 50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: FlatButton(
        onPressed: () {},
        color: color,
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Gaegu',
            //fontWeight: FontWeight.w700,
            color: textColor,
            fontSize: 24,
          ),
        ),
      ),
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
  })  : assert(child != null),
        super(key: key);

  @override
  _AnimatedButtonState createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> {
  static const Curve _curve = Curves.easeIn;
  static const double _shadowHeight = 4;
  double _position = 4;

  @override
  Widget build(BuildContext context) {
    final double _height = widget.height - _shadowHeight;

    return GestureDetector(
      // width here is required for centering the button in parent
      child: Container(
        width: widget.width,
        height: _height + _shadowHeight,
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
                  borderRadius: BorderRadius.all(
                    Radius.circular(30),
                  ),
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
                  borderRadius: BorderRadius.all(
                    Radius.circular(30),
                  ),
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
      _position = 4;
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
