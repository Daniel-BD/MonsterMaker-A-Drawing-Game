import 'package:flutter/material.dart';

import 'colors.dart';

class MonsterMakerLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Text(
        'MonsterMaker',
        style: TextStyle(
          fontFamily: 'Gaegu',
          fontWeight: FontWeight.w700,
          color: textColor,
          fontSize: 100,
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
          'Room Code',
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
    String playersAre = playersReady == 1 ? 'player is' : 'players are';

    return Text(
      playersReady != 3
          ? '$playersReady ' + playersAre + ' ready! \n Invite ${3 - playersReady} more ' + friend + ' to start...'
          : isHost == true ? 'All 3 players are ready!' : 'All 3 players are ready! \n Waiting for the host to start...',
      textAlign: TextAlign.center,
      style: smallStyle,
    );
  }
}

final _instructionStyle = TextStyle(
  fontFamily: 'Gaegu',
  color: textColor,
  fontSize: 20,
);

class WaitingForOtherPlayersToDrawText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      'Waiting for the other players to finish...',
      textAlign: TextAlign.center,
      style: _instructionStyle,
    );
  }
}

class FirstInstructionText extends StatelessWidget {
  final _firstInstruction =
      'Turn your phone this way!\n\nEach player will make 3 drawings (top, middle, bottom).\nThese will be stitched together to become monsters!\n\nThe dashed lines indicates where the next player will continue.';

  @override
  Widget build(BuildContext context) {
    return Text(
      _firstInstruction,
      textAlign: TextAlign.center,
      style: _instructionStyle,
    );
  }
}

class SecondInstructionText extends StatelessWidget {
  final _secondInstruction =
      "Now you will continue on another players drawing.\n\nDraw the middle part,\nmake sure to connect the drawings!";

  @override
  Widget build(BuildContext context) {
    return Text(
      _secondInstruction,
      textAlign: TextAlign.center,
      style: _instructionStyle,
    );
  }
}

class ThirdInstructionText extends StatelessWidget {
  final _thirdInstruction = 'Now you will finish a monster!\n\nDraw the bottom part,\nmake sure to connect the drawings!';

  @override
  Widget build(BuildContext context) {
    return Text(
      _thirdInstruction,
      textAlign: TextAlign.center,
      style: _instructionStyle,
    );
  }
}

class GameHostControlsWhatYouSeeText extends StatelessWidget {
  const GameHostControlsWhatYouSeeText({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      'The game host controls what you see!',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: 'Gaegu',
        color: textColor,
        fontSize: 16,
      ),
    );
  }
}

class MonsterNumberText extends StatelessWidget {
  final int number;

  const MonsterNumberText({Key key, this.number}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      'Monster #$number',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: 'Gaegu',
        color: textColor,
        fontSize: 30,
      ),
    );
  }
}

class LastWaitingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        'Turn your phone this way!\n\nYay! You finished all drawings!\n\nWaiting for the other players to finish',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Gaegu',
          color: textColor,
          fontSize: 24,
        ),
      ),
    );
  }
}
