import 'dart:html';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class WebcamViewer extends StatefulWidget {
  final double height;
  final double width;
  final Key webcamKey;
  final Function(MediaStream, VideoElement) onStreamAvailable;
  WebcamViewer({Key key, @required this.webcamKey, this.height, this.width, this.onStreamAvailable}) : super(key: key);

  @override
  _WebcamViewerState createState() {
    return _WebcamViewerState();
  }
}

class _WebcamViewerState extends State<WebcamViewer> {
  VideoElement _webcamVideoElement;
  Widget webcamWidget;

  @override
  void initState() {
    super.initState();

    // Create a video element which will be provided with stream source
    _webcamVideoElement = VideoElement();
    _webcamVideoElement.muted = true;
    //_webcamVideoElement.videoWidth = ;
    //_webcamVideoElement.videoHeight = ,

    // Register webcam
    ui.platformViewRegistry.registerViewFactory('webcamVideoElement', (int viewId) => _webcamVideoElement);

    //Create video widget
    webcamWidget = HtmlElementView(key: widget.webcamKey, viewType: 'webcamVideoElement');
    var videoOption = {
      //"facingMode": 'user',
      "width": widget.width ?? 1280,
      "height": widget.height ?? 720,
    };
    print(videoOption);
    // Access the webcam stream
    window.navigator.getUserMedia(
        video: videoOption,
        audio: true
    ).then((MediaStream stream) {
      _webcamVideoElement.srcObject = stream;
      _webcamVideoElement.setAttribute("style", "object-fit: cover; filter: blur(7px) saturate(0.05);");
      if (widget.onStreamAvailable != null)
        widget.onStreamAvailable(stream, _webcamVideoElement);
    });

  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      width: widget.width ?? null,
      height: widget.height ?? null,
      child: webcamWidget,
      color: Colors.black,
    );
  }
}