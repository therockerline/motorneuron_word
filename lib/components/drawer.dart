import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neuron_word/pages/routes.dart';

class MyDrawer {
  static Widget build(BuildContext context){
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            padding: EdgeInsets.zero,
            child: Container(),
          ),
          ListTile(
            title: Text("Profilo"),
            onTap: () {
              Navigator.pushNamed(context,Routes.Account,);
            },
          ),
          ListTile(
            title: Text("Nuovo esercizio"),
            onTap: () {
              Navigator.pushNamed(context,Routes.Exercise,);
            },
          ),
          ListTile(
            title: Text("Sessioni"),
            onTap: () {
              Navigator.pushNamed(context,Routes.Sessions,);
            },
          ),ListTile(
            title: Text("Logout"),
            onTap: () {
              FirebaseAuth.instance.signOut().then((value) {
                Navigator.pushReplacementNamed(context,Routes.Login,);
              });
            },
          )
        ],
      ),
    );
  }
}