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
import 'package:exquisitecorpse/widgets/MonsterFrameWidgets.dart';
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
                              Navigator.of(context).pushNamed('/playModesScreen');
                            },
                          ),
                          SizedBox(height: 30),
                          BigGameButton(
                            label: 'MONSTER GALLERY',
                            color: galleryYellow,
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
    _db.getMonsterFromRoomCode('AFYU', 3).then((value) {
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
