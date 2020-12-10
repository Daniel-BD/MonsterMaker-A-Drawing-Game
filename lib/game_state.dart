import 'package:flutter/foundation.dart';

class GameState extends ChangeNotifier {
  /// How many players the current game mode is for (right now the only option is 3, but may change in the future)
  static int numberOfPlayersGameMode = 3;

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

  bool _loadingHandIn = false;
  get loadingHandIn => _loadingHandIn;
  set loadingHandIn(bool value) {
    _loadingHandIn = value;
    notifyListeners();
  }

  void notify() {
    notifyListeners();
  }
}

/*class OtherPlayerDrawing {
  DrawingStorage drawing;
}*/

class DrawingControlsState extends ChangeNotifier {
  /// Whether to show or hide the drawing controls
  bool _showButtons = true;
  get showButtons => _showButtons;
  set showButtons(bool value) {
    _showButtons = value;
    if (!_showButtons) {
      _showBrushSettings = false;
    }
    notifyListeners();
  }

  /// Whether to show or hide the brush controls (color + size)
  bool _showBrushSettings = false;
  get showBrushSettings => _showBrushSettings;
  set showBrushSettings(bool value) {
    _showBrushSettings = value;
    notifyListeners();
  }
}
