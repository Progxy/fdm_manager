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
  static const String routeName = "/dataLoader";
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
  final List types = [
    "Tessere",
    "Libri",
    "Contributi",
    "Rinnovi",
    "Incassi",
    "Volontari"
  ];
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
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
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
          final String scaduto = info["scaduto"].toString();
          final String telefono = info["telefono"];
          final bool asMoreYear = (anniSociali.split("-").length) > 1;
          content.add(
            DataRow(cells: [
              DataCell(Text(typeTessera)),
              DataCell(Padding(
                padding: EdgeInsets.only(left: asMoreYear ? 15.0 : 40.0),
                child: Text(anniSociali),
              )),
              DataCell(Text(cap)),
              DataCell(Text(citta)),
              DataCell(Padding(
                padding: const EdgeInsets.only(left: 33.0),
                child: Text(cognome),
              )),
              DataCell(Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: Text(nome),
              )),
              DataCell(Text(email)),
              DataCell(Text(fattoDa)),
              DataCell(Text(indirizzo)),
              DataCell(Padding(
                padding: const EdgeInsets.only(left: 35.0),
                child: Text(intestazione),
              )),
              DataCell(Text(data)),
              DataCell(Padding(
                padding: const EdgeInsets.only(left: 40.0),
                child: Text(provincia),
              )),
              DataCell(Padding(
                padding: const EdgeInsets.only(left: 35.0),
                child: Text(scaduto == "true" ? "Sì" : "No"),
              )),
              DataCell(Text(telefono)),
            ]),
          );
        }
        contents = ConstrainedBox(
          constraints: BoxConstraints.tight(Size(width * .95, height)),
          child: InteractiveViewer(
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
          ),
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
          final String totale = ((int.parse(gianni) * 10) +
                      (int.parse(obbedienzaVirtu) * 8) +
                      (int.parse(parolaEguali) * 10) +
                      (int.parse(percorsoDidattico) * 6) +
                      (int.parse(silenzioVoce) * 6))
                  .toString() +
              "€";
          content.add(
            DataRow(cells: [
              DataCell(Padding(
                padding: const EdgeInsets.only(left: 100.0),
                child: Text(
                  gianni,
                ),
              )),
              DataCell(Padding(
                padding: const EdgeInsets.only(left: 225.0),
                child: Text(
                  obbedienzaVirtu,
                ),
              )),
              DataCell(Padding(
                padding: const EdgeInsets.only(left: 102.0),
                child: Text(
                  parolaEguali,
                ),
              )),
              DataCell(Padding(
                padding: const EdgeInsets.only(left: 100.0),
                child: Text(
                  percorsoDidattico,
                ),
              )),
              DataCell(Padding(
                padding: const EdgeInsets.only(left: 110.0),
                child: Text(
                  silenzioVoce,
                ),
              )),
              DataCell(Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Text(
                  totale,
                ),
              )),
              DataCell(Text(data)),
              DataCell(Text(fattoDa)),
            ]),
          );
        }
        contents = ConstrainedBox(
          constraints: BoxConstraints.tight(Size(width * .95, height)),
          child: InteractiveViewer(
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
                  "L'Obbedienza Non E' Più Una Virtù",
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
          ),
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
              DataCell(Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: Text(nome),
              )),
              DataCell(Padding(
                padding: const EdgeInsets.only(left: 33.0),
                child: Text(cognome),
              )),
              DataCell(Padding(
                padding: const EdgeInsets.only(left: 70.0),
                child: Text(valoreContributo),
              )),
              DataCell(Text(data)),
              DataCell(Text(fattoDa)),
            ]),
          );
        }
        contents = ConstrainedBox(
          constraints: BoxConstraints.tight(Size(width * .95, height)),
          child: InteractiveViewer(
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
          ),
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
              DataCell(Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: Text(nome),
              )),
              DataCell(Padding(
                padding: const EdgeInsets.only(left: 33.0),
                child: Text(cognome),
              )),
              DataCell(Text(email)),
              DataCell(Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: Text(anniSociali),
              )),
              DataCell(Padding(
                padding: const EdgeInsets.only(left: 40.0),
                child: Text(tipoTessera),
              )),
            ]),
          );
        }
        contents = ConstrainedBox(
          constraints: BoxConstraints.tight(Size(width * .95, height)),
          child: InteractiveViewer(
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
          ),
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
              DataCell(Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: Text(incasso),
              )),
              DataCell(Text(data)),
              DataCell(Text(fattoDa)),
            ]),
          );
        }
        contents = ConstrainedBox(
          constraints: BoxConstraints.tight(Size(width * .95, height)),
          child: InteractiveViewer(
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
          ),
        );
        break;
      case "Volontari":
        final Map volontari = await DatabaseInfo().getVolontari();
        List<DataRow> content = [];
        for (String name in volontari.keys.toList()) {
          final String email = volontari[name];
          content.add(
            DataRow(cells: [
              DataCell(Text(name)),
              DataCell(Text(email)),
            ]),
          );
        }
        contents = ConstrainedBox(
          constraints: BoxConstraints.tight(Size(width * .95, height)),
          child: InteractiveViewer(
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
                  "Email",
                  style: titleStyle,
                ),
              ),
            ], rows: content),
          ),
        );
        break;
    }
    return contents;
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
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
            Center(
              child: SizedBox(
                width: width * .85,
                child: DropdownButton<String>(
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
                            child: Text(type),
                          ))
                      .toList(),
                ),
              ),
            ),
            SizedBox(
              height: 35,
            ),
            FutureBuilder(
              future: loadData(choice),
              builder: (context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.hasData) {
                  return SizedBox(
                    child: snapshot.data,
                    width: width * .95,
                  );
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
