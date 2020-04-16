import 'package:flutter/material.dart';

import 'package:tuple/tuple.dart';

class PathStorage {
  /// This is essentially a list of paths, even though it may be hard to see. The inner list is a list of points (dx dy),
  /// which is the same thing as a path really. The outer list is a list of those, meaning a list of paths.
  List<List<Tuple2<double, double>>> paths = [];

  void startNewPath(Tuple2<double, double> dxDy) {
    paths.add([dxDy]);
  }

  void addPoint(Tuple2<double, double> dxDy) {
    paths.last.add(dxDy);
  }

  List<Path> getListOfPaths() {
    List<Path> pathsList = [];

    paths.forEach((fakePath) {
      pathsList.add(Path()
        ..moveTo(fakePath.first.item1, fakePath.first.item2)
        ..lineTo(fakePath.first.item1, fakePath.first.item2));

      for (int i = 1; i < fakePath.length; i++) {
        pathsList.last.lineTo(fakePath[i].item1, fakePath[i].item2);
      }
    });

    return pathsList;
  }

  PathStorage();

  PathStorage.fromJson(Map<String, dynamic> json) {
    List<List<Tuple2<double, double>>> paths = [];
    String pathsString = json['paths'];
    List<String> pathList = pathsString.split(':');

    for (var path in pathList) {
      List<Tuple2<double, double>> coordinates = [];
      List<String> coordinatesString = path.split(',');

      for (var i = 0; i < coordinatesString.length; i += 2) {
        coordinates.add(Tuple2(double.parse(coordinatesString[i]), double.parse(coordinatesString[i + 1])));
      }

      paths.add(coordinates);
    }

    this.paths = paths;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    StringBuffer pathsString = StringBuffer();

    /// For every path
    for (var i = 0; i < paths.length; i++) {
      /// Go through every coordinate in that path
      for (var j = 0; j < paths[i].length; j++) {
        /// Write down the X and Y coordinate, separated with a comma
        pathsString.write('${paths[i][j].item1},${paths[i][j].item2}');

        /// Don't write a comma after the last coordinate
        if (j < paths[i].length - 1) {
          pathsString.write(',');
        }
      }

      /// Separate every path with a colon, but don't write a colon after the last path
      if (i < paths.length - 1) {
        pathsString.write(':');
      }
    }

    json['paths'] = pathsString.toString();

    return json;
  }
}
