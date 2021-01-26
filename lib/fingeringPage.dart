import 'dart:io';
import 'dart:math';
import 'package:aa_test/myNativeBridge.dart';
import 'package:aa_test/noteParser.dart';
import 'package:aa_test/informPage.dart';
import 'package:flutter/services.dart';
import 'package:pitchdetector/pitchdetector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FingeringPage extends StatefulWidget {
  @override
  FingeringPageState createState() => FingeringPageState();
}

class FingeringPageState extends State<FingeringPage> {
  int    note            = 0; //note파일의 이름과 1씩 차이남.
  double pitch;
  bool   os;
  bool   isRecording     = false;
  bool   isGermanPressed = true; //독일식 탭 눌렀을 때
  bool   isGameStarted   = false;//게임하기 버튼 눌렀을 때
  bool   isWrongNote     = false;//음이 틀렸을 때 (true - 음 틀림, false - 기본 상태)
  bool   isCorrectNote   = false;//음이 맞았을 때 (true - 음 맞음, false - 기본 상태)
  List   gameMention     = ['리코더를 불러 주세요.', '정답입니다.', '음이 정확하지 않습니다.'];
  List   germanRecorder  = [1,2,3,4,5,6,8,10,11,12,13,15,17,18,20,21,22,23,25,28,29,31,32,33,34,35,37]; //27개
  List   baroqueRecorder = [1,2,3,4,5,7,9,10,11,12,13,15,17,18,20,21,22,24,27,28,30,31,32,33,34,36,37];
  Pitchdetector detector;

  @override
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
      if(this.mounted)      setState(() {
        var dap = gameScore(note);
        if((pitch??0) <= dap + 70 && (pitch??0) >= dap - 40)
          setState(() {
            isCorrectNote=true;
            isWrongNote=false;
          });
        else setState(() {
          isWrongNote=true;
          isCorrectNote=false;
        });
      });

    });
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    if(detector.isRecording)
      detector.stopRecording();
    super.dispose();
  }

  void gamePlay() async{
    detector.startRecording();
  }
  void gameStop() async{
    detector.stopRecording();
  }

  @override
  Widget build(BuildContext context) {
    final fullScreenSize = MediaQuery.of(context).size; // responsive
    final pixelRatio = MediaQuery.of(context).devicePixelRatio; //dp = dp pixel 변환값 * pixelRatio 해야함
    final dpSuffix   = 0.75 * pixelRatio;
    InformModal modal = InformModal();

    return Scaffold(
      backgroundColor: Color(0xff373737),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(fullScreenSize.height * 0.15),
        child:AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
              height:double.infinity,
              color:Color(0xff373737),
              child: Stack(
                children: [
                  Container(
                      width:fullScreenSize.width,
                      height:fullScreenSize.height*0.15+24,
                      alignment:Alignment.bottomRight,
                      child:Wrap(
                        children: [
                          Transform.translate(
                            offset: Offset(0,10),
                            child: Container(
                              width:fullScreenSize.width*0.68,
                              child:Align(child: Container(
                                  child: Opacity(child: SvgPicture.asset('assets/practice/background1.svg', fit:BoxFit.scaleDown, alignment: Alignment.bottomRight,color: Colors.white,),opacity:0.1)
                              ),
                                  alignment: Alignment.bottomLeft),
                            ),
                          ),
                        ],
                      )
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16*dpSuffix),
                        height:fullScreenSize.height * 0.15,
                        child:Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                child:Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 16*0.75),
                                  child: InkWell(
                                    child: FittedBox(child: Icon(Icons.arrow_back, color: Colors.white),fit:BoxFit.fitHeight),
                                    onTap: () => Navigator.of(context).pop(), //뒤로가기,
                                  ),
                                ),
                                flex:1
                            ),
                            Expanded(
                                child: Container(
                                  child: Row(
                                    children: [
                                      InkWell(
                                          child: Container(
                                              child: Align(child: Text('독일식',style: TextStyle(fontWeight: isGermanPressed?FontWeight.bold:FontWeight.normal, color:Colors.white, fontSize:20,)),alignment: Alignment.bottomCenter,),
                                              height:double.infinity,
                                              padding:EdgeInsets.symmetric(vertical: 8)
                                          ),
                                          onTap:(){
                                            setState(() {
                                              isGermanPressed = true;
                                              isWrongNote=false;
                                              isCorrectNote=false;
                                            });
                                          }
                                      ),
                                      SizedBox(
                                        width: 40,
                                      ),
                                      InkWell(
                                          child: Container(
                                              child: Align(child: Text('바로크식',style: TextStyle(fontWeight: isGermanPressed?FontWeight.normal:FontWeight.bold, color:Colors.white,  fontSize:20)),alignment: Alignment.bottomCenter,),
                                              height:double.infinity,
                                              padding:EdgeInsets.symmetric(vertical: 8)
                                          ),
                                          onTap:(){
                                            setState(() {
                                              isGermanPressed = false;
                                              isWrongNote=false;
                                              isCorrectNote=false;
                                            });
                                          }
                                      ),
                                    ],
                                  ),
                                ),
                                flex:1
                            )
                          ],
                        )
                    ),
                  ),
                  Align(child:Container(
                      child: FlatButton(
                        padding: EdgeInsets.all(3),
                        color: Colors.white,
                        shape:CircleBorder(),
                        child:SvgPicture.asset('assets/practice/question.svg', fit:BoxFit.contain, alignment: Alignment.bottomRight,),
                        onPressed: (){
                          modal.informRecorderModal(context, isGermanPressed);
                        },
                      ),
                      padding:EdgeInsets.symmetric(vertical: 8*dpSuffix)
                  ),
                    alignment: Alignment.bottomRight,)
                ],
              )
          ),
          elevation: 0,
        ),
      ),
      body:SafeArea(
        child: Container(
          width: fullScreenSize.width,
          height: fullScreenSize.height*0.85,
          decoration: new BoxDecoration(
              color: Color(0xfff2f2f2),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8))
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Expanded(
                    child: SizedBox(),
                    flex:6
                ),
                Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(child: FittedBox(child: Icon(Icons.circle, color:Color(0xff5656ff)),fit:BoxFit.fill)),
                        Container(child: Text('  왼손',style:TextStyle(color:Colors.black,fontSize:14))),
                        Container(child: SizedBox(width: 9*dpSuffix,)),
                        Container(child: FittedBox(child: Icon(Icons.circle, color:Color(0xffff5151)),fit:BoxFit.fill)),
                        Container(child: Text('  오른손',style:TextStyle(color:Colors.black,fontSize:14))),
                      ],
                    ),
                    flex:5
                ),
                Expanded(
                    child: Row(
                      children: [
                        Expanded(
                            child:SizedBox(),
                            flex:35
                        ),
                        Expanded(
                            child: SizedBox(),
                            flex:36
                        ),
                        Expanded(
                            child:SizedBox(),
                            flex:10
                        )
                      ],
                    ),
                    flex:8
                ),
                Expanded( //리코더 이미지
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                            child:SizedBox(),
                            flex:10
                        ), //공백
                        Expanded(
                            child:FittedBox(child: SvgPicture.asset('assets/practice/recorder/${isGermanPressed ? germanRecorder[note] : baroqueRecorder[note]}.svg'),fit:BoxFit.fitHeight),
                            flex:15
                        ), //리코더
                        Expanded(
                            child:SizedBox(),
                            flex:10
                        ), //공백
                        Expanded(
                            child:Column(
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
                                                    style: TextStyle(color:isWrongNote?Colors.red:Color(0xff00A40B)
                                                        // , decoration: TextDecoration.underline,decorationThickness: 1.5,
                                                        // decorationColor: isWrongNote?Color(0xff828282):Color(0xff00A40B),
                                                        // shadows: [Shadow(color:isWrongNote?Color(0xff828282):Color(0xff00A40B),
                                                        //     offset:Offset(0,-3))]
                                                           ,fontSize: 14
                                                    )
                                                    ,),
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
                                          child:FittedBox(child: isCorrectNote? ConstrainedBox(constraints: BoxConstraints(minWidth: 1, minHeight: 1),child: SvgPicture.asset('assets/practice/correctNotesBlack/${note+1}.svg'))
                                              : ConstrainedBox(constraints:BoxConstraints(minWidth: 1, minHeight: 1),child: SvgPicture.asset('assets/practice/notes/${note+1}.svg')),fit:BoxFit.fitWidth),
                                        ),
                                        alignment:Alignment.bottomCenter
                                    ),
                                  ],
                                ), flex:29),
                                Expanded(child:SizedBox(), flex:3),
                                Expanded(child:Row(
                                  children: [
                                    Expanded(
                                        child: InkWell(
                                          child:Container(
                                            decoration: BoxDecoration(
                                              color:Colors.white,
                                              borderRadius: BorderRadius.circular(4*dpSuffix),
                                            ),
                                            child:SvgPicture.asset('assets/practice/updown.svg'),
                                          ),
                                          onTap: (){
                                            if(note<26){
                                              setState(() {
                                                isCorrectNote=false;
                                                isWrongNote=false;
                                                note++;
                                              });
                                            }
                                          },
                                        ),
                                        flex:4
                                    ),
                                    Expanded(
                                        child:SizedBox(),
                                        flex:1
                                    ),
                                    Expanded(
                                        child: InkWell(
                                          child:Container(
                                              decoration: BoxDecoration(
                                                color:Colors.white,
                                                borderRadius: BorderRadius.circular(4*dpSuffix),
                                              ),
                                              child:Transform.rotate(angle: pi, alignment: Alignment.center, child:SvgPicture.asset('assets/practice/updown.svg'))
                                          ),
                                          onTap: (){
                                            if(note>0){
                                              setState(() {
                                                isCorrectNote=false;
                                                isWrongNote=false;
                                                note--;
                                              });
                                            }
                                          },
                                        ),
                                        flex:4
                                    )
                                  ],
                                ), flex:5), //위 아래 버튼
                                Expanded(child:SizedBox(), flex:2),
                                Expanded(child:InkWell(
                                  child:Container(
                                    decoration: BoxDecoration(
                                      color:Colors.black,
                                      borderRadius: BorderRadius.circular(4*dpSuffix),
                                    ),
                                    child:Center(child: Text(isGameStarted? "종료하기": "불어보기", style: TextStyle(color:Colors.white,fontSize: 16, fontWeight: FontWeight.bold))),
                                  ),
                                  onTap:(){
                                    isGameStarted?gameStop():gamePlay();
                                    setState(() {
                                      isGameStarted = !isGameStarted;
                                      isWrongNote=false;
                                      isCorrectNote=false;
                                    });
                                  },
                                ), flex:6), //종료하기 버튼
                                Expanded(child:SizedBox(), flex:2),
                                Expanded(child:InkWell(
                                  child:Container(
                                    decoration: BoxDecoration(
                                      color:isGameStarted?  Color(0xff949494) : Colors.black,
                                      borderRadius: BorderRadius.circular(4*dpSuffix),
                                    ),
                                    child:Center(child: Text("게임하기", style: TextStyle(color:Colors.white, fontSize:16, fontWeight: FontWeight.bold,))),
                                  ),
                                  onTap: (){
                                    if(!isGameStarted){
                                      Navigator.pushNamed(context, "gamePage",arguments: {"menu":isGermanPressed});
                                    }
                                  },
                                ), flex:6), //게임하기 버튼튼
                                Expanded(child:SizedBox(), flex:2),
                              ],
                            ),
                            flex:36
                        ), //여러가지
                        Expanded(
                            child:SizedBox(),
                            flex:10
                        ), //공백
                      ],
                    ),
                    flex:108
                ),
                Expanded(
                    child: SizedBox(),
                    flex:9
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }





}

/*
Navigator.push(
  context,
  MaterialPageRoute(
  builder: (context) => GamePage(),
  )
);
 */

/*
TweenAnimationBuilder<Duration>(
                                duration: Duration(minutes: 3),
                                tween: Tween(begin: Duration(minutes: 3), end: Duration.zero),
                                onEnd: () {
                                  print('Timer ended');
                                },
                                builder: (BuildContext context, Duration value, Widget child) {
                                  final minutes = value.inMinutes;
                                  final seconds = value.inSeconds % 60;
                                  return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 5),
                                      child: Text('$minutes:$seconds',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 30)));
                                });
 */