import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:exquisitecorpse/drawing_storage.dart';
import 'package:exquisitecorpse/game_state.dart';
import 'colors.dart';

class BrushSizeSlider extends StatefulWidget {
  @override
  _BrushSizeSliderState createState() => _BrushSizeSliderState();
}

class _BrushSizeSliderState extends State<BrushSizeSlider> {
  Color _lastColor;

  @override
  void initState() {
    final myDrawing = Provider.of<DrawingStorage>(context, listen: false);
    _lastColor = myDrawing.paint.color;
    super.initState();
  }

  void _timerToHideDot(double valueWhenCalled, Color colorWhenCalled) {
    final myDrawing = Provider.of<DrawingStorage>(context, listen: false);
    final drawingState = Provider.of<DrawingState>(context, listen: false);

    Future.delayed(Duration(milliseconds: 800)).then((_) {
      if (num.parse(myDrawing.paint.strokeWidth.toStringAsFixed(4)) == valueWhenCalled && myDrawing.paint.color == colorWhenCalled) {
        drawingState.showDot = false;
        Future.delayed(Duration(milliseconds: 95)).then((_) {
          if (num.parse(myDrawing.paint.strokeWidth.toStringAsFixed(4)) == valueWhenCalled && myDrawing.paint.color == colorWhenCalled) {
            drawingState.transparentDot = true;
          }
        });
      }
    });
  }

  void _colorChange() async {
    await Future.delayed(Duration(milliseconds: 10));
    final drawingState = Provider.of<DrawingState>(context, listen: false);
    final myDrawing = Provider.of<DrawingStorage>(context, listen: false);

    drawingState.onChangeStart();
    drawingState.timerOn = true;
    _timerToHideDot(num.parse(myDrawing.paint.strokeWidth.toStringAsFixed(4)), myDrawing.paint.color);
  }

  @override
  Widget build(BuildContext context) {
    final myDrawing = Provider.of<DrawingStorage>(context);
    final drawingState = Provider.of<DrawingState>(context);
    double paintSize = myDrawing.paint.strokeWidth;

    if (_lastColor != myDrawing.paint.color) {
      _lastColor = myDrawing.paint.color;
      _colorChange();
    }

    return Container(
      height: 200,
      width: 150,
      child: RotatedBox(
        quarterTurns: 1,
        child: Stack(
          alignment: AlignmentDirectional.bottomCenter,
          children: <Widget>[
            ClipPath(
              clipper: _CustomTriangleClipper(),
              child: Container(
                height: 20,
                width: 170,
                color: dashes,
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: AnimatedPadding(
                duration: Duration(milliseconds: 100),
                padding: EdgeInsets.only(bottom: drawingState.showDot ? 100 : 0, right: 55 + ((paintSize - 10) * 2.9)),
                child: Container(
                  height: paintSize,
                  width: paintSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: drawingState.transparentDot ? Colors.transparent : myDrawing.paint.color,
                    border: (!drawingState.transparentDot && myDrawing.paint.color == paper) ? Border.all(color: Colors.black) : null,
                  ),
                ),
              ),
            ),
            RotatedBox(
              quarterTurns: 2,
              child: Padding(
                padding: const EdgeInsets.only(left: 40),
                child: Container(
                  height: 20,
                  width: 164,
                  child: SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 0,
                      overlayShape: RoundSliderOverlayShape(overlayRadius: 0.0),
                      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 20.0),
                      thumbColor: Colors.black,
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
                      onChangeStart: (_) {
                        drawingState.onChangeStart();
                      },
                      onChangeEnd: (value) {
                        drawingState.timerOn = true;
                        _timerToHideDot(num.parse(value.toStringAsFixed(4)), myDrawing.paint.color);
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomTriangleClipper extends CustomClipper<Path> {
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
