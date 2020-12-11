import 'dart:async';
import 'dart:html';

enum WebcamEvent {
  startRec,
  stopRec,
  pauseRec
}

class WebcamRecorder{
  static String mimeType = "video/webm";
  static String extension = '.webm';
  MediaRecorder _videoRecorder;
  Map<dynamic, dynamic> _mediaRecorderOption = {
    "mimeType": "$mimeType;codecs=h264,vp9,opus",
    "bitPerSecond": 2500000
  };
  WebcamEvent state;
  Future<void> Function(Blob) _onDataAvailable;
  Stream<WebcamEvent> _recorderStreamSubscription;
  StreamController<WebcamEvent>  _recorderStreamController = StreamController<WebcamEvent>.broadcast();
  bool _isBusy;

  WebcamRecorder();

  void init(MediaStream stream, VideoElement webcamVideoElement){
    _videoRecorder = new MediaRecorder(stream, _mediaRecorderOption);
    _videoRecorder.addEventListener('dataavailable', (dataBlob) async {
      if(_onDataAvailable!= null) {
        BlobEvent be = (dataBlob as BlobEvent);
        await _onDataAvailable(be.data);
      }
      _isBusy = false;
    });
    _recorderStreamSubscription = _recorderStreamController.stream;
    _recorderStreamSubscription.listen((WebcamEvent event) {
      state = event;
      switch(event){
        case WebcamEvent.startRec:
          if(webcamVideoElement.srcObject.active) {
            webcamVideoElement.play();
            webcamVideoElement.hidden = false;
            _videoRecorder.start();
          }
          break;
        case WebcamEvent.stopRec:
          print(_videoRecorder.state);
          webcamVideoElement.hidden = true;
          webcamVideoElement.pause();
          if(_videoRecorder.state !='inactive') {
            _videoRecorder.stop();
          }
          break;
        case WebcamEvent.pauseRec:
          print(["onDataAvailable(video)!=null",_onDataAvailable!=null, webcamVideoElement.srcObject.active]);
          if(_videoRecorder.state !='inactive') {
            //webcamVideoElement.pause();
            _videoRecorder.stop();
          }
          break;
      }
    });
  }

  void onDataAvailable(Future<void> Function(Blob) onDataAvailable) {
    _onDataAvailable = onDataAvailable;
  }


  startRec(){
    _recorderStreamController.sink.add(WebcamEvent.startRec);
  }


  Future<void> pauseRec() {
    _isBusy = true;
    _recorderStreamController.sink.add(WebcamEvent.pauseRec);
    return Future.doWhile(() {
      return Future.delayed(Duration(microseconds: 100), () => _isBusy);
    });
  }


  stopRec(){
    _recorderStreamController.sink.add(WebcamEvent.stopRec);
  }


  dispose(){
    _recorderStreamController.close();
  }

}