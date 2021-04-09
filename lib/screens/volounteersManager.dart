import 'package:firebase_database/firebase_database.dart';

class VolounteerManager {
  static Map volounteers;
  static Map idRequests;

  getVolounteersMails() async {
    final database = FirebaseDatabase.instance;
    await database
        .reference()
        .child("Volontari")
        .orderByValue()
        .once()
        .then((DataSnapshot snapshot) {
      volounteers = new Map.from(snapshot.value);
    });
    return;
  }

  getRichiesteVisita() async {
    final FirebaseDatabase database = FirebaseDatabase.instance;
    await database
        .reference()
        .child("Prenotazione")
        .orderByValue()
        .once()
        .then((DataSnapshot snapshot) {
      idRequests = new Map.from(snapshot.value);
    });
    return;
  }
}
