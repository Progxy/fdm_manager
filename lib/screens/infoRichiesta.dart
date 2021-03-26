import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'badConnection.dart';
import 'feedback.dart';
import 'utilizzo.dart';

class InfoRichiesta extends StatefulWidget {
  static const String routeName = "/infoRichiesta";

  @override
  _InfoRichiestaState createState() => _InfoRichiestaState();
}

class _InfoRichiestaState extends State<InfoRichiesta> {
  final List<String> choices = <String>[
    "FeedBack",
    "Aiuto",
  ];

  void choiceAction(String choice) async {
    if (choice == "Aiuto") {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => Utilizzo()));
    } else {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => BadConnection()));
      } else {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => FeedBack()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map infoRichiesta = ModalRoute.of(context).settings.arguments as Map;
    print("sended data :$infoRichiesta ");

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Color.fromARGB(255, 192, 192, 192),
        ),
        title: Text(
          "Richiesta numero : ",
          style: TextStyle(
            color: Color.fromARGB(255, 192, 192, 192),
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: choiceAction,
            itemBuilder: (BuildContext context) {
              return choices.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(
                    choice,
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                );
              }).toList();
            },
          )
        ],
        backgroundColor: Color.fromARGB(255, 24, 37, 102),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 15,
            ),
            Text("content loaded!"),
            SizedBox(
              height: 15,
            )
          ],
        ),
      ),
    );
  }
}
