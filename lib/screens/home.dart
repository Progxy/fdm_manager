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
      body: Column(
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
        ],
      ),
    );
  }
}
