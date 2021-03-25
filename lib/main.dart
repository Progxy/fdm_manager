import 'package:fdm_manager/app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebaseProjectsManager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseProjectsManager().connectFirebaseCreatorApp();
  await FirebaseProjectsManager().connectFirebaseMainApp();
  await FirebaseProjectsManager().connectFirebaseDesktopApp();
  runApp(MyApp());
}
