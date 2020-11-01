import 'package:flutter/material.dart';

import 'package:exquisitecorpse/screens/share_monster_screen.dart';
import 'package:exquisitecorpse/screens/start_screen.dart';
import 'package:exquisitecorpse/screens/waiting_room_screen.dart';
import 'package:exquisitecorpse/screens/drawing_screen/drawing_screen.dart';
import 'package:exquisitecorpse/screens/get_ready_screen.dart';
import 'package:exquisitecorpse/screens/finished_screen.dart';
import 'package:exquisitecorpse/screens/play_modes_screen.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => StartScreen());
      case '/playModesScreen':
        return MaterialPageRoute(builder: (_) => PlayModesScreen());
      case '/waitingRoom':
        return MaterialPageRoute(builder: (_) => WaitingRoomScreen());
      case '/getReadyScreen':
        return MaterialPageRoute(builder: (_) => GetReadyScreen());
      case '/drawingScreen':
        return MaterialPageRoute(builder: (_) => DrawingScreen());
      case '/finishedScreen':
        return MaterialPageRoute(builder: (_) => FinishedScreen());
      case '/shareMonsterScreen':
        return MaterialPageRoute(builder: (_) => ShareMonsterScreen());

      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        body: Center(
          child: Text('ERROR'),
        ),
      );
    });
  }
}
