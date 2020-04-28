import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:random_string/random_string.dart';
import 'package:device_info/device_info.dart';
import 'package:tuple/tuple.dart';

import 'package:exquisitecorpse/models.dart';

const String _home = 'home';
const String _roomsDoc = 'rooms';
const String _active = 'active';
const String _gameData = 'gameData';
const String _isHost = 'isHost';
const String _startedGame = 'startedGame';
const String _player = 'player';

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

  Stream<GameRoom> streamWaitingRoom({@required String roomCode}) {
    return _db.collection(_home).document(_roomsDoc).collection(roomCode).snapshots().map((room) {
      bool startedGame;
      bool isHost;
      int player;

      room.documents.forEach((doc) {
        if (doc.documentID == _gameData) {
          startedGame = doc.data[_startedGame];
        } else if (doc.documentID == _deviceID) {
          isHost = doc.data[_isHost];
          player = doc.data[_player];
        }
      });

      assert(startedGame != null, 'startedGame is null');
      assert(isHost != null, 'isHost is null');
      assert(player != null, 'player is null');
      if (startedGame == null || isHost == null || player == null) {
        print('startedGame, isHost or player is null!!');
      }
      return GameRoom(
        roomCode: roomCode,
        activePlayers: room.documents.length - 1,
        startedGame: startedGame,
        isHost: isHost,
        player: player,
      );
    });
  }

  /// Creates a new room to play in.
  /// Item1 indicates if successful or not, item2 is the room code.
  Future<Tuple2<bool, String>> createNewRoom() async {
    String roomCode = randomAlpha(4).toUpperCase();
    Tuple2<bool, String> result = Tuple2(false, roomCode);

    var docs = await _db.collection(_home).document(_roomsDoc).collection(roomCode).getDocuments();

    if (docs.documents.length == 0) {
      await _db
          .collection(_home)
          .document(_roomsDoc)
          .collection(roomCode)
          .document(_deviceID)
          .setData({_active: true, _isHost: true, _player: 1}).catchError((Object error) {
        print('ERROR creating new game room, $error');
      }).whenComplete(() async {
        await _db
            .collection(_home)
            .document(_roomsDoc)
            .collection(roomCode)
            .document(_gameData)
            .setData({_startedGame: false}).catchError((Object error) {
          print('ERROR creating new game room, $error');
        }).whenComplete(() {
          result = Tuple2(true, roomCode);
        });
      });
    }

    return result;
  }

  Future<bool> startGame({@required GameRoom room}) async {
    bool result = false;

    if (!room.isHost) {
      return result;
    }

    await _db
        .collection(_home)
        .document(_roomsDoc)
        .collection(room.roomCode)
        .document(_gameData)
        .setData({_startedGame: true}).catchError((Object error) {
      print('ERROR starting game, $error');
    }).whenComplete(() {
      result = true;
    });

    return result;
  }

  Future<bool> joinRoom({@required String roomCode}) async {
    bool result = false;

    if (roomCode.length != 4) {
      return result;
    }

    var docs = await _db.collection(_home).document(_roomsDoc).collection(roomCode).getDocuments();

    if (docs.documents.length < 2) {
      print('No room with that code!');
    } else if (docs.documents.length == 2) {
      _db
          .collection(_home)
          .document(_roomsDoc)
          .collection(roomCode)
          .document(_deviceID)
          .setData({_active: true, _isHost: false, _player: 2});
      result = true;
    } else if (docs.documents.length == 3) {
      _db
          .collection(_home)
          .document(_roomsDoc)
          .collection(roomCode)
          .document(_deviceID)
          .setData({_active: true, _isHost: false, _player: 3});
      result = true;
    } else if (docs.documents.length > 3) {
      print('The room is full!');
    }

    return result;
  }

  Future<bool> leaveRoom({@required String roomCode}) async {
    bool result = false;

    await _db.collection(_home).document(_roomsDoc).collection(roomCode).document(_deviceID).delete().catchError((Object error) {
      print('ERROR leaving room, $error');
    }).whenComplete(() async {
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
