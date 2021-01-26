import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() => runApp(VideoPlayPage());


class VideoPlayPage extends StatefulWidget {
  VideoPlayPage({Key key}) : super(key: key);

  @override
  _VideoPlayPageState createState() => _VideoPlayPageState();
}

class _VideoPlayPageState extends State<VideoPlayPage> {
  VideoPlayerController vController;
  VideoPlayerController videoController;
  VoidCallback videoPlayerListener;
  String videoFile;
  bool isFirst=true;

  @override
  void dispose() {
    // 자원을 반환하기 위해 VideoPlayerController를 dispose 시키세요.
    vController.dispose();

    super.dispose();
  }

  // Future<void> _startVideoPlayer() async {
  //   vController = VideoPlayerController.file(File(videoFile));
  //   vController.addListener(() {if(!vController.value.isPlaying) setState(() {
  //
  //   });});
  //   await vController.setLooping(true);
  //   await vController.initialize();
  // }

  Future<void> _startVideoPlayer() async {
    vController = VideoPlayerController.file(File(videoFile));
    videoPlayerListener = () {
      if (videoController != null && videoController.value.size != null) {
        setState(() {
        });
      }
    };

    vController.addListener(videoPlayerListener);
    await vController.setLooping(true);
    await vController.initialize();
    await videoController?.dispose();
    if (mounted) {
      setState(() {
        videoController = vController;
      });
    }

    //await vController.play();
  }


  @override
  Widget build(BuildContext context) {
    final Map arguments = ModalRoute.of(context).settings.arguments as Map;
    var file = arguments["file"];
    videoFile = file;
    return isFirst?FutureBuilder(future:_startVideoPlayer() ,builder: (context, snapshot) {
      isFirst=false;
      return Scaffold(appBar: AppBar(title: Text("My Page"),),
        floatingActionButton: FloatingActionButton(
          onPressed: (){
            setState(() {
              vController.value.isPlaying
                  ? vController.pause()
                  : vController.play();
            });
          },
          child: Icon(vController.value.isPlaying?Icons.pause:Icons.play_arrow),
        ),
        body: Column(
          children: <Widget>[
            vController == null
                ? Text("Fucking!!")
                : Expanded(
              flex: 19,
              child: (vController == null)
                  ? Text("fcuk")
                  : Container(
                child: VideoPlayer(vController),
              ),
            ),],
        ),
      );
    },
    ):Scaffold(appBar: AppBar(title: Text("My Page"),),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          setState(() {
            vController.value.isPlaying
                ? vController.pause()
                : vController.play();
          });
        },
        child: Icon(vController.value.isPlaying?Icons.pause:Icons.play_arrow),
      ),
      body: Column(
        children: <Widget>[
          vController == null
              ? Text("Fucking!!")
              : Expanded(
            flex: 19,
            child: (vController == null)
                ? Text("fcuk")
                : Container(
              child: VideoPlayer(vController),
            ),
          ),
        ],
      ),
    );
  }
}