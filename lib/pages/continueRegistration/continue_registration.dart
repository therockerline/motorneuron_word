import 'package:flutter/material.dart';
import 'package:neuron_word/controller/hardware/display.dart';
import 'package:neuron_word/controller/helper.dart';
import 'package:neuron_word/entity/user/user_data.dart';

class ContinueRegistrationPage extends StatefulWidget {
  ContinueRegistrationPage({Key key}) : super(key: key);

  @override
  _ContinueRegistrationPageState createState() {
    return _ContinueRegistrationPageState();
  }
}

class _ContinueRegistrationPageState extends State<ContinueRegistrationPage> {
  UserData _userData;

  final FieldController _nameController = FieldController();
  final FieldController _surnameController = FieldController();
  final FieldController _medicodeController = FieldController();

  String messageError = "";

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
                  child: FocusScope(
                    node: FocusScopeNode(),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController.controller,
                          decoration: InputDecoration(
                            labelText: 'Nome',
                            errorText: _nameController.errorMessage
                          ),
                        ),
                        TextFormField(
                          controller: _surnameController.controller,
                          decoration: InputDecoration(
                            labelText: 'Cognome',
                            errorText: _surnameController.errorMessage
                          ),
                        ),
                        TextFormField(
                          controller: _medicodeController.controller,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'MediCode',
                            errorText: _medicodeController.errorMessage
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
                        onPressed: () { _save(); },
                        child: Text("login"),
                      )
                    ],
                  ),
                ),
                if(messageError != null)
                  Text(messageError),
              ]
            ),
          ),
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _save() {
    //if(_nameController.controller.value.isComposingRangeValid)
  }
}

