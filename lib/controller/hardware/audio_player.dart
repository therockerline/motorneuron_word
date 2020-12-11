import 'package:just_audio/just_audio.dart';
class WebAudioPlayer{
  AudioPlayer _audioPlayer;

  WebAudioPlayer(){
    _audioPlayer = AudioPlayer();
  }


  Future<void> playAudio(String url) async {
    await _audioPlayer.setUrl(url);
    await _audioPlayer.play();
    return _audioPlayer.durationFuture;
  }

  Future<void> stopAudio() async {
    return _audioPlayer.stop();
  }
}