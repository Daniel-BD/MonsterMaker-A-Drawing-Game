import 'package:flutter/material.dart';
import 'package:drawing_animation/drawing_animation.dart';
import 'package:provider/provider.dart';

import 'package:exquisitecorpse/drawing_storage.dart';

class AnimationCanvas extends StatefulWidget {
  AnimationCanvas({Key key}) : super(key: key);

  @override
  _AnimationCanvasState createState() => _AnimationCanvasState();
}

class _AnimationCanvasState extends State<AnimationCanvas> {
  bool _runAnimation = true;

  @override
  Widget build(BuildContext context) {
    final myDrawing = Provider.of<DrawingStorage>(context);

    return AspectRatio(
      aspectRatio: 0.6,
      child: Container(
        color: Colors.grey[200],
        child: AnimatedDrawing.paths(
          myDrawing.getPaths(),
          paints: myDrawing.getPaints(),
          run: this._runAnimation,
          scaleToViewport: false,
          duration: Duration(seconds: 1),
          onFinish: () => setState(() {
            this._runAnimation = false;
          }),
        ),
      ),
    );
  }
}
