import 'package:flutter/cupertino.dart';

enum RegexTypes {
  alphanumeric,
  numerical,
  alphabetical,
  symbols,
  email
}

//regex
final RegExp _alphanumerical = RegExp(r"^[[:alnum:]àèéìòù]*$");
final RegExp _alphanumerical_space = RegExp(r"^[[:alnum:]àèéìòù\s]*$");
final RegExp _numerical = RegExp(r"^([[:digit:]]*)$");
final RegExp _numerical_space = RegExp(r"^([[:digit:]\s]*)$");
final RegExp _alphabetical = RegExp(r"^[[:alpha:]]]*$");
final RegExp _alphabetical_space = RegExp(r"^[[:alpha:]]\s]*$");
final RegExp _symbols = RegExp(r'^((?![àèéìòù])[\W])*$');
final RegExp _email = RegExp(r"^[[:alnum:]_.+-]+@[[:alnum:]-]+\.[[:alnum:]-.]+$");

class FieldController{
  TextEditingController controller = TextEditingController();
  String errorMessage;
  String Function(String) validator;
  bool _allowSpace;
  int _maxLength;
  int _minLength;

  String get value => controller.value.text;

  FieldController(this.validator, {int maxLength, int minLength, bool allowSpace}){
    this._maxLength = maxLength;
    this._minLength = maxLength;
    this._allowSpace = allowSpace;
  }

  factory FieldController.build({int maxLength, int minLength, int length, RegexTypes regexType, bool allowSpace = true}){
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
            return _evaluateRegex(regexType, value, allowSpace: allowSpace);
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
  
  static String _evaluateRegex(RegexTypes regexType, String value, {bool allowSpace}){
    String spaceAlert = allowSpace ? "" : ", lo spazio non è consentito";
      switch(regexType){
        case RegexTypes.alphanumeric:
          if(!(allowSpace ? _alphanumerical_space : _alphanumerical).hasMatch(value))
            return "Solo i caratteri alfanumerici sono consentiti$spaceAlert";
        // TODO: Handle this case.
          break;
        case RegexTypes.numerical:
          if(!(allowSpace ? _numerical_space : _numerical).hasMatch(value))
            return "Solo i caratteri numerici sono consentiti$spaceAlert";
        // TODO: Handle this case.
          break;
        case RegexTypes.alphabetical:
          if(!(allowSpace ? _alphabetical_space : _alphabetical).hasMatch(value))
            return "Solo i caratteri alfabetici sono consentiti$spaceAlert";
        // TODO: Handle this case.
          break;
        case RegexTypes.symbols:
          if(!_symbols.hasMatch(value))
            return "Solo i caratteri simbolici sono consentiti";
        // TODO: Handle this case.
          break;
        case RegexTypes.email:
          // TODO: Handle this case.
          if(!_email.hasMatch(value))
            return "L'email inserita non è corretta";
          break;
        default: throw("Unhandled regexType");
      }
  }

}