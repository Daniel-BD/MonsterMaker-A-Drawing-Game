import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

class DrawingStorage {
  /// This is essentially a list of paths, even though it may be hard to see. The inner list is a list of points (dx dy),
  /// which is the same thing as a path really. The outer list is a list of those, meaning a list of paths.
  List<List<Tuple2<double, double>>> _deconstructedPaths = [];
  List<Paint> paints = [];
  List<Path> paths = [];

  void startNewPath(double dx, double dy, Paint paint) {
    paths.add(Path()..moveTo(dx, dy));
    paths.last.lineTo(dx, dy);

    _deconstructedPaths.add([Tuple2<double, double>(dx, dy)]);
    paints.add(paint);
    assert(_deconstructedPaths.length == paints.length, 'The length of Paths and Paints are not the same 001');
  }

  /// This function looks if the last path was a simple dot, and if it was, then it adds a very small line to it.
  /// This is done to prevent a bug in the animation library that makes it so paths with one coordinate (a dot) doesn't render
  void endPath() {
    if (_deconstructedPaths.last.length < 2) {
      addPoint(_deconstructedPaths.last.last.item1 + 0.001, _deconstructedPaths.last.last.item2 + 0.001, false, true);
    }
  }

  void addPoint(double dx, double dy, bool lastPointOutOfBounds, bool isDot) {
    if (lastPointOutOfBounds) {
      this.startNewPath(dx, dy, paints.last);
      return;
    }

    var lastDx = _deconstructedPaths.last.last.item1;
    var lastDy = _deconstructedPaths.last.last.item2;

    if (!isDot) {
      if ((dx.abs() - lastDx.abs()).abs() < 0.5 || (dy.abs() - lastDy.abs()).abs() < 0.5) {
        //print("not today!");
        return;
      }
    }

    if (_deconstructedPaths.last.length > 2) {
      //print('DX: $dx, DY: $dy');
      var nextToLastDx = _deconstructedPaths.last[_deconstructedPaths.last.length - 2].item1;
      var nextToLastDy = _deconstructedPaths.last[_deconstructedPaths.last.length - 2].item2;

      bool changingXDirection = !((dx < lastDx && lastDx < nextToLastDx) || (dx > lastDx && lastDx > nextToLastDx));
      bool changingYDirection = !((dy < lastDy && lastDy < nextToLastDy) || (dy > lastDy && lastDy > nextToLastDy));

      var bigChangeThreshold = 2;

      if (changingXDirection || changingYDirection) {
        print("CHANGING DIRECTION");
        print('NextTolastDX: $nextToLastDx, lastDY: $nextToLastDy');
        print('lastDX: $lastDx, lastDY: $lastDy');
        print('DX: $dx, DY: $dy');

        //paths.last.lineTo(lastDx - 0.5, lastDy - 0.5);
        //_deconstructedPaths.last.add(Tuple2<double, double>(lastDx + 0.001, lastDy + 0.001));

        //addPoint(dx, dy, false, false);
        //return;

        /*var dxDiff = (dx.abs() - lastDx.abs()).abs();
        var dyDiff = (dy.abs() - lastDy.abs()).abs();

        if (changingXDirection) {
          if (/*dxDiff > bigChangeThreshold &&*/ dxDiff > dyDiff || dxDiff > 1) {
            print('BIG X CHANGE!');
            this.startNewPath(dx, dy, paints.last);
            return;
          } else {
            print('SMALL X CHANGE');
          }
        } else if (changingYDirection) {
          if (/*dyDiff > bigChangeThreshold &&*/ dyDiff > dxDiff) {
            print('BIG Y CHANGE!');
            this.startNewPath(dx, dy, paints.last);
            return;
          } else {
            print('SMALL Y CHANGE');
          }
        }

        print(' ');*/
      }

      /*if (!((dx < lastDx && dx < nextToLastDx) || (dx > lastDx && dx > nextToLastDx)) ||
          !((dy < lastDy && dy < nextToLastDy) || (dy > lastDy && dy > nextToLastDy))) {
        print("CHANGING DIRECTION");
        this.startNewPath(dx, dy, paints.last);
        return;
      }*/
    }

    paths.last.lineTo(dx, dy);
    _deconstructedPaths.last.add(Tuple2<double, double>(dx, dy));
  }

  List<Path> getListOfPaths() {
    List<Path> pathsList = [];

    _deconstructedPaths.forEach((fakePath) {
      pathsList.add(Path()
        ..moveTo(fakePath.first.item1, fakePath.first.item2)
        ..lineTo(fakePath.first.item1, fakePath.first.item2));

      for (int i = 1; i < fakePath.length; i++) {
        pathsList.last.lineTo(fakePath[i].item1, fakePath[i].item2);
      }
    });

    return pathsList;
  }

  DrawingStorage();

  DrawingStorage.fromJson(Map<String, dynamic> json) {
    List<List<Tuple2<double, double>>> paths = [];
    List<Paint> paints = [];
    List<String> pathList = json['paths'].split(':');
    List<String> paintList = json['paints'].split(':');

    for (var path in pathList) {
      List<Tuple2<double, double>> coordinates = [];
      List<String> coordinatesString = path.split(',');

      for (var i = 0; i < coordinatesString.length; i += 2) {
        coordinates.add(Tuple2(double.parse(coordinatesString[i]), double.parse(coordinatesString[i + 1])));
      }

      paths.add(coordinates);
    }

    for (var paint in paintList) {
      List<String> values = paint.split(',');
      assert(double.parse(values[0]).runtimeType == double);
      assert(int.parse(values[1]).runtimeType == int);

      paints.add(Paint()
        ..color = Color(int.parse(values[1]))
        ..strokeWidth = double.parse(values[0])
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke);
    }

    this._deconstructedPaths = paths;
    this.paints = paints;

    assert(paths.length == paints.length, 'The length of Paths and Paints are not the same 004');
  }

  Map<String, dynamic> toJson() {
    assert(_deconstructedPaths.length == paints.length, 'The length of Paths and Paints are not the same 003');

    Map<String, dynamic> json = {};
    var pathsString = StringBuffer();
    var paintsString = StringBuffer();

    /// For every path
    for (var i = 0; i < _deconstructedPaths.length; i++) {
      /// Go through every coordinate in that path
      for (var j = 0; j < _deconstructedPaths[i].length; j++) {
        /// Write down the X and Y coordinate, separated with a comma
        pathsString.write('${_deconstructedPaths[i][j].item1},${_deconstructedPaths[i][j].item2}');

        /// Don't write a comma after the last coordinate
        if (j < _deconstructedPaths[i].length - 1) {
          pathsString.write(',');
        }
      }

      /// Separate every path with a colon, but don't write a colon after the last path
      if (i < _deconstructedPaths.length - 1) {
        pathsString.write(':');
      }
    }

    /// For every paint
    for (var i = 0; i < paints.length; i++) {
      /// Write down the stroke width and color value
      paintsString.write('${paints[i].strokeWidth},${paints[i].color.value}');

      /// Don't write a colon after the last paint
      if (i < paints.length - 1) {
        paintsString.write(':');
      }
    }

    json['paths'] = pathsString.toString();
    json['paints'] = paintsString.toString();

    return json;
  }
}
