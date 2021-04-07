import 'package:firebase_database/firebase_database.dart';

class DatabaseInfo {
  getStock() async {
    final FirebaseDatabase database = FirebaseDatabase.instance;
    Map result;
    await database
        .reference()
        .child("Stock")
        .orderByValue()
        .once()
        .then((DataSnapshot snapshot) {
      result = new Map.from(snapshot.value);
    });
    return result;
  }

  getRichiesteVisita() async {
    final FirebaseDatabase database = FirebaseDatabase.instance;
    Map result;
    await database
        .reference()
        .child("Prenotazione")
        .orderByValue()
        .once()
        .then((DataSnapshot snapshot) {
      result = new Map.from(snapshot.value);
    });
    return result;
  }

  hasNewRequest() async {
    final FirebaseDatabase database = FirebaseDatabase.instance;
    Map result;
    await database
        .reference()
        .child("Prenotazione")
        .orderByValue()
        .once()
        .then((DataSnapshot snapshot) {
      result = new Map.from(snapshot.value);
    });
    final List keys = result.keys.toList();
    bool newRequest = false;
    for (var key in keys) {
      newRequest = result[key]["presaVisione"] == "no";
      if (newRequest) {
        return newRequest;
      }
    }
    return newRequest;
  }

  needVolounteers() async {
    final FirebaseDatabase database = FirebaseDatabase.instance;
    Map result;
    await database
        .reference()
        .child("AssegnazioniMancanti")
        .orderByValue()
        .once()
        .then((DataSnapshot snapshot) {
      result = new Map.from(snapshot.value);
    });
    return result.isNotEmpty;
  }
}
