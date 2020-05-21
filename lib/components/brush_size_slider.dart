import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'colors.dart';

class BrushSizeSlider extends StatefulWidget {
  @override
  _BrushSizeSliderState createState() => _BrushSizeSliderState();
}

class _BrushSizeSliderState extends State<BrushSizeSlider> {
  double value = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.orange,
      child: ClipPath(
        clipper: CustomTriangleClipper(),
        child: Container(
          height: 20,
          width: 170,
          color: dashes,
          child: Slider(
            onChanged: (val) {
              setState(() {
                value = val;
              });
            },
            value: value,
          ),
        ),
      ),
    );

    return ClipPath(
      clipper: CustomTriangleClipper(),
      child: Container(
        height: 170,
        width: 20,
        color: dashes,
        child: Transform.rotate(
          angle: math.pi / 4,
          child: Slider(
            onChanged: (_) {},
            value: 0.5,
          ),
        ),
      ),
    );
  }
}

class CustomTriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(size.width, size.height / 2);
    path.lineTo(0, size.height);
    path.lineTo(0, 0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
