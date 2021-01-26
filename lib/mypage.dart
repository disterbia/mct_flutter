import 'dart:io' as io;
import 'package:aa_test/model/song.dart';
import 'package:aa_test/player.dart';
import 'package:aa_test/songdb.dart';
import 'package:aa_test/scoredb.dart';
import 'package:aa_test/scoreHistoryModal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:share/share.dart';
import 'package:aa_test/popupMenu.dart';
class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  String vdirectory;
  String rdirectory;
  List vfile = List(); //recordSong file list
  List rfile = List(); //recordVideo file list
  List<String> filePaths = [];
  FlutterSoundPlayer _mPlayer = FlutterSoundPlayer();
  bool _mPlayerIsInited = false;
  bool isPlay = false;
  bool isPlayReady= true;
  List<int> isPlayList = [];
  List<Tab> tabTitle = [Tab(child:Text("연습곡")),Tab(child:Text("즐겨찾기")),Tab(child:Text("내연주듣기")),Tab(child:Text("내연주보기"))];
  bool tabable = true;
  Song song;
  var result = []; // 퓨처빌더에서 읽어온 데이터
  var result2 = []; // 퓨처빌더에서 읽어온 데이터
  var tempoList = [0.8, 1.0, 1.2];


  final dbHelper = DatabaseHelper.instance;
  ScoreHistoryModal modal = ScoreHistoryModal();

  @override
  void initState() {
    _mPlayer.openAudioSession().then((value) {
      setState(() {
        _mPlayerIsInited = true;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    stopPlayer();
    _mPlayer.closeAudioSession();
    _mPlayer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Map arguments = ModalRoute.of(context).settings.arguments as Map;
    final fullScreenSize = MediaQuery.of(context).size; // responsive
    vdirectory = arguments["vpath"];
    rdirectory = arguments["rpath"];
    vfile = io.Directory(vdirectory)
        .listSync(recursive: true); //use your folder name insted of resume.
    rfile = io.Directory(rdirectory).listSync();
    for (var i = 0; i < rfile.length; i++) {
      isPlayList.add(0);
    }
    return DefaultTabController(
      length: 4,
      child: Stack(
          children: [
            Scaffold(
              backgroundColor:Color(0xff373737),
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
                                padding: EdgeInsets.symmetric(horizontal: 32),
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
                                            ],
                                          ),
                                        ),
                                        flex:1
                                    )
                                  ],
                                )
                            ),
                          ),
                        ],
                      )
                  ),
                  elevation: 0,
                  bottom: TabBar(
                      labelColor: Colors.white,
                      labelStyle: TextStyle(fontSize : 20, fontWeight : FontWeight.bold),
                      labelPadding: EdgeInsets.symmetric(horizontal: 16),
                      isScrollable: true,
                      unselectedLabelStyle: TextStyle(fontSize : 18, fontWeight : FontWeight.bold),
                      indicatorColor: Colors.transparent,
                      tabs: tabTitle
                  ),
                ),
              ),
              body: SafeArea(
                child: Container(
                  width: fullScreenSize.width,
                  height: fullScreenSize.height*0.85,
                  decoration: new BoxDecoration(
                      color: Color(0xfff6f6f6),
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16))
                  ),
                  padding: EdgeInsets.fromLTRB(16, 24, 16, 0),
                  child: TabBarView(
                    children: [
                      Container( child: historySongList()),
                      Container( child: goodSongList()),
                      Container( child: recordSongList()),
                      Container( child: recordVideoList()),
                    ],
                  ),
                ),
              ),
            ),
          ]
      ),
    );
  }

  Widget recordSongList() {
    return ListView.builder(
        itemCount: rfile.length,
        itemBuilder: (BuildContext context, int index) {
          var temp = rfile[index].toString();
          return Container(
              margin: EdgeInsets.only(bottom:index == rfile.length-1 ? 24: 16),
              height: 64,
              color:Colors.white,
              child: InkWell(
                  child: ListTile(
                    contentPadding: EdgeInsets.fromLTRB(16, 0, 0, 10),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: Align(child: Text(temp.substring(rdirectory.length + 8, temp.length -5)),alignment:Alignment.centerLeft),flex: 5,),
                        Expanded(child:InkWell(
                          child: Icon(isPlayList[index] == 1 ? Icons.stop_outlined : Icons.play_arrow_outlined),
                          onTap: (){
                            play(temp.substring(7, temp.length - 1), index);
                          },
                        ), flex:1),
                        Expanded(child: PopUpMenu(
                          isVideo:false,
                          shareFunction: (){
                            filePaths.add(temp.substring(7, temp.length - 1));
                            Share.shareFiles(filePaths);
                          },
                          deleteFunction: (){
                            setState(() {
                              io.File(temp.substring(7, temp.length - 1)).delete();
                            });
                            Navigator.of(context).pop();
                          },
                        ),flex:1),
                      ],
                    ),
                  ),
                  onTap:(){
                    setState((){
                      play(temp.substring(7, temp.length - 1), index);
                    });
                  }
              )
          );
        });
  }

  Widget recordVideoList(){
    return ListView.builder(
      itemCount: vfile.length,
      itemBuilder: (context, index) {
        var temp = vfile[index].toString();
        return Container(
            margin: EdgeInsets.only(bottom:index == vfile.length-1 ? 22: 14),
            height: 64,
            color:Colors.white,
            child: ListTile(
              contentPadding: EdgeInsets.fromLTRB(16, 0, 0, 10),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: Align(child: Text(temp.substring(vdirectory.length + 8, temp.length - 5)),alignment:Alignment.centerLeft),flex:6),
                  Expanded(child:PopUpMenu(
                      isVideo: true,
                      showVideoFunction: () {
                        Navigator.pushNamed(
                            context, "videoPlayPage", arguments: {
                          "file": temp.substring(7, temp.length - 1)
                        });
                      },
                      shareFunction:(){
                        filePaths.add(temp.substring(
                            7, temp.length - 1));
                        Share.shareFiles(filePaths);
                      },
                      deleteFunction: (){
                        setState(() {
                          io.File(temp.substring(7, temp.length - 1)).delete();
                        });
                        Navigator.of(context).pop();
                      }                  ), flex:1)
                ],
              ),
              onTap: () {
                Navigator.pushNamed(
                    context, "videoPlayPage", arguments: {
                  "file": temp.substring(7, temp.length - 1)
                });
              },
            )
        );
      },
    );
  }

  Widget historySongList(){
    return FutureBuilder(
        future: Future.wait([getHistorySongs(),getSongsScore()]),
        builder: (context, snapshot){
          if(snapshot.connectionState != ConnectionState.done) return Center(child: CircularProgressIndicator());
          List<Song> songs = snapshot.data[0];
          Map scores = snapshot.data[1];
          List onlyScoreId = scores.keys.toList();
          Map totalScores = {};
          songs.forEach((elem) {
            totalScores[elem.id] = onlyScoreId.contains(elem.id) ? scores[elem.id] : 0;
          });
          return ListView.builder(
            itemCount: songs.length,
            itemBuilder: (context, index) {
              Song selectedSong = songs[index];
              return Container(
                  margin: EdgeInsets.only(bottom:index == songs.length-1 ? 22: 14),
                  height: 64,
                  color: Colors.white,
                  child: ListTile(
                    contentPadding: EdgeInsets.fromLTRB(16, 0, 16, 4),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(selectedSong.title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                                SizedBox(height: 4),
                                Text('${totalScores[selectedSong.id]}/100', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300)),
                                SizedBox(height: 4),
                              ],
                            ),
                            flex:11
                        ),
                        Expanded(
                            child: GestureDetector(
                                child: SvgPicture.asset('assets/img/graph.svg', alignment: Alignment.centerRight,),
                                onTap: () async {
                                  final allRows = await dbHelper.queryAllRows(selectedSong.id);
                                  modal.mainBottomSheet(context, allRows);
                                }),
                            flex:1
                        )
                      ],
                    ),
                    onTap: () {
                      if (tabable) {
                        tabable = false;
                        test1(selectedSong);
                      }
                    },
                  )
              );
            },
          );
        }
    );
  }

  Widget goodSongList(){
    return FutureBuilder(
        future: Future.wait([getGoodSongs(),getSongsScore()]),
        builder: (context, snapshot){
          if(snapshot.connectionState != ConnectionState.done) return Center(child: CircularProgressIndicator());
          List<Song> songs = snapshot.data[0];
          Map scores = snapshot.data[1];
          List onlyScoreId = scores.keys.toList();
          Map totalScores = {};
          songs.forEach((elem) {
            totalScores[elem.id] = onlyScoreId.contains(elem.id) ? scores[elem.id] : 0;
          });

          return ListView.builder(
            itemCount: songs.length,
            itemBuilder: (context, index) {
              Song selectedSong = songs[index];
              return Container(
                  margin: EdgeInsets.only(bottom:index == songs.length-1 ? 22: 14),
                  height: 64,
                  color:Colors.white,
                  child: ListTile(
                    contentPadding: EdgeInsets.fromLTRB(16, 0, 16, 4),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(selectedSong.title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                                SizedBox(height: 4),
                                Text('${totalScores[selectedSong.id]}/100', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300)),
                                SizedBox(height: 4),
                              ],
                            ),
                            flex:11
                        ),
                        Expanded(
                            child: GestureDetector(
                                child: Icon(Icons.favorite, color:Color(0xffff5151)
                                ),
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context){
                                        return AlertDialog(
                                          content: Container(
                                            width: 100,
                                            height:80,
                                            child: Column(
                                              children: [
                                                Expanded(child:Text('"${selectedSong.title}"', style:TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),flex:1),
                                                Expanded(child:SizedBox(),flex:1),
                                                Expanded(child: Text("즐겨찾기에서 삭제하시겠습니까?", style:TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),flex: 1,),
                                                Expanded(child:SizedBox(),flex:1),
                                                Expanded(
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        FlatButton(
                                                          child: Text("네, 삭제합니다.",style:TextStyle(fontSize: 13)),
                                                          onPressed: () {
                                                            setState(() {
                                                              updateSong(Song(
                                                                  id: selectedSong.id,
                                                                  title: selectedSong.title,
                                                                  isGood: 0,
                                                                  tempo: selectedSong.tempo,
                                                                  midPath: selectedSong.midPath,
                                                                  scale: selectedSong.scale,
                                                                  history: selectedSong.history,
                                                                  level: selectedSong.level));
                                                            });
                                                            Navigator.of(context).pop();
                                                          },
                                                        ),
                                                        FlatButton(
                                                          child: Text("아니요",style:TextStyle(fontSize: 13)),
                                                          onPressed: () {
                                                            Navigator.of(context).pop();
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                    flex:1
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }
                                  );
                                }),
                            flex:1
                        )
                      ],
                    ),
                    onTap: () {
                      if (tabable) {
                        tabable = false;
                        test1(selectedSong);
                      }
                    },
                  )
              );
            },
          );
        }
    );
  }



  void play(String mPath, int i) async {
    print(mPath);
    if (!_mPlayerIsInited) {
      return null;
    }

    if(_mPlayer.isPlaying&&isPlayList[i]==1){
      stopPlayer().then((value) => setState(() {
        isPlayReady=true;
        isPlayList[i] = 0;
      }));

    }else if(!_mPlayer.isPlaying){
      setState(() {
        isPlayReady=false;
        isPlayList[i] = 1;
      });
      await _mPlayer.startPlayer(
          fromURI: mPath,
          codec: Codec.aacADTS,
          whenFinished: () {
            setState(() {
              isPlayList[i] = 0;
              isPlayReady=true;
            });
          });
    }
    // assert(_mPlayerIsInited &&
    //     _mPlayer.isStopped);
  }

  Future<void> stopPlayer() async {
    await _mPlayer.stopPlayer();
  }

  Future<List<Song>> getGoodSongs() async {
    SongDb db = SongDb();
    return await db.getGoodSongs();
  }

  Future<List<Song>> getHistorySongs() async {
    SongDb db = SongDb();
    return await db.getHistorySongs();
  }

  Future<void> updateSong(Song song) async {
    SongDb db = SongDb();
    await db.updateSong(song);
  }

  Future<Map<dynamic,dynamic>> getSongsScore() async {
    return await dbHelper.readAllRecentScores();
  }

  void test1(Song song) {
    midiInit(song.midPath, song, () {
      Navigator.pushNamed(context, "mainPage", arguments: {"song": song});
      tabable = true;
    });
  }
//
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
//                     onPressed: () => test1(
//                         song.midPath, song, song.title, tempoList[index]),
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