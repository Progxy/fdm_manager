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

  getYearSubscribed() async {
    final FirebaseDatabase database = FirebaseDatabase.instance;
    int iscritti = 0;
    await database
        .reference()
        .child("Tessere")
        .orderByValue()
        .once()
        .then((DataSnapshot snapshot) {
      final Map result = new Map.from(snapshot.value);
      for (var element in result.keys.toList()) {
        for (var elem in result[element]["anniSociali"].split("-")) {
          if (elem == DateTime.now().year.toString()) {
            iscritti++;
            continue;
          }
        }
      }
    });
    return iscritti;
  }

  getSubscribed() async {
    final FirebaseDatabase database = FirebaseDatabase.instance;
    int iscritti = 0;
    await database
        .reference()
        .child("Tessere")
        .orderByValue()
        .once()
        .then((DataSnapshot snapshot) {
      final Map result = new Map.from(snapshot.value);
      iscritti = result.length;
    });
    return iscritti;
  }

  getYearMoney() async {
    final FirebaseDatabase database = FirebaseDatabase.instance;
    int tot = 0;
    await database
        .reference()
        .child("IncassiTotali")
        .orderByValue()
        .once()
        .then((DataSnapshot snapshot) {
      final Map result = new Map.from(snapshot.value);
      for (var element in result.keys.toList()) {
        for (var key in result[element].keys.toList()) {
          if (key == "fattoDa") {
            continue;
          }
          if (key.split("-")[2] == DateTime.now().year.toString()) {
            tot += int.tryParse(result[element][key]);
          }
        }
      }
    });
    return tot;
  }

  getTodayMoney() async {
    final FirebaseDatabase database = FirebaseDatabase.instance;
    int tot = 0;
    await database
        .reference()
        .child("IncassiTotali")
        .orderByValue()
        .once()
        .then((DataSnapshot snapshot) {
      final Map result = new Map.from(snapshot.value);
      final String today = DateTime.now().day.toString() +
          "-" +
          DateTime.now().month.toString() +
          "-" +
          DateTime.now().year.toString();
      for (var element in result.keys.toList()) {
        for (var key in result[element].keys.toList()) {
          if (key == "fattoDa") {
            continue;
          }
          if (result[element][key] == today) {
            tot += int.tryParse(result[element][key]);
          }
        }
      }
    });
    return tot;
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
    final List keys = result.keys.toList();
    for (var key in keys) {
      bool newRequest = result[key]["presaVisione"] == "no";
      if (!newRequest) {
        result.remove(key);
      }
    }
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

  hasNewDisdetta() async {
    final FirebaseDatabase database = FirebaseDatabase.instance;
    Map result;
    await database
        .reference()
        .child("Disdette")
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

  getRichiesteArticoli() async {
    final FirebaseDatabase database = FirebaseDatabase.instance;
    Map result;
    await database
        .reference()
        .child("Articoli")
        .orderByValue()
        .once()
        .then((DataSnapshot snapshot) {
      result = new Map.from(snapshot.value);
    });
    return result;
  }

  hasRichiesteArticoli() async {
    final FirebaseDatabase database = FirebaseDatabase.instance;
    Map result;
    await database
        .reference()
        .child("Articoli")
        .orderByValue()
        .once()
        .then((DataSnapshot snapshot) {
      result = new Map.from(snapshot.value);
    });
    if (result.length > 0) {
      return true;
    }
    return false;
  }
}
