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

class OtherPlayerDrawing {
  DrawingStorage drawing;
}

class DrawingState extends ChangeNotifier {
  bool _showButtons = true;
  get showButtons => _showButtons;
  set showButtons(bool value) {
    _showButtons = value;
    if (!_showButtons) {
      _showBrushSettings = false;
    }
    notifyListeners();
  }

  bool _showBrushSettings = false;
  get showBrushSettings => _showBrushSettings;
  set showBrushSettings(bool value) {
    _showBrushSettings = value;
    notifyListeners();
  }

  bool _loadingHandIn = false;
  get loadingHandIn => _loadingHandIn;
  set loadingHandIn(bool value) {
    _loadingHandIn = value;
    notifyListeners();
  }

  bool _showDot = false;
  get showDot => _showDot;
  set showDot(bool value) {
    _showDot = value;
    notifyListeners();
  }

  bool _transparentDot = false;
  get transparentDot => _transparentDot;
  set transparentDot(bool value) {
    _transparentDot = value;
    notifyListeners();
  }

  bool _timerOn = false;
  get timerOn => _timerOn;
  set timerOn(bool value) {
    _timerOn = value;
    notifyListeners();
  }

  void onChangeStart() {
    _transparentDot = false;
    _timerOn = false;
    _showDot = true;
    notifyListeners();
  }
}
