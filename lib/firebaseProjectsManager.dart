import 'package:firebase_core/firebase_core.dart';

class FirebaseProjectsManager {
  static FirebaseApp mainApp;
  static FirebaseApp desktopApp;
  static FirebaseApp creatorApp;

  connectFirebaseMainApp() async {
    try {
      mainApp = await Firebase.initializeApp(
        name: 'fdmApp',
        options: const FirebaseOptions(
          apiKey: 'AIzaSyCmiAVLF7dIR9U90riDHxbLalq80dBUlfk',
          appId: '1:1096652698814:android:76ca6de6dbc5f891e0daef',
          messagingSenderId: '1096652698814',
          projectId: 'fdmapp-2dad1',
        ),
      );
      return;
    } catch (e) {
      mainApp = Firebase.app("fdmApp");
      return;
    }
  }

  getMainApp() {
    return mainApp;
  }

  connectFirebaseCreatorApp() async {
    try {
      creatorApp = await Firebase.initializeApp(
        name: 'creatorApp',
        options: const FirebaseOptions(
          apiKey: 'AIzaSyB9UyS_Sz1TtMNs8_qAsZnmi4WaSeR5GAQ',
          appId: '1:1096652698814:android:76ca6de6dbc5f891e0daef',
          messagingSenderId: '1096652698814',
          projectId: 'fdmcreator',
        ),
      );
      return;
    } catch (e) {
      creatorApp = Firebase.app("creatorApp");
      return;
    }
  }

  getCreatorApp() {
    return desktopApp;
  }

  connectFirebaseDesktopApp() async {
    try {
      desktopApp = await Firebase.initializeApp(
        name: 'desktopApp',
        options: const FirebaseOptions(
          apiKey: 'AIzaSyCTVzNkbhwluxMZ52UFvl-R9noLJTcF_Bk',
          appId: '1:146930845010:web:e166794b589574f4dea68b',
          messagingSenderId: '146930845010',
          projectId: 'fdmdesktop-d5b94',
        ),
      );
      return;
    } catch (e) {
      desktopApp = Firebase.app("desktopApp");
      return;
    }
  }

  getDesktopApp() {
    return desktopApp;
  }
}
