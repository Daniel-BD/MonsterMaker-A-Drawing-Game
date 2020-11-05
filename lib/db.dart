import 'dart:convert';

import 'package:exquisitecorpse/drawing_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:random_string/random_string.dart';

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
  FirebaseAuth _auth;
  FirebaseFirestore _db;
  String _userUID() => _auth.currentUser?.uid;

  DatabaseService._privateConstructor() {
    _init();
  }
  static final DatabaseService _instance = DatabaseService._privateConstructor();
  static DatabaseService get instance => _instance;

  Future<void> _init() async {
    if (_auth != null) {
      return;
    }
    await Firebase.initializeApp();
    _auth = FirebaseAuth.instance;
    _db = FirebaseFirestore.instance;

    _auth.authStateChanges().listen((event) {
      _onAuthStateChanged(event);
    });

    return;
  }

  /// Asserts that the current session is authenticated - which is needed to access the Firestore database.
  void _assertAuthenticated() async {
    assert(_userUID() != null, "Current session is not authenticated against Firebase");
  }

  /// If not already signed in, anonymously signs the user in to Firebase. Needed to access the database.
  /// If successful, sets [_userUID] to the UID of the [User] and returns true.
  Future<bool> _signInAnon() async {
    if (_userUID() == null) {
      try {
        await _auth.signInAnonymously();
        //TODO: Kolla om det gick bra genom att kolla _userUID() != null kanske?
        return true;
      } catch (e) {
        print(e);
        return false;
      }
    }

    return true;
  }

  /// Fires when auth state changes. Currently not used for anything.
  void _onAuthStateChanged(User user) {
    //print("Firebase User: ${user?.uid} ${user.toString()}");
  }

  Future<void> initDB() async {
    await _init();
    return;
  }

  Future<List<String>> gameRoomsToReview() async {
    var rooms = await _db.collection(_home).doc('Yf4VulohxCPurlc2uILn').get();

    var newRooms = await _db.collection(_home).doc('aA1G9SB63DDqP1jRcQTp').get();

    List<String> roomCodes = rooms.data()['roomCodes'].cast<String>();

    List<String> newRoomCodes = newRooms.data()['roomCodes'].cast<String>();

    newRoomCodes.removeWhere((element) => roomCodes.contains(element));

    print(newRoomCodes);

    return newRoomCodes;
  }

  void deleteIncompleteRooms() async {
    await _init();
    var rooms = await _db.collection(_home).doc('Eeg5IoszWif88lwfiAIi').get();

    List<dynamic> roomCodes = rooms.data()['roomCodes'];

    roomCodes.forEach((roomCode) async {
      print('RoomCode: $roomCode');

      var roomData = await _db.collection(_home).doc(_roomsDoc).collection(roomCode).get();

      //bool shouldDelete = false;

      if (roomData.size > 3) {
        roomData.docs.forEach((document) {
          if (document.id == 'gameData') {
            var gameData = document.data();
            if (gameData != null) {
              print("Bottom: ${gameData['bottom'].runtimeType}");

              Map<int, String> bottom = {};
              if (gameData['bottom'] != null) {
                print('bottom is not null for room: $roomCode');
                bottom = Map<String, String>.from(gameData[_bottom]).map((key, value) => MapEntry<int, String>(int.parse(key), value));
              } else {
                print('bottom is NULL for room: $roomCode');
              }

              if (bottom == null || bottom.length < 3) {
                print("DELETE room: $roomCode");
                //shouldDelete = true;

                roomData.docs.forEach((documentToDelete) {
                  documentToDelete.reference.delete();
                });
              }
            }
          }
        });
      } else {
        print("room to delete: $roomCode");
        roomData.docs.forEach((documentToDelete) {
          documentToDelete.reference.delete();
        });
      }
    });
  }

  Stream<GameRoom> roomToReviewFromCode({@required String roomCode}) {
    assert(roomCode != null && roomCode.isNotEmpty, 'roomCode is null or empty');

    return _db.collection(_home).doc(_roomsDoc).collection(roomCode).snapshots().map((room) {
      Map<int, String> topDrawings = {};
      Map<int, String> midDrawings = {};
      Map<int, String> bottomDrawings = {};

      room.docs.forEach((doc) {
        if (doc.id == _userUID()) {
        } else if (doc.id == _gameData) {
          var gameData = doc.data();

          if (gameData[_top] != null) {
            topDrawings = Map<String, String>.from(gameData[_top]).map((key, value) => MapEntry<int, String>(int.parse(key), value));
          }
          if (gameData[_mid] != null) {
            midDrawings = Map<String, String>.from(gameData[_mid]).map((key, value) => MapEntry<int, String>(int.parse(key), value));
          }
          if (gameData[_bottom] != null) {
            bottomDrawings = Map<String, String>.from(gameData[_bottom]).map((key, value) => MapEntry<int, String>(int.parse(key), value));
          }
        }
      });

      assert(topDrawings != null, 'topDrawing null');
      assert(midDrawings != null, 'midDrawings null');
      assert(bottomDrawings != null, 'bottomDrawings null');

      var gameRoom = GameRoom(
        roomCode: roomCode,
        activePlayers: room.docs.length - 1,
        startedGame: true,
        isHost: true,
        playerIndex: 1,
        startAnimation: true,
        monsterIndex: 1,
        animateAllAtOnce: false,
        topDrawings: topDrawings,
        midDrawings: midDrawings,
        bottomDrawings: bottomDrawings,
      );
      return gameRoom;
    });
  }

  /// TODO: ta bort
  Future<MonsterDrawing> getMonsterFromRoomCode(String roomCode, int monsterIndex) async {
    debugPrint('running getFromRoomCode');

    assert(monsterIndex >= 1 && monsterIndex <= 3, 'MonsterIndex out of range');
    await _init();
    bool loggedIn = await _signInAnon();
    if (!loggedIn) {
      debugPrint('failed to login...');
      return null;
    }

    int topIndex = monsterIndex;
    int midIndex = monsterIndex == 1
        ? 2
        : monsterIndex == 2
            ? 3
            : 1;
    int bottomIndex = monsterIndex == 1
        ? 3
        : monsterIndex == 2
            ? 1
            : 2;

    _assertAuthenticated();
    assert(roomCode != null && roomCode.isNotEmpty, 'roomCode is null or empty');

    Map<int, String> topDrawings = {};
    Map<int, String> midDrawings = {};
    Map<int, String> bottomDrawings = {};

    final gameDataDoc = await _db.collection(_home).doc(_roomsDoc).collection(roomCode).doc(_gameData).get();
    final gameData = gameDataDoc.data();

    if (gameData[_top] != null) {
      topDrawings = Map<String, String>.from(gameData[_top]).map((key, value) => MapEntry<int, String>(int.parse(key), value));
    }
    if (gameData[_mid] != null) {
      midDrawings = Map<String, String>.from(gameData[_mid]).map((key, value) => MapEntry<int, String>(int.parse(key), value));
    }
    if (gameData[_bottom] != null) {
      bottomDrawings = Map<String, String>.from(gameData[_bottom]).map((key, value) => MapEntry<int, String>(int.parse(key), value));
    }

    assert(topDrawings != null, 'topDrawing null');
    assert(midDrawings != null, 'midDrawings null');
    assert(bottomDrawings != null, 'bottomDrawings null');

    DrawingStorage top = DrawingStorage.fromJson(jsonDecode(topDrawings[topIndex]));
    DrawingStorage mid = DrawingStorage.fromJson(jsonDecode(midDrawings[midIndex]));
    DrawingStorage bottom = DrawingStorage.fromJson(jsonDecode(bottomDrawings[bottomIndex]));

    return MonsterDrawing(top, mid, bottom);
  }

  Stream<GameRoom> streamGameRoom({@required String roomCode}) {
    _assertAuthenticated();
    assert(roomCode != null && roomCode.isNotEmpty, 'roomCode is null or empty');

    return _db.collection(_home).doc(_roomsDoc).collection(roomCode).snapshots().map((room) {
      bool startedGame;
      bool isHost;
      int player;
      bool startAnimation;
      int monsterIndex;
      bool animateAllAtOnce;

      Map<int, String> topDrawings = {};
      Map<int, String> midDrawings = {};
      Map<int, String> bottomDrawings = {};

      room.docs.forEach((doc) {
        if (doc.id == _userUID()) {
          isHost = doc.get(_isHost);
          player = doc.get(_player);
        } else if (doc.id == _gameData) {
          var gameData = doc.data();

          startedGame = gameData[_startedGame];
          startAnimation = gameData[_startAnimation];
          monsterIndex = gameData[_monsterIndex];
          animateAllAtOnce = gameData[_animateAllAtOnce];

          if (gameData[_top] != null) {
            topDrawings = Map<String, String>.from(gameData[_top]).map((key, value) => MapEntry<int, String>(int.parse(key), value));
          }
          if (gameData[_mid] != null) {
            midDrawings = Map<String, String>.from(gameData[_mid]).map((key, value) => MapEntry<int, String>(int.parse(key), value));
          }
          if (gameData[_bottom] != null) {
            bottomDrawings = Map<String, String>.from(gameData[_bottom]).map((key, value) => MapEntry<int, String>(int.parse(key), value));
          }
        }
      });

      assert(topDrawings != null, 'topDrawing null');
      assert(midDrawings != null, 'midDrawings null');
      assert(bottomDrawings != null, 'bottomDrawings null');
      assert(startedGame != null, 'startedGame is null');

      if (isHost == null || player == null) {
        return null;
      }

      MonsterDrawing monsterDrawing;

      int topIndex = monsterIndex;
      int midIndex = monsterIndex == 1
          ? 2
          : monsterIndex == 2
              ? 3
              : 1;
      int bottomIndex = monsterIndex == 1
          ? 3
          : monsterIndex == 2
              ? 1
              : 2;

      if (topDrawings[topIndex] != null && midDrawings[midIndex] != null && bottomDrawings[bottomIndex] != null) {
        DrawingStorage top = DrawingStorage.fromJson(jsonDecode(topDrawings[topIndex]));
        DrawingStorage mid = DrawingStorage.fromJson(jsonDecode(midDrawings[midIndex]));
        DrawingStorage bottom = DrawingStorage.fromJson(jsonDecode(bottomDrawings[bottomIndex]));

        monsterDrawing = MonsterDrawing(top, mid, bottom);
      }

      var gameRoom = GameRoom(
        roomCode: roomCode,
        activePlayers: room.docs.length - 1,
        startedGame: startedGame,
        isHost: isHost,
        playerIndex: player,
        startAnimation: startAnimation ?? false,
        monsterIndex: monsterIndex ?? 1,
        animateAllAtOnce: animateAllAtOnce ?? false,
        topDrawings: topDrawings,
        midDrawings: midDrawings,
        bottomDrawings: bottomDrawings,
        monsterDrawing: monsterDrawing,
      );
      return gameRoom;
    });
  }

  /// Creates a new room to play in.
  /// Returns a string of the room code if successful, null otherwise
  Future<String> createNewRoom({bool randomRoomCodeAlreadyExisted}) async {
    bool loggedIn = await _signInAnon();
    if (!loggedIn) {
      return null;
    }
    _assertAuthenticated();

    QuerySnapshot roomSnapshot;

    Future<String> generateRoomCode() async {
      String roomCode = randomAlpha(4).toUpperCase();
      roomSnapshot = await _db.collection(_home).doc(_roomsDoc).collection(roomCode).get();
      if (roomSnapshot.docs.length > 0) {
        assert(false, "The room code already exists...");
        return generateRoomCode();
      }
      return roomCode;
    }

    String roomCode = await generateRoomCode();

    assert(roomSnapshot?.docs?.length == 0, 'RoomCode already exists even though we just checked if it already exists!');
    if (roomSnapshot.docs.length == 0) {
      await _db
          .collection(_home)
          .doc(_roomsDoc)
          .collection(roomCode)
          .doc(_userUID())
          .set({_active: true, _isHost: true, _player: 1}).catchError((Object error) {
        roomCode = null;
        assert(false, 'failed to create new room');
      }).whenComplete(() async {
        await _db
            .collection(_home)
            .doc(_roomsDoc)
            .collection(roomCode)
            .doc(_gameData)
            .set({_startedGame: false, "createdAt": DateTime.now()}).catchError((Object error) {
          roomCode = null;
          assert(false, 'failed to create new room');
        }).whenComplete(() {
          return roomCode;
        });
      });
    }

    return roomCode;
  }

  Future<bool> startGame({@required GameRoom room}) async {
    bool result = false;

    if (!room.isHost) {
      return result;
    }

    await _db.collection(_home).doc(_roomsDoc).collection(room.roomCode).doc(_gameData).set({
      _startedGame: true,
      _startAnimation: false,
      _monsterIndex: 1,
      _animateAllAtOnce: false,
    }, SetOptions(merge: true)).catchError((Object error) {
      assert(false, 'ERROR starting game, $error');
    }).whenComplete(() {
      result = true;
    });

    return result;
  }

  Future<bool> setAnimation(bool value, {@required GameRoom room}) async {
    bool result = false;

    if (!room.isHost) {
      assert(false, 'non-host is trying to control finished screen...');
      return result;
    }

    await _db
        .collection(_home)
        .doc(_roomsDoc)
        .collection(room.roomCode)
        .doc(_gameData)
        .set({_startAnimation: value}, SetOptions(merge: true)).catchError((Object error) {
      assert(false, 'ERROR setting animation value, $error');
    }).whenComplete(() {
      result = true;
    });

    return result;
  }

  Future<bool> setAnimateAllAtOnce(bool value, {@required GameRoom room}) async {
    bool result = false;

    if (!room.isHost) {
      assert(false, 'non-host is trying to control finished screen...');
      return result;
    }

    await _db
        .collection(_home)
        .doc(_roomsDoc)
        .collection(room.roomCode)
        .doc(_gameData)
        .set({_animateAllAtOnce: value}, SetOptions(merge: true)).catchError((Object error) {
      assert(false, 'ERROR setting animationAllAtOnce value, $error');
    }).whenComplete(() {
      result = true;
    });

    return result;
  }

  Future<bool> setMonsterIndex(int value, {@required GameRoom room}) async {
    assert(value == 1 || value == 2 || value == 3, 'Monster Index is invalid numer');
    bool result = false;

    if (!room.isHost) {
      assert(false, 'non-host is trying to control finished screen...');
      return result;
    }

    await _db
        .collection(_home)
        .doc(_roomsDoc)
        .collection(room.roomCode)
        .doc(_gameData)
        .set({_monsterIndex: value}, SetOptions(merge: true)).catchError((Object error) {
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

    var roomData = await _db.collection(_home).doc(_roomsDoc).collection(roomCode).get();

    if (roomData.docs.length < 2) {
      print('No room with that code!');
    } else if (roomData.docs.length == 2) {
      _db.collection(_home).doc(_roomsDoc).collection(roomCode).doc(_userUID()).set({_active: true, _isHost: false, _player: 2});
      result = true;
    } else if (roomData.docs.length == 3) {
      _db.collection(_home).doc(_roomsDoc).collection(roomCode).doc(_userUID()).set({_active: true, _isHost: false, _player: 3});
      result = true;
    } else if (roomData.docs.length > 3) {
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

    await _db.collection(_home).doc(_roomsDoc).collection(room.roomCode).doc(_gameData).set({
      position: {'${room.playerIndex}': drawing}
    }, SetOptions(merge: true)).catchError((Object error) {
      print('ERROR handing in drawing, $error');
    }).whenComplete(() {
      result = true;
    });

    return result;
  }

  /// Leaves the [GameRoom] with the given [roomCode].
  /// Returns true if successful.
  Future<bool> leaveRoom({@required String roomCode}) async {
    if (_userUID() == null) {
      assert(false, "This method should never be able to be called when the user is not signed into Firebase");
      return false;
    }
    _assertAuthenticated();

    bool result = false;

    await _db.collection(_home).doc(_roomsDoc).collection(roomCode).doc(_userUID()).delete().catchError((Object error) {
      print('ERROR leaving room, $error');
    }).whenComplete(() async {
      result = true;
    });

    return result;
  }
}
