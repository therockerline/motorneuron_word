import 'package:flutter/material.dart';
import 'package:neuron_word/components/drawer.dart';
import 'package:neuron_word/controller/auth.dart';

import '../routes.dart';

class AccountPage extends StatelessWidget {
  AccountPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("Account ${Auth.user?.account?.email}"),
        actions: [

        ],
      ),
      drawer: MyDrawer.build(context),
      body: Center(
        child: Column(
          children: [
            FlatButton(
              child: Column(
                children: [
                  Icon(Icons.settings),
                  Text("Settings")
                ],
              ),
              onPressed:() { openSettings(context); },
            )
          ],
        )
      )
    );
  }

  void openSettings(BuildContext context) {
    Navigator.pushNamed(
      context,
      Routes.Settings,
    );
  }
}
