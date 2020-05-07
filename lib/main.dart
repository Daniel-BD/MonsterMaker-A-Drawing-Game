import 'package:flutter/material.dart';

import 'package:home_indicator/home_indicator.dart';

import 'package:exquisitecorpse/route_generator.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drawing Game',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      onGenerateRoute: RouteGenerator.generateRoute,
    HomeIndicator.deferScreenEdges([ScreenEdge.bottom]);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CurrentRoomCode>(create: (_) => CurrentRoomCode()),
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
