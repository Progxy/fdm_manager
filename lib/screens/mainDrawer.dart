import 'package:connectivity/connectivity.dart';
import 'package:fdm_manager/screens/disdette.dart';
import 'package:fdm_manager/screens/richiesteVisita.dart';
import 'package:fdm_manager/screens/volounteersManager.dart';
import 'package:flutter/material.dart';

import '../accountInfo.dart';
import '../databaseInfo.dart';
import 'addAdmin.dart';
import 'addVolontario.dart';
import 'assegnaVolontari.dart';
import 'badConnection.dart';
import 'cambioPassword.dart';
import 'home.dart';

class MainDrawer extends StatefulWidget {
  @override
  _MainDrawerState createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  final int version = 0;
  final int subVersion = 1;
  final String beta = "Beta";
  final String name = AccountInfo.name;
  final String email = AccountInfo.email;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      child: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              child: Image(
                  image: AssetImage("assets/images/don_milani.png"),
                  fit: BoxFit.fitWidth,
                  alignment: Alignment.topCenter),
            ),
            Container(
              child: Row(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(left: 10, top: 10),
                    decoration: BoxDecoration(shape: BoxShape.circle),
                    child: CircleAvatar(
                      backgroundColor: Color.fromARGB(255, 24, 37, 102),
                      child: Icon(
                        Icons.person,
                        color: Color.fromARGB(255, 192, 192, 192),
                      ),
                    ),
                  ),
                  Stack(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(left: 8, top: 3),
                        child: Text(
                          "$name",
                          style: TextStyle(
                              fontSize: 23, fontWeight: FontWeight.w500),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 30, left: 8),
                        child: Text(
                          "$email",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w300),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ListTile(
              title: Text("Home", style: TextStyle(fontSize: 23)),
              onTap: () async {
                var connectivityResult =
                    await (Connectivity().checkConnectivity());
                if (connectivityResult == ConnectivityResult.none) {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => BadConnection()));
                } else {
                  Navigator.pushReplacementNamed(context, Home.routeName);
                }
              },
            ),
            ListTile(
              title: Text("Cambio Password", style: TextStyle(fontSize: 23)),
              onTap: () async {
                var connectivityResult =
                    await (Connectivity().checkConnectivity());
                if (connectivityResult == ConnectivityResult.none) {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => BadConnection()));
                } else {
                  Navigator.pushReplacementNamed(
                      context, CambioPassword.routeName);
                }
              },
            ),
            ListTile(
              title: Text("Richieste Visita", style: TextStyle(fontSize: 23)),
              onTap: () async {
                var connectivityResult =
                    await (Connectivity().checkConnectivity());
                if (connectivityResult == ConnectivityResult.none) {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => BadConnection()));
                } else {
                  Navigator.pushReplacementNamed(
                      context, RichiesteVisita.routeName);
                }
              },
              trailing: FutureBuilder(
                  future: DatabaseInfo().hasNewRequest(),
                  builder:
                      (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                    if (snapshot.hasData) {
                      return snapshot.data
                          ? Icon(
                              Icons.notification_important,
                              color: Colors.yellow[600],
                              size: 35,
                            )
                          : Container(
                              width: 35,
                              height: 35,
                            );
                    } else {
                      return Container(
                        width: 35,
                        height: 35,
                      );
                    }
                  }),
            ),
            ListTile(
              title: Text("Disdette", style: TextStyle(fontSize: 23)),
              onTap: () async {
                var connectivityResult =
                    await (Connectivity().checkConnectivity());
                if (connectivityResult == ConnectivityResult.none) {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => BadConnection()));
                } else {
                  await VolounteerManager().getDisdette();
                  Navigator.pushReplacementNamed(context, Disdette.routeName);
                }
              },
              trailing: FutureBuilder(
                  future: DatabaseInfo().hasNewDisdetta(),
                  builder:
                      (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                    if (snapshot.hasData) {
                      return snapshot.data
                          ? Icon(
                              Icons.notification_important,
                              color: Colors.yellow[600],
                              size: 35,
                            )
                          : Container(
                              width: 35,
                              height: 35,
                            );
                    } else {
                      return Container(
                        width: 35,
                        height: 35,
                      );
                    }
                  }),
            ),
            ListTile(
              title: Text("Assegnazione Volontari",
                  style: TextStyle(fontSize: 23)),
              onTap: () async {
                var connectivityResult =
                    await (Connectivity().checkConnectivity());
                if (connectivityResult == ConnectivityResult.none) {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => BadConnection()));
                } else {
                  await VolounteerManager().getVolounteersMails();
                  await VolounteerManager().getUnassignedRequests();
                  Navigator.pushReplacementNamed(
                      context, AssegnazioneVolontari.routeName);
                }
              },
              trailing: FutureBuilder(
                  future: DatabaseInfo().needVolounteers(),
                  builder:
                      (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                    if (snapshot.hasData) {
                      return snapshot.data
                          ? Icon(
                              Icons.notification_important,
                              color: Colors.yellow[600],
                              size: 35,
                            )
                          : Container(
                              width: 35,
                              height: 35,
                            );
                    } else {
                      return Container(
                        width: 35,
                        height: 35,
                      );
                    }
                  }),
            ),
            ListTile(
              title:
                  Text("Aggiungi Volontario", style: TextStyle(fontSize: 23)),
              onTap: () async {
                var connectivityResult =
                    await (Connectivity().checkConnectivity());
                if (connectivityResult == ConnectivityResult.none) {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => BadConnection()));
                } else {
                  Navigator.pushReplacementNamed(
                      context, AddVolontario.routeName);
                }
              },
            ),
            ListTile(
              title: Text("Aggiungi Creator", style: TextStyle(fontSize: 23)),
              onTap: () async {
                var connectivityResult =
                    await (Connectivity().checkConnectivity());
                if (connectivityResult == ConnectivityResult.none) {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => BadConnection()));
                } else {
                  Navigator.pushReplacementNamed(context, AddCreator.routeName);
                }
              },
            ),
            ListTile(
              title: Text("Richieste Articoli", style: TextStyle(fontSize: 23)),
              onTap: () async {
                var connectivityResult =
                    await (Connectivity().checkConnectivity());
                if (connectivityResult == ConnectivityResult.none) {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => BadConnection()));
                } else {
                  Navigator.pushReplacementNamed(
                      context, RichiesteVisita.routeName);
                }
              },
              trailing: FutureBuilder(
                  future: DatabaseInfo().hasRichiesteArticoli(),
                  builder:
                      (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                    if (snapshot.hasData) {
                      return snapshot.data
                          ? Icon(
                              Icons.notification_important,
                              color: Colors.yellow[600],
                              size: 35,
                            )
                          : Container(
                              width: 35,
                              height: 35,
                            );
                    } else {
                      return Container(
                        width: 35,
                        height: 35,
                      );
                    }
                  }),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: 235,
              ),
              child: Divider(
                thickness: 1,
                color: Color.fromARGB(255, 24, 37, 102),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(left: 17),
                  child: Text(
                    "Versione $beta $version.$subVersion",
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}
