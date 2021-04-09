import 'dart:io';
import 'dart:math';

import 'package:connectivity/connectivity.dart';
import 'package:fdm_manager/screens/home.dart';
import 'package:fdm_manager/screens/mainDrawer.dart';
import 'package:fdm_manager/screens/volounteersManager.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mailer2/mailer.dart';
import 'badConnection.dart';
import 'feedback.dart';
import 'utilizzo.dart';
import 'package:intl/intl.dart';

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
  String volounteerChoosen = VolounteerManager.volounteers.values.toList()[0];
  List<Widget> containerVolounteers = [];
  List mailVolounteersChoosen = [];
  Map keyContainer = {};
  Random random = new Random();
  String idTextInfo = "";

  //ottieni id dei non assegnati e confrontali con gli id totali
  // per togliere le informazioni non necessarie

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

  assignVolounteers(List volounteers, String infoGroups, String id) async {
    bool resultOperation;
    List results = [];
    for (String email in volounteers) {
      results.add(await sendResponse(
          infoGroups, email, "Info Gruppo in Visita a Barbiana"));
    }
    final databaseReference =
        FirebaseDatabase.instance.reference().child("AssegnazioniMancanti");
    databaseReference.child(id).remove();
    if (results.contains(false) || results.isEmpty) {
      resultOperation = false;
    } else {
      resultOperation = true;
    }
    return resultOperation;
  }

  ///Get the position of the first start digit and the first end digit
  List getExpressionLimit(String start, String end, String value) {
    List limits = [];
    final List searchElement = value.split("");
    final int stringStartLength = start.length;
    final int stringEndLength = end.length;
    String compare = "";
    bool startComparingStart = false;
    bool startComparingEnd = false;
    int ind = 0;
    bool findEnd = false;
    for (int index = 0; index <= searchElement.length - 1; index++) {
      compare = "";
      var element = searchElement[index];
      ind = index;
      if (findEnd) {
        if (element == end[0]) {
          startComparingEnd = true;
        }
        if (startComparingEnd) {
          if (stringEndLength == 1) {
            compare = element;
          } else {
            for (int l = 0; l <= stringEndLength - 1; l++) {
              compare += searchElement[ind];
              ind++;
            }
          }
          if (end == compare) {
            final int temp = index;
            limits.add(temp);
            break;
          } else {
            startComparingEnd = false;
          }
        }
        continue;
      }
      if (element == start[0]) {
        startComparingStart = true;
      }
      if (startComparingStart) {
        if (stringStartLength == 1) {
          compare = element;
        } else {
          for (int i = 0; i <= stringStartLength - 1; i++) {
            compare += searchElement[ind];
            ind++;
          }
        }
        if (start == compare) {
          final int temp = index;
          limits.add(temp);
          findEnd = true;
        } else {
          startComparingStart = false;
        }
      }
    }
    if (limits.length != 2) {
      limits.clear();
    }
    return limits;
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
              "Assegna i volontari per la visita scelta : ",
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
                width: width * 1.35,
                child: DropdownButton<String>(
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
                            value: infoVolounteers[mail],
                            child: Text(mail),
                          ))
                      .toList(),
                ),
              ),
            ),
            SizedBox(
              height: 25,
            ),
            Column(
              children: containerVolounteers,
            ),
            SizedBox(
              height: 15,
            ),
            Center(
              child: IconButton(
                icon: Icon(
                  Icons.add,
                  size: 40,
                  color: Color.fromARGB(255, 24, 37, 102),
                ),
                onPressed: () {
                  if (keyContainer.containsValue(volounteerChoosen)) {
                    return;
                  }
                  setState(() {
                    Key key = Key(random.nextInt(1000000000).toString());
                    keyContainer.addAll({key: volounteerChoosen});
                    mailVolounteersChoosen.add(volounteerChoosen);
                    containerVolounteers.add(
                      Center(
                        child: Column(
                          children: [
                            FittedBox(
                              fit: BoxFit.fitWidth,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    child: Text(
                                      volounteerChoosen,
                                      style: infoStyle,
                                    ),
                                  ),
                                  IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.red[800],
                                        size: 40,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          final mailDelete = keyContainer[key];
                                          final int indexMailDelete =
                                              getMapValueIndex(mailDelete,
                                                  keyContainer, true);
                                          mailVolounteersChoosen
                                              .remove(mailDelete);
                                          containerVolounteers
                                              .removeAt(indexMailDelete);
                                          keyContainer.remove(key);
                                        });
                                      }),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 25,
                            ),
                          ],
                        ),
                      ),
                    );
                  });
                },
              ),
            ),
            SizedBox(
              height: 35,
            ),
            Text(
              "Scegliere la richiesta di visita : ",
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
                      idRequestChoosen = newValue;
                      final temp = idInfos[idRequestChoosen];
                      final fullDateTime = DateTime.tryParse(temp["data"]);
                      final String fullDate = fullDateTime == null
                          ? temp["data"]
                          : DateFormat('dd/MM/yyyy HH:mm').format(fullDateTime);
                      temp["data"] = fullDate;
                      idTextInfo = "";
                      temp.forEach((key, value) {
                        if (key != "presaVisione") {
                          idTextInfo += "$key : $value\n\n";
                        }
                      });
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
            Text(
              idTextInfo,
              style: infoStyle,
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 15,
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
                    return;
                  }
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
                          "Una volta premuto il bottone, verranno assegnato il gruppo ai volontari, e non si potrà tornare indietro.\nAndare avanti ?",
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
                          "Una volta premuto il bottone, verranno assegnato il gruppo ai volontari, e non si potrà tornare indietro.\nAndare avanti ?",
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
                  final bool result = await assignVolounteers(
                      mailVolounteersChoosen, idTextInfo, idRequestChoosen);
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
                  "Accetta",
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
