import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

class DrawingStorage {
  /// This is essentially a list of paths, even though it may be hard to see. The inner list is a list of points (dx dy),
  /// which is the same thing as a path really. The outer list is a list of those, meaning a list of paths.
  List<List<Tuple2<double, double>>> _deconstructedPaths = [];
  //List<Paint> paints = [];
  //List<Path> paths = [];

  List<List<Path>> superPaths = [];

  List<Path> _undonePaths = [];
  List<Paint> _undonePaints = [];
  List<List<Tuple2<double, double>>> _undoneDeconstructedPaths = [];

  void undoLastPath() {
    //_undoneDeconstructedPaths.add(_deconstructedPaths.removeLast());
    //_undonePaths.add(paths.removeLast());
    //_undonePaints.add(paints.removeLast());
  }

  void startNewPath(double dx, double dy, Paint paint, bool continuesLastPath) {
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

  /// Adds a new point to the current path
  void addPoint(double dx, double dy, bool lastPointOutOfBounds, bool isDot) {
    /// If the path has gone out of bounds, we need to make a new path once it comes in bound again, otherwise there will be a bug
    /// when loading this drawing later.
    if (lastPointOutOfBounds) {
      startNewPath(dx, dy, paints.last, true);
      return;
    }

    var lastDx = _deconstructedPaths.last.last.item1;
    var lastDy = _deconstructedPaths.last.last.item2;

    /// Ignore new points if they're closer than 0.5 from the last point.
    if (!isDot) {
      if ((dx.abs() - lastDx.abs()).abs() < 0.5 || (dy.abs() - lastDy.abs()).abs() < 0.5) {
        return;
      }
    }

    /// This fixes the problem of jagged edges that sometimes happens when changing direction of a path
    if (_deconstructedPaths.last.length > 2) {
      var nextToLastDx = _deconstructedPaths.last[_deconstructedPaths.last.length - 2].item1;
      var nextToLastDy = _deconstructedPaths.last[_deconstructedPaths.last.length - 2].item2;

      bool changingXDirection = !((dx < lastDx && lastDx < nextToLastDx) || (dx > lastDx && lastDx > nextToLastDx));
      bool changingYDirection = !((dy < lastDy && lastDy < nextToLastDy) || (dy > lastDy && lastDy > nextToLastDy));

      if (changingXDirection || changingYDirection) {
        startNewPath(lastDx, lastDy, paints.last, true);

        paths.last.lineTo(lastDx, lastDy);
        _deconstructedPaths.last.add(Tuple2<double, double>(lastDx, lastDy));

        paths.last.lineTo(dx, dy);
        _deconstructedPaths.last.add(Tuple2<double, double>(dx, dy));
        return;
      }
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
    this.paths = getListOfPaths();

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
