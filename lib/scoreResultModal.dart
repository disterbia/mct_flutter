import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'model/song.dart';

class ScoreResultModal{
  int score              = -1; //점수 값을 게임이 끝나면 여기에 받아와야 함
  var scoreMedalPopUp    = ['clap','1', '2','3', '4', '6','6']; //50미만, 50~59, 60~, 70~, 80~, 90~,100
  var scoreBackDeco      = ['fanfare','deco'];
  var scoreResultMention = ['연습을 좀 더 해보는게 어떨까요?','연습을 한 성과가 보이기 시작해요','점점 실력이 늘고 있네요.','조금 아쉬운데 한번 더 도전해볼까요?','브라보! 멋진 연주였어요.','훌륭해요! 재능이 있는게 아닐까요?','훌륭해요! 재능이 있는게 아닐까요?'];

  mainBottomSheet(BuildContext context, int score, Song song,List<Map<String, dynamic>> rows){
    bool isGraphBtnPressed = false;
    final fullScreenSize = MediaQuery.of(context).size;
    bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context){
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState){
                return  isPortrait ? Container(
                    height:fullScreenSize.height*0.85,
                    child: Column(
                      children: [
                        Expanded(
                            child:InkWell(
                              child: SvgPicture.asset('assets/img/xbutton.svg'),
                              onTap: (){
                                Navigator.pop(context);
                              },
                            ),
                            flex:5
                        ),
                        Expanded(
                            child:Container(
                              decoration:  BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(20.0),
                                  topLeft:  Radius.circular(20.0),),
                                color:Colors.white,
                              ),
                              padding: EdgeInsets.fromLTRB(16,0,16,24),
                              child:isGraphBtnPressed==false ? Column(
                                children: [
                                  Expanded(child:SizedBox(), flex:6),
                                  Expanded(child:Row(
                                    children: [
                                      Expanded(child: SizedBox(), flex: 7),
                                      Expanded(child:FlatButton(
                                        color: Colors.black,
                                        shape:CircleBorder(),
                                        child:Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Icon(Icons.arrow_forward,color:Colors.white),
                                            FittedBox(child:Text("그래프",style:TextStyle(color:Colors.white, fontSize: 14)),fit:BoxFit.fitHeight),
                                          ],
                                        ),
                                        onPressed: () {
                                          setState((){
                                            isGraphBtnPressed = true;
                                          });
                                        },
                                      ), flex:2),
                                    ],
                                  ), flex:18),
                                  Expanded(child:SizedBox(), flex:4),
                                  Expanded(child:Stack(
                                    children: [
                                      Center(child: SvgPicture.asset('assets/img/scorepopup/${score<50?scoreBackDeco[0]:scoreBackDeco[1]}.svg')),
                                      Center(child: SvgPicture.asset('assets/img/scorepopup/${score<50?scoreMedalPopUp[0]:scoreMedalPopUp[((score-40-score%10)/10).round()]}.svg')),
                                    ],
                                  ) ,flex:39),
                                  Expanded(child:SizedBox(), flex:9),
                                  Expanded(child:Container(child:Center(child: Text(score<50?scoreResultMention[0]:scoreResultMention[((score-40-score%10)/10).round()],style:TextStyle( fontWeight: FontWeight.bold, fontSize: 20)))), flex:6),
                                  Expanded(child:SizedBox(),flex:4),
                                  Expanded(child:Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(child: Align(child: Text("$score",style: TextStyle( fontWeight: FontWeight.bold, fontSize: 56)),alignment: Alignment.bottomCenter,),height: double.infinity,),
                                      Column(
                                        children: [
                                          Expanded(child:SizedBox(), flex:1),
                                          Expanded(child:Align(child: Text(" 점",style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500)),alignment: Alignment.bottomCenter),flex:2)
                                        ],
                                      )
                                    ],
                                  ),flex:16),
                                  Expanded(child:SizedBox(), flex:10),
                                  Expanded(
                                      child:InkWell(
                                        child:Container(
                                          decoration: BoxDecoration(
                                            color:Colors.black,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Center(
                                              child:Text("확인했어요!", style: TextStyle(color:Colors.white, fontSize: 24, fontWeight: FontWeight.w500))
                                          ),
                                        ),
                                        onTap: (){
                                          Navigator.pop(context);
                                        },
                                      ),
                                      flex:14
                                  ),
                                  Expanded(child:SizedBox(), flex:6),
                                ],
                              )
                                  : Stack(
                                children: [
                                  Container(
                                      width: double.infinity,
                                      height: double.infinity,
                                      child:Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: List.generate((fullScreenSize.height/18).round(), (index) => Padding(
                                                padding: EdgeInsets.only(top:3,bottom: 3),
                                                child:Container(
                                                  height:6,
                                                  width:1,
                                                  color:Colors.black12,
                                                )
                                            )),
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: List.generate((fullScreenSize.height/18).round(), (index) => Padding(
                                                padding: EdgeInsets.only(top:3,bottom: 3),
                                                child:Container(
                                                  height:6,
                                                  width:1,
                                                  color:Colors.black12,
                                                )
                                            )),
                                          ),
                                        ],
                                      )//눈금
                                  ), //뒷 배경 선
                                  ListView.builder(
                                    itemCount: rows.length+1,
                                    itemBuilder: (BuildContext  context, int index){
                                      if(index==0){
                                        return Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                                height:fullScreenSize.height*0.1,
                                                padding:EdgeInsets.fromLTRB(0, 30, 0, 0),
                                                child:Text(rows[0]['songName'], style:TextStyle(color:Colors.black,fontWeight: FontWeight.bold, fontSize: 20))
                                            ),
                                            InkWell(
                                                child: Container(
                                                  height:fullScreenSize.height*0.1,
                                                  padding:EdgeInsets.fromLTRB(0,30,0,0),
                                                  child: Row(children: [
                                                    Text("뒤로 ",style:TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
                                                    Icon(Icons.keyboard_arrow_right_rounded, color: Colors.black,)
                                                  ],),
                                                ),
                                                onTap: (){
                                                  setState(() {
                                                    isGraphBtnPressed = false;
                                                  });
                                                })
                                          ],
                                        );
                                      }
                                      else{
                                        int parseScore = rows[rows.length-index]['score'];
                                        bool isZero = parseScore == 0;
                                        return Container(
                                            margin: EdgeInsets.symmetric(vertical: 8),
                                            child:Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                    height:16,
                                                    margin: EdgeInsets.only(right:5, bottom:4),
                                                    child: Align(
                                                      alignment: Alignment.centerLeft,
                                                      child:Text(rows[rows.length-index]['date'],
                                                          style:TextStyle(color:index>1?Color(0xff949494):Colors.black,fontWeight: FontWeight.w600, fontSize: 14)),
                                                    )
                                                ),
                                                isZero ? Container(
                                                    height:32,
                                                    child:Align(
                                                        alignment: Alignment.centerLeft,
                                                        child:Container(
                                                          margin: EdgeInsets.only(right:5, top:10),
                                                          child:Text('0점', style:TextStyle(color:index>1 ?Color(0xff949494) : Colors.black,fontWeight: FontWeight.w600, fontSize: 16)),
                                                        )
                                                    ))
                                                    : Container(
                                                    height:32,
                                                    width: (fullScreenSize.width*0.9*parseScore)/100,
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: index>1 ? [Colors.white,Colors.grey] : [Colors.white, Color(0xff00b1ff), Color(0xff0022ff)],
                                                      ),
                                                      borderRadius: BorderRadius.only(topRight:Radius.circular(4),bottomRight:Radius.circular(4)),
                                                    ),
                                                    child:Align(
                                                        alignment: Alignment.centerRight,
                                                        child:Container(
                                                          margin: EdgeInsets.only(right:5),
                                                          child:Text('${rows[rows.length-index]['score'].toString()}점', style:TextStyle(color:Colors.white,fontWeight: FontWeight.w600, fontSize: 16)),
                                                        )
                                                    )
                                                ),
                                              ],
                                            )
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                            flex:68
                        ),
                      ],
                    )
                )
                    : SafeArea(
                  child: Container(
                    padding: isGraphBtnPressed == false ? EdgeInsets.symmetric(horizontal: 16, vertical: 25) : EdgeInsets.fromLTRB(16,25,16,0),
                    color:Colors.white,
                    child:Column(
                      children: [
                        Expanded(
                            child:Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                    child: Icon(Icons.arrow_back,color: Colors.black),
                                    onTap: (){
                                      if(isGraphBtnPressed == false){
                                        Navigator.of(context).pop(); //뒤로가기,
                                      }else{
                                        setState((){
                                          isGraphBtnPressed = false;
                                        });
                                      }
                                    }
                                ),
                                Container(child: isGraphBtnPressed == false ?SizedBox(): Text(rows[0]['songName'], style:TextStyle(color:Colors.black,fontWeight: FontWeight.bold, fontSize: 20))),
                                InkWell(
                                  child: Icon(Icons.close, color:Colors.black),
                                  onTap: (){
                                    Navigator.pop(context);
                                  },
                                )
                              ],
                            ),
                            flex:8
                        ),
                        Expanded(
                            child:isGraphBtnPressed==false ? Column(
                              children: [
                                Expanded(
                                    child:Stack(
                                      children: [
                                        Center(child: SvgPicture.asset('assets/img/scorepopup/${score<50?scoreBackDeco[0]:scoreBackDeco[1]}.svg', fit: BoxFit.fitHeight,)),
                                        Transform.translate(child: Center(child: SvgPicture.asset('assets/img/scorepopup/${score<50?scoreMedalPopUp[0]:scoreMedalPopUp[((score-40-score%10)/10).round()]}.svg',fit:BoxFit.scaleDown)),
                                            offset: Offset(0,8)),
                                      ],
                                    ),
                                    flex:25
                                ),
                                Expanded(child:SizedBox(), flex:2),
                                Expanded(
                                    child:Stack(
                                      children: [
                                        Column(
                                          children: [
                                            Expanded(
                                                child:Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Container(child: Align(child: Text("$score",style: TextStyle( fontWeight: FontWeight.bold, fontSize: 40)),alignment: Alignment.bottomCenter,),height: double.infinity,),
                                                    Align(child: Text(" 점",style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500)),alignment: Alignment.bottomCenter)
                                                  ],
                                                ),
                                                flex:8
                                            ),
                                            Expanded(
                                                child:SizedBox(),
                                                flex:2
                                            ),
                                            Expanded(
                                                child:Align(
                                                    child: Text(score<50?scoreResultMention[0]:scoreResultMention[((score-40-score%10)/10).round()],
                                                        style:TextStyle( fontWeight: FontWeight.bold, fontSize: 20)), alignment: Alignment.topCenter),
                                                flex:8
                                            ),
                                          ],
                                        ),
                                        Align(child:FlatButton(
                                          color: Colors.black,
                                          shape:CircleBorder(),
                                          child:Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              SvgPicture.asset('assets/img/graph.svg', color:Colors.white),
                                              SizedBox(height: 8),
                                              FittedBox(child:Text("그래프",style:TextStyle(color:Colors.white, fontSize: 14)),fit:BoxFit.fitHeight),
                                            ],
                                          ),
                                          onPressed: () {
                                            setState((){
                                              isGraphBtnPressed = true;
                                            });
                                          },
                                        ), alignment:Alignment.bottomRight),
                                      ],
                                    ),
                                    flex:20
                                ),
                              ],
                            )
                                : Stack(
                              children: [
                                Container(
                                    width: double.infinity,
                                    height: double.infinity,
                                    child:Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: List.generate((fullScreenSize.height/16).round(), (index) => Padding(
                                              padding: EdgeInsets.only(top:3,bottom: 3),
                                              child:Container(
                                                height:6,
                                                width:1,
                                                color:Colors.black12,
                                              )
                                          )),
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: List.generate((fullScreenSize.height/16).round(), (index) => Padding(
                                              padding: EdgeInsets.only(top:3,bottom: 3),
                                              child:Container(
                                                height:6,
                                                width:1,
                                                color:Colors.black12,
                                              )
                                          )),
                                        ),
                                      ],
                                    )//눈금
                                ), //뒷 배경 선
                                ListView.builder(
                                    itemCount: rows.length,
                                    itemBuilder: (BuildContext  context, int index){
                                      int parseScore = rows[rows.length-index-1]['score'];
                                      bool isZero = parseScore == 0;
                                      return Container(
                                          margin: EdgeInsets.symmetric(vertical: 12),
                                          child:Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                  height:16,
                                                  margin: EdgeInsets.only(right:5, bottom:4),
                                                  child: Align(
                                                    alignment: Alignment.centerLeft,
                                                    child:Text(rows[rows.length-index-1]['date'],
                                                        style:TextStyle(color:index>1?Color(0xff949494):Colors.black,fontWeight: FontWeight.w600, fontSize: 14)),
                                                  )
                                              ),
                                              isZero ? Container(
                                                  height:32,
                                                  child:Align(
                                                      alignment: Alignment.centerLeft,
                                                      child:Container(
                                                        margin: EdgeInsets.only(right:5, top:10),
                                                        child:Text('0점', style:TextStyle(color:index>1 ?Color(0xff949494) : Colors.black,fontWeight: FontWeight.w600, fontSize: 16)),
                                                      )
                                                  ))
                                                  : Container(
                                                  height:32,
                                                  width: (fullScreenSize.width*0.9*parseScore)/100,
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: index>1 ? [Colors.white,Colors.grey] : [Colors.white, Color(0xff00b1ff), Color(0xff0022ff)],
                                                    ),
                                                    borderRadius: BorderRadius.only(topRight:Radius.circular(4),bottomRight:Radius.circular(4)),
                                                  ),
                                                  child:Align(
                                                      alignment: Alignment.centerRight,
                                                      child:Container(
                                                        margin: EdgeInsets.only(right:5),
                                                        child:Text('${rows[rows.length-index-1]['score'].toString()}점', style:TextStyle(color:Colors.white,fontWeight: FontWeight.w600, fontSize: 16)),
                                                      )
                                                  )
                                              ),
                                            ],
                                          )
                                      );
                                    }
                                ),
                              ],
                            ),
                            flex:47
                        ),
                      ],
                    ),
                  ),
                );
              }
          );
        }
    );
  }
}
