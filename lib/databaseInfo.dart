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
}
