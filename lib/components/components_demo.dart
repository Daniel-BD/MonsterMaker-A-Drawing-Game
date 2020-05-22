import 'package:flutter/material.dart';

import 'colors.dart';
import 'game_text_field.dart';
import 'modal_message.dart';
import 'brush_size_slider.dart';
import 'color_picker.dart';
import 'buttons.dart';

class Components extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: paper,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                GameColorPicker(),
                Container(height: 40),
                BrushSizeSlider(),
                Container(height: 40),
                QuitGameModal(),
                Container(height: 40),
                ClearDrawingGameModal(),
                Container(height: 40),
                DoneDrawingGameModal(),
                Container(height: 40),
                Row(
                  children: <Widget>[LeaveGameButton()],
                ),
                Container(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    ModalDoneGameButton(),
                    ModalQuitGameButton(),
                  ],
                ),
                Container(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    ModalBackGameButton(),
                    ModalClearGameButton(),
                  ],
                ),
                Container(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    QuitButton(),
                    ShareButton(),
                  ],
                ),
                Container(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    UndoButton(),
                    RedoButton(),
                    DeleteButton(),
                    DoneButton(),
                    BrushButton(),
                  ],
                ),
                Container(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    PlayButton(),
                    StopButton(),
                    PreviousButton(),
                    NextButton(),
                    AnimateOrderButton(),
                  ],
                ),
                Container(height: 40),
                GreenGameButton(
                  label: "BUTTON",
                ),
                Container(height: 40),
                BlueGameButton(
                  label: "BUTTON",
                ),
                Container(height: 40),
                GameTextField(
                  controller: TextEditingController(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
