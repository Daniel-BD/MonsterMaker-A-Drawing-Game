import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants.dart';

class GameTextField extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;
  final double fontSize;
  final hintText;

  /// If true, behaves as if the text field is used for entering room codes, meaning only caps and 4 characters max length
  final isRoomCode;

  const GameTextField({
    Key key,
    this.controller,
    this.onSubmitted,
    this.fontSize,
    this.hintText = 'Enter Room Code',
    this.isRoomCode = true,
  }) : super(key: key);

  @override
  _GameTextFieldState createState() => _GameTextFieldState();
}

class _GameTextFieldState extends State<GameTextField> {
  final focus = FocusNode();

  TextStyle _style;
  TextStyle _hintStyle;

  final _unFocusedBorder = OutlineInputBorder(
    borderRadius: const BorderRadius.all(
      const Radius.circular(8),
    ),
    borderSide: BorderSide(
      width: 2.0,
      color: monsterTextColor,
    ),
  );

  final _focusedBorder = OutlineInputBorder(
    borderRadius: const BorderRadius.all(
      const Radius.circular(20),
    ),
    borderSide: BorderSide(
      width: 4.0,
      color: focused,
    ),
  );

  @override
  void initState() {
    super.initState();

    _style = GoogleFonts.sniglet(
      color: monsterTextColor,
      fontSize: widget.fontSize != null ? widget.fontSize : 40,
      fontWeight: FontWeight.w600,
    );

    _hintStyle = GoogleFonts.sniglet(
      color: monsterTextColor,
      fontSize: widget.fontSize != null ? widget.fontSize : 22,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      //height: widget.isRoomCode ? 60 : 80, //TODO: Testa hur det blir när man matar in ROOM CODE
      width: min(300.0, MediaQuery.of(context).size.width * 0.8),
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
        textAlign: widget.isRoomCode ? TextAlign.center : TextAlign.start,
        textAlignVertical: widget.isRoomCode ? TextAlignVertical(y: 1.0) : null, //TODO: Testa hur det blir när man matar in ROOM CODE
        cursorColor: focused,
        style: widget.controller.text.isEmpty ? _hintStyle : _style,
        textCapitalization: widget.isRoomCode ? TextCapitalization.characters : TextCapitalization.sentences,
        onTap: () => setState(() {}),
        inputFormatters: [
          LengthLimitingTextInputFormatter(widget.isRoomCode ? 4 : monsterNameMaxCharacterLength),
        ],
        onSubmitted: widget.onSubmitted,
        onChanged: (str) {
          /// Jag vet inte varför jag gjort såhär... vet inte riktigt vad det gör
          if (widget.controller.text.isNotEmpty) {
            Future.delayed(Duration(milliseconds: 100)).then((_) => setState(() {}));
          } else {
            setState(() {});
          }
        },
        decoration: InputDecoration(
          hintStyle: widget.controller.text.isEmpty ? _hintStyle : _style,
          hintText: widget.hintText,
          enabledBorder: _unFocusedBorder,
          focusedBorder: _focusedBorder,
        ),
      ),
    );
  }
}
