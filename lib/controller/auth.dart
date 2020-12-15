import 'package:firebase_auth/firebase_auth.dart';
import 'package:neuron_word/entity/user/user_data.dart';
import 'package:neuron_word/entity/user/user_provider.dart';

class Auth {
  static Auth instance;
  static UserData user;

  Auth(){
    if(Auth.instance == null) {
      FirebaseAuth.instance.authStateChanges().listen((User user) async {
        if (user == null) {
          print('Init auth - User is currently signed out!');
        } else {
          print('Init auth - User is signed in!');
          await Auth.getUser(user: user);
        }
      });
      Auth.instance = this;
    }
  }

  static Future<void> getUser({User user}) async {
    if(user == null)
      user = FirebaseAuth.instance.currentUser;
    Auth.user = await UserProvider.getUserData(user);
  }

}