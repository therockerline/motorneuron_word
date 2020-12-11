import 'dart:async';
import 'package:microphone/microphone.dart';

import '../network.dart';

enum MicrophoneEvent {
  startRec,
  stopRec,
  pauseRec
}

class MicrophoneController{
  // Create and initialize a microphone recorder.
  MicrophoneRecorder _audioRecorder;

  Stream<MicrophoneEvent> _recorderStreamSubscription;
  StreamController<MicrophoneEvent>  _recorderStreamController = StreamController<MicrophoneEvent>.broadcast();
  bool _isBusy = false;
  MicrophoneEvent state;
  Function(Map<String,dynamic>) _onDataAvailable;

  MicrophoneController(){
    _audioRecorder = MicrophoneRecorder()
      ..init();
    _recorderStreamSubscription = _recorderStreamController.stream;
    _recorderStreamSubscription.listen((MicrophoneEvent event) async {
      state = event;
      switch(event){
        case MicrophoneEvent.startRec:
          _audioRecorder?.dispose();
          _audioRecorder = MicrophoneRecorder();
          await _audioRecorder.init();
          await _audioRecorder.start();
          break;
        case MicrophoneEvent.stopRec:
          await _audioRecorder.stop();
          break;
        case MicrophoneEvent.pauseRec:
          await _audioRecorder.stop();
          _isBusy = true;
          print(["onDataAvailable(audio)!=null",_onDataAvailable!=null]);
          if(_onDataAvailable != null)
            Network.downloadFile(_audioRecorder.value.recording.url).then((bytes) {
              _onDataAvailable({
                "bytes": bytes,
                "url": _audioRecorder.value.recording.url
              });
              _isBusy = false;
              print("audio file created");
            });
          else
            _isBusy = false;
          break;
      }
    });
  }

  onDataAvailable(Function(Map<String,dynamic>) onDataAvailable){
    _onDataAvailable = onDataAvailable;
  }

  startRec(){
    _recorderStreamController.sink.add(MicrophoneEvent.startRec);
  }

  Future<void> pauseRec() {
    _isBusy = true;
    _recorderStreamController.sink.add(MicrophoneEvent.pauseRec);
    return Future.doWhile(() {
      return Future.delayed(Duration(microseconds: 100), () => _isBusy);
    });
  }

  stopRec(){
    _recorderStreamController.sink.add(MicrophoneEvent.stopRec);
  }

  dispose(){
    _audioRecorder?.dispose();
    _recorderStreamController.close();
  }
}