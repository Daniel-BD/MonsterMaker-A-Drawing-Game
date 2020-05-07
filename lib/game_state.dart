import 'package:flutter/foundation.dart';
import 'drawing_storage.dart';

class GameState extends ChangeNotifier {
  String _currentRoomCode;
  get currentRoomCode => _currentRoomCode;
  set currentRoomCode(String value) {
    _currentRoomCode = value;
    notifyListeners();
  }

  static double canvasHeight;
  static double canvasWidth;
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

  bool _showAnimationCanvas = false;
  get showAnimationCanvas => _showAnimationCanvas;
  set showAnimationCanvas(bool value) {
    _showAnimationCanvas = value;
    notifyListeners();
  }

  bool _loadingHandIn = false;
  get loadingHandIn => _loadingHandIn;
  set loadingHandIn(bool value) {
    _loadingHandIn = value;
    notifyListeners();
  }
}
