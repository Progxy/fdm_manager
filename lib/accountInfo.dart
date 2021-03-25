import 'package:firebase_database/firebase_database.dart';

class AccountInfo {
  static String name = "Login";
  static String email = "me@example.com";
  static var userId;

  setter(String username, String mail) {
    name = username;
    email = mail;
  }

  setUser(id) {
    userId = id;
  }

  setFromUserId(database) async {
    await database
        .reference()
        .child(userId + "/User")
        .once()
        .then((DataSnapshot snapshot) {
      final Map map = snapshot.value.map((a, b) => MapEntry(a, b));
      final username = map.keys.first;
      final email = map.values.first;
      AccountInfo().setter(username, email);
    });
  }

  resetCredentials() {
    name = "Login";
    email = "me@example.com";
  }
}
