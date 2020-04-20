import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

class DrawingStorage {
  /// This is essentially a list of paths, even though it may be hard to see. The inner list is a list of points (dx dy),
  /// which is the same thing as a path really. The outer list is a list of those, meaning a list of paths.

  List<List<Path>> _superPaths = [];
  List<List<Paint>> _superPaints = [];
  List<List<List<Tuple2<double, double>>>> _superDeconstructedPaths = [];

  List<List<Path>> _undonePaths = [];
  List<List<Paint>> _undonePaints = [];
  List<List<List<Tuple2<double, double>>>> _undoneDeconstructedPaths = [];

  void clearDrawing() {
    _superPaths.clear();
    _superPaints.clear();
    _superDeconstructedPaths.clear();
    _undonePaths.clear();
    _undonePaints.clear();
    _undoneDeconstructedPaths.clear();
  }

  List<Path> getPaths() {
    List<Path> paths = [];
    for (var pathList in _superPaths) {
      for (var path in pathList) {
        paths.add(path);
      }
    }
    assert(_assertLengths());
    return paths;
  }

  List<Paint> getPaints() {
    List<Paint> paints = [];
    for (var paintList in _superPaints) {
      for (var paint in paintList) {
        paints.add(paint);
      }
    }
    assert(_assertLengths());
    return paints;
  }

  void undoLastPath() {
    if (_superDeconstructedPaths.isEmpty) {
      return;
    }
    _undoneDeconstructedPaths.add(_superDeconstructedPaths.removeLast());
    _undonePaths.add(_superPaths.removeLast());
    _undonePaints.add(_superPaints.removeLast());
    assert(_assertLengths());
  }

  void redoLastUndonePath() {
    if (_undoneDeconstructedPaths.isEmpty) {
      return;
    }
    _superDeconstructedPaths.add(_undoneDeconstructedPaths.removeLast());
    _superPaths.add(_undonePaths.removeLast());
    _superPaints.add(_undonePaints.removeLast());
    assert(_assertLengths());
  }

  void startNewPath(double dx, double dy, Paint paint, bool continuesLastPath) {
    if (continuesLastPath) {
      _superPaths.last.add(Path()..moveTo(dx, dy));
      _superPaths.last.last.lineTo(dx, dy);
      _superPaints.last.add(paint);

      _superDeconstructedPaths.last.add([Tuple2<double, double>(dx, dy)]);
    } else {
      _superPaths.add([Path()..moveTo(dx, dy)]);
      _superPaths.last.last.lineTo(dx, dy);
      _superPaints.add([paint]);

      _superDeconstructedPaths.add([
        [Tuple2<double, double>(dx, dy)]
      ]);
    }

    assert(_assertLengths());
  }

  /// This function looks if the last path was a simple dot, and if it was, then it adds a very small line to it.
  /// This is done to prevent a bug in the animation library that makes it so paths with one coordinate (a dot) doesn't render
  void endPath() {
    if (_superDeconstructedPaths.last.last.length < 2) {
      addPoint(_superDeconstructedPaths.last.last.last.item1 + 0.001, _superDeconstructedPaths.last.last.last.item2 + 0.001, false, true);
    }
  }

  /// Adds a new point to the current path
  void addPoint(double dx, double dy, bool lastPointOutOfBounds, bool isDot) {
    /// If the path has gone out of bounds, we need to make a new path once it comes in bound again, otherwise there will be a bug
    /// when loading this drawing later.
    if (lastPointOutOfBounds) {
      startNewPath(dx, dy, _superPaints.last.last, true);
      assert(_assertLengths());
      return;
    }

    var lastDx = _superDeconstructedPaths.last.last.last.item1;
    var lastDy = _superDeconstructedPaths.last.last.last.item2;

    /// Ignore new points if they're closer than 0.5 from the last point.
    if (!isDot) {
      if ((dx.abs() - lastDx.abs()).abs() < 0.5 || (dy.abs() - lastDy.abs()).abs() < 0.5) {
        return;
      }
    }

    _superPaths.last.last.lineTo(dx, dy);
    _superDeconstructedPaths.last.last.add(Tuple2<double, double>(dx, dy));
  }

  List<List<Path>> _createPathsFromDeconstructed() {
    List<List<Path>> createdList = [];

    for (var pathList in _superDeconstructedPaths) {
      List<Path> tempList = [];

      pathList.forEach((fakePath) {
        tempList.add(Path()
          ..moveTo(fakePath.first.item1, fakePath.first.item2)
          ..lineTo(fakePath.first.item1, fakePath.first.item2));

        for (int i = 1; i < fakePath.length; i++) {
          tempList.last.lineTo(fakePath[i].item1, fakePath[i].item2);
        }
      });

      createdList.add(tempList);
    }

    return createdList;
  }

  DrawingStorage();

  DrawingStorage.fromJson(Map<String, dynamic> json) {
    List<List<List<Tuple2<double, double>>>> listOfListsOfPaths = [];
    List<List<Paint>> listOfListsOfPaints = [];
    List<String> listOfPathListStrings = json['paths'].split('/');
    List<String> listOfPaintListStrings = json['paints'].split('/');

    /// Reading paths
    for (var pathList in listOfPathListStrings) {
      List<List<Tuple2<double, double>>> tempPathList = [];

      for (var path in pathList.split(':')) {
        List<Tuple2<double, double>> pathCoordinates = [];
        List<String> pathCoordinatesString = path.split(',');

        for (var i = 0; i < pathCoordinatesString.length; i += 2) {
          pathCoordinates.add(Tuple2(double.parse(pathCoordinatesString[i]), double.parse(pathCoordinatesString[i + 1])));
        }

        tempPathList.add(pathCoordinates);
      }

      listOfListsOfPaths.add(tempPathList);
    }

    /// Readings paints
    for (var paintList in listOfPaintListStrings) {
      List<Paint> tempPaintList = [];

      for (var paint in paintList.split(':')) {
        List<String> values = paint.split(',');
        assert(double.parse(values[0]).runtimeType == double);
        assert(int.parse(values[1]).runtimeType == int);

        tempPaintList.add(Paint()
          ..color = Color(int.parse(values[1]))
          ..strokeWidth = double.parse(values[0])
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke);
      }

      listOfListsOfPaints.add(tempPaintList);
    }

    _superDeconstructedPaths = listOfListsOfPaths;
    _superPaints = listOfListsOfPaints;
    _superPaths = _createPathsFromDeconstructed();

    assert(_assertLengths());
  }

  Map<String, dynamic> toJson() {
    assert(_assertLengths());

    Map<String, dynamic> json = {};
    var pathsString = StringBuffer();
    var paintsString = StringBuffer();

    /// For every list of paths...
    for (var i = 0; i < _superDeconstructedPaths.length; i++) {
      /// Go through every path, and for every path...
      for (var j = 0; j < _superDeconstructedPaths[i].length; j++) {
        /// Go through every coordinate in that path...
        for (var k = 0; k < _superDeconstructedPaths[i][j].length; k++) {
          /// Write down the X and Y coordinate, separated with a comma
          pathsString.write('${_superDeconstructedPaths[i][j][k].item1},${_superDeconstructedPaths[i][j][k].item2}');

          /// Don't write a comma after the last coordinate
          if (k < _superDeconstructedPaths[i][j].length - 1) {
            pathsString.write(',');
          }
        }

        /// Separate every path with a colon, but don't write a colon after the last path
        if (j < _superDeconstructedPaths[i].length - 1) {
          pathsString.write(':');
        }
      }

      /// Separate every list of paths with a slash, but don't write a slash after the last list of paths
      if (i < _superDeconstructedPaths.length - 1) {
        pathsString.write('/');
      }
    }

    /// For every list of paints...
    for (var i = 0; i < _superPaints.length; i++) {
      /// Go through every paint
      for (var j = 0; j < _superPaints[i].length; j++) {
        /// Write down the stroke width and color value, separated with a comma
        paintsString.write('${_superPaints[i][j].strokeWidth},${_superPaints[i][j].color.value}');

        /// Separate every paint with a colon, but don't write a colon after the last paint
        if (j < _superPaints[i].length - 1) {
          paintsString.write(':');
        }
      }

      /// Separate every list of paints with a slash, but don't write a slash after the last list of paints
      if (i < _superPaints.length - 1) {
        paintsString.write('/');
      }
    }

    json['paths'] = pathsString.toString();
    json['paints'] = paintsString.toString();

    return json;
  }

  bool _assertLengths() {
    assert(_superPaths.length == _superPaints.length, 'The length of SuperPaths and SuperPaints are not the same');
    assert(_superPaths.length == _superDeconstructedPaths.length, 'The length of SuperPaths and SuperDeconstructedPaths are not the same');

    for (var i = 0; i < _superPaths.length; i++) {
      assert(_superPaths[i].length == _superPaints[i].length, 'The length of Paths and Paints are not the same at $i');
    }
    for (var i = 0; i < _superPaths.length; i++) {
      assert(
          _superPaths[i].length == _superDeconstructedPaths[i].length, 'The length of Paths and DeconstructedPaths are not the same at $i');
    }

    // for the undone stuff
    assert(_undonePaths.length == _undonePaints.length, 'The length of UndonePathsList and UndonePaintsList are not the same');
    assert(_undonePaths.length == _undoneDeconstructedPaths.length,
        'The length of UndonePathsList and UndoneDeconstructedList are not the same');

    for (var i = 0; i < _undonePaths.length; i++) {
      assert(_undonePaths[i].length == _undonePaints[i].length, 'The length of UndonePaths and UndonePaints are not the same at $i');
    }
    for (var i = 0; i < _undonePaths.length; i++) {
      assert(_undonePaths[i].length == _undoneDeconstructedPaths[i].length,
          'The length of UndonePaths and UndoneDeconstructed are not the same at $i');
    }

    return true;
  }
}
