import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'dart:math' as math;

class Game extends StatefulWidget{

  const Game({super.key});

  @override
  State<Game> createState() => _GameState();

}

class _GameState extends State<Game> with SingleTickerProviderStateMixin{

  //Audioplayer
  final AssetsAudioPlayer audioPlayer = AssetsAudioPlayer();

  //Daten
  List<int> sektoren = [0,32,15,19,4,21,2,25,17,34,6,27,13,36,11,30,8,23,10,5,24,16,33,1,20,14,31,9,22,18,29,7,28,12,35,3,26];
  List<String> farbsektoren = ['Grün', // Sektor 0 (Grün)
  'Rot', // Sektor 32 (Rot)
  'Schwarz', // Sektor 15 (Schwarz)
  'Rot', // Sektor 19 (Rot)
  'Schwarz', // Sektor 4 (Schwarz)
  'Rot', // Sektor 21 (Rot)
  'Schwarz', // Sektor 2 (Schwarz)
  'Rot', // Sektor 25 (Rot)
  'Schwarz', // Sektor 17 (Schwarz)
  'Rot', // Sektor 34 (Rot)
  'Schwarz', // Sektor 6 (Schwarz)
  'Rot', // Sektor 27 (Rot)
  'Schwarz', // Sektor 13 (Schwarz)
  'Rot', // Sektor 36 (Rot)
  'Schwarz', // Sektor 11 (Schwarz)
  'Rot', // Sektor 30 (Rot)
  'Schwarz', // Sektor 8 (Schwarz)
  'Rot', // Sektor 23 (Rot)
  'Schwarz', // Sektor 10 (Schwarz)
  'Rot', // Sektor 5 (Rot)
  'Schwarz', // Sektor 24 (Schwarz)
  'Rot', // Sektor 16 (Rot)
  'Schwarz', // Sektor 33 (Schwarz)
  'Rot', // Sektor 1 (Rot)
  'Schwarz', // Sektor 20 (Schwarz)
  'Rot', // Sektor 14 (Rot)
  'Schwarz', // Sektor 31 (Schwarz)
  'Rot', // Sektor 9 (Rot)
  'Schwarz', // Sektor 22 (Schwarz)
  'Rot', // Sektor 18 (Rot)
  'Schwarz', // Sektor 29 (Schwarz)
  'Rot', // Sektor 7 (Rot)
  'Schwarz', // Sektor 28 (Schwarz)
  'Rot', // Sektor 12 (Rot)
  'Schwarz', // Sektor 35 (Schwarz)
  'Rot', // Sektor 3 (Rot)
  'Schwarz']; // Sektor 26 (Schwarz)
  int randomSektorenIndex = -1; //alle
  List<double> sektorenWinkel = [];
  double bogenmass = 0; //pro sektorenWinkel 

  //Flag zeigt an, ob sich Roulette dreht
  bool drehtsich = false;

  //aktuell ausgewählte Zahl
  int ausgewaehlteZahl = 0;

  //Ausgewählte Farbe
  String ausgewaehlteFarbe = "Grün";

  //Anzahl Drehungen
  int anzahlDrehungen = 0;

  //Zufallszahl
  math.Random random = math.Random();

  //Spin Animation Controller
  late AnimationController animController;

  //Animation
  late Animation<double> animation;

  //Wetteinsätze
  TextEditingController wetteinsatzController = TextEditingController(text: '200');
  String selectedWetteArt = 'Rot';
  List<Wetteinsatz> wetteinsatzListe = [];

  // Wettcoins
  double coins = 5000;
  double gewinnOderVerlust = 0;



  //initiales setup
  @override
  void initState(){
    super.initState();

    //Generiere Sektoren Auswahl
    generateSektorenWinkel();

    //animations Kontrolle, 5Sekunden Drehdauer
    animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5100),
    );

    //über einen Bereich hinweg animieren
    Tween<double> tween = Tween<double>(begin: 0, end: 1);

    //Kurvenverhalten
    CurvedAnimation kurve = CurvedAnimation(
      parent: animController, 
      curve: Curves.decelerate,
    );

    //animation
    animation = tween.animate(kurve);

    //aktualisieren des Bildschirms mit einem Listener
    animController.addListener(() {
      //nur wenn animation zuende ist
      if(animController.isCompleted){
        //neubauen
        setState(() {
          //aufnehmen der Statistik
          recordStats();
          //update status bool
          drehtsich = false;
          wettenAbgleichen();
        });
      }
    });

  }

  //Funktion für Sound abspielen
  Future<void> playSound(String assetPath) async {
    try {
      final Audio audio = Audio(assetPath);
      await audioPlayer.open(audio);
      audioPlayer.play();
    } catch (e) {
      print('Fehler beim Abspielen der Audiodatei: $e');
    }
  }


  //dispose controller nach dem Verwenden
  @override
  void dispose(){
    super.dispose();
    audioPlayer.dispose();
    animController.dispose();
  }

  //Build Methode
  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: _body(),
    );
  }


  //funktion zum Drehen des Roulettes
  void drehen(){
    //wähle zufälligen Sektor
    randomSektorenIndex = random.nextInt(sektoren.length);
    double randomBogenmass = generateRandomSektorenWinkel();
    animController.reset();
    bogenmass = randomBogenmass;
    animController.forward();
  }

  //Berechnung des nächsten Sektors
  double generateRandomSektorenWinkel(){
    return(2*math.pi*sektoren.length)+sektorenWinkel[randomSektorenIndex];
  }

  // Diese Funktion generiert die Winkel für jeden Sektor.
  void generateSektorenWinkel(){

    //Bogenmaß für einen Sektor
    double sektorBogenmass = 2 * math.pi / sektoren.length;

    for (int i = 0; i < sektoren.length; i++){
      sektorenWinkel.add((i+1)*sektorBogenmass);
    }

  }

  //Spielstatistik aufzeichnen
  void recordStats(){
      ausgewaehlteZahl = sektoren[sektoren.length - (randomSektorenIndex + 1)];
      ausgewaehlteFarbe = farbsektoren[sektoren.length - (randomSektorenIndex + 1)];
      anzahlDrehungen = anzahlDrehungen + 1;
  }

  // Diese Funktion vergleicht die Wetten und berechnet den Gewinn oder Verlust
  void wettenAbgleichen(){
    gewinnOderVerlust = 0;

    // Zerlege das gewonnene Ergebnis in Farbe und Zahl
    final String gewonneneFarbe = ausgewaehlteFarbe;
    final int gewonneneZahl = ausgewaehlteZahl;

    // Überprüfe, welche Wetten auf das gewonnene Ergebnis zutreffen
    for (final wetteinsatz in wetteinsatzListe) {
      if (wetteinsatz.art == gewonneneFarbe || 
      (wetteinsatz.art == "Gerade" && gewonneneZahl % 2 == 0) || 
      (wetteinsatz.art == "Ungerade" && gewonneneZahl % 2 != 0)) {
        gewinnOderVerlust += (wetteinsatz.bet * 2).toInt(); // Aktualisiere die Variable für den Gewinn oder Verlust
        coins += (wetteinsatz.bet * 2).toInt(); // Die Wette trifft zu, erhöhe die Coins um den Wetteinsatz verdoppelt
      }
    }

    // Leere die Wettliste
    wetteinsatzListe.clear();

    // Aktualisiere das Widget, um die neuen Coins und die geleerte Wettliste anzuzeigen
    setState(() {});

    //Rufe nächste Funktion auf
    _zeigeGewinnOderVerlustPopup(gewinnOderVerlust);
  }

  
 



  // Diese Funktion zeigt ein Popup mit Gewinn oder Verlust an
  void _zeigeGewinnOderVerlustPopup(double gewinnOderVerlust) {
    String nachricht;
    String titel = "";
    if (gewinnOderVerlust > 0) {
      playSound("assets/cashSound.mp3");
      nachricht = "Du hast gewonnen.";
      titel = "SIEG";
    } else {
      playSound("assets/bruhSound.mp3");
      nachricht = "Du hast keine Coins gewonnen.";
      titel = "Kein Gewinn";
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(titel),
          content: Text(nachricht),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Schließe das Popup
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  // Diese Funktion setzt das Spiel zurück
  void resetSpiel(){
    drehtsich = false;
    bogenmass = 0;
    ausgewaehlteZahl = 0;
    ausgewaehlteFarbe = "Grün";
    anzahlDrehungen = 0;
    coins = 5000;
    wetteinsatzListe.clear();
    setState(() {});
    animController.reset();
  }

   // Diese Funktion behandelt das Platzieren von Wetten und aktualisiert den Spielzustand
  void handleWetteUndSpiel(double wetteinsatz, String wetteArt) {
    // Überprüfe, ob der Wetteinsatz gültig ist und ob der Spieler genügend Coins hat
    if (wetteinsatz <= 0 || wetteinsatz > coins) {
      // Zeige eine Fehlermeldung oder Toast an, dass die Wette ungültig ist
      return;
    }

    // Durchlaufe die vorhandenen Wetten und prüfe, ob die Wettart bereits existiert
    bool wetteArtExists = false;
    for (int i = 0; i < wetteinsatzListe.length; i++) {
      final Wetteinsatz wetteinsatzObj = wetteinsatzListe[i];
      if (wetteinsatzObj.art == wetteArt) {
        // Die Wettart existiert bereits, erhöhe den Betrag dazu
        wetteinsatzListe[i].bet += wetteinsatz;
        wetteArtExists = true;
        break; // Wir haben die Wette gefunden, daher können wir die Schleife verlassen
      }
    }


    if (!wetteArtExists) {
      // Die Wettart wurde nicht gefunden, füge sie zur Liste hinzu
      wetteinsatzListe.add(Wetteinsatz(bet: wetteinsatz, art: wetteArt));
    }

    // Reduziere die Coins um den Wetteinsatz
    coins -= wetteinsatz;

    // Aktualisiere das Widget, um die neue Wettliste anzuzeigen
    setState(() {});
  }




  //Hauptwidget
  Widget _body(){
    //hintergrund und spiel
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
                Color.fromARGB(255, 4, 61, 6),
                Color.fromARGB(255, 8, 68, 2),
            ],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
      ),
      //Enthält den Inhalt des Spiels
      child: _spielContent(),
    );
  }

  //Alle Widget-Inhalte aufgelistet
  Widget _spielContent(){
    //verwende Stack
    return Stack(
      children: [
        _spielTitel(),
        _spielRouletteRad(),
        _spielAktionDrehen(),
        _spielAktionenReset(),
        _spielStatistik(),
        _spielWetteinsatz(),
        _coinsAnzeige(),
      ],
    );
  }

  //Widget für den Titel des Spiels
  Widget _spielTitel(){
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          border: Border.all(
            color: const Color.fromARGB(255, 0, 0, 0),
            width: 2,
          ),
          gradient: const LinearGradient(
              colors: [Color.fromARGB(255, 87, 250, 85), Color.fromARGB(255, 99, 249, 97)],
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
          ),
        ),
        child: const Text(
          "Roulette Lite",
          style: TextStyle(
            fontSize: 20,
            color: Color.fromARGB(255, 0, 0, 0),
            fontStyle: FontStyle.italic,
          )
        )
      )
    );
  }

  //Dieses Widget erstellt das Roulette-Rad und seine Animation.
  Widget _spielRouletteRad(){
      return Center(
        child: Container(
          //Hier drin ist der äußere Rand mit transparenter Mitte
          width: MediaQuery.of(context).size.width*0.8,
          height: MediaQuery.of(context).size.height*0.65,
          decoration: const BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.contain,
              image: AssetImage("assets/runderrandaussen.png"),
            ),
          ),

          //animierter Builder für das Drehen
          child: InkWell(
            child: AnimatedBuilder(
              animation: animation,
              builder: (context, child){
                  return Transform.rotate(
                    angle: animController.value * bogenmass,
                    child: Container(
                      margin: EdgeInsets.all(MediaQuery.of(context).size.width*0.005), 
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.contain,
                          image: AssetImage("assets/rouletterad.png"), //kreisrundes Bild
                        )
                      ),
                    )
                  );
              },
            ),
          ),

        ),
      );

  }


  // Dieses Widget zeigt die Spielstatistik an.
  Widget _spielStatistik() {
    return Align(
      alignment: Alignment.centerRight,
      child: FractionallySizedBox(
        widthFactor: 1.0 / 3.0, // Ein Drittel des verfügbaren Platzes
        child: Container(
          margin: const EdgeInsets.only(right: 15),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            border: Border.all(
              color: CupertinoColors.black,
              width: 2,
            ),
            gradient: const LinearGradient(
              colors: [Color.fromARGB(255, 107, 255, 105), Color.fromARGB(255, 168, 255, 167)],
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
            ),
          ),
          child: Table(
            border: TableBorder.all(color: CupertinoColors.black),
            children: [
              TableRow(
                children: [
                  _titelSpalte("Zahl"),
                  _wertSpalte(ausgewaehlteZahl),
                ],
              ),
              TableRow(
                children: [
                  _titelSpalte("Farbe"),
                  _wertSpalte(ausgewaehlteFarbe),
                ],
              ),
              TableRow(
                children: [
                  _titelSpalte("Spins"),
                  _wertSpalte(anzahlDrehungen),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  // Dieses Widget erstellt eine Spalte für Titel.
  Column _titelSpalte(String titel){
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Text(
            titel,
            style: const TextStyle(
              fontSize: 17,
              color: Color.fromARGB(255, 0, 0, 0),
            )
          )
        ),
      ],
    );
  }

  // Dieses Widget erstellt eine Spalte für Werte.
  Column _wertSpalte(var wert){
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Text(
            '$wert',
            style: const TextStyle(
              fontSize: 17,
              color: Color.fromARGB(255, 0, 0, 0),
            )
          )
        ),
      ],
    );
  }

  // Dieses Widget erstellt eine Spalte für Werte.
  Widget _coinsAnzeige(){
    return Align(
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        widthFactor: 1.0 / 4.0, // Weitenverhältnis
        child: Container(
          margin: const EdgeInsets.only(bottom: 25),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            border: Border.all(
              color: CupertinoColors.black,
              width: 2,
            ),
            gradient: const LinearGradient(
              colors: [Color.fromARGB(255, 125, 251, 242), Color.fromARGB(255, 80, 211, 255)],
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
            ),
          ),
          //Tabelle
          child: Table(
            border: TableBorder.all(color: CupertinoColors.black),
            children: [
              TableRow(
                children: [
                  _titelSpalte("Coins"),
                  _wertSpalte(coins),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Dieses Widget zeigt den Button "Drehen" an
  Widget _spielAktionDrehen(){
    return Align(
      alignment: Alignment.bottomRight,
      child: Container(
        margin: EdgeInsets.only(
          top: 50,
          bottom: MediaQuery.of(context).size.height*0.2,
          left: 20,
          right: MediaQuery.of(context).size.height*0.2,  
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            //Drehen Knopf
            InkWell(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                  border: Border.all(color: const Color.fromARGB(255, 0, 0, 0)),
                  // Ändere die Hintergrundfarbe basierend auf dem drehtsich-Status
                  color: drehtsich ? Colors.transparent : const Color.fromARGB(255, 255, 17, 0),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                child: Text(
                  drehtsich ? "Dreht sich" : "Drehen",
                  style: TextStyle(
                    fontSize: drehtsich ? 10 : 25,
                    color: const Color.fromARGB(255, 255, 255, 255),
                  ),
                )
              ),
              onTap: (){
                setState(() {
                  if(!drehtsich){
                    //sound abspielen
                    playSound("assets/roulette_sound1.mp3");
                    drehen();
                    drehtsich = true;
                  }
                });
              },
            )
          ],
        )
      )
    );
  }

  
  // Dieses Widget zeigt den Button "Reset" an
  Widget _spielAktionenReset(){
    return Align(
      alignment: Alignment.topRight,
      child: Container(
        margin: EdgeInsets.only(
          top: MediaQuery.of(context).size.height*0.05,
          left: 20,
          right: 20,  
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            //Reset Knopf
            InkWell(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                  border: Border.all(color: const Color.fromARGB(255, 0, 0, 0)),
                  // Ändere die Hintergrundfarbe basierend auf dem drehtsich-Status
                  color: const Color.fromARGB(255, 255, 252, 252),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                child: const Text(
                  "Reset",
                  style: TextStyle(
                    fontSize: 15,
                    color: Color.fromARGB(201, 0, 0, 0),
                  ),
                )
              ),
              onTap: (){
                if(drehtsich) return;
                setState((){
                  playSound("assets/buttonSound.mp3");
                  resetSpiel();
                });
              },
            ),

          ],
        )
      )
    );
  }

  

 // Dieses Widget zeigt den Wetteinsatz und ermöglicht das Platzieren von Wetten
  Widget _spielWetteinsatz() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: screenWidth * (1.0 / 3.3), 
        margin: const EdgeInsets.only(
          top: 10,
          bottom: 10,
          left: 10,
        ),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 13, 100, 3),
          border: Border.all(color: Colors.black), 
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Padding(

          padding: const EdgeInsets.all(10.0), // Allgemeiner Innenabstand für das gesamte Widget
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //Eingabefeld für Coins
              TextFormField(
                controller: wetteinsatzController,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
                decoration: const InputDecoration(
                  labelText: 'Wetteinsatz',
                  labelStyle: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),

              const SizedBox(height: 10),

              //Dropdownbutton zum Auswählen der Wettart
              Container(
                width: screenWidth * (1.0 / 3.3),
                height: screenHeight * (1.0 / 7.5),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 130, 255, 105),
                  borderRadius: BorderRadius.circular(8.0), // Füge gerundete Ecken hinzu
                ),
                child: DropdownButtonHideUnderline(
                  child: ButtonTheme(
                    alignedDropdown: true,
                    child: DropdownButton<String>(
                      value: selectedWetteArt,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedWetteArt = newValue ?? 'Rot';
                        });
                      },
                      items: <String>[
                        'Rot', 'Schwarz', 'Gerade', 'Ungerade'
                      ].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color.fromARGB(255, 0, 0, 0),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              //Bestätigen Knopf
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () {
                    playSound("assets/buttonSound.mp3");
                    double wetteinsatz =
                        double.tryParse(wetteinsatzController.text) ?? 0.0;
                    String wettenArt = selectedWetteArt;
                    handleWetteUndSpiel(wetteinsatz, wettenArt);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  ),
                  child: const Text(
                    'Bestätigen',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color.fromARGB(255, 5, 91, 4),
                    ),
                  ),
                ),
              ),


              const SizedBox(height: 10),

              //Liste aller Wetten der Runde
              const Text(
                'Wettliste:',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(0.0), // Ändere den Radius nach Bedarf
                ),
                height: 6 * 13.0, // Höhe für vier Zeilen mit einer Schriftgröße von 13
                width: screenWidth * 0.3, // Breite auf 30 % der Bildschirmbreite festlegen
                child: Center(
                  child: Text(
                    wetteinsatzListe.isEmpty
                        ? 'Keine Wetten platziert'
                        : wetteinsatzListe
                            .map((wetteinsatz) =>
                                '${wetteinsatz.art}: ${wetteinsatz.bet.toStringAsFixed(2)}')
                            .join('\n'),
                    style: const TextStyle(fontSize: 13, color: Colors.white),
                    maxLines: 5, // Maximal fünf Zeilen anzeigen
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


}

// Eine einfache Datenklasse, um Wetten zu speichern
class Wetteinsatz {
  double bet;
  String art;

  Wetteinsatz({required this.bet, required this.art});
}
