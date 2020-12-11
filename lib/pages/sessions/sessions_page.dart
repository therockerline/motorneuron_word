import 'package:flutter/material.dart';
import 'package:neuron_word/components/drawer.dart';

class SessionsPage extends StatefulWidget {
  SessionsPage({Key key}) : super(key: key);

  @override
  _SessionsPageState createState() {
    return _SessionsPageState();
  }
}

class _SessionsPageState extends State<SessionsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(),
      drawer: MyDrawer.build(context),
      body: Container(child: Text("Sessioni effettuate"),),
    );
  }
}