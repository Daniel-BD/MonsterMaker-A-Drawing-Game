import 'package:exquisitecorpse/game_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:home_indicator/home_indicator.dart';

import 'package:exquisitecorpse/route_generator.dart';
import 'package:exquisitecorpse/models.dart';
import 'drawing_storage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    HomeIndicator.deferScreenEdges([ScreenEdge.bottom]);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<GameState>(create: (_) => GameState()),
      ],
      child: MaterialApp(
        title: 'Drawing Game',
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        onGenerateRoute: RouteGenerator.generateRoute,
      ),
    );
  }
}
