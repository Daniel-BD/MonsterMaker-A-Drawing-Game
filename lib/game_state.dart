import 'package:flutter/foundation.dart';
import 'drawing_storage.dart';

class GameState extends ChangeNotifier {
  String _currentRoomCode;
  get currentRoomCode => _currentRoomCode;
  set currentRoomCode(String value) {
    _currentRoomCode = value;
    notifyListeners();
  }

  void clearCurrentRoomCode({bool notify}) {
    _currentRoomCode = null;
    if (notify == true) {
      notifyListeners();
    }
  }

  static double canvasHeight;
  static double canvasWidth;

  void notify() {
    notifyListeners();
  }
}

class DrawingState extends ChangeNotifier {
  DrawingStorage _otherPlayerDrawing;
  get otherPlayerDrawing => _otherPlayerDrawing;
  set otherPlayerDrawing(DrawingStorage value) {
    _otherPlayerDrawing = value;
    notifyListeners();
  }

  bool _showButtons = true;
  get showButtons => _showButtons;
  set showButtons(bool value) {
    _showButtons = value;
    notifyListeners();
  }

  bool _loadingHandIn = false;
  get loadingHandIn => _loadingHandIn;
  set loadingHandIn(bool value) {
    _loadingHandIn = value;
    notifyListeners();
  }
}
