import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FinishedScreen extends StatefulWidget {
  @override
  _FinishedScreenState createState() => _FinishedScreenState();
}

class _FinishedScreenState extends State<FinishedScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

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
