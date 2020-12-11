import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../routes.dart';

class EmailVerificationPage extends StatelessWidget {
  EmailVerificationPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Container(
        child: Column(
          children: [
            Text(" Ti abbiamo inviato un messaggio di verifica sulla casella di posta da te indicato. Per continuare è necessario attivare l'account seguendo il link nel messaggio."),
            FlatButton(
              child: Text("Se il messaggio non è arrivato clicca qui per inviarlo nuovamente"),
              onPressed: () {
                resendVerificationEmail();
              },
            ),
            RaisedButton(
              child: Text("Torna alla pagina di login"),
              onPressed: () {
                navigateToLogin(context);
              },
            )
          ],
        ),
      ),
    );
  }

  Future<void> resendVerificationEmail() async {
    if(!FirebaseAuth.instance.currentUser.emailVerified){
      await FirebaseAuth.instance.currentUser.sendEmailVerification();
    }
  }

  void navigateToLogin(BuildContext context) {
    Navigator.pushReplacementNamed(
        context,
        Routes.Login,
    );
  }
}
