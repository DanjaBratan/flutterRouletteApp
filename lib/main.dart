import 'package:flutter/material.dart';
import 'package:roulette_app3000/intro.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Stelle sicher, dass die Flutter-Bindung initialisiert ist

  // Setze die bevorzugten Orientierungen auf Querformat
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(const MeinRoulette());
}

class MeinRoulette extends StatelessWidget {

  const MeinRoulette({super.key});

  @override
  Widget build(BuildContext context){
      return MaterialApp(
        title: "Roulette Spiel",
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.green,
          scrollbarTheme: ScrollbarThemeData(
            thumbColor: MaterialStateProperty.all<Color>(Colors.grey), // Farbe der Scrollleiste
          ),
        ),

        home: const IntroPage(), // Starte mit der Intro-Seite

      );
  }


}