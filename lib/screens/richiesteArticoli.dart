import 'package:connectivity/connectivity.dart';
import 'package:fdm_manager/databaseInfo.dart';
import 'package:fdm_manager/screens/utilizzo.dart';
import 'package:flutter/material.dart';
import 'approvaArticoli.dart';
import 'badConnection.dart';
import 'feedback.dart';
import 'mainDrawer.dart';

class RichiesteArticoli extends StatefulWidget {
  static const String routeName = "/richiesteArticoli";

  @override
  _RichiesteArticoliState createState() => _RichiesteArticoliState();
}

class _RichiesteArticoliState extends State<RichiesteArticoli> {
  TextStyle infoStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w300,
    color: Colors.grey,
  );

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

  loadRequests(Map data) {
    final List keys = data.keys.toList();
    List<Widget> result = [];
    if (keys.isEmpty) {
      result.add(
        Center(
          child: Text(
            "Nessuna Richiesta Ricevuta !",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    } else {
      for (var key in keys) {
        final Map infoValue = data[key];
        result.add(
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 25.0),
              child: GestureDetector(
                onTap: () {
                  InfoContent.isLoaded = false;
                  Navigator.pushNamed(context, InfoContent.routeName,
                      arguments: infoValue);
                },
                child: Container(
                  width: 300,
                  height: 75,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      key,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color.fromARGB(255, 24, 37, 102),
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Color.fromARGB(255, 192, 192, 192),
        ),
        title: FittedBox(
          fit: BoxFit.fitWidth,
          child: Text(
            "Richieste Visita",
            style: TextStyle(
              color: Color.fromARGB(255, 192, 192, 192),
              fontWeight: FontWeight.w700,
            ),
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
      drawer: MainDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 15,
            ),
            FutureBuilder(
              future: DatabaseInfo().getRichiesteArticoli(),
              builder: (context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.hasData) {
                  final Map richiesteArticoli = snapshot.data;
                  return Column(
                    children: loadRequests(richiesteArticoli),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Nessuna Richiesta Ricevuta !",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }
                return Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 4.0,
                    backgroundColor: Colors.white,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
