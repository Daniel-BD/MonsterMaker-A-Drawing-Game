import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import 'package:exquisitecorpse/route_generator.dart';
import 'package:exquisitecorpse/game_state.dart';
import 'package:exquisitecorpse/ReviewWebApp/WebHome.dart';
import 'test_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIOverlays([]);
  //runApp(WebApp());
  runApp(MyApp());
  //runApp(TestApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<GameState>(create: (_) => GameState()),
      ],
      child: MaterialApp(
        theme: ThemeData(
          textTheme: GoogleFonts.snigletTextTheme(
            Theme.of(context).textTheme,
          ),
        ),
        title: 'MonsterMaker',
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        onGenerateRoute: RouteGenerator.generateRoute,
      ),
    );
  }
}
