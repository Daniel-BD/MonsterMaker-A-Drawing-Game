import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:random_string/random_string.dart';
import 'package:device_info/device_info.dart';
import 'package:tuple/tuple.dart';

import 'models.dart';

class DatabaseService {
  final Firestore _db = Firestore.instance;

  Stream<WaitingRoom> streamWaitingRoom({@required String roomCode}) {
    return _db.collection(roomCode).snapshots().map((room) {
      return WaitingRoom(roomCode: roomCode, activePlayers: room.documents.length);
    });
  }

  /// Creates a new room to play in.
  /// Item1 indicates if successful or not, item2 is the room code.
  Future<Tuple2<bool, String>> createNewRoom() async {
    String roomCode = randomAlpha(4).toUpperCase();
    Tuple2<bool, String> result = Tuple2(false, roomCode);

    var docs = await _db.collection(roomCode).getDocuments();

    if (docs.documents.length == 0) {
      await _db.collection(roomCode).document(await _getDeviceUID()).setData({'active': true}).catchError((Object error) {
        print('ERROR creating new game room, $error');
      }).whenComplete(() {
        result = Tuple2(true, roomCode);
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
    } else if (docs.documents.length == 1) {
      Firestore.instance.collection(roomCode).document(await _getDeviceUID()).setData({'active': true});
      result = true;
    } else if (docs.documents.length == 2) {
      Firestore.instance.collection(roomCode).document(await _getDeviceUID()).setData({'active': true});
      result = true;
    } else if (docs.documents.length > 2) {
      print('The room is full!');
    }

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
