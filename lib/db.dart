import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:random_string/random_string.dart';
import 'package:tuple/tuple.dart';

import 'package:exquisitecorpse/models.dart';

const String _home = 'home';
const String _roomsDoc = 'rooms';
const String _active = 'active';
const String _gameData = 'gameData';
const String _isHost = 'isHost';
const String _startedGame = 'startedGame';
const String _player = 'player';
const String _top = 'top';
const String _mid = 'middle';
const String _bottom = 'bottom';
const String _startAnimation = 'startAnimation';
const String _monsterIndex = 'monsterIndex';
const String _animateAllAtOnce = 'animateAllAtOnce';

class DatabaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _db = Firestore.instance;
  String _lastUserUID;

  DatabaseService._privateConstructor() {
    _init();
  }
  static final DatabaseService _instance = DatabaseService._privateConstructor();
  static DatabaseService get instance => _instance;

  void _init() async {
    _auth.onAuthStateChanged.listen((event) {
      _onAuthStateChanged(event);
    });
  }

  /// Asserts that the current session is authenticated - which is needed to access the Firestore database.
  void _assertAuthenticated() async {
    String uid = await _getUserUID();
    assert(uid == _lastUserUID, "Current session is not authenticated against Firebase");
  }

  /// If not already signed in, anonymously signs the user in to Firebase. Needed to access the database.
  /// If successful, sets [_lastUserUID] to the UID of the [FirebaseUser] and returns true.
  Future<bool> _signInAnon() async {
    String uid = await _getUserUID();
    if (uid == null || uid != _lastUserUID) {
      try {
        await _auth.signInAnonymously();
        _lastUserUID = await _getUserUID();
        return true;
      } catch (e) {
        print(e);
        return false;
      }
    } else if (uid == _lastUserUID) {
      return true;
    }

    return false;
  }

  /// Returns the UID of the current [FirebaseUser]. If there is no current user, returns null instead.
  Future<String> _getUserUID() async {
    _lastUserUID = (await _auth.currentUser())?.uid;
    return _lastUserUID;
  }

  /// Fires when auth state changes. Currently not used for anything.
  void _onAuthStateChanged(FirebaseUser user) {
    //print("Firebase User: ${user?.uid} ${user.toString()}");
  }

  Stream<GameRoom> streamGameRoom({@required String roomCode}) {
    _assertAuthenticated();
    assert(roomCode != null && roomCode.isNotEmpty, 'roomCode is null or empty');

    return _db.collection(_home).document(_roomsDoc).collection(roomCode).snapshots().map((room) {
      bool startedGame;
      bool isHost;
      int player;
      bool startAnimation;
      int monsterIndex;
      bool animateAllAtOnce;

      Map<int, String> topDrawings = {};
      Map<int, String> midDrawings = {};
      Map<int, String> bottomDrawings = {};

      room.documents.forEach((doc) {
        if (doc.documentID == _lastUserUID) {
          isHost = doc.data[_isHost];
          player = doc.data[_player];
        } else if (doc.documentID == _gameData) {
          startedGame = doc.data[_startedGame];
          startAnimation = doc.data[_startAnimation];
          monsterIndex = doc.data[_monsterIndex];
          animateAllAtOnce = doc.data[_animateAllAtOnce];

          if (doc.data[_top] != null) {
            topDrawings = Map<String, String>.from(doc.data[_top]).map((key, value) => MapEntry<int, String>(int.parse(key), value));
          }
          if (doc.data[_mid] != null) {
            midDrawings = Map<String, String>.from(doc.data[_mid]).map((key, value) => MapEntry<int, String>(int.parse(key), value));
          }
          if (doc.data[_bottom] != null) {
            bottomDrawings = Map<String, String>.from(doc.data[_bottom]).map((key, value) => MapEntry<int, String>(int.parse(key), value));
          }
        }
      });

      assert(topDrawings != null, 'topDrawing null');
      assert(midDrawings != null, 'midDrawings null');
      assert(topDrawings != null, 'topDrawings null');
      assert(startedGame != null, 'startedGame is null');

      if (isHost == null || player == null) {
        return null;
      }

      var gameRoom = GameRoom(
        roomCode: roomCode,
        activePlayers: room.documents.length - 1,
        startedGame: startedGame,
        isHost: isHost,
        player: player,
        startAnimation: startAnimation ?? false,
        monsterIndex: monsterIndex ?? 1,
        animateAllAtOnce: animateAllAtOnce ?? true,
        topDrawings: topDrawings,
        midDrawings: midDrawings,
        bottomDrawings: bottomDrawings,
      );
      return gameRoom;
    });
  }

  /// Creates a new room to play in.
  /// Item1 indicates if successful or not, item2 is the room code.
  Future<Tuple2<bool, String>> createNewRoom({bool randomRoomCodeAlreadyExisted}) async {
    bool loggedIn = await _signInAnon();
    if (!loggedIn) {
      return Tuple2(false, "");
    }
    _assertAuthenticated();

    QuerySnapshot docs;

    Future<String> generateRoomCode() async {
      String roomCode = randomAlpha(4).toUpperCase();
      docs = await _db.collection(_home).document(_roomsDoc).collection(roomCode).getDocuments();
      if (docs.documents.length > 0) {
        return generateRoomCode();
      }
      return roomCode;
    }

    String roomCode = await generateRoomCode();
    Tuple2<bool, String> result = Tuple2(false, "");

    assert(docs?.documents?.length == 0, "RoomCode already exists even though we just checked if it already exists!");
    if (docs.documents.length == 0) {
      await _db
          .collection(_home)
          .document(_roomsDoc)
          .collection(roomCode)
          .document(_lastUserUID)
          .setData({_active: true, _isHost: true, _player: 1}).catchError((Object error) {
        print('ERROR creating new game room, $error');
      }).whenComplete(() async {
        await _db
            .collection(_home)
            .document(_roomsDoc)
            .collection(roomCode)
            .document(_gameData)
            .setData({_startedGame: false, "createdAt": DateTime.now()}).catchError((Object error) {
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

  Future<bool> setAnimation(bool value, {@required GameRoom room}) async {
    bool result = false;

    if (!room.isHost) {
      assert(true, 'non-host is trying to control finished screen...');
      return result;
    }

    await _db
        .collection(_home)
        .document(_roomsDoc)
        .collection(room.roomCode)
        .document(_gameData)
        .setData({_startAnimation: value}, merge: true).catchError((Object error) {
      print('ERROR setting animation value, $error');
    }).whenComplete(() {
      result = true;
    });

    return result;
  }

  Future<bool> setAnimateAllAtOnce(bool value, {@required GameRoom room}) async {
    bool result = false;

    if (!room.isHost) {
      assert(true, 'non-host is trying to control finished screen...');
      return result;
    }

    await _db
        .collection(_home)
        .document(_roomsDoc)
        .collection(room.roomCode)
        .document(_gameData)
        .setData({_animateAllAtOnce: value}, merge: true).catchError((Object error) {
      print('ERROR setting animateAllAtOnce value, $error');
    }).whenComplete(() {
      result = true;
    });

    return result;
  }

  Future<bool> setMonsterIndex(int value, {@required GameRoom room}) async {
    assert(value == 1 || value == 2 || value == 3, 'Monster Index is invalid numer');
    bool result = false;

    if (!room.isHost) {
      assert(true, 'non-host is trying to control finished screen...');
      return result;
    }

    await _db
        .collection(_home)
        .document(_roomsDoc)
        .collection(room.roomCode)
        .document(_gameData)
        .setData({_monsterIndex: value}, merge: true).catchError((Object error) {
      print('ERROR setting monster index, $error');
    }).whenComplete(() {
      result = true;
    });

    return result;
  }

  /// Joins a [GameRoom] with the given [roomCode].
  /// Returns true if successful.
  Future<bool> joinRoom({@required String roomCode}) async {
    bool loggedIn = await _signInAnon();
    if (!loggedIn) {
      return false;
    }
    _assertAuthenticated();

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
          .document(_lastUserUID)
          .setData({_active: true, _isHost: false, _player: 2});
      result = true;
    } else if (docs.documents.length == 3) {
      _db
          .collection(_home)
          .document(_roomsDoc)
          .collection(roomCode)
          .document(_lastUserUID)
          .setData({_active: true, _isHost: false, _player: 3});
      result = true;
    } else if (docs.documents.length > 3) {
      print('The room is full!');
    }

    return result;
  }

  Future<bool> handInDrawing({@required String roomCode, @required String drawing}) async {
    GameRoom room = await streamGameRoom(roomCode: roomCode).first;
    bool result = false;
    String position;

    /// First we need to figure out what part of the drawing this is
    if (!room.myTopDrawingDone()) {
      position = _top;
    } else if (!room.myMidDrawingDone()) {
      position = _mid;
    } else if (!room.myBottomDrawingDone()) {
      position = _bottom;
    }
    assert(position != null);

    /// Then we need to see if this player has already submitted their drawing for this part of the drawing
    if (room.haveAlreadySubmittedDrawing()) {
      return false;
    }

    await _db.collection(_home).document(_roomsDoc).collection(room.roomCode).document(_gameData).setData({
      position: {'${room.player}': drawing}
    }, merge: true).catchError((Object error) {
      print('ERROR handing in drawing, $error');
    }).whenComplete(() {
      result = true;
    });

    return result;
  }

  /// Leaves the [GameRoom] with the given [roomCode].
  /// Returns true if successful.
  Future<bool> leaveRoom({@required String roomCode}) async {
    String uid = await _getUserUID();
    if (uid == null) {
      assert(false, "This method should never be able to be called when the user is not signed into Firebase");
      return false;
    }
    _assertAuthenticated();

    bool result = false;

    await _db.collection(_home).document(_roomsDoc).collection(roomCode).document(uid).delete().catchError((Object error) {
      print('ERROR leaving room, $error');
    }).whenComplete(() async {
      result = true;
    });

    return result;
  }
}
