import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_brand_icons/flutter_brand_icons.dart';
import 'package:neuron_word/controller/auth.dart';
import 'package:neuron_word/controller/hardware/display.dart';
import 'package:neuron_word/pages/routes.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pswController = TextEditingController();

  String messageError;
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
    Display.updateSize(size: MediaQuery.of(context).size);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Container(
            width: Display.vw * 80,
            child: Column(
              children: [
                Form(
                  child: FocusScope(
                    node: FocusScopeNode(),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                              labelText: 'Email'
                          ),
                        ),
                        TextFormField(
                          controller: _pswController,
                          obscureText: true,
                          decoration: InputDecoration(
                              labelText: 'Password'
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      RaisedButton(
                        onPressed: () { _login(); },
                        child: Text("login"),
                      ),
                      FlatButton(
                        onPressed: () {_registration(); },
                        child: Text("registrati"),
                      )
                    ],
                  ),
                ),
                if(messageError != null)
                  Text(messageError),
                Spacer(),
                Text("Oppure utilizza uno dei seguenti metodi per accedere"),
                Row(
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
                Spacer(flex:2),
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
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.value.text,
          password: _pswController.value.text
      );
      User user = FirebaseAuth.instance.currentUser;
      await user.sendEmailVerification();
      _navigateToVerificationPage();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
        setState(() {
          messageError = 'The password provided is too weak.';
        });
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
        setState(() {
          messageError = 'The account already exists for that email.';
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
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.value.text,
          password: _pswController.value.text
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
          messageError = 'No user found for that email.';
        });
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
        setState(() {
          messageError = 'Wrong password provided for that user.';
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

  _navigateToContinueRegistrationPage(){
    Navigator.pushNamed(
      context,
      Routes.Verification,
    );
  }
}