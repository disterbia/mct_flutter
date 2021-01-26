import 'dart:io';
import 'dart:async';
import 'package:aa_test/noteParser.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math';

import 'package:pitchdetector/pitchdetector.dart';

class GamePage extends StatefulWidget {
  @override
  GamePageState createState() => GamePageState();
}

class GamePageState extends State<GamePage> {
  int  cnt         = 0;
  int  note        = 7;
  int  currentNoteNum  = 1; //각 단계에서 몇 번 째 음표인지
  int  currentPhaseTab = 0;   //1~7 단계 (0~6)
  bool isGameStarted = false; //시작하기 버튼 눌렀을 때
  bool isWrongNote   = false; //음이 틀렸을 때 (true - 음 틀림, false - 기본 상태)
  bool isCorrectNote = false; //음이 맞았을 때 (true - 음 맞음, false - 기본 상태)
  bool os;
  bool isRecording     = false;
  bool isGermanPressed = true; //독일식 탭 눌렀을 때
  List gameMention     = ['리코더를 불어 주세요.', '정답입니다.', '음이 정확하지 않습니다.'];
  List germanRecorder  = [1, 2,3,4,5,6, 8,10, 11,12, 13,15,17,18, 20,21,22,23,25,28,29,31,32,33,34, 35,36 ]; //27개
  List baroqueRecorder = [1,2,3,4,5,7,9,10,11,12,13,15,17,18,20,21,22,24,27,28,30,31,32,33,34,35,36];
  List<List<int>> phases = [[8,10,12,13,15],[1,3,5,6],[7,11],[17,18,20,22],[9,14,16,19],[12,13,15],[14,16,21,23]];
  List unplayedNoteList = [8,10,12,13,15,8,10,12,13,15,8,10,12,13,15]; //phase * 3
  Pitchdetector detector;
  double pitch;


  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    os = Platform.isAndroid;
    detector = Pitchdetector(
        sampleRate: os ? 44100 : 5514, sampleSize: os ? 4096 : 1024);
    isRecording = isRecording;
    detector.onRecorderStateChanged.listen((event) {
      pitch = event["pitch"];
      if (this.mounted)
        setState(() {
          var dap = gameScore(note);
          if ((pitch ?? 0) <= dap + 20 && (pitch ?? 0) >= dap - 20)
            setState(() {
              if (cnt == 0) {
                if(currentNoteNum == phases[currentPhaseTab].length * 3){
                  gameStop();
                  unplayedNoteList = phases[currentPhaseTab].toList();
                  unplayedNoteList = unplayedNoteList + unplayedNoteList + unplayedNoteList;
                  isGameStarted = false;
                }else{
                  isCorrectNote = true;
                  isWrongNote = false;
                  gameRule();
                  currentNoteNum++;
                }
              }
            });
          else if (cnt == 0)
            setState(() {
              isWrongNote = true;
              isCorrectNote = false;
            });
        });
    });
    super.initState();
  }

  @override
  void dispose() {
    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.landscapeRight,
    //   DeviceOrientation.landscapeLeft,
    //   DeviceOrientation.portraitUp,
    //   DeviceOrientation.portraitDown,
    // ]);
    if(detector.isRecording) detector.stopRecording();
    super.dispose();
  }

  void gameRule() {
    cnt++;
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        unplayedNoteList.removeAt(0);
        note = unplayedNoteList[0] -1;
        isWrongNote = false;
        isCorrectNote = false;
        cnt = 0;
      });
    });
  }

  void gamePlay() async {
    detector.startRecording();
  }

  void gameStop() async {
    detector.stopRecording();
  }

  // int getRandomNote(){
  //   final randomGenerator = Random();
  //   int newNote = -2;
  //   if(unplayedNoteList.length>0){
  //     int newNoteIndex = randomGenerator.nextInt(unplayedNoteList.length);
  //     newNote = unplayedNoteList[newNoteIndex];
  //     unplayedNoteList.removeAt(newNoteIndex);
  //   }
  //   return newNote;
  // }


  @override
  Widget build(BuildContext context) {
    final Map arguments = ModalRoute.of(context).settings.arguments as Map;
    isGermanPressed = arguments["menu"];
    final fullScreenSize = MediaQuery.of(context).size; // responsive
    final dpSuffix = 0.75 * MediaQuery.of(context).devicePixelRatio;
    return Stack(
      children: [
        Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(fullScreenSize.height * 0.15),
            child: AppBar(
              automaticallyImplyLeading: false,
              flexibleSpace: Container(
                  height: double.infinity,
                  color: Color(0xfff6f6f6),
                  child: Stack(
                    children: [
                      SafeArea(
                        child: Container(
                            width:fullScreenSize.width,
                            height:fullScreenSize.height*0.15,
                            alignment:Alignment.bottomRight,
                            child:Wrap(
                              children: [
                                Transform.translate(
                                  offset: Offset(0,0),
                                  child: Container(
                                    width:fullScreenSize.width*0.68,
                                    child:Align(child: Container(
                                      child: ShaderMask(
                                        child: SvgPicture.asset(
                                          'assets/practice/background1.svg',
                                          fit: BoxFit.contain,
                                          alignment: Alignment.bottomRight,
                                          color: Colors.white,
                                        ),
                                        shaderCallback: (Rect bounds) {
                                          return LinearGradient(colors: [
                                            Colors.white,
                                            Colors.white,
                                            Colors.grey
                                          ]).createShader(bounds);
                                        },
                                        blendMode: BlendMode.srcATop,
                                      ),
                                    ),
                                        alignment: Alignment.bottomLeft),
                                  ),
                                ),
                              ],
                            )
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                            padding:
                            EdgeInsets.symmetric(horizontal: 16 * dpSuffix),
                            height: fullScreenSize.height * 0.15,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                    child: Stack(
                                      children: [
                                        Align(
                                          child: InkWell(
                                            child: FittedBox(
                                                child: Icon(Icons.arrow_back,
                                                    color: Colors.black),
                                                fit: BoxFit.fitHeight),
                                            onTap: () =>
                                                Navigator.of(context).pop(), //뒤로가기,
                                          ),
                                          alignment: Alignment.centerLeft,
                                        ),
                                        Center(
                                            child: FittedBox(
                                                child: Text(isGermanPressed?"독일식":"바로크식",
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.w500,
                                                        fontSize: 20)),
                                                fit:BoxFit.fitHeight
                                            )),
                                        SizedBox(),
                                      ],
                                    ),
                                    flex: 1),
                                Expanded(
                                    child: Container(
                                        child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            shrinkWrap: true,
                                            itemCount: 7,
                                            itemBuilder:(BuildContext context, int index) {
                                              return InkWell(
                                                  child: Container(
                                                    height: double.infinity,
                                                    padding: EdgeInsets.fromLTRB(0,0,40,8),
                                                    child: Align(
                                                        child: Text(
                                                            '${index+1}',
                                                            style: TextStyle(
                                                                fontWeight: currentPhaseTab == index ? FontWeight.bold: FontWeight.w500,
                                                                color:Colors.black,fontSize: 20)), alignment: Alignment .bottomCenter),
                                                  ),
                                                  onTap: () { // 단계 탭 눌렀을 때
                                                    currentPhaseTab = index;
                                                    setState(() {
                                                      unplayedNoteList = phases[currentPhaseTab].toList();
                                                      unplayedNoteList = unplayedNoteList + unplayedNoteList + unplayedNoteList;
                                                      note = unplayedNoteList[0]-1; // 각 단계의 첫 음을 보여줌
                                                      currentNoteNum = 1;
                                                      if(isGameStarted == true){
                                                        gameStop();
                                                        isGameStarted = false;
                                                      }
                                                    });
                                                  });
                                            })),
                                    flex: 1)
                              ],
                            )),
                      ), //1~7 탭 단계
                    ],
                  )),
              elevation: 0,
            ),
          ),
          body: SafeArea(
            child: Container(
              decoration: new BoxDecoration(
                  color: Color(0xff373737),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8 * dpSuffix),
                      topRight: Radius.circular(8 * dpSuffix))),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8 * dpSuffix),
                child: Column(
                  children: [
                    Expanded(child: SizedBox(), flex: 6),
                    Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                                child: FittedBox(
                                    child: Icon(Icons.circle,
                                        color: Color(0xff5656ff)),
                                    fit: BoxFit.fill)),
                            Container(
                                child: Text('  왼손',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16))),
                            Container(
                                child: SizedBox(
                                  width: 9 * dpSuffix,
                                )),
                            Container(
                                child: FittedBox(
                                    child: Icon(Icons.circle,
                                        color: Color(0xffff5151)),
                                    fit: BoxFit.fill)),
                            Container(
                                child: Text('  오른손',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16))),
                          ],
                        ),
                        flex: 5),
                    Expanded(
                        child: Row(
                          children: [
                            Expanded(child: SizedBox(), flex: 35),
                            Expanded(child: SizedBox(), flex: 36),
                            Expanded(child: SizedBox(), flex: 10)
                          ],
                        ),
                        flex: 8),
                    Expanded(
                      //리코더 이미지
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(child: SizedBox(), flex: 10), //공백
                            Expanded(
                                child: FittedBox(child: SvgPicture.asset('assets/practice/recorder/${isGermanPressed ? germanRecorder[note] : baroqueRecorder[note]}.svg'),fit:BoxFit.fitHeight),
                                flex: 15), //리코더
                            Expanded(child: SizedBox(), flex: 10), //공백
                            Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(child:Stack(
                                      children: [
                                        Align(
                                            child: Container(
                                              width: double.infinity,
                                              child: FittedBox(
                                                  child: Opacity(
                                                      child: Text(isWrongNote ? gameMention[2] : isCorrectNote ? gameMention[1] : gameMention[0],
                                                        style: TextStyle(color:isWrongNote?Colors.red:Color(0xff00A40B),
                                                            // decoration: TextDecoration.underline,decorationThickness: 1.5,
                                                            // decorationColor: isWrongNote?Color(0xff828282):Color(0xff00A40B),
                                                            // shadows: [Shadow(color:isWrongNote?Color(0xff828282):Color(0xff00A40B),
                                                            //     offset:Offset(0,-3))],
                                                            fontSize: 14),),
                                                      opacity:isGameStarted?1:0
                                                  ),
                                                  fit:BoxFit.fitWidth
                                              ),
                                            ),
                                            alignment:Alignment.topCenter
                                        ),
                                        Align(
                                            child: Container(
                                              width:double.infinity,
                                              child: FittedBox(child: isCorrectNote? ConstrainedBox(constraints: BoxConstraints(minWidth: 1, minHeight: 1),child: SvgPicture.asset('assets/practice/correctNotesBlack/${note+1}.svg'))
                                                  : ConstrainedBox(constraints:BoxConstraints(minWidth: 1, minHeight: 1),child: SvgPicture.asset('assets/practice/notes/${note+1}.svg', color: Colors.white,)),fit:BoxFit.fitWidth),
                                            ),
                                            alignment:Alignment.bottomCenter
                                        ),
                                      ],
                                    ), flex:29),
                                    Expanded(child: SizedBox(), flex: 4),
                                    Expanded(
                                        child: Center(
                                            child: Text("$currentNoteNum/${phases[currentPhaseTab].length * 3}",
                                                style: TextStyle(
                                                    color: Color(0xff949494),
                                                    fontSize: 16))),
                                        flex: 3), //위 아래 버튼
                                    Expanded(child: SizedBox(), flex: 3),
                                    Expanded(
                                        child: InkWell(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(
                                                  4 * dpSuffix),
                                            ),
                                            child: Center(
                                                child: Text(
                                                    isGameStarted ? "종료하기" : "시작하기",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 16,
                                                        fontWeight:
                                                        FontWeight.bold))),
                                          ),
                                          onTap: () {
                                            isGameStarted = !isGameStarted;
                                            currentNoteNum = 1;
                                            unplayedNoteList = phases[currentPhaseTab].toList();
                                            unplayedNoteList = unplayedNoteList + unplayedNoteList + unplayedNoteList; //3회 반복
                                            note = unplayedNoteList[0]-1; // 각 단계의 첫 음을 보여줌
                                            if(isGameStarted == false){ //종료됨
                                              gameStop();
                                            }else{//시작됨됨
                                              gamePlay();
                                            }
                                            setState(() {
                                              isWrongNote=false;
                                              isCorrectNote=false;
                                            });
                                          },
                                        ),
                                        flex: 6), //시작/종료하기 버튼
                                    Expanded(child: SizedBox(), flex: 7), //3 with timer, now it's 7.
                                    // Expanded(child: Container( // 타이머 부분 삭제됨.
                                    //   height: double.infinity,
                                    //   child:FittedBox(
                                    //     child: Opacity(child: Center(child:Text("0:${timeCounter>9? timeCounter : '0'+timeCounter.toString()}", style: TextStyle(color:Colors.white))),
                                    //     opacity: isGameStarted ? 1.0 : 0.0),
                                    //     fit:BoxFit.fitHeight
                                    //   )
                                    // ), flex: 4),
                                    Expanded(child: SizedBox(), flex: 3),
                                  ],
                                ),
                                flex: 36), //여러가지
                            Expanded(child: SizedBox(), flex: 10), //공백
                          ],
                        ),
                        flex: 108),
                    Expanded(child: SizedBox(), flex: 9),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}


