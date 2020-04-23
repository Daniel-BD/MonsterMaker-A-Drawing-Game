import 'package:flutter/material.dart';

import 'start_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drawing Game',
      home: StartScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
