import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:neuron_word/controller/auth.dart';
import 'package:neuron_word/entity/exercise/exercise_data.dart';
import 'package:neuron_word/entity/mock_exercises.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;

class Network {
  static firebase_storage.FirebaseStorage _storage;
  static Network instance;


  Network(){
    if(Network.instance == null){
      Network._storage = firebase_storage.FirebaseStorage.instance;
      Network.instance = this;
    }
  }

  static Future<Uint8List> downloadFile(String url) async {
    return http.get(Uri.parse(url)).then((response) async {
      return response.bodyBytes;
    });
  }

  static uploadSession(SessionModel session) async {
    for(ExerciseData exercise in session.exercises){
      String baseUrl = '${FirebaseAuth.instance.currentUser.uid}(${Auth.user.name} ${Auth.user.surname})/${DateFormat("yyyy-MM-dd HH:mm:ss").format(session.startDate)}/';
      firebase_storage.Reference refV = _storage.ref('$baseUrl${exercise.videoFile.filename}${exercise.videoFile.extension}');
      try {
        var metadata = firebase_storage.SettableMetadata(
            //contentEncoding: "deflate",
            contentType: exercise.videoFile.mimeType,
            customMetadata: {
              "title": exercise.type,
              "duration": DateFormat("HH:mm:ss:SSS").format(DateTime.utc(0,0,0).add(exercise.executionTime)),
              //"videocodecid":".mkv",
              //"audiocodedid":".mka",
              //"videoframerate":"30",
              //"audiosamplerate":"",
              //"audiochannels":"1",
              "width":"1280",
              "height":"720",

            }
        );
        await refV.putData(exercise.videoFile.data, metadata);
      } on firebase_core.FirebaseException catch (e) {
        // e.g, e.code == 'canceled'
      }
    }
  }

  static Future<void> listStorage() async {
    firebase_storage.ListResult result = await _storage.ref().list(firebase_storage.ListOptions(maxResults: 10));

    result.items.forEach((firebase_storage.Reference ref) {
      print('Found file: $ref');
    });

    result.prefixes.forEach((firebase_storage.Reference ref) {
      print('Found directory: $ref');
    });

    /*
    if (result.nextPageToken != null) {
      firebase_storage.ListResult additionalResults = await firebase_storage
          .FirebaseStorage.instance
          .ref()
          .list(firebase_storage.ListOptions(
        maxResults: 10,
        pageToken: result.nextPageToken,
      ));
    }
     */
  }
}