import 'package:aa_test/model/last_note.dart';
import 'package:aa_test/player.dart';
import 'package:aa_test/songdb.dart';
import 'package:flutter/material.dart';
import 'package:aa_test/model/song.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_provider/path_provider.dart' as path;
import 'dart:math';
import 'package:headset_connection_event/headset_event.dart';

class SongList extends StatefulWidget {
  @override
  _SongListState createState() => _SongListState();
}

class _SongListState extends State<SongList> {
  bool tabable = true;
  bool isFirst = true;
  Song song;
  int currentPhase = 0;
  var result = []; // 퓨처빌더에서 읽어온 데이터
  var isGoodList = [[], [], [], [], [], [], [], [], []];
  var tempoList = [0.8, 1.0, 1.2];
  var levelSongs = [[], [], [], [], [], [], [], [], []];
  List titles = [
    '왼손 연습',
    '왼손 + 오른손 연습',
    '사이음 연습 1',
    '높은 음 연습 1',
    '사이음 연습 2',
    '높은 음 연습 2',
    '사이음 연습 3',
    '이음줄, 스타카토, 더블텅잉,',
    '소프라노 리코더로'
  ];
  List subTitles = [
    '',
    '',
    '(시b, 파#)',
    '(미, 파, 솔, 라)',
    '(높은 미b, 높은 파#, 높은 도#, 솔#)',
    '(시, 도, 레)',
    '(그 밖의 사이음)',
    '트리플텅잉, 트릴',
    '연주하는 클래식 명곡 테마'
  ];
  HeadsetEvent headsetPlugin = HeadsetEvent();
  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    // headsetPlugin.setListener((_val) {
    //   MidiPlayer().newSeqJustOnly();
    //   // showDialog(context: context,builder: (context) {
    //   //   return AlertDialog(title: Text("오디오 채널변경"),content: Text("오디오 채널이 변경되었습니다.\n앱을 재실행해주세요."),actions: [
    //   //     FlatButton(onPressed: ()=>os?SystemNavigator.pop():exit(0), child: Text("OK"))
    //   //   ],);
    //   // },);
    // });
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    path
        .getExternalStorageDirectory()
        .then((value) => print("1.${value.path}")); //android
    path
        .getApplicationDocumentsDirectory()
        .then((value) => print("2.${value.path}")); //ios
    path
        .getApplicationSupportDirectory()
        .then((value) => print("3.${value.path}"));
    path.getTemporaryDirectory().then((value) => print("4.${value.path}"));
    final fullScreenSize = MediaQuery.of(context).size;
    return Container(
      width: fullScreenSize.width,
      height: fullScreenSize.height,
      decoration: BoxDecoration(
        color: Color(0xff373737),
        image: DecorationImage(
            image: AssetImage('assets/img/songlist/backgroundImage2.png'),
            fit: BoxFit.fill),
      ),
      child: Scaffold(
          backgroundColor: Color(0xff373737).withOpacity(0.9),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(), //뒤로가기
            ),
          ),
          body: isFirst
              ? FutureBuilder(
              future: getAllSongs(currentPhase + 1),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done)
                  return CircularProgressIndicator();
                result = snapshot.data;
                isFirst = false;
                levelSongs[currentPhase].clear();
                result.forEach((element) {
                  levelSongs[element.level - 1].add(element);
                });
                return Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        Expanded(
                          //좌우버튼, 중간 뱃지
                            child: Stack(
                              children: [
                                Column(
                                  children: [
                                    Expanded(child: SizedBox(), flex: 6),
                                    Expanded(
                                        child: Stack(
                                          children: [
                                            Center(
                                                child: SvgPicture.asset(
                                                    'assets/img/songlist/${currentPhase == 0 ? 'blue' : currentPhase < 7 ? 'yellow' : 'red'}.svg')),
                                            Center(
                                                child: Text(
                                                    "${currentPhase + 1}",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 28,
                                                        fontWeight:
                                                        FontWeight
                                                            .bold)))
                                          ],
                                        ),
                                        flex: 16),
                                    Expanded(child: SizedBox(), flex: 27)
                                  ],
                                ),
                                Column(
                                  children: [
                                    Expanded(child: SizedBox(), flex: 15),
                                    Expanded(
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: InkWell(
                                                  child: SvgPicture.asset(
                                                      'assets/img/songlist/arrow_2.svg'),
                                                  onTap: () {
                                                    if (currentPhase > 0) {
                                                      setState(() {
                                                        currentPhase--;
                                                        isFirst = true;
                                                      });
                                                    }else{
                                                      setState(() {
                                                        currentPhase=8;
                                                        isFirst=true;
                                                      });
                                                    }
                                                  }),
                                              flex: 7,
                                            ),
                                            Expanded(
                                                child: SizedBox(),
                                                flex: 79),
                                            Expanded(
                                                child: InkWell(
                                                    child: Transform.rotate(
                                                        angle: pi,
                                                        alignment: Alignment
                                                            .center,
                                                        child: SvgPicture.asset(
                                                            'assets/img/songlist/arrow_2.svg')),
                                                    onTap: () {
                                                      if (currentPhase <
                                                          8) {
                                                        setState(() {
                                                          currentPhase++;
                                                          isFirst = true;
                                                        });
                                                      }else{
                                                        setState(() {
                                                          currentPhase=0;
                                                          isFirst=true;
                                                        });
                                                      }
                                                    }),
                                                flex: 7),
                                          ],
                                        ),
                                        flex: 12),
                                    Expanded(child: SizedBox(), flex: 2),
                                    Expanded(
                                        child: Text(titles[currentPhase],
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20),
                                            textAlign: TextAlign.center),
                                        flex: 6),
                                    Expanded(child: SizedBox(), flex: 2),
                                    Expanded(
                                        child: Text(
                                          subTitles[currentPhase],
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: currentPhase >= 7
                                                  ? FontWeight.bold
                                                  : FontWeight.w100,
                                              fontSize: currentPhase >= 7
                                                  ? 20
                                                  : 16),
                                          textAlign: TextAlign.center,
                                        ),
                                        flex: 6),
                                    Expanded(child: SizedBox(), flex: 9)
                                  ],
                                )
                              ],
                            ),
                            flex: 16),
                        Expanded(
                          //곡 리스트
                            child: Container(
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount:
                                levelSongs[currentPhase].length == 0
                                    ? 5
                                    : levelSongs[currentPhase].length,
                                itemBuilder:
                                    (BuildContext context, int index) {
                                  bool isLengthZero =
                                      levelSongs[currentPhase].length == 0;
                                  var isGood = 0;
                                  if (levelSongs[currentPhase].length !=
                                      0) {
                                    song = levelSongs[currentPhase][index];
                                    isGoodList[currentPhase]
                                        .add(song.isGood);
                                    isGood =
                                    isGoodList[currentPhase][index];
                                  }

                                  double allHeight = (fullScreenSize
                                      .height -
                                      AppBar().preferredSize.height) *
                                      25 /
                                      41;
                                  return songListTile(song, isGood, index,
                                      isLengthZero, allHeight / 6.9);
                                },
                              ),
                            ),
                            flex: 25),
                      ],
                    ));
              })
              : Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Expanded(
                    //좌우버튼, 중간 뱃지
                      child: Stack(
                        children: [
                          Column(
                            children: [
                              Expanded(child: SizedBox(), flex: 6),
                              Expanded(
                                  child: Stack(
                                    children: [
                                      Center(
                                          child: SvgPicture.asset(
                                              'assets/img/songlist/${currentPhase == 0 ? 'blue' : currentPhase < 8 ? 'yellow' : 'red'}.svg')),
                                      Center(
                                          child: Text("${currentPhase + 1}",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 28,
                                                  fontWeight:
                                                  FontWeight.bold)))
                                    ],
                                  ),
                                  flex: 16),
                              Expanded(child: SizedBox(), flex: 27)
                            ],
                          ),
                          Column(
                            children: [
                              Expanded(child: SizedBox(), flex: 15),
                              Expanded(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: InkWell(
                                            child: SvgPicture.asset(
                                                'assets/img/songlist/arrow_2.svg'),
                                            onTap: () {
                                              if (currentPhase > 0) {
                                                setState(() {
                                                  currentPhase--;
                                                  isFirst = true;
                                                });
                                              }
                                            }),
                                        flex: 7,
                                      ),
                                      Expanded(child: SizedBox(), flex: 79),
                                      Expanded(
                                          child: InkWell(
                                              child: Transform.rotate(
                                                  angle: pi,
                                                  alignment:
                                                  Alignment.center,
                                                  child: SvgPicture.asset(
                                                      'assets/img/songlist/arrow_2.svg')),
                                              onTap: () {
                                                if (currentPhase < 8) {
                                                  setState(() {
                                                    currentPhase++;
                                                    isFirst = true;
                                                  });
                                                }
                                              }),
                                          flex: 7),
                                    ],
                                  ),
                                  flex: 12),
                              Expanded(child: SizedBox(), flex: 2),
                              Expanded(
                                  child: Text(titles[currentPhase],
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20),
                                      textAlign: TextAlign.center),
                                  flex: 6),
                              Expanded(child: SizedBox(), flex: 2),
                              Expanded(
                                  child: Text(
                                    subTitles[currentPhase],
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: currentPhase >= 7
                                            ? FontWeight.bold
                                            : FontWeight.w100,
                                        fontSize:
                                        currentPhase >= 7 ? 20 : 16),
                                    textAlign: TextAlign.center,
                                  ),
                                  flex: 6),
                              Expanded(child: SizedBox(), flex: 9)
                            ],
                          )
                        ],
                      ),
                      flex: 16),
                  Expanded(
                    //곡 리스트
                      child: Container(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: levelSongs[currentPhase].length == 0
                              ? 5
                              : levelSongs[currentPhase].length,
                          itemBuilder: (BuildContext context, int index) {
                            bool isLengthZero =
                                levelSongs[currentPhase].length == 0;
                            var isGood = 0;
                            if (levelSongs[currentPhase].length != 0) {
                              song = levelSongs[currentPhase][index];
                              isGoodList[currentPhase].add(song.isGood);
                              isGood = isGoodList[currentPhase][index];
                            }
                            double allHeight = (fullScreenSize.height -
                                AppBar().preferredSize.height) *
                                25 /
                                41;
                            return songListTile(song, isGood, index,
                                isLengthZero, allHeight / 6.9);
                          },
                        ),
                      ),
                      flex: 25),
                ],
              ))),
    );
  }

  Widget songListTile(
      Song song, int isGood, int i, bool isLengthZero, double tileHeight) {
    return GestureDetector(
      onTap: () {
        if (tabable) {
          tabable = false;
          test1(levelSongs[currentPhase][i]);
        }
      },
      child: Container(
          height: tileHeight,
          margin: EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4), color: Color(0xff3e3e3e)),
          child: Row(
            children: [
              Expanded(
                child: Container(
                    child: currentPhase + 1 >= 8
                        ? // 8단계 이상인가?
                    SvgPicture.asset('assets/img/songlist/list5.svg')
                        : SvgPicture.asset(
                        'assets/img/songlist/list${i + 1}.svg')),
                flex: 1,
              ),
              //일단은 레벨에 곡이 없으면 nodata로 뜨게 함
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: SizedBox(), flex: 1),
                    Expanded(
                        child: FittedBox(
                          child: Text(
                              isLengthZero
                                  ? 'nodata'
                                  : levelSongs[currentPhase][i].title,
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white)),
                          fit: BoxFit.fitHeight,
                        ),
                        flex: 1),
                    Expanded(child: SizedBox(), flex: 1)
                  ],
                ),
                flex: 3,
              ), //db에서 이름 받아오기
              Expanded(
                  child: GestureDetector(
                      child: Icon(
                        Icons.favorite,
                        color: isGood == 1 ? Colors.red : Color(0xff949494),
                      ),
                      onTap: () {
                        setState(() {
                          if (isGood == 1) {
                            isGoodList[currentPhase][i] = 0;
                            updateSong(Song(
                                id: song.id,
                                title: song.title,
                                isGood: 0,
                                tempo: song.tempo,
                                midPath: song.midPath,
                                scale: song.scale,
                                history: song.history,
                                level: song.level));
                          } else {
                            isGoodList[currentPhase][i] = 1;
                            updateSong(Song(
                                id: song.id,
                                title: song.title,
                                isGood: 1,
                                midPath: song.midPath,
                                tempo: song.tempo,
                                scale: song.scale,
                                history: song.history,
                                level: song.level));
                          }
                        });
                      }),
                  flex: 1)
            ],
          )),
    );
  }

  void test1(Song song) {
    midiInit(song.midPath, song, () {
      if (LAST_NOTE[song.id] != null) {
        LAST_NOTE[song.id].forEach((lastNote) {
          song.notes.add(lastNote);
        });
      }
      Navigator.pushNamed(context, "mainPage", arguments: {"song": song});
      tabable = true;
    });
  }

  Future<List<Song>> getAllSongs(int level) async {
    SongDb db = SongDb();
    return await db.getAllSongs(level);
  }

  Future<void> updateSong(Song song) async {
    SongDb db = SongDb();
    await db.updateSong(song);
  }

// void setTempo(Song song) {
//   tabable = true;
//   showDialog(
//     context: context,
//     builder: (context) {
//       return AlertDialog(
//           title: Text("템포설정"),
//           content: Container(
//             height: MediaQuery.of(context).size.height / 5,
//             width: MediaQuery.of(context).size.width / 5,
//             child: ListView.builder(
//                 itemCount: tempoList.length,
//                 itemBuilder: (context, index) {
//                   return RaisedButton(
//                     onPressed: () {
//                       test1(song.midPath, song, song.title, tempoList[index]);
//                       Navigator.pop(context);
//                     },
//                     child: Text("${tempoList[index].toString()}배속"),
//                   );
//                 }),
//           ),
//           actions: [
//             FlatButton(
//                 onPressed: () => Navigator.pop(context), child: Text("Close"))
//           ]);
//     },
//   );
// }
}

// Widget songList() {
//   return isFirst
//       ? //깜빡거림방지를위해 퓨처빌더는 한번만!
//   FutureBuilder(
//     future: getAllSongs(1),
//     builder: (context, snapshot) {
//       if (snapshot.connectionState != ConnectionState.done)
//         return CircularProgressIndicator();
//       result = snapshot.data;
//       return ListView.builder(
//         padding: EdgeInsets.all(16.0),
//         itemCount: result.length,
//         itemBuilder: (context, i) {
//           song = result[i];
//           isGoodList.add(song.isGood);
//           isFirst = false;
//           var isGood = isGoodList[i];
//           return songListTile(song, isGood, i);
//         },
//       );
//     },
//   )
//       : ListView.builder(
//     padding: EdgeInsets.all(16.0),
//     itemCount: result.length,
//     itemBuilder: (context, i) {
//       song = result[i];
//       isGoodList.add(song.isGood);
//       var isGood = isGoodList[i];
//       return songListTile(song, isGood, i);
//     },
//   );
// }
