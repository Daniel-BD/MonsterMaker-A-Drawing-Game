import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_dash/flutter_dash.dart';
import 'package:exquisitecorpse/game_state.dart';
import 'package:exquisitecorpse/models.dart';

class OverlapDashedLines extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final gameRoom = Provider.of<GameRoom>(context);

    /// I think I should listen to gameState changes to know that this will rebuild after canvasHeigt/Width is not null anymore
    /// Right now I think it's just by chance that this works, because it rebuilds this widget when navigating in because
    /// of the animation in navigation?
    //final gameState = Provider.of<GameState>(context);

    if (GameState.canvasHeight == null || GameState.canvasWidth == null) {
      return Container();
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        if (!gameRoom.allTopDrawingsDone()) Container(),
        if (gameRoom.allTopDrawingsDone())
          Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 7),
            child: Dash(
              direction: Axis.horizontal,
              length: GameState.canvasWidth,
              dashColor: Colors.black.withOpacity(0.5),
              dashLength: 20,
              dashGap: 20,
              dashThickness: 4,
            ),
          ),
        if (!gameRoom.allMidDrawingsDone())
          Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height / 7),
            child: Dash(
              direction: Axis.horizontal,
              length: GameState.canvasWidth,
              dashColor: Colors.black.withOpacity(0.5),
              dashLength: 20,
              dashGap: 20,
              dashThickness: 4,
            ),
          )
      ],
    );
  }
}
