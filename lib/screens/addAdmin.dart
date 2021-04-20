import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:fdm_manager/authentication_service.dart';
import 'package:fdm_manager/screens/home.dart';
import 'package:fdm_manager/screens/mainDrawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mailer2/mailer.dart';
import 'package:progress_dialog/progress_dialog.dart';
import '../firebaseProjectsManager.dart';
import 'badConnection.dart';
import 'feedback.dart';
import 'utilizzo.dart';

class AddCreator extends StatefulWidget {
  static const String routeName = "/addCreator";
  final FirebaseAuth auth =
      FirebaseAuth.instanceFor(app: FirebaseProjectsManager().getCreatorApp());
  final FirebaseDatabase database =
      FirebaseDatabase(app: FirebaseProjectsManager().getCreatorApp());

  @override
  _AddCreatorState createState() => _AddCreatorState();
}

class _AddCreatorState extends State<AddCreator> {
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

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  addDataToDatabase(String email, String name, String id) {
    final databaseReference = widget.database.reference();
    databaseReference.child(id).set({name: email});
    return;
  }

  getNewUserUid(String email, String password) async {
    await AuthenticationService(widget.auth)
        .signIn(email: email, password: password);
    return widget.auth.currentUser.uid;
  }

  String passwordGenerator() {
    int id = (((DateTime.now().millisecondsSinceEpoch) * 35) / 13579).round();
    return id.toString();
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

  addCreator(String email, String name) async {
    final String password = passwordGenerator();
    final String result =
        await AuthenticationService(widget.auth).signUp(email, password);
    if (result == "Operazione effetuata con successo!") {
      final String id = await getNewUserUid(email, password);
      addDataToDatabase(email, name, id);
      final String text =
          "Salve,\n\nè stato aggiunto un account creator a suo nome con cui potrà accedere all'applicazione FdmCreator con i privilegi di amministratore.\n\nEcco di seguito le sue credenziali di accesso :\n\nEmail : $email ,\n\nPassword : $password.\n\nCordiali Saluti, Ermes Fdm Express.";
      await sendResponse(text, email, "Aggiunto come Manager");
    }
    return result;
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
          "Aggiungi Creator",
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
            Form(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(
                    width: width * 1.35,
                    child: TextFormField(
                      controller: _nameController,
                      maxLines: 20,
                      decoration: const InputDecoration(
                        hintText: "Inserire nome e cognome",
                        hintStyle: TextStyle(
                          fontSize: 23.0,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        border: OutlineInputBorder(),
                        labelText: "Nome e Cognome",
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
                  SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: width * 1.35,
                    child: TextFormField(
                      controller: _emailController,
                      maxLines: 20,
                      decoration: const InputDecoration(
                        hintText: "Inserire l'email",
                        hintStyle: TextStyle(
                          fontSize: 23.0,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        border: OutlineInputBorder(),
                        labelText: "Email",
                        labelStyle: TextStyle(
                          fontSize: 23.0,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Dati Mancanti";
                        } else if (RegExp(
                                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                            .hasMatch(value)) {
                          return "Email Invalida!";
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 50,
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
                  if (_formKey.currentState.validate()) {
                    ProgressDialog dialog = new ProgressDialog(context);
                    dialog.style(message: 'Caricamento...');
                    await dialog.show();
                    final String email = _emailController.text.trim();
                    final String name = _nameController.text.trim();
                    final String result = await addCreator(email, name);
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
                            result,
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
                            result,
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
                  }
                },
                child: Text(
                  "Aggiungi",
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
