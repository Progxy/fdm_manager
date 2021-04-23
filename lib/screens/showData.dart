import 'package:connectivity/connectivity.dart';
import 'package:fdm_manager/screens/utilizzo.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../accountInfo.dart';
import '../databaseInfo.dart';
import 'badConnection.dart';
import 'feedback.dart';
import 'mainDrawer.dart';

class DataLoader extends StatefulWidget {
  static const String routeName = "/home";
  final FirebaseApp defaultApp = Firebase.app();

  @override
  _DataLoaderState createState() => _DataLoaderState();
}

class _DataLoaderState extends State<DataLoader> {
  String name = AccountInfo.name;
  final TextStyle infoStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w300,
    color: Colors.grey,
  );
  final TextStyle titleStyle = TextStyle(
    fontSize: 21,
    fontWeight: FontWeight.w600,
  );
  final List<String> choices = <String>[
    "FeedBack",
    "Aiuto",
  ];
  final List types = ["Tessere", "Libri", "Contributi", "Rinnovi", "Incassi"];
  String choice = "Tessere";

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

  loadData(String choice) async {
    Widget contents;
    switch (choice) {
      case "Tessere":
        final Map tessere = await DatabaseInfo().getTessere();
        List<DataRow> content = [];
        for (var key in tessere.keys.toList()) {
          final Map info = tessere[key];
          final String typeTessera = info["Tipo di Tessera"];
          final String anniSociali = info["anniSociali"];
          final String cap = info["cap"];
          final String citta = info["citta"];
          final String cognome = info["cognome"];
          final String data = info["data"];
          final String email = info["email"];
          final String fattoDa = info["fattoDa"];
          final String indirizzo = info["indirizzo"];
          final String intestazione = info["intestazione"];
          final String nome = info["nome"];
          final String provincia = info["provincia"];
          final String scaduto = info["scaduto"];
          final String telefono = info["telefono"];
          content.add(
            DataRow(cells: [
              DataCell(Text(typeTessera)),
              DataCell(Text(anniSociali)),
              DataCell(Text(cap)),
              DataCell(Text(citta)),
              DataCell(Text(cognome)),
              DataCell(Text(nome)),
              DataCell(Text(email)),
              DataCell(Text(fattoDa)),
              DataCell(Text(indirizzo)),
              DataCell(Text(intestazione)),
              DataCell(Text(data)),
              DataCell(Text(provincia)),
              DataCell(Text(scaduto == "true" ? "Sì" : "No")),
              DataCell(Text(telefono)),
            ]),
          );
        }
        contents = InteractiveViewer(
          constrained: false,
          child: DataTable(columns: [
            DataColumn(
              label: Text(
                "Tipo di Tessera",
                style: titleStyle,
              ),
            ),
            DataColumn(
              label: Text(
                "Anni Sociali",
                style: titleStyle,
              ),
            ),
            DataColumn(
              label: Text(
                "Cap",
                style: titleStyle,
              ),
            ),
            DataColumn(
              label: Text(
                "Città",
                style: titleStyle,
              ),
            ),
            DataColumn(
              label: Text(
                "Cognome",
                style: titleStyle,
              ),
            ),
            DataColumn(
              label: Text(
                "Nome",
                style: titleStyle,
              ),
            ),
            DataColumn(
              label: Text(
                "Email",
                style: titleStyle,
              ),
            ),
            DataColumn(
              label: Text(
                "Fatto Da",
                style: titleStyle,
              ),
            ),
            DataColumn(
              label: Text(
                "Indirizzo",
                style: titleStyle,
              ),
            ),
            DataColumn(
              label: Text(
                "Intestazione",
                style: titleStyle,
              ),
            ),
            DataColumn(
              label: Text(
                "Data",
                style: titleStyle,
              ),
            ),
            DataColumn(
              label: Text(
                "Provincia",
                style: titleStyle,
              ),
            ),
            DataColumn(
              label: Text(
                "Scaduta",
                style: titleStyle,
              ),
            ),
            DataColumn(
              label: Text(
                "Telefono",
                style: titleStyle,
              ),
            ),
          ], rows: content),
        );
        break;
      case "Libri":
        final Map libri = await DatabaseInfo().getLibri();
        List<DataRow> content = [];
        for (var key in libri.keys.toList()) {
          final Map info = libri[key];
          final String data = info["data"];
          final String fattoDa = info["fattoDa"];
          final String gianni = info["Gianni"];
          final String obbedienzaVirtu = info["ObbedienzaVirtu"];
          final String parolaEguali = info["ParolaEguali"];
          final String percorsoDidattico = info["PercorsoDidattico"];
          final String silenzioVoce = info["SilenzioVoce"];
          final String totale = (int.parse(gianni) +
                  int.parse(obbedienzaVirtu) +
                  int.parse(parolaEguali) +
                  int.parse(percorsoDidattico) +
                  int.parse(silenzioVoce))
              .toString();
          content.add(
            DataRow(cells: [
              DataCell(Text(gianni)),
              DataCell(Text(obbedienzaVirtu)),
              DataCell(Text(parolaEguali)),
              DataCell(Text(percorsoDidattico)),
              DataCell(Text(silenzioVoce)),
              DataCell(Text(totale)),
              DataCell(Text(data)),
              DataCell(Text(fattoDa)),
            ]),
          );
        }
        contents = InteractiveViewer(
          constrained: false,
          child: DataTable(columns: [
            DataColumn(
              label: Text(
                "Lettera A Una Professoressa",
                style: titleStyle,
              ),
            ),
            DataColumn(
              label: Text(
                "L'Obbedienza Non è Una Virtù",
                style: titleStyle,
              ),
            ),
            DataColumn(
              label: Text(
                "La Parola Fa Eguali",
                style: titleStyle,
              ),
            ),
            DataColumn(
              label: Text(
                "Percorso Didattico",
                style: titleStyle,
              ),
            ),
            DataColumn(
              label: Text(
                "Il Silenzio Diventa Voce",
                style: titleStyle,
              ),
            ),
            DataColumn(
              label: Text(
                "Totale",
                style: titleStyle,
              ),
            ),
            DataColumn(
              label: Text(
                "Data",
                style: titleStyle,
              ),
            ),
            DataColumn(
              label: Text(
                "Fatto Da",
                style: titleStyle,
              ),
            ),
          ], rows: content),
        );
        break;
      case "Contributi":
        final Map contributi = await DatabaseInfo().getContributi();
        List<DataRow> content = [];
        for (var key in contributi.keys.toList()) {
          final Map info = contributi[key];
          final String data = info["data"];
          final String fattoDa = info["fattoDa"];
          final String valoreContributo = info["valoreContributo"] + "€";
          final String nome = info["nome"];
          final String cognome = info["cognome"];
          content.add(
            DataRow(cells: [
              DataCell(Text(nome)),
              DataCell(Text(cognome)),
              DataCell(Text(valoreContributo)),
              DataCell(Text(data)),
              DataCell(Text(fattoDa)),
            ]),
          );
        }
        contents = InteractiveViewer(
          constrained: false,
          child: DataTable(columns: [
            DataColumn(
              label: Text(
                "Nome",
                style: titleStyle,
              ),
            ),
            DataColumn(
              label: Text(
                "Cognome",
                style: titleStyle,
              ),
            ),
            DataColumn(
              label: Text(
                "Valore Contributo",
                style: titleStyle,
              ),
            ),
            DataColumn(
              label: Text(
                "Data",
                style: titleStyle,
              ),
            ),
            DataColumn(
              label: Text(
                "Fatto Da",
                style: titleStyle,
              ),
            ),
          ], rows: content),
        );
        break;
      case "Rinnovi":
        final Map rinnovi = await DatabaseInfo().getRinnovi();
        List<DataRow> content = [];
        for (var key in rinnovi.keys.toList()) {
          final Map info = rinnovi[key];
          final String tipoTessera = info["tipo di tessera"];
          final String email = info["email"];
          final String anniSociali = info["anniSociali"];
          final String nome = info["nome"];
          final String cognome = info["cognome"];
          content.add(
            DataRow(cells: [
              DataCell(Text(nome)),
              DataCell(Text(cognome)),
              DataCell(Text(email)),
              DataCell(Text(anniSociali)),
              DataCell(Text(tipoTessera)),
            ]),
          );
        }
        contents = InteractiveViewer(
          constrained: false,
          child: DataTable(columns: [
            DataColumn(
              label: Text(
                "Nome",
                style: titleStyle,
              ),
            ),
            DataColumn(
              label: Text(
                "Cognome",
                style: titleStyle,
              ),
            ),
            DataColumn(
              label: Text(
                "Email",
                style: titleStyle,
              ),
            ),
            DataColumn(
              label: Text(
                "Anni Sociali",
                style: titleStyle,
              ),
            ),
            DataColumn(
              label: Text(
                "Tipo di Tessera",
                style: titleStyle,
              ),
            ),
          ], rows: content),
        );

        break;
      case "Incassi":
        final Map incassi = await DatabaseInfo().getIncassi();
        List<DataRow> content = [];
        for (var key in incassi.keys.toList()) {
          final Map info = incassi[key];
          final String fattoDa = info["fattoDa"];
          String incasso = "";
          String data = "";
          for (var element in info.keys.toList()) {
            if (element != "fattoDa") {
              incasso = info[element] + "€";
              data = element;
            }
          }
          content.add(
            DataRow(cells: [
              DataCell(Text(incasso)),
              DataCell(Text(data)),
              DataCell(Text(fattoDa)),
            ]),
          );
        }
        contents = InteractiveViewer(
          constrained: false,
          child: DataTable(columns: [
            DataColumn(
              label: Text(
                "Incasso",
                style: titleStyle,
              ),
            ),
            DataColumn(
              label: Text(
                "Data",
                style: titleStyle,
              ),
            ),
            DataColumn(
              label: Text(
                "Fatto Da",
                style: titleStyle,
              ),
            ),
          ], rows: content),
        );
        break;
    }
    return contents;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Color.fromARGB(255, 192, 192, 192),
        ),
        title: FittedBox(
          fit: BoxFit.fitWidth,
          child: Text(
            "Dati Fondazione",
            style: TextStyle(
              color: Color.fromARGB(255, 192, 192, 192),
              fontWeight: FontWeight.w700,
            ),
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
          children: [
            SizedBox(
              height: 25,
            ),
            DropdownButton<String>(
              isExpanded: true,
              isDense: true,
              value: choice,
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
                  choice = newValue;
                });
              },
              items: types
                  .map((type) => new DropdownMenuItem<String>(
                        value: type,
                        child: type,
                      ))
                  .toList(),
            ),
            SizedBox(
              height: 25,
            ),
            FutureBuilder(
              future: loadData(choice),
              builder: (context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.hasData) {
                  return snapshot.data;
                } else if (snapshot.hasError) {
                  print("err : ${snapshot.error}");
                  return Text(
                    "Errore nel caricamento dei dati!",
                    style: infoStyle,
                    textAlign: TextAlign.center,
                  );
                }
                return Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 4.0,
                    backgroundColor: Colors.white,
                  ),
                );
              },
            ),
            SizedBox(
              height: 15,
            ),
          ],
        ),
      ),
    );
  }
}
