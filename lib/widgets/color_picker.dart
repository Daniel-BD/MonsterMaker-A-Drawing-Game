import 'package:flutter/material.dart';
import 'dart:math';

import 'package:flutter_icons/flutter_icons.dart';

import 'colors.dart';

class GameColorPicker extends StatelessWidget {
  final void Function(Color) onTap;

  const GameColorPicker({Key key, @required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      runSpacing: 10,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: _ColorGameButton(
            color: paper,
            icon: MaterialCommunityIcons.eraser,
            onTap: () => onTap(paper),
          ),
        ),
        for (final color in brushColors)
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: _ColorGameButton(
              color: color,
              onTap: () => onTap(color),
            ),
          ),
      ],
    );
  }
}

class _ColorGameButton extends StatelessWidget {
  final Color color;
  final GestureTapCallback onTap;
  final IconData icon;

  const _ColorGameButton({Key key, @required this.color, @required this.onTap, this.icon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final diameter = min(((size.height - 70) / 6), 48.0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        child: icon != null ? Icon(icon, size: diameter * 0.7) : null,
        height: diameter,
        width: diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: Border.all(color: color == paper ? Colors.black : Colors.white, width: 2),
        ),
      ),
    );
  }
}
