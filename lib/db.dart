import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:random_string/random_string.dart';
import 'package:device_info/device_info.dart';
import 'package:tuple/tuple.dart';

import 'package:exquisitecorpse/models.dart';

class DatabaseService {
  final Firestore _db = Firestore.instance;
  var _deviceID;

  DatabaseService._privateConstructor() {
    init();
  }
  static final DatabaseService _instance = DatabaseService._privateConstructor();
  static DatabaseService get instance => _instance;

  void init() async {
    _deviceID = await _getDeviceUID();
    assert(_deviceID != null || _deviceID is String);
  }

  Stream<WaitingRoom> streamWaitingRoom({@required String roomCode}) {
    return _db.collection(roomCode).snapshots().map((room) {
      bool startedGame = false;
      bool isHost;

      room.documents.forEach((doc) {
        if (doc.documentID == 'gameData') {
          startedGame = doc.data['startedGame'];
        } else if (doc.documentID == _deviceID) {
          isHost = doc.data['isHost'];
        }
      });

      assert(startedGame != null && isHost != null, 'startedGame or isHost is null');
      return WaitingRoom(roomCode: roomCode, activePlayers: room.documents.length - 1, startedGame: startedGame, isHost: isHost);
    });
  }

  /// Creates a new room to play in.
  /// Item1 indicates if successful or not, item2 is the room code.
  Future<Tuple2<bool, String>> createNewRoom() async {
    String roomCode = randomAlpha(4).toUpperCase();
    Tuple2<bool, String> result = Tuple2(false, roomCode);

    var docs = await _db.collection(roomCode).getDocuments();

    if (docs.documents.length == 0) {
      await _db.collection(roomCode).document(_deviceID).setData({'active': true, 'isHost': true}).catchError((Object error) {
        print('ERROR creating new game room, $error');
      }).whenComplete(() async {
        await _db.collection(roomCode).document('gameData').setData({'startedGame': false}).catchError((Object error) {
          print('ERROR creating new game room, $error');
        }).whenComplete(() {
          result = Tuple2(true, roomCode);
        });
      });
    }

    return result;
  }

  Future<bool> joinRoom({@required String roomCode}) async {
    bool result = false;

    if (roomCode.length != 4) {
      return result;
    }

    var docs = await _db.collection(roomCode).getDocuments();

    if (docs.documents.length == 0) {
      print('No room with that code!');
    } else if (docs.documents.length == 2) {
      Firestore.instance.collection(roomCode).document(_deviceID).setData({'active': true, 'isHost': false});
      result = true;
    } else if (docs.documents.length == 3) {
      Firestore.instance.collection(roomCode).document(_deviceID).setData({'active': true, 'isHost': false});
      result = true;
    } else if (docs.documents.length > 3) {
      print('The room is full!');
    }

    return result;
  }

  Future<bool> leaveRoom({@required String roomCode}) async {
    bool result = false;

    print('leaving room...');

    await _db.collection(roomCode).document(_deviceID).delete().catchError((Object error) {
      print('ERROR leaving room, $error');
    }).whenComplete(() async {
      print('deleted...');
      result = true;
    });

    return result;
  }

  Future<String> _getDeviceUID() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor;
    } else if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.androidId;
    } else {
      assert(false, 'Failed to find UID for device');
      return 'FAILED_TO_FIND_UID';
    }
  }
}
