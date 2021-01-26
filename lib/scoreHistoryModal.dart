import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ScoreHistoryModal{
  mainBottomSheet(BuildContext context, List<Map<String, dynamic>> rows){
    final fullScreenSize =  MediaQuery.of(context).size;
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context){
          return Container(
              height: fullScreenSize.height* 0.85,
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
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(20.0),
                            topLeft:  Radius.circular(20.0),),
                          color:Colors.white,
                        ),
                        padding: EdgeInsets.fromLTRB(16,0,16,24),
                        child:  Stack(
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
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                          height:fullScreenSize.height*0.1,
                                          padding:EdgeInsets.fromLTRB(0, 30, 0, 0),
                                          child:Text(rows[0]['songName'], style:TextStyle(color:Colors.black,fontWeight: FontWeight.bold, fontSize: 20))
                                      ),
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
                  )
                ],
              )
          );
        }
    );
  }
}

