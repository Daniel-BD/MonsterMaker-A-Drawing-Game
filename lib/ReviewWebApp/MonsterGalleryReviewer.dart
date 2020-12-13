import 'package:flutter/material.dart';
//import 'package:cloud_functions/cloud_functions.dart';

import 'package:exquisitecorpse/db.dart';

import 'package:exquisitecorpse/ReviewWebApp/MonsterViewer.dart';

class MonsterGalleryReviewer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MonsterMaker Reviewer',
      debugShowCheckedModeBanner: false,
      home: ReviewerHome(),
    );
  }
}

class ReviewerHome extends StatefulWidget {
  @override
  _ReviewerHomeState createState() => _ReviewerHomeState();
}

class _ReviewerHomeState extends State<ReviewerHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: MonsterList()),
    );
  }
}

class MonsterList extends StatefulWidget {
  @override
  _MonsterListState createState() => _MonsterListState();
}

class _MonsterListState extends State<MonsterList> {
  bool _loadingInit = false;
  final _buttonColor = Colors.blue[200];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_loadingInit) CircularProgressIndicator(),
        FlatButton(
          color: _buttonColor,
          onPressed: () async {
            setState(() {
              _loadingInit = true;
              print("calling init");
            });
            await DatabaseService.instance.initDB();
            setState(() {
              _loadingInit = false;
              print("init done!");
            });
          },
          child: Text('Init DB'),
        ),
        FlatButton(
          color: _buttonColor,
          onPressed: () {
            DatabaseService.instance.deleteIncompleteRooms();
          },
          child: Text('Delete Incomplete Rooms'),
        ),
        FlatButton(
          color: _buttonColor,
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => MonsterViewer()));
          },
          child: Text('Go to MonsterViewer'),
        ),
      ],
    );
  }

  /*void _getRoomCodes() async {
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
      functionName: 'getSubCollections',
    );

    dynamic resp = await callable.call();

    print('RESP: $resp');
  }*/
}
