// ignore: avoid_web_libraries_in_flutter
import 'dart:html';
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:neuron_word/components/drawer.dart';
import 'package:neuron_word/components/webcam_viewer.dart';
import 'package:neuron_word/controller/auth.dart';
import 'package:neuron_word/controller/hardware/audio_player.dart';
import 'package:neuron_word/controller/hardware/display.dart';
import 'package:neuron_word/controller/hardware/webcam_recorder.dart';
import 'package:neuron_word/controller/network.dart';
import 'package:neuron_word/entity/exercise/exercise_data.dart';
import 'package:neuron_word/entity/exercise/exercise_provider.dart';
import 'package:neuron_word/entity/mock_exercises.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

enum ExerciseStates{
  awaiting,
  countdown,
  resetCountdown,
  execution,
  completed
}

class ExercisePage extends StatefulWidget {
  ExercisePage({Key key}) : super(key: key);

  @override
  _ExercisePageState createState() {
    return _ExercisePageState();
  }
}

class _ExercisePageState extends State<ExercisePage> {
  final Key webcamKey = UniqueKey();
  WebAudioPlayer webAudioPlayer;
  //MicrophoneController microphoneController = MicrophoneController();
  WebcamRecorder webcamRecorder;
  WebcamViewer webcamViewer;
  ExerciseStates state = ExerciseStates.awaiting;

  int millis = 15; //passo dell'animazione in millisecondi
  DateTime elapsedTime = DateTime.fromMillisecondsSinceEpoch(0); //tempo attuale dell'esercizio
  DateTime startTime = DateTime.fromMillisecondsSinceEpoch(0); //tempo attuale dell'esercizio
  Timer timer; //entità per la misurazione del tempo
  int step = 0; // esercizio attualmente visualizzato
  bool isStarted = false; //flag per capire se la sessione è stata avviata o meno
  bool isAwait = false; //flag per impedire all'utente di continuare finchè il file non viene scaricato

  double vh; //1% altezza device
  double vw; //1% larghezza device

  int maxCountdown = 0;
  Timer countdownTimer;
  String countdown = '';
  String _userName = "";

  double progress;

  List<ExerciseData> exercises = []; //esercizi da effettuare
  ExerciseProvider _exerciseProvider;
  SessionModel session;

  bool _isBusy = true;
  bool _isAudioPlaying = false;

  //debug
  int _elapsed=0;

  @override
  void initState() {
    super.initState();
    webAudioPlayer  = WebAudioPlayer();
    webcamRecorder  = WebcamRecorder();
    vh = Display.vh;
    vw = Display.vw;
    _exerciseProvider = Provider.of<ExerciseProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Auth.getUser();
      setState(() {
        _userName = "${Auth.user?.name} ${Auth.user?.surname}";
        webcamViewer = WebcamViewer(webcamKey: webcamKey, onStreamAvailable: (stream, webcamVideoElement) {
          print("stream attached");
          setState(() {
            _isBusy = false;
          });
          webcamRecorder.init(stream, webcamVideoElement);
          //avvio il video
          if(webcamVideoElement.srcObject.active)
            webcamVideoElement.play();
        },
          width: vw * 100,
          height: vh * 100,
        );
      });
      print("sono pronto");
      exercises = await _exerciseProvider.getExercises();
      //l'evento si scatena quando il video viene messo in pausa
      webcamRecorder.onDataAvailable((Blob blob) async {
        print(["save video file", step]);
        //arrivato qui lo step è stato già incrementato
        String url = Url.createObjectUrlFromBlob(blob);
        Uint8List bytes = await Network.downloadFile(url);
        exercises[step].videoFile = ExerciseVideoFile(
          filename: "Step_${step+1}(${exercises[step].type})",
          data: bytes,
          url: url,
          mimeType: WebcamRecorder.mimeType,
          extension: WebcamRecorder.extension
        );
      });
      newSession();
    });
  }


  @override
  void dispose() {
    // Dispose the microphone recorder.
    //microphoneController.dispose();
    webcamRecorder.dispose();
    timer.cancel();
    countdownTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget result = Container();
    String titleText = "Benvenuto\nPremi il tasto play per iniziare";
    Color textColor = Colors.white;
    if(exercises.length>0) {
      switch (state) {
        case ExerciseStates.awaiting:
          if(step>0)
            titleText = exercises[step].type;
          result = getButton(startExercise, Icons.play_arrow);
          break;
        case ExerciseStates.countdown:
          titleText = exercises[step].type;
          result = getButton(pauseCountdown, Icons.play_disabled);
          break;
        case ExerciseStates.resetCountdown:
          titleText = exercises[step].type;
          result = getButton(startExercise, Icons.play_arrow);
          break;
        case ExerciseStates.execution:
          titleText = exercises[step].type;
          result = getButton(completeExercise, Icons.stop);
          break;
        case ExerciseStates.completed:
          if (step == exercises.length) {
            titleText = "Fine della sessione\nPremi il tasto in basso per\niniziarne una nuova";
            result = getButton(newSession, Icons.replay);
          }else {
            titleText = "${exercises[step].type}";
            result = getButton(startExercise, Icons.play_arrow);
          }
          break;
      }
    }
    bool showComponent = state != ExerciseStates.awaiting && step < exercises.length;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Color(0x44000000),
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(_userName),
        /*actions: [
          RaisedButton(
            child: Text("Abort"),
            onPressed: () {
              abort();
            },
          )
        ],*/
      ),
      drawer: MyDrawer.build(context),
      body: Center(
        child: Container(
          width: vw*100,
          child: Stack(
            alignment: Alignment.center,
            fit: StackFit.loose,
            children: [
              Positioned(
                top: 0,
                left: 0,
                width: 100 * vw,
                height: 100 * vh,
                child: webcamViewer ?? Container()
              ),
              Positioned(
                top:  150,
                height: vh * 100 - 350,
                width: vw * 80,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(titleText, style: TextStyle(fontSize: 32, color: textColor), textAlign: TextAlign.center,),
                    if(showComponent)
                      ...[
                        Spacer(flex: 2,),
                        Text(exercises[step]?.text ?? "", style: TextStyle(fontSize: 32, color: textColor), textAlign: TextAlign.center,),
                        Spacer(flex: 1,),
                        Text(exercises[step]?.hint ?? "", style: TextStyle(fontSize: 32, color: textColor), textAlign: TextAlign.center,),
                        Spacer(flex: 5,),
                      ]
                  ],
                )
              ),
              Positioned(
                bottom: 0,
                child: Container(
                  height: vh*30,
                  width: vw*100,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if(state == ExerciseStates.countdown)
                        Positioned(
                            bottom: vh*20,
                            child: Text(countdown, style: TextStyle(fontSize: 52, color: textColor), textAlign: TextAlign.center,)
                        ),
                      if((state == ExerciseStates.completed || state == ExerciseStates.resetCountdown) && step < exercises.length)
                        Positioned(
                          bottom: vh*20,
                          child: Container(
                            //height: vh*30,
                            width: vw*80,
                            //color: Colors.deepPurple,
                            child: Text("Quando sei pronto premi il tasto play per iniziare il nuovo esercizio", style: TextStyle(fontSize: 20, color: textColor), textAlign: TextAlign.center,),
                          ),
                        ),
                      if(state == ExerciseStates.completed && false)
                        Positioned(
                          bottom: vh*5,
                          right: vw*5,
                          child: getButton(() {
                              if(_isAudioPlaying)
                                stopAudio();
                              else
                                playAudio();
                            },
                            _isAudioPlaying ? Icons.volume_off : Icons.volume_up,
                            sizeMultiplier: 6,
                            color: _isAudioPlaying ? Colors.red : Colors.white
                          )
                        ),
                      if(state == ExerciseStates.execution)
                        ...getTimeVisualizer(exercises[step]),
                      Positioned(
                        bottom: vh * 7.5,
                        child: result
                      )
                    ],
                  )
                )
              ),
              Positioned(
                  bottom: 0,
                  child: Container(
                      width: vw*100,
                      //color: Colors.blueGrey,
                      child: LinearProgressIndicator(
                        minHeight: 10,
                        backgroundColor: Colors.white,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.deepOrangeAccent),
                        value: exercises.length > 0 ? (step / exercises.length) : 0,
                      )
                  )
              ),
              getDebug()
            ],
          ),
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void playAudio(){
    if(!_isAudioPlaying) {
      print("play audio");
      setState(() {
        _isAudioPlaying = true;
      });
      print([step, exercises[step - 1].videoFile != null, _isAudioPlaying]);
      webAudioPlayer.playAudio(exercises[step - 1].videoFile.url).then((value) {
        print("audio finish");
        setState(() {
          _isAudioPlaying = false;
        });
      });
    }
  }

  void stopAudio(){
    print("stop audio");
    webAudioPlayer.stopAudio().then((value) {
      setState(() {
        _isAudioPlaying = false;
      });
    });
  }

  void newSession() {
    // Init recording audio/video.
    if(_isAudioPlaying){
      stopAudio();
    }
    exercises.forEach((element) {
      //element.audioFile = null;
      element.videoFile = null;
      element.executionTime = null;
    });
    setState(() {
      step = 0;
      isStarted = false;
      state = ExerciseStates.awaiting;
    });
  }

  void startExercise() {
    //controllo se è il primo avvio
    if (!isStarted) {
      setState(() {
        isStarted = true;
      });
      //salvo il momento di inizio
      session = SessionModel.start();
    }
    //faccio partire il countdown
    if(maxCountdown > 0) {
      setState(() {
        countdown = "$maxCountdown";
        state = ExerciseStates.countdown;
      });
      countdownTimer = Timer.periodic(Duration(seconds: 1), (sec) {
        setState(() {
          countdown = "${maxCountdown - sec.tick}";
        });
        if (sec.tick == maxCountdown) {
          executeExercise();
        }
      });
    }else{
      executeExercise();
    }
  }

  executeExercise(){
    countdownTimer?.cancel();
    // facio partire la registrazione audio/video
    webcamRecorder.startRec();
    //microphoneController.startRec();
    ExerciseData exercise = exercises[step];
    startTime = DateTime.now();
    //faccio partire il timer
    timer = Timer.periodic(Duration(milliseconds: millis), (period) {
      Duration time = Duration(milliseconds: period.tick * millis);
      if (exercise.duration != null || exercise.maxDuration != null) {
        double _progress = 0;
        _elapsed = time.inMilliseconds;
        _progress = time.inMilliseconds / (exercise.duration ?? exercise.maxDuration).inMilliseconds;
        setState(() {
          elapsedTime = startTime.add(time);
          progress = exercise.duration != null ? _progress : null;
        });
        if (_progress >= 1) {
          completeExercise();
        }
      } else {
        setState(() {
          elapsedTime = startTime.add(time);
        });
      }
    });
    //metto l'esercizio in esecuzione
    setState(() {
      state = ExerciseStates.execution;
      elapsedTime = startTime;
      progress = 0;
    });
  }

  Future<void> completeExercise() async {
    // Stop timer
    timer.cancel();
    // finito l'esercizio salvo il tempo di esecuzione
    exercises[step].executionTime = elapsedTime.difference(startTime);

    setState(() {
      _isBusy = true;
    });

    Future.delayed(Duration(seconds: 1), () async {
      //pausa audio e video (questo scatenerà il listener e verranno salvati i dati su exercises[step]
      await webcamRecorder.pauseRec();
      //await microphoneController.pauseRec();
      int _step = step;
      _step++;
      setState(() {
        state = ExerciseStates.completed;
        step = _step;
      });
      if(_step == exercises.length) {
        //la sessione di esercizi è finita
        endSession();
      } else {
        setState(() {
          _isBusy = false;
        });
      }
    });
  }

  Future<void> endSession() async {
    print("END SESSION");
    webcamRecorder.stopRec();
    //microphoneController.stopRec();

    session.exercises = exercises;
    session.endDate = DateTime.now();
    //conclusa la sessione la devo salvare e inviare
    await Network.uploadSession(session);
    //Mock.sessions.add(session);
    session = null;
    setState(() {
      _isBusy=false;
    });
  }

  getButton(Function callback, IconData icon, { Color color = Colors.white, int sizeMultiplier = 10}){
    return RaisedButton(
        shape: CircleBorder(),
        elevation: 4,
        color: Colors.transparent,
        child: Container(
          width: vh * sizeMultiplier,
          height: vh * sizeMultiplier,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(icon,
                color: _isBusy ? Colors.grey : null
              ),
              if(_isBusy)
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.deepOrangeAccent),
                    ),
                  ),
                ),

            ],
          ),
          decoration: ShapeDecoration(
            shape: CircleBorder(),
            color: color,
          ),
        ),
        onPressed: () {
          if(!_isBusy)
            callback();
        }
    );
  }

  List<Widget> getTimeVisualizer(ExerciseData exercise) {
    //print(progress);
    return [
      Positioned(
        bottom: vh * 2.5,
        child: Container(
          width: vw*70,
          child: LinearProgressIndicator(
            minHeight: 30,
            backgroundColor: Colors.white,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.deepOrangeAccent),
            value: progress,
          )
        )
      ),
      Positioned(
        bottom: vh * 2.5 + 7,
        child: Text("${DateFormat('ss.SSS').format(DateTime.utc(0).add(elapsedTime.difference(startTime)))}"),
      ),
    ];
  }

  pauseCountdown() {
    countdownTimer.cancel();
    setState(() {
      countdown = "$maxCountdown";
      state = ExerciseStates.resetCountdown;
    });
  }

  getDebug() {
    return Positioned(
        top: 50,
        left: 10,
        child: Container(
            width: vw*100,
            //color: Colors.blueGrey,
            child: Text(
              "Debug:\n"
                  "State:$state\n"
                  "Step:$step\n"
                  "Exercises:${exercises.length}\n"
                  "VideoRec:${webcamRecorder.state}\n"
                  "Milliseconds:${_elapsed}\n"
                  "Started:${startTime}\n"
                  "Elapsed:${elapsedTime}\n"
                  //"AudioRec:${microphoneController.state}\n"
                  "session:\n"
                  "\tstart:${session?.startDate?.toIso8601String()}\n"
                  "\texercises:${session?.exercises?.length}\n" +
                  (exercises.length > 0 && step<exercises.length ?
                  "exercise:\n"
                      "\tmetadataDuration:${DateFormat("HH:mm:ss:SSS").format(DateTime.utc(0).add(exercises[step]?.executionTime ?? Duration(seconds: 0)))}\n"
                      "\tduration:${exercises[step]?.duration?.inSeconds}\n"
                      "\tmaxDuration:${exercises[step]?.maxDuration?.inSeconds}\n"
                      "\tisVideo:${exercises[step]?.isVideo}\n"
                      //"\ta_fn:${exercises[step]?.audioFile?.filename}\n"
                      "\tvideo:${exercises[step]?.videoFile?.filename}\n"
                      "\telapsedTime:${exercises[step]?.executionTime?.inMilliseconds}\n"
                      : "no exercise"),
              style: TextStyle(fontSize: 12, color: Colors.red), textAlign: TextAlign.left,)
        )
    );
  }

  void abort() {
    countdownTimer?.cancel();
    timer?.cancel();
    _isBusy = false;
    webcamRecorder.stopRec();
    newSession();
  }




}