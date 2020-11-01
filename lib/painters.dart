import 'package:flutter/material.dart';

class MyPainter extends CustomPainter {
  List<Path> paths;
  List<Paint> paints;

  MyPainter(this.paths, this.paints);

  @override
  void paint(Canvas canvas, Size size) {
    assert(paths.length == paints.length, 'The length of Paths and Paints are not the same 002');

    for (var i = 0; i < paths.length; i++) {
      canvas.drawPath(paths[i], paints[i]);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
