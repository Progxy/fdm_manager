import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:fdm_manager/firebaseProjectsManager.dart';
import 'package:fdm_manager/screens/richiesteArticoli.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mailer2/mailer.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import '../mapDecoder.dart';
import '../mapToWidget.dart';
import 'badConnection.dart';
import 'feedback.dart';
import 'utilizzo.dart';

class InfoContent extends StatefulWidget {
  static const String routeName = "/infoevento";
  static bool isLoaded = false;

  @override
  _InfoContentState createState() => _InfoContentState();
}

class _InfoContentState extends State<InfoContent> {
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

  bool isSecondary = false;
  int numVideoPlayer = 0;
  final TextEditingController _messaggioController = TextEditingController();
  final TextStyle infoStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w300,
    color: Colors.grey,
  );
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  refresh() {
    setState(() {
      print("refresh");
    });
  }

  video(Map content) async {
    final String top = content["Top"];
    final String bottom = content["Bottom"];
    final String right = content["Right"];
    final String left = content["Left"];
    final String videoLink = content["VideoLink"];
    isSecondary = _videoController != null;
    if (isSecondary) {
      _videoControllerSecondary = VideoPlayerController.network(videoLink);
      await _videoControllerSecondary.initialize();
      await _videoControllerSecondary.setLooping(true);
    } else {
      _videoController = VideoPlayerController.network(videoLink);
      await _videoController.initialize();
      await _videoController.setLooping(true);
    }
    final Widget result = Padding(
      padding: EdgeInsets.only(
        top: double.parse(top),
        bottom: double.parse(bottom),
        left: double.parse(left),
        right: double.parse(right),
      ),
      child: GestureDetector(
        onTap: isSecondary
            ? () => managerVideocontrollerSecondary()
            : () => managerVideoController(),
        child: Container(
          child: isSecondary
              ? _videoControllerSecondary.value.initialized
                  ? AspectRatio(
                      aspectRatio: _videoControllerSecondary.value.aspectRatio,
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: <Widget>[
                          VideoPlayer(_videoControllerSecondary),
                          VideoProgressIndicator(
                            _videoControllerSecondary,
                            allowScrubbing: true,
                            colors: VideoProgressColors(
                              playedColor:
                                  const Color.fromARGB(255, 24, 37, 102),
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Container(
                      color: Colors.black,
                      height: 200,
                      width: 200,
                    )
              : _videoController.value.initialized
                  ? AspectRatio(
                      aspectRatio: _videoController.value.aspectRatio,
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: <Widget>[
                          VideoPlayer(_videoController),
                          VideoProgressIndicator(
                            _videoController,
                            allowScrubbing: true,
                            colors: VideoProgressColors(
                              playedColor:
                                  const Color.fromARGB(255, 24, 37, 102),
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Container(
                      color: Colors.black,
                      height: 200,
                      width: 200,
                    ),
        ),
      ),
    );
    return result;
  }

  managerVideoController() {
    setState(() {
      _videoController.value.isPlaying
          ? _videoController.pause()
          : _videoController.play();
    });
    refresh();
  }

  managerVideocontrollerSecondary() {
    setState(() {
      _videoControllerSecondary.value.isPlaying
          ? _videoControllerSecondary.pause()
          : _videoControllerSecondary.play();
    });
    refresh();
  }

  loadContent(Map infoContent) async {
    if (InfoContent.isLoaded) {
      return;
    } else {
      InfoContent.isLoaded = true;
    }
    final contentInfo = MapDecoder().decoder(infoContent["Content"]);
    List<Widget> result = [];
    for (var element in contentInfo) {
      var type = element["Type"];
      if (type == "Video") {
        result.add(await video(element));
      } else {
        result.add(MapToWidget().selector(type, element));
      }
    }
    setState(() {
      contents = result;
    });
    return;
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

  deleteData(String prenotazioneId, String title) {
    final databaseReference =
        FirebaseDatabase.instance.reference().child("Articoli");
    databaseReference.child(prenotazioneId).remove();
    firebase_storage.FirebaseStorage.instanceFor(
            app: FirebaseProjectsManager().getCreatorApp())
        .ref(title)
        .delete();
  }

  refuseOperation(String prenotazioneId, String email, String title) async {
    bool resultOperation;
    if (Platform.isIOS) {
      await showCupertinoDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: Text(
            "Rifiuto Articolo",
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
                    controller: _messaggioController,
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
                if (_formKey.currentState.validate()) {
                  final String text =
                      "Siamo dispiaciuti ma il suo articolo è stato rifiutato poichè : \n\n${_messaggioController.text.trim()}\n\nCordiali Saluti, Agostino Burberi.";
                  resultOperation = sendResponse(text, email,
                      "Rifiuto Articolo per Fondazione Don Milani");
                  if (resultOperation) {
                    deleteData(prenotazioneId, title);
                  } else {
                    return;
                  }
                  _messaggioController.clear();
                  Navigator.of(context, rootNavigator: true).pop('dialog');
                }
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
            "Rifiuto Articolo",
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
                    controller: _messaggioController,
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
                if (_formKey.currentState.validate()) {
                  final String text =
                      "Siamo dispiaciuti ma il suo articolo è stato rifiutato poichè : \n\n${_messaggioController.text.trim()}\n\nCordiali Saluti, Agostino Burberi.";
                  resultOperation = sendResponse(text, email,
                      "Rifiuto Articolo per Fondazione Don Milani");
                  if (resultOperation) {
                    deleteData(prenotazioneId, title);
                  } else {
                    return;
                  }
                  _messaggioController.clear();
                  Navigator.of(context, rootNavigator: true).pop('dialog');
                }
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

  accetta(String title, String date, String typeArticle, String posterImage,
      String author, String contentContainer, String linkStorage) async {
    Map resultUpload = {
      "Title": title,
      "Date": date,
      "PosterImage": posterImage,
      "Content": contentContainer,
      "Author": author,
      "VideoLink": linkStorage,
    };
    try {
      var databaseReference =
          FirebaseDatabase(app: FirebaseProjectsManager().getMainApp())
              .reference()
              .child(typeArticle + "/" + title);
      databaseReference.set(resultUpload);
      return true;
    } catch (e) {
      print("An error occurred while posting on database : $e");
      return false;
    }
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

  VideoPlayerController _videoController;
  VideoPlayerController _videoControllerSecondary;
  List<Widget> contents = [
    Center(
      child: CircularProgressIndicator(
        strokeWidth: 4.0,
      ),
    ),
  ];

  @override
  void dispose() {
    super.dispose();
    _videoController.dispose();
    _videoControllerSecondary.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Map infoContent = ModalRoute.of(context).settings.arguments as Map;
    final String title = infoContent["Title"];
    loadContent(infoContent);

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Color.fromARGB(255, 192, 192, 192),
        ),
        title: Text(
          title,
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
              children: contents,
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
                    ProgressDialog dialog = new ProgressDialog(context);
                    dialog.style(message: 'Caricamento...');
                    await dialog.show();
                    final String date = infoContent["Date"];
                    final String typeArticle = infoContent["ArticleType"];
                    final String posterImage = infoContent["PosterImage"];
                    final String author = infoContent["Author"];
                    final String contentContainer = infoContent["Content"];
                    final String linkStorage = infoContent["VideoLink"];
                    final bool resultAccepting = accetta(
                        title,
                        date,
                        typeArticle,
                        posterImage,
                        author,
                        contentContainer,
                        linkStorage);
                    if (resultAccepting == null) {
                      return;
                    }
                    await dialog.hide();
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
                    MaterialPageRoute(
                        builder: (context) => RichiesteArticoli());
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
                    ProgressDialog dialog = new ProgressDialog(context);
                    dialog.style(message: 'Caricamento...');
                    await dialog.show();
                    final bool resultRefusing = true;
                    if (resultRefusing == null) {
                      return;
                    }
                    await dialog.hide();
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
                    MaterialPageRoute(
                        builder: (context) => RichiesteArticoli());
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
