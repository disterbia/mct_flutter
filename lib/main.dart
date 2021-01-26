import 'dart:io';

import 'package:aa_test/aboutPage.dart';
import 'package:aa_test/gamePage.dart';
import 'package:aa_test/mypage.dart';
import 'package:aa_test/songList.dart';
import 'package:aa_test/splash.dart';
import 'package:aa_test/temp.dart';
import 'package:aa_test/videoPlayPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'fingeringPage.dart';

final navigatorKey = GlobalKey<NavigatorState>();
void main() {
  return runApp(MaterialApp(
    home: Splash(),
    routes: {
      "mainPage": (context) => MyApp2(),
      "myPage": (context) => MyPage(),
      "videoPlayPage": (context) => VideoPlayPage(),
      "gamePage": (context) => GamePage()
    },
    theme: ThemeData(fontFamily: 'Gmarket'),
    navigatorKey: navigatorKey,
  ));
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  Directory vpath;
  Directory rpath;
  int nameCount = 0;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    directoryCreate();

    super.initState();
  }

  Future<void> directoryCreate() async {
    await Permission.microphone.request();
    await Permission.storage.request();
    await Permission.camera.request();
    var temp = await getApplicationDocumentsDirectory();
    var vvpath = await Directory("${temp.path}/video").create();
    var rrpath = await Directory("${temp.path}/audio").create();
    setState(() {
      vpath = vvpath;
      rpath = rrpath;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final fullScreenSize = MediaQuery.of(context).size;
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Color(0xffefefef),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(fullScreenSize.height * 0.4),
        child: Stack(
          children: [
            ClipPath(
                clipper: CustomShape(),
                child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    height: double.infinity,
                    color: Color(0xff373737),
                    child: Stack(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child:SizedBox(), flex: isPortrait ? 20 : 18),
                            Expanded(child: Align(
                              child: FittedBox(
                                  child: GestureDetector(          onTap: () {
                                    nameCount++;
                                    if (nameCount >= 20) {
                                      nameCount = 0;
                                      scaffoldKey.currentState
                                          .showSnackBar(SnackBar(
                                          content: FittedBox(fit: BoxFit.fill,
                                            child: Text(
                                              "developer: 이지원)010-7979-7191 , 차승한)010-2229-6713",
                                              style: TextStyle(color: Colors.blueAccent,),
                                            ),
                                          )));
                                    }
                                  },
                                    child: Text("리코더 온 교실에  오신 것을\n환영합니다.",
                                        style: TextStyle(color:Colors.white, fontSize: 20, fontWeight: FontWeight.w500, height: 1.5)),
                                  ),
                                  fit:BoxFit.fitHeight
                              ),
                              alignment: Alignment.bottomLeft,),
                                flex: isPortrait ? 16 : 20),
                            Expanded(child:SizedBox(), flex: isPortrait ? 10 : 8),
                            Expanded(child: Center(
                                child:FlatButton(
                                  color: Colors.white,
                                  child:Container(
                                    width: 180,
                                    height:48,
                                    child: Center(child: FittedBox(child: Text("마이페이지",style:TextStyle(color: Colors.black, fontSize: 20)), fit:BoxFit.fitHeight)),
                                  ),
                                  onPressed: () async {
                                    Navigator.push(context, MaterialPageRoute(
                                        builder: (context)=>MyPage(),
                                        settings: RouteSettings(arguments: {"vpath":vpath.path,"rpath":rpath.path})
                                    ));
                                  },
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                )),
                                flex: 12),
                            Expanded(child: SizedBox(), flex: 21),
                          ],
                        ),
                      ],
                    ))),
          ],
        ),
      ),
      body: Container(
          width: fullScreenSize.width,
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                  flex: 1,
                  child: Center(
                      child: InkWell(
                        child: menuContainer("main3", fullScreenSize.width,
                            "리코더 알아보기", "리코더의 역사, 종류, 연주 자세, 텅잉 방법을 알아볼까요?"),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AboutPage(),
                              ));
                        },
                      ))),
              Expanded(
                  flex: 1,
                  child: Center(
                      child: InkWell(
                          child: menuContainer("main1", fullScreenSize.width,
                              "운지법 익히기", "독일식, 바로크식 리코더의 기초적인 운지법 연습을 해봐요."),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FingeringPage(),
                                ));
                          }))),
              Expanded(
                  flex: 1,
                  child: Center(
                      child:InkWell(
                          child: menuContainer("main2", fullScreenSize.width, "연주곡 익히기", "각 단계별 연습곡에 도전해요." ),
                          onTap: (){
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SongList(),
                                ));
                          }))),
            ],
          )),
    );
  }
}

class CustomShape extends CustomClipper<Path> {
  @override
  getClip(Size size) {
    double height = size.height;
    double width = size.width;
    var path = Path();
    path.lineTo(0, height - 50);
    path.quadraticBezierTo(width / 2, height, width, height - 50);
    path.lineTo(width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) {
    return true;
  }
}

Column menuContainer(
    String imageName, double width, String title, String content) {
  return Column(
    children: [
      Expanded(
        child: Container(
          width: width,
          margin: EdgeInsets.symmetric(horizontal: 16),
          height: double.infinity,
          decoration: BoxDecoration(
              color:Colors.white,
              borderRadius: BorderRadius.circular(4)
          ),
          child:Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: Container(
                  child: Center(child: SvgPicture.asset('assets/img/$imageName.svg'))
              ), flex: 8),
              Expanded(child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                    SizedBox(height: 4),
                    Text(content, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, height: 1.5))
                  ],
                ),
              ), flex: 23),
              Expanded(
                  child:SizedBox(),
                  flex: 2
              )
            ],
          ),
        ),
        flex: 6,
      ),
      Expanded(child: SizedBox(), flex: 1)
    ],
  );
}
