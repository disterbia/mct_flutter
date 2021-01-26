import 'package:aa_test/informPage.dart';
import 'package:aa_test/model/song.dart';
import 'package:aa_test/pageViewChild.dart';
import 'package:aa_test/tabViewChild.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:math';

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> with SingleTickerProviderStateMixin{
  List<Widget> titleList = [Tab(text:'역사'), Tab(text:'종류'), Tab(text:'연주자세'), Tab(text:'호흡과 텅잉')];

  @override
  Widget build(BuildContext context) {
    final fullScreenSize = MediaQuery.of(context).size; // responsive
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor:Color(0xff373737),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(fullScreenSize.height * 0.15),
          child:AppBar(
            backgroundColor: Colors.transparent,
            automaticallyImplyLeading: false,
            flexibleSpace:Container(
                height: double.infinity,
                color: Color(0xff373737),
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
                    SafeArea(
                      child: Container(
                          padding:
                          EdgeInsets.symmetric(horizontal: 16),
                          height: fullScreenSize.height * 0.15,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16 * 0.75),
                                child: Stack(
                                  children: [
                                    InkWell(
                                      child: FittedBox(
                                          child: Icon(Icons.arrow_back,
                                              color: Colors.white),
                                          fit: BoxFit.fitHeight),
                                      onTap: () =>
                                          Navigator.of(context).pop(), //뒤로가기,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )),
                    ),//뒤로가기
                  ],
                )),
            elevation: 0,
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(40),
              child: Container(
                padding:EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TabBar(
                    isScrollable: true,
                    indicatorSize: TabBarIndicatorSize.label,
                    labelColor: Colors.white,
                    labelStyle: TextStyle(fontSize : 20, fontWeight : FontWeight.bold),
                    labelPadding: EdgeInsets.symmetric(horizontal: 16),
                    unselectedLabelStyle: TextStyle(fontSize : 18, fontWeight : FontWeight.bold),
                    indicatorColor: Colors.transparent,
                    tabs: titleList,
                  ),
                ),
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: Container(
            width: fullScreenSize.width,
            height: fullScreenSize.height*0.85,
            decoration: new BoxDecoration(
              color: Color(0xfff2f2f2),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
            padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: TabBarView(
              children: [
                TabViewChild(pageViewChildren: [
                  PageViewChild(
                    fullScreenSize: fullScreenSize,
                    isRow: false,
                    isSvgPicture: false,
                    isImageBig: true,
                    imagePath: ['assets/img/about/explain2.webp'],
                    textContent: '리코더와 유사한 악기는 오래전부터 있었다.     \n'
                        '그러나 리코더와 그와 유사한 악기는 다르게\n'
                        '분류되는데, 리코더를 다른 원시 관악기와\n'
                        '구분하는 기준은 여덟 개의 구멍의 존재\n'
                        '여부이다.',
                  ),
                  PageViewChild(
                    fullScreenSize: fullScreenSize,
                    isRow: false,
                    isSvgPicture: false,
                    isImageBig: true,
                    imagePath: ['assets/img/about/explain3.webp'],
                    textContent: '르네상스 시대 때 오늘날 리코더 구멍의 수와\n'
                        '같은 8개가 되었고, 바로크 시대 때 최전성기를\n'
                        '맞는다.이후 플루트라는 음량이 크고 음색이\n'
                        '화려한 악기에 밀려 사라질 뻔했지만 아놀드\n'
                        '돌매치를 비롯한 고음악 연구가들의 노력으로\n'
                        '다시 세상 밖으로 나오게 되었다.',
                  ),
                ]),//역사
                TabViewChild(pageViewChildren: [
                  Container(
                      child:Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                              height: fullScreenSize.height*0.55,
                              width: double.infinity,
                              child: FittedBox(
                                  child:Image.asset('assets/img/about/explain1.webp'),
                                  fit:BoxFit.fitWidth
                              )
                          ),
                        ],
                      )
                  ),
                  Container(
                      child:Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          FittedBox(
                              child: Text(
                                '리코더의 종류는 기준에 따라 다양하게 분류할\n'
                                    '수 있다. 그중 음역에 따른 분류는 높은\n'
                                    '음역대부터 클라이네 소프라니노, 소프라니노,\n'
                                    '소프라노, 알토, 테너, 베이스, 그레이트 베이스,\n'
                                    '콘트라 베이스 리코더 등으로 나눌 수 있는데\n'
                                    '리코더하면 떠올리는 초등학교 시절 많이\n'
                                    '배우던 리코더는 "소프라노 리코더"이다',
                                style:TextStyle(fontSize: 16, height: 1.5),
                              ),
                              fit:BoxFit.fitWidth
                          ),
                        ],
                      )
                  ),
                ]),//종류
                TabViewChild(pageViewChildren: [
                  Container(
                      child:Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            width:fullScreenSize.width/2-24,
                            child: FittedBox(
                                child: Text(
                                  '구멍은 손가락 지문의\n'
                                      '둥근 중심 부분으로\n'
                                      '가볍게 얹는 기분으로\n'
                                      '막는다. 막지 않는\n'
                                      '손가락은 항상 구멍\n'
                                      '위에 둔다.\n'
                                      '너무 가까이 있으면.\n'
                                      '음정에 영향을 주며,\n'
                                      '구멍에서 너무 멀면\n'
                                      '빠른 곡을 연주할 때\n'
                                      '불리하다. 따라서   \n'
                                      '자연스럽게 힘을 빼고\n'
                                      '악기를 잡아야 한다.',
                                  style:TextStyle(fontSize: 16, height: 1.5),
                                ),
                                fit:BoxFit.fitWidth
                            ),
                          ),
                          SizedBox(width:16),
                          Container(
                              width: fullScreenSize.width/2-24,
                              child: FittedBox(child: SvgPicture.asset('assets/img/about/pose1.svg'),fit:BoxFit.fitHeight)
                          ),
                        ],
                      )
                  ),
                  PageViewChild(
                    fullScreenSize: fullScreenSize,
                    isRow: true,
                    isSvgPicture: true,
                    isImageBig: true,
                    imagePath: ['assets/img/about/finger1.svg','assets/img/about/finger2.svg'],
                    textContent: '구멍을 막지 않는 손가락은 항상 구멍의 위에\n'
                        '있어야 하는데 너무 가까이에 있으면 음정에 \n'
                        '영향을 주어 너무 멀리 있거나 악기 밑으로 \n'
                        '내려놓으면 빠른 곡을 연주할 때 불리하다.\n'
                        '자연스럽게 힘을 빼고 악기를 잡는 것이 \n'
                        '중요하다.',
                  ),
                  PageViewChild(
                    fullScreenSize: fullScreenSize,
                    isRow: true,
                    isSvgPicture: true,
                    isImageBig: true,
                    imagePath: ['assets/img/about/pose2.svg','assets/img/about/pose3.svg'],
                    textContent:  '연주할 때 다리를 어깨너비 정도로 벌려 안정감\n'
                        '있게 서거나 의자의 등받이에 등이 닿지 않게\n'
                        '허리를 펴고 앉아 팔꿈치를 약간 벌려서\n'
                        '리코더를 잡는다. 리코더와 몸의 각도는 45도\n'
                        '정도로 이는 고개를 편안하게 들고 악기를 \n'
                        '물었을 때 자연스럽게 이루어지는 각도이다.',
                  ),
                  PageViewChild(
                    fullScreenSize: fullScreenSize,
                    isRow: false,
                    isSvgPicture: true,
                    isImageBig: true,
                    imagePath: ['assets/img/about/pose4.svg'],
                    textContent:  '팔꿈치를 벌리지 않고 겨드랑이에 붙인 채   \n'
                        '고개를 숙여서 악기를 입에 문다면 오래 연습했\n'
                        '을 때 몸에 무리를 준다. 그리고 소리가 나가는\n'
                        '방향, 음악의 표현 등에 좋지 않은 영향을 주므로\n'
                        '항상 바른 자세로 연주하는 습관이 중요하다.',
                  ),
                ]),//연주자세
                TabViewChild(pageViewChildren: [ //
                  PageViewChild(
                    fullScreenSize: fullScreenSize,
                    isRow: false,
                    isSvgPicture: true,
                    isImageBig: true,
                    imagePath: ['assets/img/about/breath2.svg'],
                    textContent:  '리코더에 혀나 이가 닿지 않게 해야 한다.       \n\n'
                        '호흡을 할 때는 윗 입술을 열어 코와 입으로 \n'
                        '동시에 들이쉰다.\n',
                  ),// 호흡과 텅잉
                  PageViewChild(
                    fullScreenSize: fullScreenSize,
                    isRow: false,
                    isSvgPicture: true,
                    isImageBig: true,
                    imagePath: ['assets/img/about/breath3.svg'],
                    textContent:  '1cm 정도 살짝 입술에 댄다.\n\n'
                        '연주할 때 내쉬는 호흡은 소리가 흔들리지 않게\n'
                        '천천히 일정한 양을 균일하게 내쉰다. 이를\n'
                        '연습하기 위해서는 같은 음을 길게 소리내는\n'
                        "'Long tone'연습 등이 좋다. ",
                  ),
                  PageViewChild(
                    fullScreenSize: fullScreenSize,
                    isRow: false,
                    isSvgPicture: true,
                    isImageBig: false,
                    imagePath: ['assets/img/about/breath1.svg'],
                    textContent:  '1)혀끝을 윗니 뒤쪽에 가볍게 댄다.\n'
                        "2)혀를 떼면서 '두'라고 발음하며 입안의 공기를\n"
                        '    내보낸다\n'
                        '3)음을 끊을 때는 혀끝을 다시 윗니 뒤쪽에 댄다.\n\n'
                        "'두-두-두-'하고 말하는 것에서 성대의 울림을\n"
                        '뺀 것이라 생각하면 쉽다.',
                  ),
                ]) //호흡과 텅잉
              ],
            ),
          ),
        ),
      ),
    );
  }
}



