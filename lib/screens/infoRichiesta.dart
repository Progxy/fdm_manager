import 'dart:io';
import 'dart:math';
import 'package:connectivity/connectivity.dart';
import 'package:fdm_manager/screens/richiesteVisita.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mailer2/mailer.dart';
import 'badConnection.dart';
import 'feedback.dart';
import 'utilizzo.dart';
import 'package:intl/intl.dart';

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
      if (key == "presaVisione") {
        index++;
        continue;
      }
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
        "Siamo spiacenti ma la vostra richiesta di visita è stata rifiutata perchè : \n\n" +
            motivazione +
            "\n\nCordiali saluti\n\nAgostino Burberi.";
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
                  Text(
                    "Nella motivazione non inserire un saluto finale, essendo già inserito!",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
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
                  Text(
                    "Nella motivazione non inserire un saluto finale, essendo già inserito!",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
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
            TextButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop('dialog');
              },
              child: Text(
                "Annulla",
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

  accetta(String email, String date, String hour, String prenotazioneId) async {
    final String start =
        "Buongiorno, va bene per il $date. ore $hour a Barbiana: 'Si informa  che i pullman grandi, devono essere ";
    final String p1 =
        "lasciati a circa Km 3 prima LAGO VIOLA, dove vi è il cartello di divieto di transito. Da lì ";
    final String p2 =
        "bisogna proseguire a piedi per circa 45 minuti, salendo per il Sentiero della Costituzione. I ";
    final String p3 =
        "pullman fino a 25/30 posti e le auto, possono arrivare fino al bivio dove è segnalato il ";
    final String p4 =
        "“Sentiero della Costituzione”, da li 1 km a piedi, gli ultimi 800 metri sono molto ripidi, nel ";
    final String p5 =
        "caso in cui una macchina abbia a bordo una persona anziana o disabile, l’auto può arrivare ";
    final String p6 =
        "fino a Barbiana. Le scolaresche e i gruppi che hanno al loro seguito disabili o ";
    final String p7 =
        "persone che non possono affrontare la strada a piedi, devono rivolgersi per ";
    final String p8 =
        "tempo alla PUBBLICA ASSISTENZA DI VICCHIO, 055 8449980 – 392 6992691 Sig.ra ";
    final String p9 =
        "Giuliana. Si prega di utilizzare le piattaforme della Fondazione per annullare la visita. ";
    final String p10 =
        "Per emergenza COVID19 LA VISITA AGLI AMBIENTI INTERNI (SCUOLA E ";
    final String p11 =
        "OFFICINA) SARA’ EFFETTUATA IN GRUPPI MAX 10 PERSONE PER I GRUPPI ";
    final String p12 =
        "SUPERIORI VERRANNO ORGANIZZATE VISITE SCAGLIONATE. MENTRE LA ";
    final String p13 =
        "TESTIMONIANZA VERRA’ EFFETTUATA POSSIBILMENTE ALL’ESTERNO. I ";
    final String p14 =
        "PARTECIPANTI DOVRANNO INDOSSARE LA MASCHERINA, MANTENERE LE ";
    final String p15 =
        "DISTANZE DI UN METRO E IGIENIZZARSI LE MANI CON GEL MESSO A ";
    final String p16 = "DISPOSIZIONE DALLA FONDAZIONE STESSA. ";
    final String p17 =
        "La Fondazione chiede massimo rispetto di Barbiana, luogo di sofferenza ed ";
    final String p18 =
        "esilio che don Lorenzo ha trasformato in luogo di fede, di pensiero, di scuola e ";
    final String p19 =
        "di esempio religioso e sociale per ridare dignità ai poveri. ";
    final String p20 =
        "Per le visite guidate con spiegazione di tutto il Percorso didattico, la Fondazione ";
    final String p21 =
        "GRADIREBBE che i gruppi scolastici, parrocchiali e sociali, che ne condividono gli scopi, ";
    final String p22 =
        "aderissero iscrivendosi come soci; in alternativa GRADIREBBE un contributo volontario pari ";
    final String p23 =
        "alla quota di iscrizione di 50,00 euro per tutto il Gruppo. Per singoli il contributo è di 15 ";
    final String p24 =
        "euro che sale a 30 per gruppi familiari. Questo per aiutare al mantenimento del luogo ";
    final String p25 =
        "e del Percorso. E' possibile provvedere direttamente sul posto e sarà rilasciata regolare ricevuta e tessera”. ";
    final String end = "\n\nCordiali saluti\n\nAgostino\n\n3355682242";
    final String responseText = start +
        p1 +
        p2 +
        p3 +
        p4 +
        p5 +
        p6 +
        p7 +
        p8 +
        p9 +
        p10 +
        p11 +
        p12 +
        p13 +
        p14 +
        p15 +
        p16 +
        p17 +
        p18 +
        p19 +
        p20 +
        p21 +
        p22 +
        p23 +
        p24 +
        p25 +
        end;
    final bool resultSend = await sendResponse(
        "Richiesta Visita a Barbiana accettata", email, responseText);
    final databaseReference =
        FirebaseDatabase.instance.reference().child("Prenotazione");
    databaseReference.child(prenotazioneId).update({"presaVisione": "si"});
    return resultSend;
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

  addAssegnazioneMancante(String prenotazioneId) {
    final databaseReference =
        FirebaseDatabase.instance.reference().child("AssegnazioniMancanti");
    databaseReference.set({prenotazioneId: "id"});
  }

  accettaOperation(String prenotazioneId, String email, Map infoGroup,
      String date, String hour) async {
    bool resultOperation;
    String errorText = "";
    final Map volounteersData = await getVolounteersMails();
    final List volounteersMail = volounteersData.keys.toList();
    List<Widget> containerVolounteers = [];
    List mailVolounteersChoosen = [];
    String groupInfo = "";
    infoGroup.forEach((key, value) => {
          if (key != "presaVisione") {groupInfo += "\n$key : $value"}
        });
    String dropDownValue = volounteersData[volounteersMail[0]];
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
                    Text(
                      "Assegna i volontari per questa visita",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(
                      height: 25,
                    ),
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
                                value: volounteersData[mail],
                                child: Text(mail),
                              ))
                          .toList(),
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.add,
                        size: 40,
                        color: Color.fromARGB(255, 24, 37, 102),
                      ),
                      onPressed: () {
                        if (keyContainer.containsValue(dropDownValue)) {
                          return;
                        }
                        setState(() {
                          errorText = "";
                          Key key = Key(random.nextInt(1000000000).toString());
                          keyContainer.addAll({key: dropDownValue});
                          mailVolounteersChoosen.add(dropDownValue);
                          containerVolounteers.add(
                            Column(
                              children: [
                                FittedBox(
                                  fit: BoxFit.fitWidth,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        child: Text(
                                          dropDownValue,
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
                                              final mailDelete =
                                                  keyContainer[key];
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
                          );
                        });
                      },
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
                    errorText.isNotEmpty
                        ? FittedBox(
                            fit: BoxFit.fitWidth,
                            child: Text(
                              errorText,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.red[900],
                              ),
                            ),
                          )
                        : Container(
                            height: 10,
                            width: 10,
                          ),
                  ],
                ),
              ),
            ),
            actions: [
              CupertinoDialogAction(
                onPressed: () async {
                  if (mailVolounteersChoosen.isEmpty) {
                    setState(() {
                      errorText = "Assegnare i Volontari!";
                    });
                    return;
                  }
                  final bool result =
                      await accetta(email, date, hour, prenotazioneId);
                  for (String email in mailVolounteersChoosen) {
                    await sendResponse(
                        groupInfo, email, "Info gruppo per Visita Barbiana");
                  }
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
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop('dialog');
                },
                child: Text(
                  "Annulla",
                  style: TextStyle(
                    fontSize: 28,
                  ),
                ),
              ),
              CupertinoDialogAction(
                onPressed: () async {
                  final bool result =
                      await accetta(email, date, hour, prenotazioneId);
                  addAssegnazioneMancante(prenotazioneId);
                  Navigator.of(context, rootNavigator: true).pop('dialog');
                  resultOperation = result;
                },
                child: Text(
                  "Conferma Senza Assegnazioni",
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: 26,
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
                    Text(
                      "Assegna i volontari per questa visita",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(
                      height: 25,
                    ),
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
                                value: volounteersData[mail],
                                child: Text(mail),
                              ))
                          .toList(),
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.add,
                        size: 40,
                        color: Color.fromARGB(255, 24, 37, 102),
                      ),
                      onPressed: () {
                        if (keyContainer.containsValue(dropDownValue)) {
                          return;
                        }
                        setState(() {
                          errorText = "";
                          Key key = Key(random.nextInt(1000000000).toString());
                          keyContainer.addAll({key: dropDownValue});
                          mailVolounteersChoosen.add(dropDownValue);
                          containerVolounteers.add(
                            Column(
                              children: [
                                FittedBox(
                                  fit: BoxFit.fitWidth,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        child: Text(
                                          dropDownValue,
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
                                              final mailDelete =
                                                  keyContainer[key];
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
                          );
                        });
                      },
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
                    errorText.isNotEmpty
                        ? FittedBox(
                            fit: BoxFit.fitWidth,
                            child: Text(
                              errorText,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.red[900],
                              ),
                            ),
                          )
                        : Container(
                            height: 10,
                            width: 10,
                          ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  if (mailVolounteersChoosen.isEmpty) {
                    setState(() {
                      errorText = "Assegnare i Volontari!";
                    });
                    return;
                  }
                  final bool result =
                      await accetta(email, date, hour, prenotazioneId);
                  for (String email in mailVolounteersChoosen) {
                    await sendResponse(
                        groupInfo, email, "Info gruppo per Visita Barbiana");
                  }
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
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop('dialog');
                },
                child: Text(
                  "Annulla",
                  style: TextStyle(
                    fontSize: 28,
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  final bool result =
                      await accetta(email, date, hour, prenotazioneId);
                  addAssegnazioneMancante(prenotazioneId);
                  Navigator.of(context, rootNavigator: true).pop('dialog');
                  resultOperation = result;
                },
                child: Text(
                  "Conferma Senza Assegnazioni",
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: 26,
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
    final fullDateTime = DateTime.tryParse(infoRichiesta["data"]);
    final String fullDate = fullDateTime == null
        ? infoRichiesta["data"]
        : DateFormat('dd/MM/yyyy HH:mm').format(fullDateTime);
    final String hour = infoRichiesta["data"].contains("T")
        ? infoRichiesta["data"].split("T")[1]
        : infoRichiesta["data"].split(" ")[1];
    final String date = fullDate.split(" ")[0];
    infoRichiesta["data"] = fullDate;

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
                  onPressed: () async {
                    final String email = infoRichiesta["email"];
                    final bool resultAccepting = await accettaOperation(
                        prenotazioneId, email, infoRichiesta, date, hour);
                    if (resultAccepting == null) {
                      return;
                    }
                    if (Platform.isIOS) {
                      await showCupertinoDialog(
                        context: context,
                        builder: (BuildContext context) => CupertinoAlertDialog(
                          title: Text(
                            "Esito Operazione",
                            style: TextStyle(
                              fontSize: 28,
                            ),
                          ),
                          content: Text(
                            resultAccepting
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
                      await showDialog(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: Text(
                            "Esito Operazione",
                            style: TextStyle(
                              fontSize: 28,
                            ),
                          ),
                          content: Text(
                            resultAccepting
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
                    MaterialPageRoute(builder: (context) => RichiesteVisita());
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
                    if (resultRefusing == null) {
                      return;
                    }
                    if (Platform.isIOS) {
                      await showCupertinoDialog(
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
                      await showDialog(
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
                    MaterialPageRoute(builder: (context) => RichiesteVisita());
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
