import 'package:flutter/material.dart';
import 'package:neuron_word/components/form_field_widget.dart';
import 'package:neuron_word/controller/auth.dart';
import 'package:neuron_word/controller/hardware/display.dart';
import 'package:neuron_word/controller/helper.dart';
import 'package:neuron_word/entity/user/user_data.dart';
import 'package:neuron_word/entity/user/user_provider.dart';
import 'package:neuron_word/pages/routes.dart';
import 'package:provider/provider.dart';

class ContinueRegistrationPage extends StatefulWidget {
  ContinueRegistrationPage({Key key}) : super(key: key);

  @override
  _ContinueRegistrationPageState createState() {
    return _ContinueRegistrationPageState();
  }
}

class _ContinueRegistrationPageState extends State<ContinueRegistrationPage> {
  UserData _userData;
  final _formKey = GlobalKey<FormState>();

  final FieldController _nameController =     FieldController.build(maxLength: 15, regexType: RegexTypes.alphabetical);
  final FieldController _surnameController =  FieldController.build(maxLength: 15, regexType: RegexTypes.alphabetical);
  final FieldController _medicodeController = FieldController.build(length: 4, regexType: RegexTypes.alphanumeric);

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
    // TODO: implement build
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Container(
            width: Display.vw * 80,
            child: Column(
              children: [
                Form(
                  key: _formKey,
                  child: FocusScope(
                    node: FocusScopeNode(),
                    child: Column(
                      children: [
                        FormFieldWidget(label: "Nome", fieldController: _nameController,),
                        FormFieldWidget(label: "Cognome", fieldController: _surnameController,),
                        FormFieldWidget(label: "MediCode", fieldController: _medicodeController,),
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
                        onPressed: () { _save(); },
                        child: Text("Completa"),
                      )
                    ],
                  ),
                ),
              ]
            ),
          ),
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future<void> _save() async {
    if(_formKey.currentState.validate()){
      _userData = UserData(
          account: Auth.getFirebaseUser(),
          name: _nameController.value,
          surname: _surnameController.value,
          medicode: _medicodeController.value,
      );
      _userData = await UserProvider.addUserData(_userData);
      Auth.user = _userData;
      Navigator.pushReplacementNamed(
        context,
        Routes.Exercise,
      );
    } else
      setState(() {});
  }
}

