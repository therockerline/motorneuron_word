import 'dart:typed_data';

class ExerciseVideoFile {
    Uint8List data;
    String url;
    String filename;
    String mimeType;
    String extension;

    ExerciseVideoFile({this.data, this.filename, this.mimeType, this.extension, this.url});
}

class ExerciseData {
    Duration duration;
    String hint;
    bool isVideo;
    Duration maxDuration;
    String text;
    String type;
    Duration _executionTime;
    ExerciseVideoFile _videoFile;
    ExerciseVideoFile get videoFile => _videoFile;

    set videoFile(ExerciseVideoFile value) {
        _videoFile = value;
    }

    Duration get executionTime => _executionTime;

    set executionTime(Duration value) {
      _executionTime = value;
    }

    ExerciseData({this.duration, this.hint, this.maxDuration, this.text, this.type, this.isVideo = false});

    factory ExerciseData.fromJson(Map<String, dynamic> json) {
        return ExerciseData(
            duration: json['duration'] != null ? Duration(milliseconds: json['duration']) : null,
            hint: json['hint'],
            isVideo: json['isVideo'] ?? false,
            maxDuration: json['maxDuration'] != null ? Duration(milliseconds: json['maxDuration']) : null,
            text: json['text'],
            type: json['type'],
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        if(this.duration!=null)
          data['duration'] = this.duration.inMilliseconds;
        if(this.maxDuration!=null)
          data['maxDuration'] = this.maxDuration.inMilliseconds;
        if(this.hint!=null)
          data['hint'] = this.hint;
        data['isVideo'] = this.isVideo;
        data['text'] = this.text;
        data['type'] = this.type;
        return data;
    }
}