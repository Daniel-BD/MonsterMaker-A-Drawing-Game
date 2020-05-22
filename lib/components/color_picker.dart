import 'package:flutter/material.dart';

import 'colors.dart';

class GameColorPicker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: <Widget>[
        for (final color in brushColors) _ColorGameButton(color: color),
      ],
    );
  }
}

class _ColorGameButton extends StatelessWidget {
  final Color color;
  final GestureTapCallback onTap;

  const _ColorGameButton({Key key, this.color, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: Border.all(color: color == paper ? Colors.black : Colors.white, width: 2),
        ),
      ),
    );
  }
}

List<Color> brushColors = [
  paper,
  Colors.black,
  const Color(0xFF0085FF),
  const Color(0xFF22F300),
  const Color(0xFFFFD600),
  const Color(0xFF8F4500),
  const Color(0xFFFD7900),
  const Color(0xFFF30000),
  const Color(0xFFE40189),
  const Color(0xFFFFB6EF),
];
