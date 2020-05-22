import 'package:flutter/material.dart';

import 'colors.dart';

class MonsterMakerLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Text(
        "MonsterMaker",
        style: TextStyle(
          fontFamily: 'CraftyGirls',
          color: textColor,
          fontSize: 40,
        ),
      ),
    );
  }
}

class RoomCodeInfo extends StatelessWidget {
  final String roomCode;

  final smallStyle = TextStyle(
    fontFamily: 'Gaegu',
    color: textColor,
    fontSize: 24,
  );
  final bigStyle = TextStyle(
    fontFamily: 'Gaegu',
    color: textColorBlack,
    fontSize: 42,
  );

  RoomCodeInfo({Key key, this.roomCode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          "Room Code",
          style: smallStyle,
        ),
        Text(
          roomCode,
          style: bigStyle,
        )
      ],
    );
  }
}

class WaitingRoomText extends StatelessWidget {
  final int playersReady;
  final bool isHost;

  final smallStyle = TextStyle(
    fontFamily: 'Gaegu',
    color: textColor,
    fontSize: 24,
  );

  WaitingRoomText({Key key, this.playersReady, this.isHost}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String friend = playersReady == 2 ? 'friend' : 'friends';

    return Text(
      playersReady != 3
          ? '$playersReady player is ready! \n Invite ${3 - playersReady} more ' + friend + ' to start...'
          : isHost == true ? 'All 3 players are ready!' : 'All 3 players are ready! \n Waiting for the host to start...',
      textAlign: TextAlign.center,
      style: smallStyle,
    );
  }
}
