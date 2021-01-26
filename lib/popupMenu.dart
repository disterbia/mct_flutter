import 'package:flutter/material.dart';

class PopUpMenu extends StatelessWidget {
  PopUpMenu({
    Key key,
    @required this.shareFunction,
    @required this.deleteFunction,
    @required this.isVideo,
    this.showVideoFunction,
  }) : super(key: key);

  final Function shareFunction;
  final Function deleteFunction;
  final Function showVideoFunction;
  final bool isVideo;

  List<PopupMenuEntry<Object>> shareAndDelete = [
    PopupMenuItem(
        child: Center(child: FittedBox(child:Text('외부로 공유하기', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),fit:BoxFit.fitHeight)),
        value: 1
    ),
    PopupMenuItem(
        child: Divider(color:Color(0xffdbdbdb), thickness: 1),
        enabled: false,
        height:6,
        value:0
    ),
    PopupMenuItem(
        child: Center(child: FittedBox(child:Text('삭제하기', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),fit:BoxFit.fitHeight)),
        value: 2
    ),
  ];

  List<PopupMenuEntry<Object>> showVideo = [
    PopupMenuItem(
        child: Center(child: FittedBox(child:Text('들어보기', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)), fit:BoxFit.fitHeight)),
        value:3
    ),
    PopupMenuItem(
        child: Divider(color:Color(0xffdbdbdb), thickness: 1),
        enabled: false,
        height:6,
        value:0
    )
  ];

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
        offset: Offset(0,50),
        padding: EdgeInsets.all(0),
        itemBuilder: (context) {
          return isVideo == false ? shareAndDelete : showVideo + shareAndDelete;
        },
        onSelected: (choiceNumber){
          if(choiceNumber == 1){
            shareFunction();
            print("shareFunction is pressed");
          }
          else if(choiceNumber == 2){
            print("delteFunction is pressed");
            showDialog(
                context: context,
                builder: (BuildContext context){
                  return AlertDialog(
                    shape: RoundedRectangleBorder(),
                      content:Container(height:50,child: Align(child: Text('정말 취소 하시겠습니까?',style:TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),alignment: Alignment.bottomLeft,)),
                      actions:[
                        FlatButton(
                          child: Text("취소",style:TextStyle(fontSize: 18,fontWeight: FontWeight.w300, color:Color(0xff1c0000))),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        FlatButton(
                          child: Text("확인",style:TextStyle(fontSize: 18,fontWeight: FontWeight.w300,color:Color(0xff1c0000))),
                          onPressed: () {
                            deleteFunction();
                          },
                        ),
                      ]
                  );
                }
            );
          }
          else if(choiceNumber == 3){
            showVideoFunction();
          }
        }
    );
  }
}
