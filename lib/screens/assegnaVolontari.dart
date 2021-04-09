import 'dart:math';

import 'package:connectivity/connectivity.dart';
import 'package:fdm_manager/screens/volounteersManager.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mailer2/mailer.dart';
import 'badConnection.dart';
import 'feedback.dart';
import 'utilizzo.dart';

class AssegnazioneVolontari extends StatefulWidget {
  static const String routeName = "/assegnaVolontari";

  @override
  _AssegnazioneVolontariState createState() => _AssegnazioneVolontariState();
}

class _AssegnazioneVolontariState extends State<AssegnazioneVolontari> {
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

  final TextStyle infoStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w300,
    color: Colors.grey,
  );
  final Map idInfos = VolounteerManager.idRequests;
  final List idInfo = VolounteerManager.idRequests.keys.toList();
  final Map infoVolounteers = VolounteerManager.volounteers;
  final List volounteersMail = VolounteerManager.volounteers.keys.toList();
  String idRequestChoosen = VolounteerManager.idRequests.keys.toList()[0];
  String volounteerChoosen = VolounteerManager.volounteers.keys.toList()[0];
  List<Widget> containerVolounteers = [];
  List mailVolounteersChoosen = [];
  Map keyContainer = {};
  Random random = new Random();
  String idTextInfo = "";

  loadData(Map data) {
    List<Widget> result = [];
    final List keys = data.keys.toList();
    final List values = data.values.toList();
    int index = 0;
    for (var key in keys) {
      final value = values[index];
      result.add(Padding(
        padding: const EdgeInsets.only(top: 15.0),
        child: FittedBox(
          fit: BoxFit.fitWidth,
          child: Text(
            "$key : $value",
            style: infoStyle,
          ),
        ),
      ));
      index++;
    }
    return result;
  }

  sendResponse(String text, String email, String object) async {
    var options = new GmailSmtpOptions()
      ..username = 'ermes.express.fdm@gmail.com'
      ..password = 'CASTELLO1967';
    var emailTransport = new SmtpTransport(options);
    var mail = new Envelope()
      ..from = 'ermes.express.fdm@gmail.com'
      ..recipients.add(email)
      ..subject = object
      ..text = text;
    bool result;
    await emailTransport.send(mail).then((mail) async {
      result = true;
    }).catchError((e) async {
      print("Error while sending response email : $e");
      result = false;
    });
    return result;
  }

  getMapValueIndex(value, Map data, bool isValue) {
    List values = [];
    if (isValue) {
      values = data.values.toList();
    } else {
      values = data.keys.toList();
    }
    int index = 0;
    for (var val in values) {
      if (val == value) {
        return index >= data.length ? data.length - 1 : index;
      }
      index++;
    }
    return null;
  }

  removeAssegnazioneMancante(String prenotazioneId) {
    final databaseReference =
        FirebaseDatabase.instance.reference().child("AssegnazioniMancanti");
    databaseReference.set({prenotazioneId: "id"});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Color.fromARGB(255, 192, 192, 192),
        ),
        title: Text(
          "Assegnazione Volontari",
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
            Text(
              "Assegna i volontari per la visita scelta : ",
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            DropdownButton<String>(
              isExpanded: true,
              isDense: true,
              value: volounteerChoosen,
              icon: Icon(Icons.arrow_downward),
              iconSize: 40,
              elevation: 20,
              style: TextStyle(
                color: Colors.black87,
                fontSize: 23,
                fontWeight: FontWeight.w600,
              ),
              onChanged: (String newValue) {
                setState(() {
                  volounteerChoosen = newValue;
                });
              },
              items: volounteersMail
                  .map((mail) => new DropdownMenuItem<String>(
                        value: mail,
                        child: Text(infoVolounteers[mail]),
                      ))
                  .toList(),
            ),
            Text(
              "Scegliere la richiesta di visita : ",
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            DropdownButton<String>(
              isExpanded: true,
              isDense: true,
              value: idRequestChoosen,
              icon: Icon(Icons.arrow_downward),
              iconSize: 40,
              elevation: 20,
              style: TextStyle(
                color: Colors.black87,
                fontSize: 23,
                fontWeight: FontWeight.w600,
              ),
              onChanged: (String newValue) {
                setState(() {
                  idRequestChoosen = newValue;
                  idTextInfo = idInfos[idRequestChoosen];
                });
              },
              items: idInfo
                  .map((id) => new DropdownMenuItem<String>(
                        value: id,
                        child: Text(id),
                      ))
                  .toList(),
            ),
            IconButton(
              icon: Icon(
                Icons.add,
                size: 40,
                color: Color.fromARGB(255, 102, 37, 45),
              ),
              onPressed: () {
                Key key = Key(random.nextInt(1000000000).toString());
                keyContainer.addAll({key: volounteerChoosen});
                mailVolounteersChoosen.add(volounteerChoosen);
                containerVolounteers.add(
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            child: Text(
                              infoVolounteers[volounteerChoosen],
                              style: infoStyle,
                            ),
                          ),
                          IconButton(
                              icon: Icon(
                                Icons.delete,
                                color: Colors.red,
                                size: 40,
                              ),
                              onPressed: () {
                                setState(() {
                                  final mailDelete = keyContainer[key];
                                  mailVolounteersChoosen.remove(mailDelete);
                                  final int indexMailDelete = getMapValueIndex(
                                      mailDelete, keyContainer, true);
                                  containerVolounteers
                                      .removeAt(indexMailDelete);
                                });
                              }),
                        ],
                      ),
                      SizedBox(
                        height: 25,
                      ),
                    ],
                  ),
                );
              },
            ),
            Column(
              children: containerVolounteers,
            ),
            SizedBox(
              height: 25,
            ),
            Text(
              idTextInfo,
              style: infoStyle,
            ),
            SizedBox(
              height: 35,
            ),
          ],
        ),
      ),
    );
  }
}
