import 'package:firebase_database/firebase_database.dart';

class VolounteerManager {
  static Map volounteers;
  static Map idRequests;
  static Map idDisdette;

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

  getUnassignedRequests() async {
    final FirebaseDatabase database = FirebaseDatabase.instance;
    await database
        .reference()
        .child("Prenotazione")
        .orderByValue()
        .once()
        .then((DataSnapshot snapshot) {
      idRequests = new Map.from(snapshot.value);
    });
    await database
        .reference()
        .child("AssegnazioniMancanti")
        .orderByValue()
        .once()
        .then((DataSnapshot snapshot) {
      final Map result = new Map.from(snapshot.value);
      final List assignments = result.keys.toList();
      final List allIdKeys = idRequests.keys.toList();
      for (var element in assignments) {
        if (allIdKeys.contains(element)) {
          allIdKeys.remove(element);
        }
      }
      for (var elem in allIdKeys) {
        idRequests.remove(elem);
      }
    });
    return;
  }

  getDisdette() async {
    final FirebaseDatabase database = FirebaseDatabase.instance;
    await database
        .reference()
        .child("Disdette")
        .orderByValue()
        .once()
        .then((DataSnapshot snapshot) {
      idDisdette = new Map.from(snapshot.value);
    });
    return;
  }
}
