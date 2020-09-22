import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:random_string/random_string.dart';
import 'package:cloud_functions/cloud_functions.dart';

import 'package:exquisitecorpse/models.dart';
import 'package:exquisitecorpse/db.dart';
import 'package:exquisitecorpse/drawing_storage.dart';

import 'package:exquisitecorpse/ReviewWebApp/MonsterViewer.dart';

class WebApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MonsterMaker Reviewer',
      debugShowCheckedModeBanner: false,
      home: WebHome(),
    );
  }
}

class WebHome extends StatefulWidget {
  @override
  _WebHomeState createState() => _WebHomeState();
}

class _WebHomeState extends State<WebHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MonsterList(),
    );
  }
}

class MonsterList extends StatefulWidget {
  @override
  _MonsterListState createState() => _MonsterListState();
}

class _MonsterListState extends State<MonsterList> {
  bool _loadingInit = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_loadingInit) CircularProgressIndicator(),
        FlatButton(
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
          onPressed: () {
            DatabaseService.instance.deleteIncompleteRooms();
          },
          child: Text('Delete Incomplete Rooms'),
        ),
        FlatButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => MonsterViewer()));
          },
          child: Text('Go to MonsterViewer'),
        ),
      ],
    );
  }

  void _getRoomCodes() async {
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
      functionName: 'getSubCollections',
    );

    dynamic resp = await callable.call();

    print('RESP: $resp');
  }
}
