import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:neuron_word/entity/user/user_data.dart';

class Database{
  static Database instance;
  static FirebaseFirestore _firestore;
  static CollectionReference users;
  static CollectionReference exercises;


  Database(){
     if(Database.instance == null){
       _firestore = FirebaseFirestore.instance;
       users = _firestore.collection('users');
       exercises = _firestore.collection('exercises');
       Database.instance = this;
       print("database init");
    }
  }

  static Future<UserData> getUserData(User user) {
    print(user.uid);
    return users.where("uid", isEqualTo: user.uid).get().then((value) {
      if(value.docs.isNotEmpty){
        return UserData.fromJson(value.docs[0].data(), user);
      }
      return null;
    });
  }

}