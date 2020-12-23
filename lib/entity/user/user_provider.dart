import 'package:firebase_auth/firebase_auth.dart';
import 'package:neuron_word/controller/database.dart';

import 'user_data.dart';

class UserProvider {

  static getUserData(User user) {
    if(user == null)
      throw("Utente non definito");
    else
      return Database.users.where("uid", isEqualTo: user.uid).get().then((value) {
        if(value.docs.isNotEmpty){
          return UserData.fromJson(value.docs[0].data(), user);
        }
        return null;
      });
  }

  static Future<UserData> addUserData(UserData user) {
    return Database.users.add(user.toJson()).then((value) {
      if(value != null){
        print(value.toString());
        return user;
      }
      return null;
    });
  }
}