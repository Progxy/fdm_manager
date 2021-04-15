import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:fdm_manager/screens/home.dart';
import 'package:fdm_manager/screens/mainDrawer.dart';
import 'package:fdm_manager/screens/volounteersManager.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mailer2/mailer.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'badConnection.dart';
import 'feedback.dart';
import 'utilizzo.dart';
import 'package:intl/intl.dart';

class Disdette extends StatefulWidget {
  static const String routeName = "/disdette";

  @override
  _DisdetteState createState() => _DisdetteState();
}

class _DisdetteState extends State<Disdette> {
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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _textController = TextEditingController();
  final Map idInfos = VolounteerManager.idDisdette;
  final List idInfo = VolounteerManager.idDisdette.keys.toList();
  String idRequestChoosen = VolounteerManager.idDisdette.keys.toList()[0];
  String email = VolounteerManager
      .idDisdette[VolounteerManager.idDisdette.keys.toList()[0]]["email"];
  String errorText = "";
  String idTextInfo = "";
  String errorTextMail = "";

  sendResponse(String text, String email, String object) async {
    text = text + "\n\nCordiali saluti\n\nAgostino Burberi.";
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

  disdici(String disdettaId) async {
    final databaseReference =
        FirebaseDatabase.instance.reference().child("Disdette");
    databaseReference.child(disdettaId).remove();
    return;
  }

  presaVisione(String disdettaId) async {
    final databaseReference =
        FirebaseDatabase.instance.reference().child("Disdette");
    databaseReference.child(disdettaId).update({"presaVisione": "si"});
    return;
  }

  getVolontari(String disdettaId) async {
    final database = FirebaseDatabase.instance;
    Map result;
    await database
        .reference()
        .child("Prenotazione")
        .child(disdettaId)
        .orderByValue()
        .once()
        .then((DataSnapshot snapshot) {
      result = new Map.from(snapshot.value);
    });
    final String res = result["volontariAssegnati"];
    return res;
  }

  getDate(String disdettaId) async {
    final database = FirebaseDatabase.instance;
    Map result;
    await database
        .reference()
        .child("Prenotazione")
        .child(disdettaId)
        .orderByValue()
        .once()
        .then((DataSnapshot snapshot) {
      result = new Map.from(snapshot.value);
    });
    final fullDateTime = DateTime.tryParse(result["data"]);
    final String fullDate = fullDateTime == null
        ? result["data"]
        : DateFormat('dd/MM/yyyy HH:mm').format(fullDateTime);
    return fullDate;
  }

  @override
  Widget build(BuildContext context) {
    final double width = ((MediaQuery.of(context).size.width) / 3) * 2;

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Color.fromARGB(255, 192, 192, 192),
        ),
        title: Text(
          "Disdette",
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
      drawer: MainDrawer(),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 15,
            ),
            Text(
              "Scegliere la disdetta : ",
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 15,
            ),
            Center(
              child: SizedBox(
                width: width,
                child: DropdownButton<String>(
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
                      errorText = "";
                      idTextInfo = "";
                      idRequestChoosen = newValue;
                      final temp = idInfos[idRequestChoosen];
                      temp.forEach((key, value) {
                        if (key != "presaVisione") {
                          idTextInfo += "$key : $value\n\n";
                        }
                      });
                      email = idInfos[idRequestChoosen]["email"];
                    });
                  },
                  items: idInfo
                      .map((id) => new DropdownMenuItem<String>(
                            value: id,
                            child: Text(id),
                          ))
                      .toList(),
                ),
              ),
            ),
            SizedBox(
              height: 25,
            ),
            Center(
              child: Text(
                idTextInfo,
                style: infoStyle,
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Center(
              child: Text(
                errorText,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.red[900],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            errorText.isEmpty
                ? Container()
                : SizedBox(
                    height: 25,
                  ),
            Form(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              key: _formKey,
              child: Column(
                children: [
                  Text(
                    "Nel messaggio non inserire un saluto finale, essendo già inserito!",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  SizedBox(
                    width: width * 1.35,
                    child: TextFormField(
                      controller: _textController,
                      maxLines: 20,
                      decoration: const InputDecoration(
                        hintText: "Inserire un messaggio",
                        hintStyle: TextStyle(
                          fontSize: 23.0,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        border: OutlineInputBorder(),
                        labelText: "Messaggio",
                        labelStyle: TextStyle(
                          fontSize: 23.0,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Dati Mancanti";
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 25,
            ),
            Center(
              child: TextButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7.0),
                  ),
                  primary: Color.fromARGB(255, 24, 37, 102),
                ),
                onPressed: () async {
                  if (idTextInfo.isEmpty) {
                    setState(() {
                      errorText = "Scegliere un id !";
                    });
                    return;
                  } else if (!_formKey.currentState.validate()) {
                    return;
                  }
                  final String text = _textController.text.trim();
                  bool continuE = false;
                  if (Platform.isIOS) {
                    await showCupertinoDialog(
                      context: context,
                      builder: (BuildContext context) => CupertinoAlertDialog(
                        title: Text(
                          "Continuare ?",
                          style: TextStyle(
                            fontSize: 28,
                          ),
                        ),
                        content: Text(
                          "Andare Avanti ?",
                          style: TextStyle(
                            fontSize: 28,
                          ),
                        ),
                        actions: [
                          CupertinoDialogAction(
                            child: Text(
                              "Continua",
                              style: TextStyle(
                                fontSize: 28,
                              ),
                            ),
                            onPressed: () {
                              continuE = true;
                              Navigator.of(context, rootNavigator: true)
                                  .pop('dialog');
                            },
                          ),
                          CupertinoDialogAction(
                            child: Text(
                              "Annulla",
                              style: TextStyle(
                                fontSize: 28,
                              ),
                            ),
                            onPressed: () {
                              continuE = false;
                              Navigator.of(context, rootNavigator: true)
                                  .pop('dialog');
                            },
                          ),
                        ],
                      ),
                    );
                  } else {
                    await showDialog(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: Text(
                          "Continuare ?",
                          style: TextStyle(
                            fontSize: 28,
                          ),
                        ),
                        content: Text(
                          "Andare Avanti ?",
                          style: TextStyle(
                            fontSize: 28,
                          ),
                        ),
                        actions: [
                          TextButton(
                            child: Text(
                              "Continua",
                              style: TextStyle(
                                fontSize: 28,
                              ),
                            ),
                            onPressed: () {
                              continuE = true;
                              Navigator.of(context, rootNavigator: true)
                                  .pop('dialog');
                            },
                          ),
                          TextButton(
                            child: Text(
                              "Annulla",
                              style: TextStyle(
                                fontSize: 28,
                              ),
                            ),
                            onPressed: () {
                              continuE = false;
                              Navigator.of(context, rootNavigator: true)
                                  .pop('dialog');
                            },
                          ),
                        ],
                      ),
                    );
                  }
                  if (!continuE) {
                    return;
                  }
                  ProgressDialog dialog = new ProgressDialog(context);
                  dialog.style(message: 'Caricamento...');
                  await dialog.show();
                  final bool result = await sendResponse(
                      text, email, "Disdetta Visita a Barbiana");
                  if (result) {
                    if (idInfo.length > 1) {
                      disdici(idRequestChoosen);
                    } else {
                      presaVisione(idRequestChoosen);
                    }
                    final String emailVolontari =
                        await getVolontari(idRequestChoosen);
                    if (emailVolontari != null && emailVolontari.isNotEmpty) {
                      List volontari = emailVolontari
                          .replaceAll("[", "")
                          .replaceAll("]", "")
                          .split(",");
                      for (int index = 0; index < volontari.length; index++) {
                        volontari[index] = volontari[index].trim();
                      }
                      final String nomeGruppo =
                          idInfos[idRequestChoosen]["nomeGruppo"];
                      final String date = await getDate(idRequestChoosen);
                      final String textDisdetta =
                          "La visita del gruppo $nomeGruppo del $date è stata disdetta.\n\nCordiali Saluti\n\nAgostino Burberi.";
                      for (String email in volontari) {
                        await sendResponse(
                            textDisdetta, email, "Disdetta Gruppo");
                      }
                    }
                  }
                  await dialog.hide();
                  if (Platform.isIOS) {
                    showCupertinoDialog(
                      context: context,
                      builder: (BuildContext context) => CupertinoAlertDialog(
                        title: Text(
                          "Esito Operazione",
                          style: TextStyle(
                            fontSize: 28,
                          ),
                        ),
                        content: Text(
                          result
                              ? "Operazione effetuata con successo !"
                              : "Ops... Si è verificato un'errore mentre veniva spedita l'email.",
                          style: TextStyle(
                            fontSize: 28,
                          ),
                        ),
                        actions: [
                          CupertinoDialogAction(
                            child: Text(
                              "OK",
                              style: TextStyle(
                                fontSize: 28,
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context, rootNavigator: true)
                                  .pop('dialog');
                            },
                          )
                        ],
                      ),
                    );
                  } else {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: Text(
                          "Esito Operazione",
                          style: TextStyle(
                            fontSize: 28,
                          ),
                        ),
                        content: Text(
                          result
                              ? "Operazione effetuata con successo !"
                              : "Ops... Si è verificato un'errore mentre veniva spedita l'email.",
                          style: TextStyle(
                            fontSize: 28,
                          ),
                        ),
                        actions: [
                          TextButton(
                            child: Text(
                              "OK",
                              style: TextStyle(
                                fontSize: 28,
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context, rootNavigator: true)
                                  .pop('dialog');
                            },
                          )
                        ],
                      ),
                    );
                  }
                  MaterialPageRoute(builder: (context) => Home());
                },
                child: Text(
                  "Disdici",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 25,
                  ),
                ),
              ),
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
