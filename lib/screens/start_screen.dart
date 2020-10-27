import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'package:exquisitecorpse/db.dart';
import 'package:exquisitecorpse/game_state.dart';
import 'package:exquisitecorpse/widgets/buttons.dart';
import 'package:exquisitecorpse/widgets/game_text_field.dart';
import 'package:exquisitecorpse/widgets/text_components.dart';
import 'package:exquisitecorpse/widgets/colors.dart';
import 'package:exquisitecorpse/painters.dart';
import '../models.dart';

class StartScreen extends StatefulWidget {
  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> /*with WidgetsBindingObserver*/ {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    //WidgetsBinding.instance.addObserver(this);
  }

  /*@override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }*/

  final _db = DatabaseService.instance;
  var _loading = false;
  var _inputtingRoomCode = false;
  var _roomCodeController = TextEditingController();
  var _joinGameKey = GlobalKey();
  var _overlap = 0.0;

  @override
  Widget build(BuildContext context) {
    final logoWidth = min(300.0, MediaQuery.of(context).size.width);

    return Scaffold(
      backgroundColor: paper,
      /*appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: _inputtingRoomCode ? null : FittedBox(child: MonsterMakerLogo()),
        leading: _inputtingRoomCode
            ? IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: textColor,
                  size: 32,
                ),
                onPressed: () {
                  setState(() {
                    _inputtingRoomCode = false;
                    _roomCodeController.clear();
                  });
                },
              )
            : null,
      ),*/
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Builder(
          builder: (context) => _loading
              ? Center(child: CircularProgressIndicator())
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: logoWidth,
                        child: FittedBox(
                          child: MonsterMakerLogo(),
                        ),
                      ),
                      Column(
                        children: [
                          BigGameButton(
                            label: 'PLAY',
                            color: playButtonColor,
                            onPressed: () {
                              //TODO
                            },
                          ),
                          SizedBox(height: 30),
                          BigGameButton(
                            label: 'MONSTER GALLERY',
                            color: galleryButtonColor,
                            onPressed: () {
                              //TODO
                            },
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            'New Monsters',
                            style: GoogleFonts.sniglet(
                              fontSize: 30,
                              color: monsterTextColor,
                            ),
                          ),
                          MonsterCarousel(),
                        ],
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  /*

                      if (!_inputtingRoomCode)
                        GreenGameButton(
                          onPressed: () => _createNewGame(context),
                          label: "NEW GAME",
                        ),
                      if (_inputtingRoomCode)
                        GameTextField(
                          controller: _roomCodeController,
                          onSubmitted: (str) => _joinRoom(context),
                        ),
                      Padding(
                        padding: EdgeInsets.only(bottom: _overlap, top: _inputtingRoomCode ? 30 : 40),
                        child: BlueGameButton(
                          label: "JOIN GAME",
                          onPressed: () => _joinRoom(context),
                        ),
                      ),
   */

  void _createNewGame(BuildContext context) async {
    setState(() => _loading = true);

    String roomCode = await _db.createNewRoom().timeout(Duration(seconds: 10), onTimeout: () => null);

    if (roomCode != null) {
      Provider.of<GameState>(context, listen: false).currentRoomCode = roomCode;
      Navigator.of(context).pushReplacementNamed('/waitingRoom');
    } else {
      assert(false, 'creating new room failed...');
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text("Something went wrong... Check your internet connection or try again later"),
        ),
      );
      setState(() => _loading = false);
    }
  }

  void _joinRoom(BuildContext context) async {
    FocusScope.of(context).unfocus();

    if (!_inputtingRoomCode) {
      setState(() {
        _inputtingRoomCode = true;
      });
    } else {
      setState(() {
        _loading = true;
      });

      String roomCode = _roomCodeController.text.toUpperCase();
      bool success = await _db.joinRoom(roomCode: roomCode).timeout(Duration(seconds: 10), onTimeout: () => null);

      if (success == true) {
        Provider.of<GameState>(context, listen: false).currentRoomCode = roomCode;
        Navigator.of(context).pushReplacementNamed('/waitingRoom');
      } else {
        assert(false, 'join room failed');
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text("Something went wrong... Check if the room code is correct and you have internet connection"),
          ),
        );
      }
      setState(() {
        _loading = false;
      });
    }
  }
}

class MonsterCarousel extends StatefulWidget {
  @override
  _MonsterCarouselState createState() => _MonsterCarouselState();
}

class _MonsterCarouselState extends State<MonsterCarousel> {
  final _db = DatabaseService.instance;
  final borderWidth = 5.0;
  MonsterDrawing drawing;

  @override
  void initState() {
    super.initState();
    _db.getMonsterFromRoomCode('BQCZ', 1).then((value) {
      drawing = value;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (drawing == null) return CircularProgressIndicator();

    final frameWidth = min(300.0, MediaQuery.of(context).size.width * 0.45);
    final frameHeight = frameWidth * 1.5;

    return CarouselSlider(
      options: CarouselOptions(
        autoPlay: true,
        height: frameHeight + 7.5 * borderWidth + 28,
        enlargeCenterPage: true,
        enlargeStrategy: CenterPageEnlargeStrategy.scale,
        viewportFraction: 0.5,
      ),
      items: [
        for (var monster in ['Surf Dog', 'VeggieMonster', 'Coolio', 'Doggo'])
          FittedBox(
            child: MonsterFrame(
              monsterName: monster,
              drawing: drawing,
            ),
          ),
      ],
    );
  }
}

class MonsterFrame extends StatelessWidget {
  final MonsterDrawing drawing;
  final borderWidth = 5.0;
  final monsterName;

  const MonsterFrame({Key key, this.monsterName = 'Monster Name', @required this.drawing}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final frameWidth = min(200.0, MediaQuery.of(context).size.width * 0.4);
    final frameHeight = frameWidth * 1.5;

    return Container(
      height: frameHeight + 7.5 * borderWidth + 28,
      color: Colors.black,
      child: Container(
        margin: EdgeInsets.all(borderWidth),
        color: const Color(0xFF764700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.only(
                left: borderWidth * 1.5,
                right: borderWidth * 1.5,
                top: borderWidth * 1.5,
              ),
              color: Colors.black,
              child: Container(
                margin: EdgeInsets.all(borderWidth),
                color: paper,
                height: frameHeight,
                width: frameWidth,
                child: MonsterDrawingWidget(drawing: drawing),
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                top: borderWidth,
                bottom: borderWidth,
              ),
              color: Colors.black,
              child: Container(
                margin: EdgeInsets.all(2),
                color: Colors.yellow,
                height: 24,
                width: frameWidth + borderWidth - 1,
                child: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: Center(
                    child: FittedBox(
                      child: Text(
                        monsterName,
                        style: GoogleFonts.forum(
                          fontWeight: FontWeight.w500,
                          fontSize: 40,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MonsterDrawingWidget extends StatelessWidget {
  final MonsterDrawing drawing;

  const MonsterDrawingWidget({Key key, @required this.drawing}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final frameWidth = min(200.0, MediaQuery.of(context).size.width * 0.4);
    final frameHeight = frameWidth * 1.5;

    drawing.top.height = frameHeight / 3;

    return Stack(
      children: <Widget>[
        Container(
          foregroundDecoration: BoxDecoration(color: Colors.blue),
          child: CustomPaint(
            painter: MyPainter(
              drawing.top.getScaledPaths(
                inputHeight: drawing.top.height,
                outputHeight: frameHeight / 3,
                inputWidth: drawing.top.width,
                outputWidth: frameWidth,
              ),
              drawing.top.getScaledPaints(
                inputHeight: drawing.top.height,
                outputHeight: frameHeight / 3,
              ),
            ),
          ),
        ),
        Positioned(
          top: (frameHeight / 3) * (5 / 6),
          child: CustomPaint(
            painter: MyPainter(
              drawing.middle.getScaledPaths(
                inputHeight: drawing.middle.height,
                outputHeight: frameHeight / 3,
                inputWidth: drawing.middle.width,
                outputWidth: frameWidth,
              ),
              drawing.middle.getScaledPaints(
                inputHeight: drawing.middle.height,
                outputHeight: frameHeight / 3,
              ),
            ),
          ),
        ),
        Positioned(
          top: 2 * (frameHeight / 3) * (5 / 6),
          child: CustomPaint(
            painter: MyPainter(
              drawing.bottom.getScaledPaths(
                inputHeight: drawing.bottom.height,
                outputHeight: frameHeight / 3,
                inputWidth: drawing.bottom.width,
                outputWidth: frameWidth,
              ),
              drawing.bottom.getScaledPaints(
                inputHeight: drawing.bottom.height,
                outputHeight: frameHeight / 3,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
