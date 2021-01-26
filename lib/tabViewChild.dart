import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:math';

class TabViewChild extends StatefulWidget {
  const TabViewChild({
    Key key,
    @required this.pageViewChildren,
  }) : super(key: key);

  final List<Widget> pageViewChildren;

  @override
  _TabViewChildState createState() => _TabViewChildState();
}

class _TabViewChildState extends State<TabViewChild> {
  int pageViewIndex = 0;
  PageController pageController = PageController(initialPage: 0);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Expanded(child:SizedBox(), flex: 5), //위 여백
          Expanded(
            flex:53,
            child: Container(
              height:double.infinity,
              width: double.infinity,
              child: PageView(
                controller: pageController,
                onPageChanged: (index){
                  setState((){
                    pageViewIndex = index;
                    print(pageViewIndex);
                  });
                },
                children:widget.pageViewChildren,
              ),
            ),
          ), //내용
          Expanded(child:SizedBox(), flex:2), //버튼까지 여백
          Expanded( //버튼
              flex:5,
              child:Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                      child: Container( //TODO: flex에 맞게 크기 바꾸기
                        height: 40,
                        width: 64,
                        decoration: BoxDecoration(
                          color:pageViewIndex > 0 ? Colors.black : Color(0xff949494),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child:  SvgPicture.asset('assets/img/about/prev_next.svg'),
                        ),
                      ),
                      onTap: (){
                        setState(() {
                          if(pageViewIndex>0)pageViewIndex--;
                          pageController.animateToPage(pageViewIndex, duration: Duration(milliseconds:250), curve: Curves.bounceInOut);
                        });
                      }
                  ),
                  SizedBox(width: 10,),
                  InkWell(
                      child: Container(
                        height: 40,
                        width: 64,
                        decoration: BoxDecoration(
                          color: pageViewIndex>=widget.pageViewChildren.length-1? Color(0xff949494):Colors.black,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                            child: Transform.rotate(angle: pi, alignment: Alignment.center, child:SvgPicture.asset('assets/img/about/prev_next.svg'))
                        ),
                      ),
                      onTap: (){
                        setState(() {
                          if(pageViewIndex<widget.pageViewChildren.length-1)pageViewIndex++;
                          pageController.animateToPage(pageViewIndex, duration: Duration(milliseconds:250), curve: Curves.bounceInOut);
                        });
                      }
                  ),
                ],
              )
          ),
          Expanded(child:SizedBox(), flex:3) //버튼 이후 여백
        ],
      ),
    );
  }
}
