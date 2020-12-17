
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neuron_word/controller/hardware/display.dart';
import 'package:neuron_word/pages/account/account_page.dart';
import 'package:neuron_word/pages/account/settings/settings_page.dart';
import 'package:neuron_word/pages/continueRegistration/continue_registration.dart';
import 'package:neuron_word/pages/exercise/exercise_page.dart';
import 'package:neuron_word/pages/login/email_verification_page.dart';
import 'package:neuron_word/pages/login/login_page.dart';
import 'package:neuron_word/pages/sessions/sessions_page.dart';

class Routes {
  // Route name constants
  static const String Login = '/login';
  static const String Exercise = '/exercise';
  static const String Verification = '/verification';
  static const String Settings = '/settings';
  static const String Account = '/account';
  static const String Sessions = '/sessions';
  static const String ContinueRegistration = '/registration';

  static String currentRoute;

  static Route<dynamic> onGenerateRoute(RouteSettings settings){
    print(["page",settings]);
    String pageName = settings.name;
    if(FirebaseAuth.instance.currentUser != null) {
      //Auth.getUserData(FirebaseAuth.instance.currentUser);
      if (pageName == Routes.Login || pageName == '/' || pageName == '') {
        pageName = Routes.Exercise;
      }
    }else{
      pageName = Routes.Login;
    }
    currentRoute = pageName;
    return MaterialPageRoute(builder: (context) {
      print(["gotopage",pageName]);
      Display.context = context;
      return getRoutes()[pageName](context);
    });
  }

  /// The map used to define our routes, needs to be supplied to [MaterialApp]
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      Routes.Login: (context) => LoginPage(),
      Routes.Exercise: (context) => ExercisePage(),
      Routes.Verification: (context) => EmailVerificationPage(),
      Routes.Settings: (context) => SettingsPage(),
      Routes.Account: (context) => AccountPage(),
      Routes.Sessions: (context) => SessionsPage(),
      Routes.ContinueRegistration: (context) => ContinueRegistrationPage(),
    };
  }
}