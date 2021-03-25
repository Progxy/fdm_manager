import 'package:fdm_manager/databaseInfo.dart';
import 'package:fdm_manager/firebaseProjectsManager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../accountInfo.dart';
import '../authentication_service.dart';
import 'access.dart';
import 'mainDrawer.dart';

class Home extends StatefulWidget {
  static const String routeName = "/home";
  final FirebaseApp defaultApp = Firebase.app();
  final FirebaseApp mainApp = FirebaseProjectsManager().getMainApp();
  final FirebaseApp creatorApp = FirebaseProjectsManager().getCreatorApp();
  final FirebaseApp desktopApp = FirebaseProjectsManager().getDesktopApp();

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String name = AccountInfo.name;
  TextStyle infoStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w300,
    color: Colors.grey,
  );

  @override
  Widget build(BuildContext context) {
    final FirebaseDatabase database = FirebaseDatabase(app: widget.defaultApp);
    final FirebaseDatabase mainDb = FirebaseDatabase(app: widget.mainApp);
    final FirebaseDatabase creatorDb = FirebaseDatabase(app: widget.creatorApp);
    final FirebaseDatabase desktopDb = FirebaseDatabase(app: widget.desktopApp);
    final FirebaseAuth _auth = FirebaseAuth.instanceFor(app: widget.defaultApp);
    getAccount() async {
      if (name == "Login") {
        await AccountInfo().setFromUserId(database);
        setState(() {
          name = AccountInfo.name;
        });
      }
      return name;
    }

    final double stockPercentage = 15.0;
    final double stockParole = 30.0;
    final double stockGianni = 20.0;
    final double stockObbedienza = 50.0;
    final double stockSilenzio = 75.0;
    final double stockPercorso = 5.0;

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Color.fromARGB(255, 192, 192, 192),
        ),
        title: FittedBox(
          fit: BoxFit.fitWidth,
          child: Text(
            "Home di $name",
            style: TextStyle(
              color: Color.fromARGB(255, 192, 192, 192),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              AuthenticationService(_auth).signOut();
              Navigator.pushReplacementNamed(context, Access.routeName);
            },
            icon: Icon(
              Icons.logout,
              size: 40.0,
              color: Color.fromARGB(255, 192, 192, 192),
            ),
          )
        ],
        backgroundColor: Color.fromARGB(255, 24, 37, 102),
        centerTitle: true,
      ),
      drawer: MainDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            FutureBuilder(
              future: getAccount(),
              builder: (context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.hasData) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        right: 15.0,
                        left: 15.0,
                      ),
                      child: Text(
                        "Benvenuto $name !",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                } else if (snapshot.hasError) {
                  print("Error : ${snapshot.error}");
                }
                return Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 4.0,
                    backgroundColor: Color.fromARGB(255, 24, 37, 102),
                  ),
                );
              },
            ),
            SizedBox(
              height: 15,
            ),
            CircularProgressIndicator(
              strokeWidth: 5.0,
              value: stockPercentage,
              backgroundColor: Colors.grey,
              valueColor: AlwaysStoppedAnimation<Color>(
                Color.fromARGB(255, 24, 37, 102),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            FutureBuilder(
              future: DatabaseInfo().getStock(),
              builder: (context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.hasData) {
                  Container();
                }
                return Container();
              },
            ),
            Center(
              child: Text(
                "Percentuale stock libri : $stockPercentage%",
                style: infoStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: Divider(
                height: 2,
                color: Colors.grey,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15.0, right: 25),
              child: Text(
                "La Parola Fa Eguali : ",
                style: infoStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 250,
                    child: LinearProgressIndicator(
                      minHeight: 5,
                      value: stockParole,
                      backgroundColor: Colors.grey,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.deepOrangeAccent[400],
                      ),
                    ),
                  ),
                  Text(
                    "$stockParole",
                    style: infoStyle,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: Divider(
                height: 2,
                color: Colors.grey,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15.0, left: 15.0),
              child: Text(
                "L'obbedienza non è una virtù : ",
                style: infoStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 250,
                    child: LinearProgressIndicator(
                      minHeight: 5,
                      value: stockObbedienza,
                      backgroundColor: Colors.grey,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.green,
                      ),
                    ),
                  ),
                  Text(
                    "$stockObbedienza",
                    style: infoStyle,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: Divider(
                height: 2,
                color: Colors.grey,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15.0, left: 15.0),
              child: Text(
                "Gianni Pierino : ",
                style: infoStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 250,
                    child: LinearProgressIndicator(
                      minHeight: 5,
                      value: stockGianni,
                      backgroundColor: Colors.grey,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.teal,
                      ),
                    ),
                  ),
                  Text(
                    "$stockGianni",
                    style: infoStyle,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: Divider(
                height: 2,
                color: Colors.grey,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15.0, left: 15.0),
              child: Text(
                "Il Silenzio Diventa Voce : ",
                style: infoStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 250,
                    child: LinearProgressIndicator(
                      minHeight: 5,
                      value: stockSilenzio,
                      backgroundColor: Colors.grey,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.cyan,
                      ),
                    ),
                  ),
                  Text(
                    "$stockSilenzio",
                    style: infoStyle,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: Divider(
                height: 2,
                color: Colors.grey,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15.0, left: 15.0),
              child: Text(
                "Percorso Didattico : ",
                style: infoStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 250,
                    child: LinearProgressIndicator(
                      minHeight: 5,
                      value: stockPercorso,
                      backgroundColor: Colors.white,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.orange,
                      ),
                    ),
                  ),
                  Text(
                    "$stockPercorso",
                    style: infoStyle,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: Divider(
                height: 2,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
