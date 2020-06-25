import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:exquisitecorpse/drawing_storage.dart';

class BrushSizeSlider extends StatefulWidget {
  @override
  _BrushSizeSliderState createState() => _BrushSizeSliderState();
}

class _BrushSizeSliderState extends State<BrushSizeSlider> {
  @override
  Widget build(BuildContext context) {
    final myDrawing = Provider.of<DrawingStorage>(context);
    double paintSize = myDrawing.paint.strokeWidth;

    return RotatedBox(
      quarterTurns: 0,
      child: Container(
        height: 60,
        //width: 234,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: <Widget>[
            Container(width: 20),
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: Colors.white,
                inactiveTrackColor: Colors.white.withOpacity(0.25),
                overlayShape: RoundSliderOverlayShape(overlayRadius: 0.0),
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10.0),
                thumbColor: Colors.white,
              ),
              child: Slider(
                min: 5,
                max: 40,
                onChanged: (value) {
                  setState(
                    () {
                      myDrawing.paint = Paint()
                        ..color = myDrawing.paint.color
                        ..strokeWidth = num.parse(value.toStringAsFixed(4))
                        ..strokeCap = myDrawing.paint.strokeCap
                        ..strokeJoin = myDrawing.paint.strokeJoin
                        ..style = myDrawing.paint.style;
                    },
                  );
                },
                value: myDrawing.paint.strokeWidth,
              ),
            ),
            Container(
              height: 40,
              width: 40,
              child: Center(
                child: Container(
                  height: paintSize,
                  width: paintSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: myDrawing.paint.color,
                  ),
                ),
              ),
            ),
            Container(width: 10),
          ],
        ),
      ),
    );
  }
}
