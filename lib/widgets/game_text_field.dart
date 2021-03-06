import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'colors.dart';

class GameTextField extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;

  const GameTextField({Key key, this.controller, this.onSubmitted}) : super(key: key);

  @override
  _GameTextFieldState createState() => _GameTextFieldState();
}

class _GameTextFieldState extends State<GameTextField> {
  final focus = FocusNode();

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
        autocorrect: false,
        focusNode: focus,
        controller: widget.controller,
        textAlign: TextAlign.center,
        textAlignVertical: TextAlignVertical(y: 1.0),
        cursorColor: focused,
        style: widget.controller.text.isEmpty ? hintStyle : style,
        textCapitalization: TextCapitalization.characters,
        onTap: () => setState(() {}),
        inputFormatters: [
          LengthLimitingTextInputFormatter(4),
        ],
        onSubmitted: widget.onSubmitted,
        onChanged: (str) {
          //controller.text = str.toUpperCase();
          if (widget.controller.text.isNotEmpty) {
            Future.delayed(Duration(milliseconds: 100)).then((value) => setState(() {}));
          } else {
            setState(() {});
          }
        },
        decoration: InputDecoration(
          hintStyle: widget.controller.text.isEmpty ? hintStyle : style,
          hintText: 'Enter Room Code',
          enabledBorder: unFocusedBorder,
          focusedBorder: focusedBorder,
        ),
      ),
    );
  }
}
