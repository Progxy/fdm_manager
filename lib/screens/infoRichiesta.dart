import 'dart:io';
import 'dart:math';

import 'package:connectivity/connectivity.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
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

  getVolounteersMails() async {
    Map result = {};
    final database = FirebaseDatabase.instance;
    await database
        .reference()
        .child("Volontari")
        .orderByValue()
        .once()
        .then((DataSnapshot snapshot) {
      result = new Map.from(snapshot.value);
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
    return resultSend;
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
                _motivazioneController.clear();
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
                _motivazioneController.clear();
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
          ],
        ),
      );
    }
    return resultOperation;
  }

  accetta(String email, String date, String prenotazioneId) async {
    final bool resultSend = await sendResponse(
        "Richiesta Visita a Barbiana accettata",
        email,
        "La vostra richiesta di visita a Barbiana è stata accettata !\n\nVi aspettiamo il $date");
    final databaseReference =
        FirebaseDatabase.instance.reference().child("Prenotazione");
    databaseReference.child(prenotazioneId).update({"presaVisione": "si"});
    return resultSend;
    //aggiungi testo informativo !
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
        return index;
      }
      index++;
    }
    return null;
  }

  accettaOperation(
      String prenotazioneId, String email, String date, Map infoGroup) async {
    bool resultOperation;
    final Map<String, String> volounteersData = await getVolounteersMails();
    final List<String> volounteersMail = volounteersData.keys.toList();
    List<Widget> containerVolounteers = [];
    List mailVolounteersChoosen = [];
    String groupInfo = "";
    infoGroup.forEach((key, value) => {groupInfo += "\n$key : $value"});
    String dropDownValue = volounteersMail[0];
    Map keyContainer = {};
    Random random = new Random();
    if (Platform.isIOS) {
      await showCupertinoDialog(
        context: context,
        builder: (BuildContext context) => StatefulBuilder(
          builder: (context, setState) => CupertinoAlertDialog(
            title: Text(
              "Accettazione Prenotazione",
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
                    Text("Assegna i volontari per questa visita"),
                    DropdownButton<String>(
                      isExpanded: true,
                      isDense: true,
                      value: dropDownValue,
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
                          dropDownValue = newValue;
                        });
                      },
                      items: volounteersMail
                          .map((mail) => new DropdownMenuItem<String>(
                                value: mail,
                                child: Text(volounteersData[mail]),
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
                        keyContainer.addAll({key: dropDownValue});
                        mailVolounteersChoosen.add(dropDownValue);
                        containerVolounteers.add(
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    child: Text(
                                      volounteersData[dropDownValue],
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
                                          mailVolounteersChoosen
                                              .remove(mailDelete);
                                          final int indexMailDelete =
                                              getMapValueIndex(mailDelete,
                                                  keyContainer, true);
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
                  ],
                ),
              ),
            ),
            actions: [
              CupertinoDialogAction(
                onPressed: () async {
                  final bool result =
                      await accetta(email, date, prenotazioneId);
                  mailVolounteersChoosen.forEach((email) async {
                    await sendResponse(
                        groupInfo, email, "Info gruppo per Visita Barbiana");
                  });
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
            ],
          ),
        ),
      );
    } else {
      await showDialog(
        context: context,
        builder: (BuildContext context) => StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text(
              "Accettazione Prenotazione",
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
                    Text("Assegna i volontari per questa visita"),
                    DropdownButton<String>(
                      isExpanded: true,
                      isDense: true,
                      value: dropDownValue,
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
                          dropDownValue = newValue;
                        });
                      },
                      items: volounteersMail
                          .map((mail) => new DropdownMenuItem<String>(
                                value: mail,
                                child: Text(volounteersData[mail]),
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
                        keyContainer.addAll({key: dropDownValue});
                        mailVolounteersChoosen.add(dropDownValue);
                        containerVolounteers.add(
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    child: Text(
                                      volounteersData[dropDownValue],
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
                                          mailVolounteersChoosen
                                              .remove(mailDelete);
                                          final int indexMailDelete =
                                              getMapValueIndex(mailDelete,
                                                  keyContainer, true);
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
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  final bool result =
                      await accetta(email, date, prenotazioneId);
                  mailVolounteersChoosen.forEach((email) async {
                    await sendResponse(
                        groupInfo, email, "Info gruppo per Visita Barbiana");
                  });
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
            ],
          ),
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
                          actions: [
                            CupertinoDialogAction(
                              child: Text("OK"),
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
                            resultRefusing
                                ? "Operazione effetuata con successo !"
                                : "Ops... Si è verificato un'errore mentre veniva spedita l'email.",
                            style: TextStyle(
                              fontSize: 28,
                            ),
                          ),
                          actions: [
                            CupertinoDialogAction(
                              child: Text("OK"),
                              onPressed: () {
                                Navigator.of(context, rootNavigator: true)
                                    .pop('dialog');
                              },
                            )
                          ],
                        ),
                      );
                    }
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
