import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:neuron_word/controller/auth.dart';
import 'package:neuron_word/controller/database.dart';
import 'package:neuron_word/entity/exercise/exercise_provider.dart';
import 'package:neuron_word/pages/login/login_page.dart';
import 'package:neuron_word/pages/routes.dart';
import 'package:provider/provider.dart';

import 'controller/hardware/display.dart';
import 'controller/network.dart';
import 'environment.dart';

Future<void> main() async {
  runApp(
      MultiProvider(
          providers: [
            ChangeNotifierProvider<ExerciseProvider>(
                create: (context) => ExerciseProvider(),
            ),
          ],
          child: App(),
      )
  );
}

class App extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if(snapshot.hasError)
          return Container(child: Text("ERROR initialization"));
        if(snapshot.connectionState == ConnectionState.done) {
          Network();
          Database();
          Auth();
          return MaterialApp(
            title: APP_NAME,
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            routes: Routes.getRoutes(),
            //initialRoute: Routes.Login,
            onGenerateRoute: Routes.onGenerateRoute,

            //home: LoginPage(),
          );
        }
        return CircularProgressIndicator();
      },
    );
  }
}
