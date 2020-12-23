import 'package:firebase_auth/firebase_auth.dart';
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
          return FutureBuilder(
            future: Auth.awaitListener(),
            builder: (context, listenerSnapshot) {
              if(listenerSnapshot.hasError)
                return Container(child: Text("ERROR initialization"));
              if(listenerSnapshot.connectionState == ConnectionState.done) {
                return MaterialApp(
                  title: APP_NAME,
                  /*theme: ThemeData(
                    primarySwatch: Colors.blue,
                  ),*/
                  onGenerateRoute: Routes.onGenerateRoute,
                );
              }
              return showLoader();
            },
          );
        }
        return showLoader();
      },
    );
  }

  showLoader(){
    return Center(
      child: Container(
        width: 50,
        height: 50,
        child: CircularProgressIndicator(),
      ),
    );
  }
}

/*
class MyNav extends NavigatorObserver{

  @override
  void didPush(Route<dynamic> route, Route<dynamic> previousRoute) {
    print(["didPush", route.settings]);
    super.didPush(validate(route.settings), previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic> previousRoute) {
    print("didPop");
    super.didPop(validate(route.settings), previousRoute);
  }

  @override
  void didReplace({Route<dynamic> newRoute, Route<dynamic> oldRoute}) {
    print("didReplace");
    super.didReplace(newRoute: validate(newRoute.settings), oldRoute: oldRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic> previousRoute) {
    print("didRemove");
    super.didRemove(validate(route.settings), previousRoute);
  }

  Route<dynamic> validate(RouteSettings settings){
    String pageName = settings.name;
    print(["try",pageName, FirebaseAuth.instance.currentUser ]);
    if(FirebaseAuth.instance.currentUser != null) {
      if (pageName == Routes.Login || pageName == '/' || pageName == '') {
        pageName = Routes.Exercise;
      }
    }else{
      pageName = Routes.Login;
    }
    print(["gotopage",pageName]);
    return MaterialPageRoute(builder: (context) {
      print(["build",pageName]);
      Map<String, WidgetBuilder> routes = Routes.getRoutes();
      if(routes.keys.contains(pageName)) {
        print(routes[pageName]);
        return routes[pageName](context);
      }
      return routes["404"](context);
    });
  }
}
*/