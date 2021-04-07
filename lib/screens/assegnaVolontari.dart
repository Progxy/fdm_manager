import 'package:connectivity/connectivity.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mailer2/mailer.dart';
import 'badConnection.dart';
import 'feedback.dart';
import 'utilizzo.dart';
import 'package:intl/intl.dart';

class AssegnazioneVolontari extends StatefulWidget {
  static const String routeName = "/infoRichiesta";

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
            Column(
              children: loadData(infoRichiesta),
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
