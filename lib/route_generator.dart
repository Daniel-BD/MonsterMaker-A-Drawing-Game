import 'package:flutter/material.dart';

import 'package:exquisitecorpse/screens/start_screen.dart';
import 'package:exquisitecorpse/screens/waiting_room_screen.dart';
import 'package:exquisitecorpse/screens/drawing_screen.dart';
import 'package:exquisitecorpse/screens/get_ready_screen.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => StartScreen());
      case '/waitingRoom':
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => WaitingRoomScreen(roomCode: args),
          );
        }
        return _errorRoute();
        return MaterialPageRoute(builder: (_) => WaitingRoomScreen());
      case '/getReadyScreen':
        return MaterialPageRoute(builder: (_) => GetReadyScreen());
      case '/drawingScreen':
        if (args is GameRoom) {
          return MaterialPageRoute(
            builder: (_) => DrawingScreen(room: args),
          );
        }
        return _errorRoute();
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
