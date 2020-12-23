import 'dart:async';
import 'dart:html';

enum WebcamEvent {
  startRec,
  stopRec,
  pauseRec
}

class WebcamRecorder{
  List<String> mimeTypes = [
    "webm",
    "mpeg"
  ];

  List<String> codecs = [
    "h265"
    "h264",
    "vp9",
    "vp8",
    "opus",
    "daala",
  ];

  static String videoType;
  static String codecType;
  static String extension;
  MediaRecorder _videoRecorder;
  Map<dynamic, dynamic> _mediaRecorderOption = {
    "mimeType": null,
    //"bitPerSecond": 2500000
  };
  WebcamEvent state;
  Future<void> Function(Blob) _onDataAvailable;
  Stream<WebcamEvent> _recorderStreamSubscription;
  StreamController<WebcamEvent>  _recorderStreamController = StreamController<WebcamEvent>.broadcast();
  bool _isBusy;

  WebcamRecorder();

  void init(MediaStream stream, VideoElement webcamVideoElement){
    for(String _videoType in mimeTypes){
      for (String _codecType in codecs) {
        var type = "video/$_videoType;codecs=$_codecType";
        if(MediaRecorder.isTypeSupported(type)){
          videoType ="video/$_videoType";
          codecType ="codecs=$_codecType";
          extension=".$videoType";
          _mediaRecorderOption["mimeType"] = type;
          break;
        }
      }
    }
    if(_mediaRecorderOption["mimeType"] == null){
      throw("NO SUPPORTED TYPE");
    }else {
      print(["MEDIA_RECORDER_OPTIONS", _mediaRecorderOption]);
      _videoRecorder = new MediaRecorder(stream, _mediaRecorderOption);
      _videoRecorder.addEventListener('dataavailable', (dataBlob) async {
        if (_onDataAvailable != null) {
          BlobEvent be = (dataBlob as BlobEvent);
          await _onDataAvailable(be.data);
        }
        _isBusy = false;
      });
      _recorderStreamSubscription = _recorderStreamController.stream;
      _recorderStreamSubscription.listen((WebcamEvent event) {
        state = event;
        switch (event) {
          case WebcamEvent.startRec:
            if (webcamVideoElement.srcObject.active) {
              _videoRecorder.start();
            }
            break;
          case WebcamEvent.stopRec:
            print(_videoRecorder.state);
            if (_videoRecorder.state != 'inactive') {
              _videoRecorder.stop();
            }
            break;
          case WebcamEvent.pauseRec:
            print([
              "onDataAvailable(video)!=null",
              _onDataAvailable != null,
              webcamVideoElement.srcObject.active
            ]);
            if (_videoRecorder.state != 'inactive') {
              //webcamVideoElement.pause();
              _videoRecorder.stop();
            }
            break;
        }
      });
    }
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