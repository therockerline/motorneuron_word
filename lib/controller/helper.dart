import 'package:flutter/cupertino.dart';

enum RegexTypes {
  alphanumeric,
  numerical,
  alphabetical,
  symbols
}

//regex
final RegExp _alphanumerical = RegExp(r"^[a-zA-Z0-9]*$");
final RegExp _numerical = RegExp(r"^([0-9]*)$");
final RegExp _alphabetical = RegExp(r"^[a-zA-Z]*$");
final RegExp _symbols = RegExp(r'/[$-/:-?{-~!"^_`\[\]]/');

class FieldController{
  TextEditingController controller = TextEditingController();
  String errorMessage = "";
  String Function(String) validator;
  int _maxLength;
  int _minLength;

  String get value => controller.value.text;

  FieldController(this.validator, {int maxLength, int minLength}){
    this._maxLength = maxLength;
    this._minLength = maxLength;
  }

  factory FieldController.build({int maxLength, int minLength, int length, RegexTypes regexType}){
    return FieldController((value) {
      if (value.isEmpty)
        return "Il campo non può essere vuoto";
      else {
        if (maxLength != null)
          if (value.length > maxLength)
            return "Il campo non può superare i $maxLength caratteri";
        if (minLength != null)
          if (value.length < minLength)
            return "Il campo non può essere inferiore a $minLength caratteri";
        if (length != null) {
          if (value.length != length)
            return "Il campo deve contenere $length caratteri";
        }
        if(regexType != null){
          try {
            return _evaluateRegex(regexType, value);
          }catch(e){
            return "Errore di compilazione, se l'errore persiste contattare l'amministratore del servizio";
          }
        }
      }
      return null;
    },
        maxLength: maxLength ?? length,
        minLength: minLength ?? length,
    );
  }
  
  static String _evaluateRegex(RegexTypes regexType, String value){
      switch(regexType){
        case RegexTypes.alphanumeric:
          if(!_alphanumerical.hasMatch(value))
            return "Solo i caratteri alfanumerici sono consentiti";
        // TODO: Handle this case.
          break;
        case RegexTypes.numerical:
          if(!_numerical.hasMatch(value))
            return "Solo i caratteri numerici sono consentiti";
        // TODO: Handle this case.
          break;
        case RegexTypes.alphabetical:
          if(!_alphabetical.hasMatch(value))
            return "Solo i caratteri alfabetici sono consentiti";
        // TODO: Handle this case.
          break;
        case RegexTypes.symbols:
          if(!_symbols.hasMatch(value))
            return "Solo i caratteri simbolici sono consentiti";
        // TODO: Handle this case.
          break;
      }
      throw("Unhandled regexType");
  }

}