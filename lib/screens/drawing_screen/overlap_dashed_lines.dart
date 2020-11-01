import 'package:exquisitecorpse/drawing_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_dash/flutter_dash.dart';
import 'package:exquisitecorpse/models.dart';
import 'package:exquisitecorpse/widgets/colors.dart';

class OverlapDashedLines extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final gameRoom = Provider.of<GameRoom>(context);
    final myDrawing = Provider.of<DrawingStorage>(context);

    if (myDrawing.originalWidth == null) {
      return Container();
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        if (!gameRoom.allMidDrawingsDone())
          Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height / 6),
            child: _Dashes(
              width: myDrawing.originalWidth,
            ),
          )
      ],
    );
  }
}

class _Dashes extends StatelessWidget {
  final double width;

  const _Dashes({Key key, this.width}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dash(
      direction: Axis.horizontal,
      length: width,
      dashColor: dashes,
      dashLength: 20,
      dashGap: 20,
      dashThickness: 4,
    );
  }
}
