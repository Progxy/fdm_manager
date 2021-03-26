import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mailer2/mailer.dart';
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

  final TextStyle infoStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w300,
    color: Colors.grey,
  );
  final TextEditingController _motivazioneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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

  rifiuto(String motivazione, String email, String prenotazioneId) async {
    final databaseReference =
        FirebaseDatabase.instance.reference().child("Prenotazione");
    final String rifiuto =
        "Siamo spiacenti ma la vostra richiesta di visita è stata rifiutata poichè " +
            motivazione;
    final bool resultSend = await sendResponse(
        rifiuto, email, "Rifiuto Richiesta Visita a Barbiana");
    databaseReference.child(prenotazioneId).remove();
    if (resultSend) {
      return true;
    } else {
      return false;
    }
  }

  refuseOperation(String prenotazioneId, String email) async {
    bool resultOperation;
    if (Platform.isIOS) {
      await showCupertinoDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: Text(
            "Rifiuto Prenotazione",
            style: TextStyle(
              fontSize: 28,
            ),
          ),
          content: SingleChildScrollView(
            child: Form(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _motivazioneController,
                    maxLines: 20,
                    decoration: const InputDecoration(
                      hintText: "Inserire la motivazione",
                      hintStyle: TextStyle(
                        fontSize: 23.0,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      border: OutlineInputBorder(),
                      labelText: "Motivazione",
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
                ],
              ),
            ),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () async {
                final String motivazione = _motivazioneController.text.trim();
                final bool result =
                    await rifiuto(motivazione, email, prenotazioneId);
                Navigator.of(context, rootNavigator: true).pop('dialog');
                resultOperation = result;
              },
              child: Text(
                "Conferma",
                style: TextStyle(
                  fontSize: 28,
                ),
              ),
            ),
            CupertinoDialogAction(
              onPressed: () async {
                _motivazioneController.clear();
                Navigator.of(context, rootNavigator: true).pop('dialog');
              },
              child: Text(
                "Conferma",
                style: TextStyle(
                  fontSize: 28,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      await showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text(
            "Rifiuto Prenotazione",
            style: TextStyle(
              fontSize: 28,
            ),
          ),
          content: SingleChildScrollView(
            child: Form(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _motivazioneController,
                    maxLines: 20,
                    decoration: const InputDecoration(
                      hintText: "Inserire la motivazione",
                      hintStyle: TextStyle(
                        fontSize: 23.0,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      border: OutlineInputBorder(),
                      labelText: "Motivazione",
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
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final String motivazione = _motivazioneController.text.trim();
                final bool result =
                    await rifiuto(motivazione, email, prenotazioneId);
                Navigator.of(context, rootNavigator: true).pop('dialog');
                resultOperation = result;
              },
              child: Text(
                "Conferma",
                style: TextStyle(
                  fontSize: 28,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                _motivazioneController.clear();
              },
              child: Text(
                "Conferma",
                style: TextStyle(
                  fontSize: 28,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return resultOperation;
  }

  @override
  Widget build(BuildContext context) {
    final List richiesta = ModalRoute.of(context).settings.arguments as List;
    final Map infoRichiesta = richiesta[0];
    final String prenotazioneId = richiesta[1];

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Color.fromARGB(255, 192, 192, 192),
        ),
        title: Text(
          "Info Richiesta",
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
            Column(
              children: loadData(infoRichiesta),
            ),
            SizedBox(
              height: 35,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7.0),
                    ),
                    primary: Color.fromARGB(255, 24, 37, 102),
                  ),
                  onPressed: () {
                    //avverti della conferma il richiedente e manda email di conferma ai volontari, inoltre setta tu "si"
                  },
                  child: Text(
                    "Accetta",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 25,
                    ),
                  ),
                ),
                TextButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7.0),
                    ),
                    primary: Color.fromARGB(255, 24, 37, 102),
                  ),
                  onPressed: () async {
                    final String email = infoRichiesta["email"];
                    final bool resultRefusing =
                        await refuseOperation(prenotazioneId, email);
                    //implement result print
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
                            resultRefusing
                                ? "Operazione effetuata con successo !"
                                : "Ops... Si è verificato un'errore mentre veniva spedita l'email.",
                            style: TextStyle(
                              fontSize: 28,
                            ),
                          ),
                        ),
                      );
                    } else {}
                  },
                  child: Text(
                    "Rifiuta",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 25,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
