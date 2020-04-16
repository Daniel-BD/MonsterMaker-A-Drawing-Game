import 'package:flutter/material.dart';

import 'path_storage.dart';

class MyPainter extends CustomPainter {
  List<Path> paths;

  MyPainter(List<Path> paths) {
    this.paths = paths;
  }

  MyPainter.fromStorage(PathStorage pathStorage) {
    this.paths = pathStorage.getListOfPaths();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    paths.forEach((path) {
      canvas.drawPath(path, paint);
    });
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
