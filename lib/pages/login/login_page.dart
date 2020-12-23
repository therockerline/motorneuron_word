import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_brand_icons/flutter_brand_icons.dart';
import 'package:neuron_word/components/form_field_widget.dart';
import 'package:neuron_word/controller/auth.dart';
import 'package:neuron_word/controller/hardware/display.dart';
import 'package:neuron_word/controller/helper.dart';
import 'package:neuron_word/pages/routes.dart';

import '../../environment.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final FieldController _emailController = FieldController.build(maxLength: 100,regexType: RegexTypes.email);
  final FieldController _pswController = FieldController.build(maxLength: 30, minLength: 4);

  String messageError;
  int errors = 0;
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
    Display.updateSize(context);
    double height =(Display.vh * 60) + (errors * 125);
    return Scaffold(
      body: Center(
        child: Card(
          //color: Colors.blueGrey.withOpacity(0.05),
          clipBehavior: Clip.antiAlias,
          child: Container(
            padding: EdgeInsets.all(32.0),
            //width: Display.vw * 40,
            //height: height,
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.shield),
                  title: Text("$APP_NAME"),
                  subtitle: const Text("Inserisci le tue credenziali di accesso o registra un nuovo account"),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: FocusScope(
                      node: FocusScopeNode(),
                      child: Column(
                        children: [
                          FormFieldWidget(label: "Username", fieldController: _emailController,),
                          FormFieldWidget(label: "Password",fieldController: _pswController, obscuredText: true,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              RaisedButton(
                                onPressed: () { _login(); },
                                elevation: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text("Login"),
                                ),
                              ),
                              FlatButton(
                                onPressed: () {_registration(); },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text("Usa queste credenziali\nper registrarti", textAlign: TextAlign.center,),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                if(messageError != null)
                  Text(messageError,style: TextStyle(color: Colors.red), textAlign: TextAlign.center,),
                Spacer(flex: 2,),
                Text("Oppure utilizza uno dei seguenti metodi per accedere", textAlign: TextAlign.center,),
                Padding(
                  padding: const EdgeInsets.only(top: 32.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        iconSize: 35,
                        icon: Icon(BrandIcons.google),
                        onPressed: () {
                          _loginWithGoogle();
                        },
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future<UserCredential> signInWithGoogle() async {
    // Create a new provider
    GoogleAuthProvider googleProvider = GoogleAuthProvider();

    googleProvider.addScope('https://www.googleapis.com/auth/contacts.readonly');
    googleProvider.setCustomParameters({
      'login_hint': 'user@example.com'
    });

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithPopup(googleProvider);

    // Or use signInWithRedirect
    // return await FirebaseAuth.instance.signInWithRedirect(googleProvider);
  }

  _loginWithGoogle() async {
    try {
      await signInWithGoogle();
      _navigate();
    }catch(e){
      print(e);
      setState(() {
        messageError = e;
      });
    }
  }

  _registration() async {
    try {
      _validate();
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.value,
          password: _pswController.value
      );
      User user = FirebaseAuth.instance.currentUser;
      await user.sendEmailVerification();
      _navigateToVerificationPage();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
        setState(() {
          _pswController.errorMessage = 'The password provided is too weak.';
        });
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
        setState(() {
          _emailController.errorMessage = 'The account already exists for that email.';
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        messageError = e;
      });
    }
  }

  _login() async {
    try {
      _validate();
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.value,
          password: _pswController.value
      );
      User user = FirebaseAuth.instance.currentUser;
      if (!user.emailVerified) {
        await user.sendEmailVerification();
        _navigateToVerificationPage();
      }else
        _navigate();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
        setState(() {
          _emailController.errorMessage = 'No user found for that email.';
        });
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
        setState(() {
          _pswController.errorMessage = 'Wrong password provided for that user.';
        });
      }
    }
  }

  _navigate() async {
    await Auth.getUser();
    print(["USER", Auth.user]);
    if(Auth.user?.name == null){
      Navigator.pushNamed(
        context,
        Routes.ContinueRegistration
      );
    }else {
      Navigator.pushReplacementNamed(
        context,
        Routes.Exercise,
      );
    }
  }

  _navigateToVerificationPage(){
    Navigator.pushNamed(
        context,
        Routes.Verification,
    );
  }

  void _validate(){
    setState(() {
      messageError = null;
      _pswController.errorMessage = null;
      _emailController.errorMessage = null;
    });
    bool isValid = _formKey.currentState.validate();
    setState(() {
      errors = (_pswController.errorMessage != null ? 1: 0 ) + (_emailController.errorMessage != null ? 1: 0) +  (messageError != null ? 1: 0 );
    });
    if(!isValid) {
      throw("Error on validation");
    }
  }

}