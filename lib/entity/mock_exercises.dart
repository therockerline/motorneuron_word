import 'package:neuron_word/entity/exercise/exercise_data.dart';

class SessionModel {
  DateTime startDate;
  DateTime endDate;
  List<ExerciseData> exercises;

  SessionModel({this.startDate, this.endDate, this.exercises});

  factory SessionModel.start(){
    return SessionModel(startDate: DateTime.now());
  }
}

class Mock {
  static List<ExerciseData> mockExercises = [
    ExerciseData(type: "Resisti", text:"Vocalizza una \"a\"", hint: "aaaaaaaaaaaaaaaaaa", maxDuration: Duration(seconds: 5)),
    ExerciseData(type: "Ripeti velocemente", text:"Ripeti \"u-i\"", hint: "Ui, ui, ui, ui, ui, ui", duration: Duration(seconds: 5)),
    ExerciseData(type: "Muoviti velocemente", text:"Apri e chiudi la bocca", duration: Duration(seconds: 5), isVideo: true),
    ExerciseData(type: "Riposati", text:"Mantieni un'espressione neutrale", duration: Duration(seconds: 5),isVideo: true),
    ExerciseData(type: "Dimmi qualcosa", text:"Pronuncia questa frase:", hint:"Il temporale è cessato e la pioggia ormai non cade più", maxDuration: Duration(seconds: 5),),
  ];

  static List<SessionModel> sessions = [];
}