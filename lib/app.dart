import 'package:fdm_manager/screens/access.dart';
import 'package:fdm_manager/screens/addAdmin.dart';
import 'package:fdm_manager/screens/addVolontario.dart';
import 'package:fdm_manager/screens/approvaArticoli.dart';
import 'package:fdm_manager/screens/assegnaVolontari.dart';
import 'package:fdm_manager/screens/badConnection.dart';
import 'package:fdm_manager/screens/cambioPassword.dart';
import 'package:fdm_manager/screens/disdette.dart';
import 'package:fdm_manager/screens/errorpage.dart';
import 'package:fdm_manager/screens/feedback.dart';
import 'package:fdm_manager/screens/home.dart';
import 'package:fdm_manager/screens/infoRichiesta.dart';
import 'package:fdm_manager/screens/richiesteArticoli.dart';
import 'package:fdm_manager/screens/richiesteVisita.dart';
import 'package:fdm_manager/screens/showData.dart';
import 'package:fdm_manager/screens/utilizzo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'authentication_service.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthenticationService>(
          create: (_) => AuthenticationService(FirebaseAuth.instance),
        ),
        StreamProvider(
          create: (context) =>
              context.read<AuthenticationService>().authStateChanges,
          initialData: null,
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'FdmManager',
        theme: ThemeData(
          fontFamily: "Avenir",
          primaryColor: Color.fromARGB(255, 24, 37, 102),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: Access(),
        routes: {
          Access.routeName: (context) => Access(),
          BadConnection.routeName: (context) => BadConnection(),
          Utilizzo.routeName: (context) => Utilizzo(),
          FeedBack.routeName: (context) => FeedBack(),
          Home.routeName: (context) => Home(),
          ErrorPage.routeName: (context) => ErrorPage(),
          CambioPassword.routeName: (context) => CambioPassword(),
          RichiesteVisita.routeName: (context) => RichiesteVisita(),
          InfoRichiesta.routeName: (context) => InfoRichiesta(),
          AssegnazioneVolontari.routeName: (context) => AssegnazioneVolontari(),
          Disdette.routeName: (context) => Disdette(),
          AddVolontario.routeName: (context) => AddVolontario(),
          AddCreator.routeName: (context) => AddCreator(),
          RichiesteArticoli.routeName: (context) => RichiesteArticoli(),
          InfoContent.routeName: (context) => InfoContent(),
          DataLoader.routeName: (context) => DataLoader(),
        },
      ),
    );
  }
}
