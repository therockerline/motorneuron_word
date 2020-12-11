import 'package:flutter/material.dart';
import 'package:neuron_word/controller/database.dart';
import 'package:neuron_word/entity/exercise/exercise_data.dart';
class ExerciseProvider extends ChangeNotifier{

  Future<List<ExerciseData>> getExercises() async {
    return await Database.exercises.get().then((value) {
      if(value.docs.isNotEmpty){
        List<ExerciseData> data = [];
        value.docs.forEach((element) {
          data.add(ExerciseData.fromJson(element.data()));
        });
        return data;
      }
      return [];
    });
  }

}