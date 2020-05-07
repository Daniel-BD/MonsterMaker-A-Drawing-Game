import 'package:flutter/material.dart';

class FinishedScreen extends StatefulWidget {
  @override
  _FinishedScreenState createState() => _FinishedScreenState();
}

class _FinishedScreenState extends State<FinishedScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Text("NU ÄR SPELET KLART! HÄR SKALL MÅLNINGARNA VISAS UPP NÄR ALLA ÄR KLARA!"),
        ),
      ),
    );
  }
}
