import 'package:flutter/material.dart';
import 'package:roulette_app3000/game.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({Key? key}) : super(key: key);

  @override
  _IntroPageState createState() {
    return _IntroPageState();
  }
}

class _IntroPageState extends State<IntroPage> {
  //2 Sekunden Wartezeit Konstante
  static const _delayDuration = Duration(seconds: 2);

  @override
  void initState() {
    super.initState();

    // Warte 2 Sekunden und dann wechsle zur Spiel-App
    Future.delayed(_delayDuration, () {
      // Navigiere zur Spiel-App-Seite und ersetze die aktuelle Seite
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const Game()),
      );
    });
  }

  //GUI erstellen, bestehend aus einem Bild
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/roulette_App_3000.jpg'),
            fit: BoxFit.cover, // Füllt den gesamten Bildschirm aus und streckt das Bild
          ),
        ),
      ),
    );
  }

}
