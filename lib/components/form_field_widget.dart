import 'package:flutter/material.dart';
import 'package:neuron_word/controller/helper.dart';

class FormFieldWidget extends StatefulWidget {
  final FieldController fieldController;
  final String label;
  final bool obscuredText;
  FormFieldWidget({Key key, this.label, this.fieldController, this.obscuredText = false}) : super(key: key);

  @override
  _FormFieldWidgetState createState() {
    return _FormFieldWidgetState();
  }
}

class _FormFieldWidgetState extends State<FormFieldWidget> {
  bool isObscured = false;
  @override
  void initState() {
    super.initState();
    if(widget.obscuredText)
      isObscured = true;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return TextFormField(
      controller: widget.fieldController.controller,
      validator: widget.fieldController.validator,
      obscureText: isObscured,
      decoration: InputDecoration(
          labelText: widget.label,
          errorText: widget.fieldController.errorMessage,
          suffixIcon: getSuffixIcon()
      ),
      onChanged: (value) {
        setState(() {
          widget.fieldController.errorMessage = null;
        });
      },

    );
  }

  Widget getSuffixIcon() {
    if(widget.obscuredText){
      return FlatButton.icon(
        label: Container(),
        icon: Icon(isObscured ? Icons.visibility : Icons.visibility_off),
        onPressed: () {
          setState(() {
            isObscured = !isObscured;
          });
        },
      );
    }
    return null;
  }
}