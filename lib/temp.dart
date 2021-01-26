import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:aa_test/model/custom_song.dart';
import 'package:aa_test/model/songs.dart';
import 'package:aa_test/myNativeBridge.dart';
import 'package:aa_test/scoreResultModal.dart';
import 'package:aa_test/scoredb.dart';
import 'package:aa_test/songdb.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:aa_test/model/madi.dart';
import 'package:aa_test/noteParser.dart';

import 'package:aa_test/player.dart';
import 'package:aa_test/model/song.dart';

import 'package:aa_test/sheetFunction.dart';
import 'package:flutter_sequencer/native_bridge.dart';
import 'package:flutter_sequencer/sequence.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:pitchdetector/pitchdetector.dart';
import 'package:screen/screen.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:camera/camera.dart';
import 'package:video_player/video_player.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hardware_buttons/hardware_buttons.dart' as HardwareButtons;

import 'noteParser.dart';

class MyApp2 extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

//0 -검정 1 - 주황 2- 초록 3 - 빨강 4 -파랑
class _MyAppState extends State<MyApp2> {
  double widgetHeight = 70; // 마디높이
  List<int> check = []; //음표 진행상태, 점수 체크용
  List<int> toScroll = []; //현재 진행중인 row위치 체크용
  List<double> toTempo = []; // 현재 진행중인 음표의 박자 체크용
  List<int> temp = []; //음표 진행상태, 점수 체크용
  int rownum = 1; // row index
  int i = 1;
  bool isFirst = true; // initstate 안에 넣을수 없는 최초실행 확인 여부
  Song song;
  String midiPath;
  bool isDisposed = false; //disopse안에 넣을수 없는 값들을위해  dispose가 되었는지 확인
  ItemScrollController scrollController = ItemScrollController();
  int ckIndex = 0; //음표진행상태 음표 index
  bool os;
  int ckLeng;
  var isSound = true;
  var tempoCnt = 0;
  var tempoList = [0.8, 1.0, 1.2];
  var j = 1;
  final DateFormat formatter = DateFormat('yyyy-MM-dd_HHmm');

  FlutterSoundRecorder _mRecorder = FlutterSoundRecorder();
  bool _mRecorderIsInited = false;
  String _mPath;

  List<CameraDescription> cameras = [];
  CameraController controller;
  VideoPlayerController videoController;
  VoidCallback videoPlayerListener;
  bool enableAudio = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  VideoPlayerController vController;

  Pitchdetector detector;
  bool isRecording = false;
  double pitch;
  Sequence seq;

  OverlayEntry overlay;
  Directory vpath;
  Directory rpath;

  int widgetState = 0;
  bool isFirstPlayPress = true;
  bool isFirstStop = true;
  ScoreResultModal modal = ScoreResultModal();
  final dbHelper = DatabaseHelper.instance;
  StreamSubscription<HardwareButtons.HomeButtonEvent> _homeButtonSubscription;
  StreamSubscription<HardwareButtons.LockButtonEvent> _lockButtonSubscription;
  List<int> checkCntArr = [];

  @override
  void initState() {
    os = Platform.isAndroid;
    Screen.keepOn(true);
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
    ]);
    seq = MidiPlayer().sequence;
    detector = Pitchdetector(
        sampleRate: os ? 44100 : 11025, sampleSize: os ? 4096 : 512);

    if (Platform.isIOS) MyNativeBridge().setSpeaker();

    isRecording = isRecording;

    cameraInitialized().then((value) => openTheRecorder().then((value) {
          setState(() {
            _mRecorderIsInited = true;
          });
        }));
    _homeButtonSubscription = HardwareButtons.homeButtonEvents.listen((event) {
      seq.stop();
      if (isRecording == true) stopRecording();
      setState(() {
        widgetState = 0;
      });
      if (overlay != null) {
        overlay.remove();
        overlay = null;
      }
    });

    _lockButtonSubscription = HardwareButtons.lockButtonEvents.listen((event) {
      seq.stop();
      if (isRecording == true) stopRecording();
      setState(() {
        widgetState = 0;
      });
      if (overlay != null) {
        overlay.remove();
        overlay = null;
      }
    });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    seq.stop();
    isDisposed = true;
    if (isRecording == true) stopRecording();

    _mRecorder.stopRecorder();
    _mRecorder.closeAudioSession();
    _mRecorder = null;
    // if (_mPath != null) {
    //    var outputFile = File(_mPath);
    //   if (outputFile.existsSync()) {
    //     outputFile.delete();
    //   }
    // }
    if (overlay != null) {
      overlay.remove();
      //print("==============$overlay");
      overlay = null;
    }

    if (vController != null) vController.dispose();
    _homeButtonSubscription?.cancel();
    _lockButtonSubscription?.cancel();
    controller.dispose();
    super.dispose();
  }

  Future<void> cameraInitialized() async {
    bool storage = await Permission.storage.isGranted;
    bool camera = await Permission.camera.isGranted;
    if(!camera){
      await Permission.camera.request();
    }
    if(!storage){
      await Permission.storage.request();
    }
    var temp = await getApplicationDocumentsDirectory();
    vpath = Directory("${temp.path}/video");
    rpath = Directory("${temp.path}/audio");
    try {
      WidgetsFlutterBinding.ensureInitialized();
      cameras = await availableCameras();

      // if (controller != null) {
      //   await controller.dispose();
      // }
      controller = CameraController(
        cameras[1],
        ResolutionPreset.medium,
        enableAudio: enableAudio,
      );

      // If the controller is updated then update the UI.
      controller.addListener(() {
        if (controller.value.hasError) {
          //showInSnackBar('Camera error ${controller.value.errorDescription}');
          //print("ㅈ됐다시발");
        }
      });

      try {
        await controller.initialize();
      } on CameraException catch (e) {
        //print("ㅈ됐다시발2");
      }
    } on CameraException catch (e) {
      logError(e.code, e.description);
    }
  }

  void logError(String code, String message) =>
      print('Error: $code\nError Message: $message');

  Future<void> openTheRecorder() async {
    // if (outputFile.existsSync()) {
    //   await outputFile.delete();
    // }
    await _mRecorder.openAudioSession();
    _mRecorderIsInited = true;
  }

  Future<void> record() async {
    if (!controller.value.isRecordingVideo) {
      assert(_mRecorderIsInited);
      stopRecording();
      String formatted;
      setState(() {
        check.fillRange(0, ckLeng, 0);
        temp.fillRange(0, ckLeng, 0);
        final DateTime now = DateTime.now();
        formatted = formatter.format(now);
        _mPath = '${rpath.path}/${song.title}$formatted.aac';
        //print(_mPath);
        //var outputFile = File(_mPath);
      });
      await _mRecorder
          .startRecorder(
        toFile: _mPath,
        codec: Codec.aacADTS,
      )
          .then((value) {
        setState(() {
          widgetState = 4;
        });
        startMusic();
      });
    }
  }

  Future<void> stopRecorder() async {
    await _mRecorder.stopRecorder();
    deleteFile();
  }

  void deleteFile() {
    File(_mPath).delete();
  }

  void getRecorderFn() {
    if (!_mRecorderIsInited) {
      return;
    }
    var track = seq.getTracks();
    track[0].addVolumeChange(volume: 0, beat: 0);
    isSound = false;
    record();
  }

  Widget _cameraPreviewWidget() {
    if (controller == null || !controller.value.isInitialized) {
      Navigator.pop(context);
      return const Text(
        'Tap a camera',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      return AspectRatio(
        child: CameraPreview(controller),
        aspectRatio: 16 / 9,
      );
    }
  }

  void onVideoRecordButtonPressed() async {
    //SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    overlayScreen();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Overlay.of(context).insert(overlay);
    });
    stopRecording();
    await startVideoRecording();
    setState(() {
      widgetState = 1;
      check.fillRange(0, ckLeng, 0);
      temp.fillRange(0, ckLeng, 0);
    });
    startMusic();
  }

  Future<void> startVideoRecording() async {
    if (!controller.value.isInitialized) {
      //print("시발");
      //showInSnackBar('Error: select a camera first.');
      return;
    }

    if (controller.value.isRecordingVideo) {
      // print("시발2");
      // A recording is already started, do nothing.
      return;
    }

    try {
      await controller.startVideoRecording();
    } on CameraException catch (e) {
      Navigator.pop(context);
      //_showCameraException(e);
      return;
    }
  }

  Future<XFile> stopVideoRecording() async {
    if (!controller.value.isRecordingVideo) {
      //print("시발");
      return null;
    }

    try {
      return controller.stopVideoRecording();
    } on CameraException catch (e) {
      //_showCameraException(e);
      return null;
    }
  }

  void onStopButtonPressed() async {
    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.landscapeRight,
    //   DeviceOrientation.landscapeLeft,
    //   DeviceOrientation.portraitUp,
    //   DeviceOrientation.portraitDown,
    // ]);
    if (controller != null &&
        controller.value.isInitialized &&
        controller.value.isRecordingVideo) {
      await stopVideoRecording();
      stopRecording();
      setState(() {
        widgetState = 0;
      });
    }
  }

  // void _showCameraException(CameraException e) {
  //   logError(e.code, e.description);
  //   showInSnackBar('Error: ${e.code}\n${e.description}');
  // }
  //
  // void showInSnackBar(String message) {
  //   // ignore: deprecated_member_use
  //   _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
  // }

  void overlayScreen() {
    overlay = OverlayEntry(
      builder: (context) {
        var height = MediaQuery.of(context).size.height;
        var width = MediaQuery.of(context).size.width;
        return Positioned(
          bottom: 1,
          right: 1,
          child: RotatedBox(
              quarterTurns: 3,
              child: Container(
                  height: 54, width: 96, child: _cameraPreviewWidget())),
        );
      },
    );
  }

  double thisTempo = 0;

  @override
  Widget build(BuildContext context) {
    // if (MediaQuery.of(context).orientation == Orientation.portrait)
    //   return Container();
    final Map arguments = ModalRoute.of(context).settings.arguments as Map;
    song = arguments["song"];
    var tempo = tempoList[j];
    if (isFirst) {
      song.notes.forEach((note) {
        check.add(0);
        temp.add(0);
        toScroll.add(0);
        checkCntArr.add(0);
      });
      thisTempo = (song.tempo * tempo);
      toTempo = getTempos(song.notes, thisTempo);
      check.add(0);
      temp.add(0);
      checkCntArr.add(0);
      ckLeng = check.length;
      isFirst = false;
      MidiPlayer().sequence.setTempo((song.tempo * tempoList[j]));
    }
    return Scaffold(
      body: SafeArea(child: createSong(8, song, context)),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        title: Center(
            child: Text(
          song.title,
          style: TextStyle(color: Colors.black),
        )),
        // actions: [
        //   GestureDetector(
        //     child: Icon(Icons.person),
        //     onTap: () {
        //       if (!isRecording)
        //         Navigator.pushReplacementNamed(context, "myPage",
        //             arguments: {"vpath": vpath.path, "rpath": rpath.path});
        //     },
        //   ),
        //   Container(
        //     width: 20,
        //   ),
        // ],
      ),
    );
  }

  void startMusic() async {
    int myPlayCnt = playCnt;
    //stopRecording();
    if (!detector.isRecording) {
      setState(() {
        isRecording = true;
        check.fillRange(0, ckLeng, 0);
        temp.fillRange(0, ckLeng, 0);
      });
    }
    if (!isDisposed) {
      //리코더음 recurder
      seq.stop();
      seq.play();

      for (i = 0; i < ckLeng; i++) {
        if (myPlayCnt != playCnt) {
          i--;
          break;
        }
        if (!isRecording) break;
        await Future.delayed(
            Duration(
                microseconds: i == 0 ? 0 : (toTempo[i - 1] * 1000).toInt()),
            () {
          if (isRecording && myPlayCnt == playCnt) {
            if (!isDisposed) {
              setState(() {
                check[i] = 1;
                if (i > 0) {
                  check[i - 1] = 2;
                }
              });
            }
          }
        });

        // row 하나 끝날떄마다 스크롤
        if (!isDisposed) if (toScroll[i] == 1) {
          scrollController.scrollTo(
              index: rownum, duration: Duration(seconds: 1));
          rownum++;
        }

        if (i == ckLeng - 1) {
          //detector.stopRecording();
          rownum = 1;
          if (_mRecorder.isRecording) {
            _mRecorder.stopRecorder(); //저장
          }

          stopVideoRecording().then((file) {
            setState(() {
              if (overlay != null) {
                overlay.remove();
                overlay = null;
              }
              widgetState = 0;
              isRecording = false;
            });
            setState(() {
              widgetState = 0;
            });
            isFirstPlayPress = true;

            if (file != null) {
              //file.saveTo("/sdcard/DCIM/Camera/abcd.mp4");
              final DateTime now = DateTime.now();
              final String formatted = formatter.format(now);
              file.saveTo("${vpath.path}/${song.title}$formatted.mp4");
              // GallerySaver.saveVideo(file.path);
            }
          });

          break;
        }
      }
    }
  }

  Future<void> updateSong(Song song) async {
    SongDb db = SongDb();
    await db.updateSong(song);
  }

  int notePitch = -1;
  double noteTempo = 0;
  bool isFirstPlay = true;

  //20210111 중복재생 방지용 변수
  int playCnt = 0;
  double note = 0;
  double input = 0;

  //pitch detector start
  void startRecording() async {
    noteTempo = 0;
    notePitch = -1;
    note = 0;
    input = 0;
    i = 0;
    notePitch = -1;
    double stBeat = 0;
    //checkCntArr.fillRange(0, checkCntArr.length);
    if (isFirstPlay) {
      detector.onRecorderStateChanged.listen((event) {
        if (!isDisposed) {
          //double tempPitch = pitchScore(song.notes[i - 1].pitch);
          pitch = event["pitch"];
          input = (pitch ?? 0);
          // print(detector.sampleRate / detector.sampleSize);
          // print(pitch);

          //print("listen : ${seq.getBeat()}");
          // print("listen2: ${DateTime.now().millisecondsSinceEpoch}");
          // print(DateTime.now().millisecondsSinceEpoch);

          int loopCnt = song.notes.length;

          double nowAbsTime = seq.getBeat();

          int stPos = 0;
          for (int kk = 0; kk < loopCnt; kk++) {
            Note note = song.notes[kk];
            if (nowAbsTime >= stPos / 1000 - 0.5 &&
                nowAbsTime <= (stPos + note.leng) / 1000 + 0.5) {
              double nowPosScore = pitchScore(note.pitch);
              if (input <= nowPosScore + 40 && input >= nowPosScore - 40) {
                checkCntArr[kk] += 1;
                // print("$kk +++");
              }
              stPos += note.leng;
            }

            stPos += note.leng;
          }

          //(DateTime.now().millisecondsSinceEpoch - startTime) / 1000

        }
      });
      isFirstPlay = false;
    }
    if (!isDisposed)
      setState(() {
        isRecording = false;
        check.fillRange(0, ckLeng, 0);
        temp.fillRange(0, ckLeng, 0);
      });
    int myPlayCnt = playCnt;

    await detector.startRecording();
    if (detector.isRecording) {
      setState(() {
        isRecording = true;
      });
    }

    //here

    //음표 진행상태 색변경
    var cnt = 0;
    if (!isDisposed) {
      var track = seq.getTracks();
      checkCntArr.fillRange(0, checkCntArr.length, 0);

      seq.stop();
      track[0].addVolumeChange(volume: 0, beat: 0);
      seq.play();
      //int startTime = DateTime.now().millisecondsSinceEpoch;

      for (i = 0; i < ckLeng; i++) {
        if (isDisposed) break;
        if (!isRecording) break;
        if (myPlayCnt != playCnt) {
          i --;
          break;
        }
        if (i != 0) {
          notePitch = song.notes[i - 1].pitch;
          noteTempo = toTempo[i - 1];
          note = pitchScore(notePitch);
          //print("===========$note");
        }
        await Future.delayed(
            Duration(microseconds: i == 0 ? 0 : (noteTempo * 1000).toInt()),
            () {
          var result = checkCntArr[i < 5 ? 0 : i - 5];
          if (isRecording && myPlayCnt == playCnt) {
            if (!isDisposed) {
              setState(() {
                tempoCnt = 0; //박자 초기화
                check[i] = 1;
                if (i > 4) {
                  int tempResult1 = toTempo[i - 5] ~/ 300;
                  int tempResult2 = 1;
                  if (song.notes[i - 5].pitch == -1) {
                    check[i - 5] = 2;
                  } else if (result > tempResult1)
                    check[i - 5] = 2;
                  else if (result >= tempResult2)
                    check[i - 5] = 4;
                  else
                    check[i - 5] = 3;
                }
              });
            }
          }
        });

        // row 하나 끝날떄마다 스크롤
        if (!isDisposed) if (toScroll[i] == 1) {
          scrollController.scrollTo(
              index: rownum, duration: Duration(seconds: 1));
          rownum++;
        }

        if (i == ckLeng - 1) {
          List<int> board = [];
          setState(() {
            widgetState = 0;
          });
          isFirstPlayPress = true;

          detector.stopRecording();
          updateSong(Song(
              id: song.id,
              title: song.title,
              isGood: song.isGood,
              midPath: song.midPath,
              tempo: song.tempo,
              scale: song.scale,
              history: 1,
              level: song.level));
          rownum = 1;
          var date = DateTime.now();
          String convertedDateTime =
              "${date.year.toString().substring(2)}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')} ${date.hour.toString()}:${date.minute.toString()}";

          await Future.delayed(Duration(milliseconds: 1500), () {
            for (var i = 0; i < 5; i++) {
              int tempResult1 = toTempo[ckLeng - 6 + i] ~/ 300;
              int tempResult2 = 1;
              var result = checkCntArr[ckLeng - 6 + i];
              setState(() {
                if (song.notes[ckLeng - 6 + i].pitch == -1) {
                  check[ckLeng - 6 + i] = 2;
                } else if (result > tempResult1)
                  check[ckLeng - 6 + i] = 2;
                else if (result >= tempResult2)
                  check[ckLeng - 6 + i] = 4;
                else
                  check[ckLeng - 6 + i] = 3;
              });
            }
          });
          check.forEach((score) {
            if (score == 2) {
              board.add(0);
            }
          });
          await dbHelper.insert(song.id, song.title,
              ((board.length + 1) / ckLeng * 100).ceil(), convertedDateTime);
          final allRows = await dbHelper.queryAllRows(song.id);

          modal.mainBottomSheet(context,
              ((board.length + 1) / ckLeng * 100).ceil(), song, allRows);
          break;
        }
        // 음표 pitch체크 색변경

      }
    }
  }

  void stopRecording() {
    seq.stop();
    i = 0;
    playCnt++;
    if (detector.isRecording) detector.stopRecording();
    if (_mRecorder.isRecording) {
      stopRecorder();
    }
    rownum = 1;
    if (!isDisposed)
      setState(() {
        isRecording = false;
        check.fillRange(0, ckLeng, 0);
        temp.fillRange(0, ckLeng, 0);
      });
  }

  /*
  * sheet sheet sheet sheet sheet sheet sheet sheet sheet sheet sheet sheet sheet sheet sheet sheet sheet sheet sheet sheet sheet sheet
  * sheet sheet sheet sheet sheet sheet sheet sheet sheet sheet sheet sheet sheet sheet sheet sheet sheet sheet sheet sheet sheet sheet
  * sheet sheet sheet sheet sheet sheet sheet sheet sheet sheet sheet sheet sheet sheet sheet sheet sheet sheet sheet sheet sheet sheet
  * sheet sheet sheet sheet sheet sheet sheet sheet sheet sheet sheet sheet sheet sheet sheet sheet sheet sheet sheet sheet sheet sheet
  * */
  List<Widget> buttonList(Orientation orientation, double height) {
    Widget vRecordBtn = FlatButton(
      color: Colors.transparent,
      textColor: Colors.black,
      child: Column(
        children: [SvgPicture.asset("assets/img/video.svg"), Text("녹화")],
        mainAxisAlignment: MainAxisAlignment.center,
      ),
      onPressed: () {
        if (isFirstPlayPress) {
          isFirstPlayPress = false;
          isFirstStop = true;

          if (controller != null &&
              controller.value.isInitialized &&
              !controller.value.isRecordingVideo) {
            onVideoRecordButtonPressed();
            var track = seq.getTracks();
            track[0].addVolumeChange(volume: 0, beat: 0);
            isSound = false;
          }
          scrollController.scrollTo(
              index: 0, duration: Duration(milliseconds: 300));
        }
      },
    );

    Widget vStopBtn = FlatButton(
        minWidth: double.infinity,
        onPressed: () {
          if (isFirstStop) {
            isFirstStop = false;
            isFirstPlayPress = true;
            setState(() {
              widgetState = 0;
              if (overlay != null) {
                overlay.remove();
                overlay = null;
              }
            });
            onStopButtonPressed();
            scrollController.scrollTo(
                index: 0, duration: Duration(milliseconds: 300));
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FittedBox(
              child: Text(
                "중지",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              fit: BoxFit.cover,
            ),
          ],
        ),
        textColor: Colors.white,
        color: Colors.black);

    Widget aRecordBtn = FlatButton(
      color: Colors.transparent,
      textColor: Colors.black,
      child: Column(
        children: [
          SvgPicture.asset("assets/img/record.svg"),
          Text(
            "녹음",
          )
        ],
        mainAxisAlignment: MainAxisAlignment.center,
      ),
      onPressed: () {
        if (isFirstPlayPress) {
          isFirstPlayPress = false;
          isFirstStop = true;
          getRecorderFn();
          scrollController.scrollTo(
              index: 0, duration: Duration(milliseconds: 300));
        }
      },
    );

    Widget playBtn = FlatButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0),
        ),
        textColor: Colors.white,
        color: Colors.black,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FittedBox(
              fit: BoxFit.cover,
              child: Text(
                "도전하기",
                style: TextStyle(fontSize: 30),
              ),
            ),
          ],
        ),
        onPressed: () {
          if (isFirstPlayPress) {
            isFirstPlayPress = false;
            isFirstStop = true;
            setState(() {
              widgetState = 2;
            });
            startRecording();
            scrollController.scrollTo(
                index: 0, duration: Duration(milliseconds: 300));
          }

          // return !isRecording ? startRecording() : stopRecording();
        });
    Widget practiceBtn = FlatButton(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0),
          side: BorderSide(color: Colors.grey)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "연습하기",
            style: TextStyle(fontSize: 30),
          ),
        ],
      ),
      color: Colors.white,
      textColor: Colors.black,
      onPressed: () {
        setState(() {
          widgetState = 3;
        });
      },
    );
    Widget listenBtn = FlatButton(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0),
          side: BorderSide(color: Colors.grey)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "들어보기",
            style: TextStyle(fontSize: 30),
          ),
        ],
      ),
      color: Colors.black,
      textColor: Colors.white,
      onPressed: () {
        if (isFirstPlayPress) {
          isFirstPlayPress = false;
          isFirstStop = true;
          setState(() {
            widgetState = 4;
          });
          var track = seq.getTracks();
          if (os)
            track[0].addVolumeChange(volume: 0.25, beat: 0);
          else
            track[0].addVolumeChange(volume: 0.3, beat: 0);
          isSound = true;
          startMusic();
          scrollController.scrollTo(
              index: 0, duration: Duration(milliseconds: 300));
        }
      },
    );

    Widget stopBtn = FlatButton(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0),
          side: BorderSide(color: Colors.grey)),
      onPressed: () {
        if (isFirstStop) {
          isFirstStop = false;
          isFirstPlayPress = true;
          stopRecording();
          scrollController.scrollTo(
              index: 0, duration: Duration(milliseconds: 300));
        }
        setState(() {
          widgetState = 0;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            child: Text(
              "중지",
              style: TextStyle(
                fontSize: 30,
              ),
            ),
            fit: BoxFit.cover,
          ),
        ],
      ),
      textColor: Colors.white,
      color: Colors.black,
    );

    Widget muteBtn = FlatButton(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
            side: BorderSide(color: Colors.grey)),
        textColor: Colors.black,
        color: isSound ? Colors.white : Colors.yellow,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FittedBox(
              fit: BoxFit.fill,
              child: Text(
                "반주만듣기",
                style: TextStyle(fontSize: 30),
              ),
            ),
          ],
        ),
        onPressed: () {
          var track = seq.getTracks();
          track[0].changeVolumeNow(volume: isSound ? 0 : 0.25);
          setState(() {
            isSound = !isSound;
          });
        });

    Widget speedBtn = FlatButton(
        onPressed: () {
          setState(() {
            j >= 2 ? j = 0 : j++;
            MidiPlayer().sequence.setTempo((song.tempo * tempoList[j]));
          });
          thisTempo = (song.tempo * tempoList[j]);
          toTempo = getTempos(song.notes, thisTempo);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FittedBox(
                fit: BoxFit.fill,
                child: Text(
                  "${tempoList[j].toString()}배속",
                  style: TextStyle(fontSize: 30),
                ))
          ],
        ),
        textColor: Colors.black,
        color: Colors.transparent);

    //Widget cameraView = _cameraPreviewWidget();

    List<Widget> widgetList = [];
    if (widgetState == 0) {
      widgetList.add(Expanded(child: Container()));
      widgetList.add(Expanded(child: Container()));
      widgetList.add(Expanded(child: speedBtn));
      widgetList.add(Expanded(
        child: practiceBtn,
        flex: 2,
      ));
      widgetList.add(SizedBox(
        width: 10,
      ));
      widgetList.add(Expanded(
        child: playBtn,
        flex: 2,
      ));
    } else if (widgetState == 1) {
      //var width = MediaQuery.of(context).size.width;
      // widgetList.add(Expanded(
      //   child: Container(
      //     child: cameraView,
      //     height: double.infinity,
      //     width:
      //         orientation == Orientation.portrait ? width * 0.3 : width * 0.2,
      //   ),
      // ));
      widgetList.add(Expanded(
        child: vStopBtn,
      ));
      widgetList.add(SizedBox(
        width: 10,
      ));
      widgetList.add(Expanded(
        child: muteBtn,
      ));
      widgetList.add(Expanded(child: Container()));
      widgetList.add(Expanded(child: Container()));
    } else if (widgetState == 2) {
      widgetList.add(Expanded(child: Container()));
      widgetList.add(Expanded(child: Container()));
      widgetList.add(Expanded(child: Container()));
      widgetList.add(Expanded(
        child: Container(),
        flex: 2,
      ));
      widgetList.add(SizedBox(
        width: 10,
      ));
      widgetList.add(Expanded(child: stopBtn, flex: 2));
    } else if (widgetState == 3) {
      widgetList.add(Expanded(child: Container()));
      widgetList.add(Expanded(
        child: Container(),
        flex: 2,
      ));
      widgetList.add(Expanded(child: aRecordBtn));
      widgetList.add(VerticalDivider(
        width: 1,
      ));
      widgetList.add(Expanded(child: vRecordBtn));
      widgetList.add(SizedBox(
        width: 10,
      ));
      widgetList.add(Expanded(
        child: listenBtn,
        flex: 2,
      ));
    } else if (widgetState == 4) {
      widgetList.add(Expanded(child: Container()));
      widgetList.add(Expanded(child: Container()));
      widgetList.add(Expanded(child: Container()));
      widgetList.add(Expanded(
        child: muteBtn,
        flex: 2,
      ));
      widgetList.add(SizedBox(
        width: 10,
      ));
      widgetList.add(Expanded(
        child: stopBtn,
        flex: 2,
      ));
    }

    return widgetList;
  }

  Widget createSong(int maxNotesInLine, Song song, BuildContext context) {
    //한마디에 총 허용되는 노트(1000 = 4분음표 1개)
    var height = MediaQuery.of(context).size.height;
    var maxOfMadi = 4000 * song.rhythmUpper / song.rhythmUnder;
    List<Madi> madiList = [];
    madiList.add(Madi(
        id: 0,
        isRhythmShown: false,
        endType: 0,
        clef: 0,
        scale: song.notes.first.scale,
        rhythmUnder: song.rhythmUnder,
        rhythmUpper: song.rhythmUpper,
        notes: []));

    // 1. 노래를 마디 리스트화
    int nowMadiLength = 0;
    int madiIndex = 1;
    int songId = song.id;
    double defaultMaxOfMadi = 4000 * song.rhythmUpper / song.rhythmUnder;
    song.notes.forEach((note) {
      //박자변경 처리
      if (CUSTOM_MADI[songId] != null) {
        maxOfMadi = defaultMaxOfMadi;
        CUSTOM_MADI[songId].forEach((optMadi) {
          if (optMadi.id == madiIndex) {
            maxOfMadi = 4000 * optMadi.rhythmUpper / optMadi.rhythmUnder;
            madiList.last.rhythmUnder = optMadi.rhythmUnder;
            madiList.last.rhythmUpper = optMadi.rhythmUpper;
          }
        });
      }
      if (nowMadiLength + note.leng <= maxOfMadi) {
        madiList.last.notes.add(note);
        nowMadiLength = nowMadiLength + note.leng;
      } else {
        madiList.add(Madi(
            id: madiIndex++,
            isRhythmShown: false,
            endType: 0,
            clef: 0,
            scale: note.scale,
            rhythmUnder: song.rhythmUnder,
            rhythmUpper: song.rhythmUpper,
            notes: []));
        madiList.last.notes.add(note);
        nowMadiLength = note.leng;
      }
    });

    //마지막마디 endType처리 0122
    madiList.last.endType = 2;

    List<Row> rows = [];
    var deviceWidth = os
        ? MediaQuery.of(context).size.width * 0.99
        : MediaQuery.of(context).size.width * 0.85;

    // 줄별로 마디 분배
    int nowNoteCnt = 0;
    int madiCount = 0;
    int madiTotalSize = madiList.length;
    var tempMadisList = [];
    var temp = [];
    List<int> lineCntArr = lineInfo[song.id];
    if (lineCntArr.length > 0) {
      int nowMadiCnt = 0;
      int lineCntIndex = 0;
      madiList.forEach((madi) {
        if (nowMadiCnt < lineCntArr[lineCntIndex]) {
          temp.add(madi);
          nowMadiCnt++;
        } else {
          tempMadisList.add(temp);
          temp = [madi];
          lineCntIndex++;
          nowMadiCnt = 1;
        }

        if (lineCntIndex == lineCntArr.length - 1 &&
            nowMadiCnt == lineCntArr[lineCntIndex]) {
          tempMadisList.add(temp);
        }
      });
    } else {
      madiList.forEach((madi) {
        madiCount++;
        // 지금까지의 음표의 개수가 4개 미만이면 무조건 붙임(가시성때문)
        if (nowNoteCnt < 5) {
          temp.add(madi);
          nowNoteCnt += madi.getNotesCount();
        } else {
          // 현재 줄의 마디노트의 개수와 새로운 마디의 노트 개수가 허용치 이상이면 로우 삽입
          if (nowNoteCnt + madi.getNotesCount() >= maxNotesInLine) {
            tempMadisList.add(temp);
            temp = [madi];
            nowNoteCnt = madi.getNotesCount();
          } else {
            temp.add(madi);
            nowNoteCnt = nowNoteCnt + madi.getNotesCount();
          }
        }

        //마지막마디 처리
        if (madiCount == madiTotalSize) {
          tempMadisList.add(temp);
        }
      });
    }

    // 줄별로 분배된 마디를 위젯으로 만들고 Row에 삽입
    int tempCnt = 0;
    int tempMadisListCnt = tempMadisList.length;
    int size = 0;
    toScroll.add(0);
    bool isFirstMadiOfSong = true;
    bool isFirstTemp = true;
    int lineNum = 0;
    tempMadisList.forEach((madis) {
      lineNum++;
      tempCnt++;
      int absScale = song.scale < 0 ? song.scale * -1 : song.scale;
      int cnt = madis.length;
      int totalNotes = 0;
      List<int> noteCntOfMadi = [];
      for (int i = 0; i < cnt; i++) {
        int tempCnt = (madis[i] as Madi).getNotesCount();
        tempCnt += tempCnt < 2 ? 2 : 0;
        totalNotes += tempCnt;
        noteCntOfMadi.add(tempCnt);
      }
      //마디길이 수정
      // double unitWidth = deviceWidth / totalNotes;
      // double firstWidth =
      //     cnt > 1 ? unitWidth * noteCntOfMadi[0] + absScale * 6 : deviceWidth;
      // if (isFirstTemp) {
      //   firstWidth += 25;
      //   isFirstTemp = false;
      // }
      // double otherUnitWidth = cnt > 1
      //     ? (deviceWidth - firstWidth) / (totalNotes - noteCntOfMadi[0])
      //     : 0;

      double firstWidth =
          cnt > 1 ? absScale * 5 + widgetHeight * 0.15 : deviceWidth;
      double otherWidth =
          cnt > 1 ? (deviceWidth - firstWidth) / cnt : deviceWidth;
      firstWidth = cnt > 1 ? firstWidth + otherWidth : firstWidth;
      List<Widget> temRowItem = [];
      for (int i = 0; i < cnt; i++) {
        double widthSize = 0;
        //마지막마디가 하나일때 처리
        if (i == 0 && i == cnt - 1 && tempCnt == tempMadisListCnt) {
          madis[i].clef = 1;
          widthSize = deviceWidth / 2;
        } else if (i == 0) {
          madis[i].clef = 1;
          if (isFirstMadiOfSong) {
            madis[i].isRhythmShown = true;
            isFirstMadiOfSong = false;
          } else {
            madis[i].isRhythmShown = false;
          }
          madis[i].endType = cnt == 1 && tempCnt == tempMadisListCnt ? 2 : 0;
          widthSize = firstWidth;
        } else {
          widthSize = otherWidth;
        }
        // 0120
        var customMadiMap = CUSTOM_MADI_WITH_NOTE[song.id];

        if (customMadiMap == null) {
          temRowItem.add(createMadi(madis[i], widthSize));
        } else {
          OptionMadi customMadi = customMadiMap[madis[i].id + 1];
          customMadi != null
              ? temRowItem.add(createCustomMadi(customMadi, widthSize))
              : temRowItem.add(createMadi(madis[i], widthSize));
        }
      }

      // 0121=========st
      var tempStack = Stack(children: []);
      if (TIE_INFO[songId] != null) {
        //
        var tieInfo = TIE_INFO[songId];
        if (tieInfo[lineNum] != null) {
          var realTieInfo = tieInfo[lineNum];
          realTieInfo.forEach((tie) {
            drawSlur(tempStack, deviceWidth, widgetHeight, tie.zoomX, tie.posX,
                tie.posY, tie.isDown);
          });
        }
      }
      //drawSlur(tempStack, deviceWidth, widgetHeight, 0.05, 0.65, 0.2, false);

      tempStack.children.add(Row(
        children: temRowItem,
      ));

      rows.add(Row(
        children: [tempStack],
      ));

      // 0121=========end

      //현재 진행중인 row의 위치를 알기위해
      madis.forEach((madi) {
        size += madi.notes.length;
      });
      toScroll[size] = 1;
    });
    rows.add(Row(
      children: [
        Container(
          height: widgetHeight,
        )
      ],
    ));

    // 2. 마디 리스트 아이템의 노트 갯수와 한줄에 허용되는 노트의 갯수와 맞게 Row List화
    var scroll = ScrollablePositionedList.builder(
        physics: ClampingScrollPhysics(),
        itemScrollController: scrollController,
        itemCount: rows.length,
        itemBuilder: (context, index) {
          return rows[index];
        });
    // 3. 컨테이너 return
    return OrientationBuilder(
      builder: (context, orientation) {
        return Column(
          children: [
            Container(
                child: scroll,
                height: orientation == Orientation.landscape
                    ? height * 0.6
                    : height * 0.77),
            Container(
              height: 5,
            ),
            Expanded(
                child: Container(
                    child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: buttonList(orientation, height),
            )))
          ],
        );
      },
    );
  }

  Widget createMadi(Madi madi, double madiWidth) {
    List<Widget> widgets = [];

    double startPosition = madiWidth * 0.08;
    double endPosition = madiWidth - widgetHeight * endPosInfo[song.id];

    //기본 오선보 삽입
    drawStaff(widgets, madiWidth, widgetHeight);

    // 템포 삽입 곡의 첫마디 위에
    if (madi.isRhythmShown) {
      drawTempo(widgets, widgetHeight, thisTempo.floor());
    }

    // 마디끝 삽입
    drawEndLine(widgets, widgetHeight, madiWidth, madi.endType);

    int tempScale = madi.scale;
    int absScale = tempScale < 0 ? tempScale * -1 : tempScale;
    // 음자리표 삽입
    if (madi.clef != 0) {
      drawClef(widgets, true, widgetHeight);
      startPosition = startPosition + widgetHeight / 4;
      //스케일삽입
      drawScale(widgets, tempScale, widgetHeight);
      startPosition = startPosition + widgetHeight / 6 * absScale;
    }

    //임시박자표삽입
    if (CUSTOM_MADI[song.id] != null && !madi.isRhythmShown) {
      CUSTOM_MADI[song.id].forEach((optMadi) {
        if (optMadi.id - 1 == madi.id) {
          drawTempRhythem(widgets, madi.rhythmUpper, madi.rhythmUnder,
              widgetHeight, absScale);
          startPosition = startPosition + 7;
        }
      });
    }
    // 박자표삽입
    if (madi.isRhythmShown) {
      drawRhythem(
          widgets, madi.rhythmUpper, madi.rhythmUnder, widgetHeight, absScale);
      startPosition = startPosition + widgetHeight / 4;
    }

    // 음표삽입
    var nowPosition = startPosition;
    // var interval = (endPosition - startPosition) / 4;
    //박자에 따라 간격 설정
    var interval = madi.rhythmUnder == 4
        ? (endPosition - startPosition) / madi.rhythmUpper
        : (endPosition - startPosition) /
            madi.rhythmUpper *
            madi.rhythmUnder /
            4;

    // 한마디 안의 노트 카운트용(내부에 for문이 여러개 있어서 foreach문으로 하고 변수로 관리) 반복문 초반에 플러스 시킬거라 -1시작
    int madiNotesCnt = -1;
    //같은 마디 내 동일 임시표 처리를 위해
    HashMap absPosNowState = HashMap<int, int>();
    //셋잇단음표 카운트용
    int tripletCnt = 0;
    //셋잇단음표 피치 배열(3번째에서 꼬리모두그림)
    List<int> tripletPitchs = [];
    //셋잇단음표 가로포지션배열
    List<double> tripletLeft = [];
    //셋잇단음표 세로포지션
    List<double> tripletVertical = [];
    if (ckIndex == ckLeng - 1) ckIndex = 0;
    //점16분음표이하여부
    bool isShort = false;
    madi.notes.forEach((note) {
      madiNotesCnt++;
      var checkckIndex = check[ckIndex];
      var leng = note.leng;
      var pitch = note.pitch;
      //C Major 음계가 아닌 반음계 이면 기존 값에서 1이 추가됨
      double tempVerticalPosition =
          pitchParser(pitch == -1 && leng > 1500 ? -2 : pitch, madi.scale);
      // 임시표 여부
      bool isAccidentals = false;
      // 제자리표 여부
      bool isNature = false;
      //플랫인지 여부
      bool isFlat = tempVerticalPosition < 0 ? true : false;
      if (isFlat) {
        tempVerticalPosition *= -1;
      }
      double verticalPosition = 0;
      if (tempVerticalPosition > 2) {
        verticalPosition = tempVerticalPosition - 2;
        isAccidentals = true;
        isNature = true;
      } else if (tempVerticalPosition > 1) {
        verticalPosition = tempVerticalPosition - 1;
        isAccidentals = true;
      } else {
        verticalPosition = tempVerticalPosition;
      }

      //셋잇단음표 여부
      bool isTriplet = false;
      if (leng == 41 ||
          leng == 83 ||
          leng == 166 ||
          leng == 333 ||
          leng == 666 ||
          leng == 1333) {
        isTriplet = true;
        tripletCnt++;
        tripletPitchs.add(pitch);
        tripletLeft.add(nowPosition);
        tripletVertical.add(verticalPosition);
      }

      if (leng == 200 || leng == 300) {
        //엇박 셋잇단음표
        var tempNotes = madi.notes;
        if (tempNotes.length > madiNotesCnt + 2) {
          if (tempNotes[madiNotesCnt + 2].leng == 200 ||
              tempNotes[madiNotesCnt + 2].leng == 300) {
            int secondLeng = tempNotes[madiNotesCnt + 1].leng;
            int thirdLeng = tempNotes[madiNotesCnt + 2].leng;
            int secondPitch = tempNotes[madiNotesCnt + 1].pitch;
            int secondAbsPos = getPitchPosition(secondPitch, note.scale);
            int secondCkIndex = check[ckIndex + 1];
            //가운데 음표 점찍기
            widgets.add(Positioned(
              bottom:
                  widgetHeight * 0.22 + secondAbsPos * (0.03 * widgetHeight),
              left: nowPosition +
                  leng / 1000 * interval +
                  secondLeng / 3000 * interval,
              child: Text(
                ".",
                style: TextStyle(
                    fontSize: 30,
                    color: secondCkIndex == 0
                        ? Colors.black
                        : secondCkIndex == 1
                            ? Colors.orange
                            : secondCkIndex == 2
                                ? Colors.greenAccent
                                : secondCkIndex == 4
                                    ? Colors.blueGrey
                                    : Colors.red),
              ),
            ));
            //3
            widgets.add(Positioned(
                bottom: widgetHeight * 0.02,
                left: nowPosition +
                    leng / 1000 * interval +
                    secondLeng / 3000 * interval,
                child: Text("3")));
            //괄호그리기
            for (int i = 0; i < 2; i++) {
              widgets.add(Positioned(
                  bottom: widgetHeight * 0.1,
                  left: nowPosition +
                      leng / 250 +
                      (secondLeng / 1000 * interval +
                              thirdLeng / 1000 * interval) *
                          i,
                  child: Container(
                    width: leng / 1200 * interval,
                    height: 10,
                    color: Colors.black,
                  )));
              widgets.add(Positioned(
                  bottom: widgetHeight * 0.11,
                  left: (nowPosition + leng / 250) +
                      1.2 -
                      2.4 * i +
                      (secondLeng / 1000 * interval +
                              thirdLeng / 1000 * interval) *
                          i,
                  child: Container(
                    width: leng / 1200 * interval,
                    height: 10,
                    color: Colors.white,
                  )));
            }
          }
        }
      }

      //셋잇단음표 표시
      if (isTriplet) {
        // 3 그리기
        if (tripletCnt == 2) {
          widgets.add(Positioned(
              bottom: widgetHeight * 0.02,
              left: nowPosition + leng / 250,
              child: Text("3")));
        }
        // 2분음표이상 괄호 그려주기
        if (leng >= 666) {
          switch (tripletCnt) {
            case 1:
              widgets.add(Positioned(
                  bottom: widgetHeight * 0.1,
                  left: nowPosition + leng / 250,
                  child: Container(
                    width: leng / 1200 * interval,
                    height: 10,
                    color: Colors.black,
                  )));
              widgets.add(Positioned(
                  bottom: widgetHeight * 0.11,
                  left: (nowPosition + leng / 250) + 1.2,
                  child: Container(
                    width: leng / 1200 * interval,
                    height: 10,
                    color: Colors.white,
                  )));
              break;
            case 2:
              widgets.add(Positioned(
                  bottom: widgetHeight * 0.1,
                  left: (nowPosition + leng / 250) + leng / 2500 * interval,
                  child: Container(
                    width: leng / 1200 * interval,
                    height: 10,
                    color: Colors.black,
                  )));
              widgets.add(Positioned(
                  bottom: widgetHeight * 0.11,
                  left:
                      (nowPosition + leng / 250) + leng / 2500 * interval - 1.2,
                  child: Container(
                    width: leng / 1200 * interval,
                    height: 10,
                    color: Colors.white,
                  )));

              break;
          }
        }
      }

      // 셋잇단음표 끝날 시 카운트 리셋
      if (tripletCnt == 3) {
        int baseB = note.scale < 0 || note.scale > 6 ? 70 : 71;
        //여기서 모든걸 그리자
        //1. 세음이 모두 '시'자리 이상이면 꼬리아래
        //2. 하나라도 3옥도#(85)이상이 있으면 꼬리아래
        //3. 이외는 모두 꼬리 위
        bool isDown = false;
        int bCnt = 0;
        tripletPitchs.forEach((tp) {
          if (tp >= baseB) {
            bCnt++;
            if (tp >= 85) {
              isDown = true;
            }
          }
        });
        if (bCnt == 3) {
          isDown = true;
        }
        //=======이까지 위인지 아래인지 판별
        if (leng < 666) {
          //이음줄 그리기
          double thisPos = tripletLeft[0];
          int verticalBaseIndex = 0; //피치가 제일 높은곳
          int tempPitch = 0;
          // 꼬리가 위일때 피치 제일높은곳을 이음줄 위치로, 꼬리가 아래이면 피치 제일 낮은곳을 이음줄 위치로
          for (int i = 0; i < 3; i++) {
            if (isDown) {
              if (tempPitch >= tripletPitchs[i]) {
                verticalBaseIndex = i;
                tempPitch = tripletPitchs[i];
              }
            } else {
              if (tempPitch <= tripletPitchs[i]) {
                verticalBaseIndex = i;
                tempPitch = tripletPitchs[i];
              }
            }
          }
          int maxVerticalPositon =
              getPitchPosition(tripletPitchs[verticalBaseIndex], note.scale);
          double thisVertical = tripletVertical[verticalBaseIndex]; //제일높은곳기준으로
          double leftPos = isDown
              ? thisPos + widgetHeight * 0.01
              : thisPos + widgetHeight / 10.5;
          double bottomPos = 0;
          if (isDown) {
            bottomPos = tempPitch <= baseB
                ? widgetHeight * thisVertical * 0.23 + widgetHeight * 0.25
                : widgetHeight * thisVertical * 0.23;
          } else {
            bottomPos = tempPitch >= baseB
                ? widgetHeight * thisVertical * 0.3 + widgetHeight * 0.72
                : widgetHeight * thisVertical * 0.3 + widgetHeight * 0.47;
          }
          double lineAngle = getAngleForTriplet(tripletPitchs, note.scale);

          int horizontalLineCnt = 0;
          switch (leng) {
            case 41:
              horizontalLineCnt = 4;
              break;
            case 83:
              horizontalLineCnt = 3;
              break;
            case 166:
              horizontalLineCnt = 2;
              break;
            case 333:
              horizontalLineCnt = 1;
              break;
          }

          for (int i = 0; i < horizontalLineCnt; i++) {
            double multiLinePos = i * widgetHeight * 0.05;
            if (!isDown) {
              multiLinePos *= -1;
            }
            widgets.add(Positioned(
              bottom: bottomPos + multiLinePos,
              left: leftPos, // 이건얼추완성
              child: RotationTransition(
                  turns: AlwaysStoppedAnimation(lineAngle), //스케일 미반영 완성
                  child: Container(
                    height: widgetHeight * 0.03, //고정값
                    width: leng / 1000 * interval * 2 +
                        widgetHeight * 0.01, //가로길이 완성, 세로줄두께만큼추가!
                    color: checkckIndex == 0
                        ? Colors.black
                        : checkckIndex == 1
                            ? Colors.orange
                            : checkckIndex == 2
                                ? Colors.greenAccent
                                : checkckIndex == 4
                                    ? Colors.blueGrey
                                    : Colors.red, //여기
                  )),
            ));
          }

          //꼬리그리기 시작
          //기울기가 있으면 사선의 가운데가 바텀포지션
          for (int i = 0; i < 3; i++) {
            double nowPos = tripletLeft[i];
            double nowVertical = tripletVertical[i];
            int nowPitch = tripletPitchs[i];
            double leftPos = isDown
                ? nowPos + widgetHeight * 0.01
                : nowPos + widgetHeight / 10.5;
            double bottomPos = 0;
            if (isDown) {
              bottomPos = nowPitch >= baseB
                  ? widgetHeight * nowVertical * 0.25 + widgetHeight * 0.27
                  : widgetHeight * nowVertical * 0.25;
            } else {
              bottomPos = nowPitch >= baseB
                  ? widgetHeight * nowVertical * 0.3 + widgetHeight * 0.5
                  : widgetHeight * nowVertical * 0.3 + widgetHeight * 0.24;
            }

            //꼬리그리기
            //꼬리아래일때 바텀 마이너스 시키고 하이트추가
            double tempAddedHeight = 0;
            // 기울기 0일경우
            //(thisVertical*1000).floor() == (nowVertical*1000).floor() => 임시표가 붙으면 -1, -2 등 연산이 들어가는데
            // 그때 소숫점 끝자리가 바뀌는 경우가 있슴. 그걸잡아내기위해서...
            int nowABSVertical = getPitchPosition(
                tripletPitchs[i], note.scale); //포문돌고있는 현재의 피치 악보상 포지션인덱스
            //수평
            int addedCnt = nowABSVertical >= maxVerticalPositon
                ? nowABSVertical - maxVerticalPositon
                : maxVerticalPositon - nowABSVertical;
            double shortLine = leng / 1000 * interval * 0.0875; //삼각형 짧은면
            //여기서부터 기울기 별로 로직
            if (lineAngle == 0) {
              //수평일땐 높으 다른애만 추가
              if ((thisVertical * 1000).floor() !=
                  (nowVertical * 1000).floor()) {
                tempAddedHeight = widgetHeight * 1 / 8.5 * 0.3 * addedCnt;
                if (isDown && nowABSVertical < maxVerticalPositon)
                  tempAddedHeight *= -1;
              }
            } else if (lineAngle < 0) {
              //우상일때
              //첫번째일땐 삼각형 짧은 면만큼만..
              //가운데는 addedCnt만
              //마지막은 마이너스 짧은면
              tempAddedHeight = widgetHeight * 1 / 8.5 * 0.3 * addedCnt;
              if (i == 0) {
                tempAddedHeight += isDown ? shortLine : -shortLine;
              } else if (i == 2) {
                tempAddedHeight -= isDown ? shortLine : -shortLine;
              }
            } else {
              //우하일때
              //첫번째일땐 마이너스 짧은면
              //가운데는 addedCnt만
              //마지막은 삼각형 짧은 면만큼만..
              tempAddedHeight = widgetHeight * 1 / 8.5 * 0.3 * addedCnt;
              if (i == 0) {
                tempAddedHeight -= isDown ? shortLine : -shortLine;
              } else if (i == 2) {
                tempAddedHeight *= isDown ? -0.8 : 1;
                tempAddedHeight += isDown ? shortLine : -shortLine;
              }
            }

            int tempCk = check[ckIndex - (2 - i)];

            widgets.add(Positioned(
                bottom: isDown ? bottomPos - tempAddedHeight : bottomPos,
                left: leftPos,
                child: Container(
                  width: widgetHeight * 0.01,
                  height: widgetHeight * 0.25 + tempAddedHeight,
                  color: tempCk == 0
                      ? Colors.black
                      : tempCk == 1
                          ? Colors.orange
                          : tempCk == 2
                              ? Colors.greenAccent
                              : tempCk == 4
                                  ? Colors.blueGrey
                                  : Colors.red,
                )));
          }
        }

        tripletCnt = 0;
        tripletPitchs = [];
        tripletLeft = [];
        tripletVertical = [];
      }

      //같은마디내 동일 위치 임시표 처리 시작
      // isAccidentals : 임시표여부
      // isFlat : 플랫여부 T - b, F - #
      // isNature : 제자리표여부
      // -1 플랫, 0 낫띵, 1 샵, 2 제자리표
      int nowAbsPos =
          getAbsPosition(pitch, note.scale, isAccidentals, isFlat, isNature);
      int nowPosState = absPosNowState[nowAbsPos];
      int nowState = 0;
      if (isAccidentals) {
        if (isNature) {
          nowState = 2;
        } else {
          nowState = isFlat ? -1 : 1;
        }
      }

      if (nowPosState == null) {
        //해당위치의 음이 처음이면 해쉬맵에 추 가
        absPosNowState[nowAbsPos] = nowState;
      } else {
        //해당위치의 음 0 -> 해당위치 갱신만해줌
        if (nowPosState == 0) {
          if (nowState != 0) {
            absPosNowState[nowAbsPos] = nowState;
          }
        } else {
          //해당위치의 음별로 처리
          if (nowPosState == nowState) {
            //해당위치와 현재위치 임시표가 같을경우 임시표 추가 X
            isAccidentals = false;
          } else {
            isAccidentals = true;
            switch (nowPosState) {
              //해당위치 플랫
              case -1:
                switch (nowState) {
                  case 0:
                    isNature = true;
                    break;
                  case 1:
                    isNature = false;
                    isFlat = false;
                    break;
                  case 2:
                    isNature = true;
                    isFlat = false;
                    break;
                }
                break;
              //해당위치 샵
              case 1:
                switch (nowState) {
                  case 0:
                    isNature = true;
                    break;
                  case -1:
                    isNature = false;
                    isFlat = true;
                    break;
                  case 2:
                    isNature = true;
                    isFlat = false;
                    break;
                }
                break;
              //해당위치 제자리표
              case 2:
                switch (nowState) {
                  case 0:
                    isNature = false;
                    isFlat = note.scale < 0 ? true : false;
                    break;
                  case -1:
                    isNature = false;
                    isFlat = true;
                    break;
                  case 1:
                    isNature = false;
                    isFlat = false;
                    break;
                }
                break;
            }
            absPosNowState[nowAbsPos] = nowState;
          }
        }
      }
      // print(
      //     "test : ${nowAbsPos} ${absPosNowState[nowAbsPos]} $nowState ${pitch} ${leng}");

      if (isAccidentals) {
        int tempCntForAccNote = 0;
        if (tempCntForAccNote == 0) {
          String sharpFlat =
              isFlat ? "assets/sheet/fl1.svg" : "assets/sheet/sh1.svg";
          double addPos = isFlat ? widgetHeight * 0.195 : widgetHeight * 0.17;
          double addHorizontalPos =
              isFlat ? widgetHeight * 0.05 : widgetHeight * 0.03;
          //제자리표 위치찾기 해야함 todo 0106
          if (nowAbsPos >= 6) {
            addPos = isFlat ? widgetHeight * 0.45 : widgetHeight * 0.42;
            if (isNature) {
              addPos =
                  nowAbsPos >= 7 ? widgetHeight / 2.5 : widgetHeight * 0.38 + 2;
            }
            addHorizontalPos =
                isFlat ? widgetHeight * 0.05 : widgetHeight * 0.08;
          }
          double accLeftPos = isShort
              ? nowPosition * 1.15 - addHorizontalPos + 1
              : nowPosition - addHorizontalPos + 1;
          if (isNature) {
            accLeftPos += widgetHeight * 0.015;
          }

          widgets.add(Positioned(
            //here
            bottom: isNature
                ? widgetHeight * verticalPosition * 0.3 + addPos
                : widgetHeight * verticalPosition * 0.3 + addPos,
            left: accLeftPos,
            child: SvgPicture.asset(
              isNature ? "assets/sheet/nat1.svg" : sharpFlat,
              color: CHECK_COLOR[checkckIndex],
              height: widgetHeight / 6,
            ),
          ));
        }
      }
      //Note Assets 파일명 분류
      String notePath = "assets/sheet/";
      String noteFileName = "";
      bool isOnRest = false;
      int tempLeng = leng == 41 || leng == 83 || leng == 166 ? 333 : leng;
      if (pitch < 0) {
        noteFileName = "rest$tempLeng.svg";
        if ((leng == madi.rhythmUpper / madi.rhythmUnder * 4000)) {
          noteFileName = "rest4000.svg";
          isOnRest = true;
        }
      } else {
        if (pitch < 71) {
          //시 미만
          if (pitch == 70) {
            if (note.scale >= 7 || note.scale < 0) {
              noteFileName = "note${tempLeng}_2.svg";
            } else {
              noteFileName =
                  pitch == 60 ? "note${tempLeng}_c.svg" : "note$tempLeng.svg";
            }
          } else {
            noteFileName =
                pitch == 60 ? "note${tempLeng}_c.svg" : "note$tempLeng.svg";
          }
        } else {
          //시 이상
          if (pitch < 81) {
            //높은 라 미만
            noteFileName = "note${tempLeng}_2.svg";
          } else {
            //높은 라 이상
            if (pitch > 85) {
              //레
              noteFileName = "note${tempLeng}_2_86.svg";
            } else if (pitch > 83) {
              //도 도#
              noteFileName = "note${tempLeng}_2_84.svg";
            } else if (pitch > 82) {
              //시
              noteFileName = "note${tempLeng}_2_83.svg";
            } else {
              //라 라#
              noteFileName = "note${tempLeng}_2_81.svg";
            }
          }
        }
      }

      ///test
      //

      if (leng >= 4000) {
        if (pitch != -1) {
          int absPos = getPitchPosition(pitch, note.scale);
          if (absPos > 6) {
            verticalPosition += 100 * 0.0045;
          } else {
            verticalPosition -= 100 * 0.0036;
          }
        }
      }

      double leftPos = isTriplet
          ? nowPosition - widgetHeight * 0.070
          : isShort
              ? nowPosition * 1.15 //여기 십육분음표이하
              : nowPosition;
      if (pitch == -1 && leng <= 500) {
        leftPos += widgetHeight * 0.08;
      }

      double svgHeight = pitch != -1
          ? leng >= 4000
              ? widgetHeight / 14
              : widgetHeight / 2
          : leng < 500
              ? widgetHeight / 6
              : leng < 1000
                  ? widgetHeight / 7
                  : leng < 2000
                      ? widgetHeight / 5
                      : widgetHeight / 16;
      double noteWgHeight =
          leng >= 4000 ? widgetHeight * 0.30 : widgetHeight * 0.33;
      double btPos = pitch == -1
          ? widgetHeight * verticalPosition * 0.3 + widgetHeight * 0.23
          : widgetHeight * verticalPosition * 0.3 + widgetHeight * 0.21;

      if (isOnRest) {
        leftPos = madiWidth / 2.1;
        svgHeight = widgetHeight / 18;
        noteWgHeight = widgetHeight * 0.33;
        btPos = widgetHeight * 0.38;
      }

      widgets.add(drawNote(btPos, leftPos, noteWgHeight, svgHeight,
          "$notePath$noteFileName", checkckIndex));

      if (leng <= shortBaseLeng[song.id]) {
        isShort = true;
      } else {
        isShort = false;
      }
      nowPosition = nowPosition + leng / 1000 * interval;
      ckIndex++;
    });

    return Stack(
      children: widgets,
    );
  }

  Widget createCustomMadi(OptionMadi madi, double madiWidth) {
    List<Widget> widgets = [];

    double startPosition = madiWidth * 0.08;
    double endPosition = madiWidth - widgetHeight * endPosInfo[song.id];

    //기본 오선보 삽입
    drawStaff(widgets, madiWidth, widgetHeight);

    // 템포 삽입 곡의 첫마디 위에
    if (madi.isTempoShown) {
      drawTempo(widgets, widgetHeight, thisTempo.floor());
    }

    // 마디끝 삽입
    drawEndLine(widgets, widgetHeight, madiWidth, madi.endType);

    int tempScale = madi.scale;
    int absScale = tempScale < 0 ? tempScale * -1 : tempScale;
    // 음자리표 삽입
    if (madi.isClefShown) {
      drawClef(widgets, true, widgetHeight);
      startPosition = startPosition + widgetHeight / 4;
    }
    if (madi.isScaleShown) {
      drawScale(widgets, tempScale, widgetHeight);
      startPosition = startPosition + widgetHeight / 6 * absScale;
    }

    // 박자표삽입
    if (madi.isRhythmShown) {
      drawRhythem(
          widgets, madi.rhythmUpper, madi.rhythmUnder, widgetHeight, absScale);
      startPosition = startPosition + widgetHeight / 4;
    }

    if (ckIndex == ckLeng - 1) ckIndex = 0;
    double maxOfMadi = madi.rhythmUpper / madi.rhythmUnder * 4000;
    //셋잇단음표 카운트용
    int tripletCnt = 0;
    //셋잇단음표 피치 배열(3번째에서 꼬리모두그림)
    List<int> tripletVerticalIndex = [];
    //셋잇단음표 가로포지션배열
    List<double> tripletLeft = [];
    //셋잇단음표 세로포지션
    List<double> tripletVertical = [];
    //음표그리기 시작
    madi.notes.forEach((note) {
      var checkckIndex = check[ckIndex];
      var leng = note.leng;
      bool isOnRest = false;

      double horizontalPosition =
          startPosition + (endPosition - startPosition) * note.horihontalPos;

      double verticalPosition = getPositionByAbsPos(note.verticalIndex);

      if (maxOfMadi == note.leng && note.isRest) {
        isOnRest = true;
      }

      // 셋잇단음표
      //셋잇단음표 여부
      bool isTriplet = false;
      if (note.leng == 333 ||
          note.leng == 166 ||
          note.leng == 83 ||
          note.leng == 41) {
        isTriplet = true;
        tripletCnt++;
        tripletVerticalIndex.add(note.verticalIndex);
        tripletLeft.add(horizontalPosition);
        tripletVertical.add(verticalPosition);
      }

      if (note.is3Shown) {
        widgets.add(Positioned(
            bottom: widgetHeight * 0.02,
            left: horizontalPosition,
            child: Text("3")));
      }

      if (note.parType > 0) {
        drawParForCustomMadi(
            widgets, widgetHeight, horizontalPosition, note.parType);
      }

      //셋잇단음표 끝날 시 카운트 리셋
      if (tripletCnt == 3) {
        //여기서 모든걸 그리자
        //1. 세음이 모두 '시'자리 이상이면 꼬리아래
        //2. 하나라도 3옥도#(85)이상이 있으면 꼬리아래
        //3. 이외는 모두 꼬리 위
        double lineAngle = 0;
        if (tripletVerticalIndex[0] != tripletVerticalIndex[2]) {
          lineAngle = tripletVerticalIndex[0] > tripletVerticalIndex[2]
              ? 5 / 360
              : -5 / 360;
        }
        bool isDown = false;
        int bCnt = 0;
        tripletVerticalIndex.forEach((tp) {
          if (tp > 6) {
            //도이상
            bCnt++;
            if (tp > 14) {
              isDown = true;
            }
          }
        });
        if (bCnt >= 2) {
          //도가두개이상
          isDown = true;
        }
        //=======이까지 위인지 아래인지 판별
        // 꼬리가 위일때 피치 제일높은곳을 이음줄 위치로, 꼬리가 아래이면 피치 제일 낮은곳을 이음줄 위치로
        int maxVerticalIndex = tripletVerticalIndex[0];
        tripletVerticalIndex.forEach((tp) {
          if (isDown) {
            if (maxVerticalIndex > tp) {
              maxVerticalIndex = tp;
            }
          } else {
            if (maxVerticalIndex < tp) {
              maxVerticalIndex = tp;
            }
          }
        });

        //꼬리그리기 시작
        //기울기가 있으면 사선의 가운데가 바텀포지션
        double middleBottomPos = 0; //가운데 세로선의 바텀포지션(가로선기준용)
        double hLineLeftPos = 0; //가로션 시작점(세로선의 시작점과 일치)
        for (int i = 0; i < 3; i++) {
          int tempCk = check[ckIndex - (2 - i)];

          double oneWeight = widgetHeight * 0.04;
          // 기본 꼬리길이
          double basicHeight = widgetHeight * 0.25;
          // 제일 높은(아래이면 낮은) 음표의 절대 위치와의 현재음과의 차이(길이값)
          double gapWithMax = isDown
              ? (tripletVerticalIndex[i] - maxVerticalIndex) * oneWeight
              : (maxVerticalIndex - tripletVerticalIndex[i]) * oneWeight;

          // 세로선의 길이 : 기본길이와 제일 긴 노트와의 갭만큼 추가
          double hLineHeight = basicHeight + gapWithMax;

          // 세로선의 아래에서부터의 위치 : 꼬리아래이면 현재위치에 갭만큼 빼줌(아래에서부터이니)
          // 꼬리 위이면 갭만큼 안빼줘도됨, 대신 꼬리길이만큼 위치 추가! (아래에서부터이니)
          double vLineBottomPos = isDown
              ? tripletVerticalIndex[i] * oneWeight - gapWithMax
              : tripletVerticalIndex[i] * oneWeight + basicHeight;

          double vLineLeftPos = isDown
              ? tripletLeft[i] + widgetHeight * 0.08
              : tripletLeft[i] + widgetHeight * 0.165;

          if (i == 0) {
            hLineLeftPos = vLineLeftPos;
          } else if (i == 1) {
            //중간음표 세로포지션 담아줌(가로선그릴때쓸꺼)
            middleBottomPos =
                isDown ? vLineBottomPos : vLineBottomPos + hLineHeight;
          }

          // 가로선의 각도가 0이 아닐 때 더해줄 수
          double addHeightAtAngleIsNotZero = 0;
          double addBottomPosAtAngleIsNotZero = 0;
          if (lineAngle != 0 && i != 1) {
            double tan5 = 0.087488;
            double baseLineOfTriAngle = tripletLeft[2] - tripletLeft[0];
            double gapPitagoras = tan5 * baseLineOfTriAngle / 2;

            if (isDown) {
              //바텀포스도
              // 기울기 우하 && 꼬리아래 : 첫번째 - 탄젠트5도값x2(처음과끝을 삼각형 밑변으로 잡아서), 세번째 + 탄젠트5
              // 기울기 우상 && 꼬리아래 : 첫번째 + 탄젠트5도값, 세번째 - 탄젠트5
              addHeightAtAngleIsNotZero =
                  lineAngle > 0 ? -gapPitagoras : gapPitagoras;
              if (i == 2) {
                addHeightAtAngleIsNotZero *= -1;
              }
              addBottomPosAtAngleIsNotZero = -addHeightAtAngleIsNotZero;
              //lineAngle > 0 => 우하
            } else {
              // 기울기 우하 && 꼬리위 : 첫번째 + 탄젠트5도값, 세번째 - 탄젠트5
              // 기울기 우상 && 꼬리위 : 첫번째 - 탄젠트5도값, 세번째 + 탄젠트5
              addHeightAtAngleIsNotZero =
                  lineAngle > 0 ? -gapPitagoras : gapPitagoras;
              if (i == 0) {
                addHeightAtAngleIsNotZero *= -1;
              }
            }
          }

          widgets.add(Positioned(
              bottom: vLineBottomPos + addBottomPosAtAngleIsNotZero,
              left: vLineLeftPos, // 완성
              child: Container(
                  width: widgetHeight * 0.01,
                  height: hLineHeight + addHeightAtAngleIsNotZero,
                  color: CHECK_COLOR[tempCk])));
        }

        //가로선 그리기 시작
        int horizontalLineCnt = 0;
        switch (leng) {
          case 41:
            horizontalLineCnt = 4;
            break;
          case 83:
            horizontalLineCnt = 3;
            break;
          case 166:
            horizontalLineCnt = 2;
            break;
          case 333:
            horizontalLineCnt = 1;
            break;
        }
        for (int i = 0; i < horizontalLineCnt; i++) {
          double multiLinePos = i * widgetHeight * 0.05;
          if (!isDown) {
            multiLinePos *= -1;
          }
          widgets.add(Positioned(
            bottom: middleBottomPos + multiLinePos,
            left: hLineLeftPos, // 이건얼추완성
            child: RotationTransition(
                turns: AlwaysStoppedAnimation(lineAngle),
                child: Container(
                  height: widgetHeight * 0.03, //고정값
                  width:
                      (tripletLeft[2] - tripletLeft[0]) + widgetHeight * 0.01,
                  //가로길이 완성, 세로줄두께만큼추가(widgetHeight * 0.01)!
                  color: CHECK_COLOR[checkckIndex], //여기
                )),
          ));
        }

        tripletCnt = 0;
        tripletVerticalIndex = [];
        tripletLeft = [];
        tripletVertical = [];
      }

      //임시표 삽입
      if (note.accType != 0) {
        widgets.add(drawAccForCustomMadi(note, horizontalPosition,
            verticalPosition, widgetHeight, checkckIndex));
      }

      //Note Assets 파일명 분류
      String notePath = "assets/sheet/";

      double svgHeight = !note.isRest
          ? leng == 4000
              ? widgetHeight / 14
              : widgetHeight / 2
          : leng < 500
              ? widgetHeight / 6
              : leng < 1000
                  ? widgetHeight / 7
                  : leng < 2000
                      ? widgetHeight / 5
                      : widgetHeight / 16;
      double noteWgHeight =
          leng == 4000 ? widgetHeight * 0.30 : widgetHeight * 0.33;
      double btPos = note.isRest
          ? widgetHeight * verticalPosition * 0.3 + widgetHeight * 0.23
          : widgetHeight * verticalPosition * 0.3 + widgetHeight * 0.21;

      if (isOnRest) {
        svgHeight = widgetHeight / 18;
        noteWgHeight = widgetHeight * 0.33;
        btPos = widgetHeight * 0.38;
      }

      //아티큘레이션
      if (note.articType > 0) {
        widgets.add(drawArticulation(
            note, btPos, horizontalPosition, widgetHeight, checkckIndex));
      }

      if (note.leng == 333 ||
          note.leng == 166 ||
          note.leng == 83 ||
          note.leng == 41) {
        if (note.verticalIndex > 5) {
          btPos += widgetHeight * 0.245;
        }
      }

      // 음표 삽입
      widgets.add(drawNote(btPos, horizontalPosition, noteWgHeight, svgHeight,
          "$notePath${note.assetName}", checkckIndex));

      ckIndex++;
    });

    return Stack(
      children: widgets,
    );
  }
}
