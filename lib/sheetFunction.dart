//음자리표 그려주는 함수
import 'package:aa_test/model/custom_song.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shape_of_view/shape_of_view.dart';

var CHECK_COLOR = [
  Colors.black,
  Colors.orange,
  Colors.greenAccent,
  Colors.red,
  Colors.blueGrey
];

void drawScale(List<Widget> widgets, int scale, double widgetHeight) {
  int cnt = scale;
  String svgAsset = "assets/sheet/sh1.svg";
  List<double> pos = [8, 3.2, 12, 4, 2.3, 5, 2.7];

  if (scale < 0) {
    cnt *= -1;
    svgAsset = "assets/sheet/fl1.svg";
    pos = [3.2, 8, 2.7, 5, 2.3, 4, 12];
  }

  for (int i = 0; i < cnt; i++) {
    widgets.add(Positioned(
        child: SvgPicture.asset(
          svgAsset,
          height: widgetHeight * 0.15, //크기
        ),
        left: 28 + widgetHeight / 16 * i,
        top: widgetHeight / pos[i] / 1.6 + widgetHeight * 0.2));
  }
}

void drawClef(List<Widget> widgets, bool isTreble, double widgetHeight) {
  widgets.add(Positioned(
    child: SvgPicture.asset(
      isTreble ? "assets/sheet/start.svg" : "assets/sheet/start.svg",
      height: widgetHeight * 0.5,
    ),
    height: widgetHeight,
    left: widgetHeight / 15,
  ));
  widgets.add(Positioned(
    left: widgetHeight / 6.5,
    top: widgetHeight / 11,
    child: Text(
      "8",
      style: TextStyle(fontSize: 9, fontWeight: FontWeight.w500),
    ),
  ));
}

//박자표 그려주는 함수
void drawRhythem(List<Widget> widgets, int upper, int under,
    double widgetHeight, int scale) {
  widgets.add(Positioned(
      child: Text(
        upper.toString(),
        style:
            TextStyle(fontSize: widgetHeight / 6, fontWeight: FontWeight.w500),
      ),
      left: 32 + widgetHeight / 13 * scale,
      top: widgetHeight / 2.9));
  widgets.add(Positioned(
      child: Text(
        under.toString(),
        style:
            TextStyle(fontSize: widgetHeight / 6, fontWeight: FontWeight.w500),
      ),
      left: 32 + widgetHeight / 13 * scale,
      top: widgetHeight / 2.05));
}

//임시박자표 그려주는 함수
void drawTempRhythem(List<Widget> widgets, int upper, int under,
    double widgetHeight, int scale) {
  widgets.add(Positioned(
      child: Text(
        upper.toString(),
        style:
            TextStyle(fontSize: widgetHeight / 6, fontWeight: FontWeight.w500),
      ),
      left: 7,
      top: widgetHeight / 2.9));
  widgets.add(Positioned(
      child: Text(
        under.toString(),
        style:
            TextStyle(fontSize: widgetHeight / 6, fontWeight: FontWeight.w500),
      ),
      left: 7,
      top: widgetHeight / 2.05));
}

//마디 끝 라인 그려주는 함수
// 0 일반, 1  도돌이표, 2, :곡끝
void drawEndLine(
    List<Widget> widgets, double widgetHeight, double widgetWidth, int type) {
  int endLineWidth = type == 0 ? 1 : 2;
  widgets.add(Positioned(
    child: Container(
      width: widgetHeight * 0.015 * endLineWidth,
      color: Colors.black,
    ),
    height: widgetHeight * 0.29,
    top: widgetHeight * 0.36,
    right: 0,
  ));
  if (type == 2) {
    widgets.add(Positioned(
      child: Container(
        width: widgetHeight * 0.02,
        color: Colors.black,
      ),
      height: widgetHeight * 0.3,
      top: widgetHeight * 0.35,
      right: widgetHeight * 0.07,
    ));
  }
}

// BPM 박자 그리는 함수
void drawTempo(List<Widget> widgets, double widgetHeight, int tempo) {
  widgets.add(Positioned(
      top: 0,
      left: 20,
      child: SvgPicture.asset(
        "assets/sheet/note1000.svg",
        color: Colors.black,
        height: widgetHeight / 5,
      )));
  widgets.add(Positioned(
      top: -1,
      left: 30,
      child: Text(
        "=${tempo}",
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      )));
}

// 오선보 그리는 함수
void drawStaff(
  List<Widget> widgets,
  double madiWidth,
  double widgetHeight,
) {
  widgets.add(Container(
      width: madiWidth,
      height: widgetHeight,
      child: SvgPicture.asset(
        "assets/sheet/base2.svg",
        fit: BoxFit.fill,
      )));
}

Widget drawNote(double btPos, double horizontalPosition, double noteWgHeight,
    double svgHeight, String assetName, checkIndex) {
  return Positioned(
    bottom: btPos,
    left: horizontalPosition,
    height: noteWgHeight,
    child: SvgPicture.asset(
      "${assetName}",
      color: CHECK_COLOR[checkIndex],
      height: svgHeight,
    ),
  );
}

// 0 X 1 스타카토 2 테누토
Widget drawArticulation(OptionNote note, double bottomPosition,
    double horizontalPosition, double widgetHeight, int checkIndex) {
  //음표높이
  double noteWgHeight =
      note.leng == 4000 ? widgetHeight * 0.30 : widgetHeight * 0.33;

  double articBottom = note.verticalIndex > 5
      ? bottomPosition + widgetHeight * 0.3 //시이상
      : bottomPosition - widgetHeight * 0.15; //시미만
  if (note.leng == 333 && note.verticalIndex == 6) {
    articBottom = bottomPosition + widgetHeight * 0.05;
  }
  //레프트는완성(셋잇단음표포함)
  double articLeft = note.leng == 333
      ? horizontalPosition + noteWgHeight * 0.22
      : horizontalPosition + noteWgHeight * 0.07;
  String articString = ".";
  FontWeight fontWeight = FontWeight.normal;
  double fontSize = widgetHeight * 0.5;

  if (note.articType == 2) {
    articBottom = note.verticalIndex > 5
        ? bottomPosition + widgetHeight * 0.22 //시이상
        : bottomPosition - widgetHeight * 0.246; //시미만 - widgetHeight * 0.246
    //레프트는완성(셋잇단음표포함)
    articLeft = note.leng == 333
        ? horizontalPosition + noteWgHeight * 0.15
        : horizontalPosition + noteWgHeight * 0.07;
    articString = "-";
    fontWeight = FontWeight.w500;
    fontSize = widgetHeight * 0.33;
  }

  return Positioned(
      bottom: articBottom,
      left: articLeft,
      child: Text(
        articString,
        style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: CHECK_COLOR[checkIndex]),
      ));
}

Widget drawAccForCustomMadi(OptionNote note, double horizontalPosition,
    double verticalPosition, double widgetHeight, int checkIndex) {
  var accAssetName = {
    -1: "assets/sheet/fl1.svg",
    1: "assets/sheet/sh1.svg",
    2: "assets/sheet/nat1.svg"
  };
  var accLeftPos = {
    -1: horizontalPosition,
    1: horizontalPosition - 3,
    2: horizontalPosition - 3,
  };
  var btPos = {
    -1: widgetHeight * verticalPosition * 0.3 + widgetHeight * 0.44,
    1: widgetHeight * verticalPosition * 0.3 + widgetHeight * 0.42,
    2: widgetHeight * verticalPosition * 0.3 + widgetHeight * 0.43,
  };
  if (note.verticalIndex < 6) {
    accLeftPos = {
      -1: horizontalPosition,
      1: horizontalPosition - 2,
      2: horizontalPosition - 1,
    };
    btPos = {
      -1: widgetHeight * verticalPosition * 0.3 + widgetHeight * 0.21,
      1: widgetHeight * verticalPosition * 0.3 + widgetHeight * 0.16,
      2: widgetHeight * verticalPosition * 0.3 + widgetHeight * 0.16,
    };
  }
  return Positioned(
    //here
    bottom: btPos[note.accType],
    left: accLeftPos[note.accType],
    child: SvgPicture.asset(
      accAssetName[note.accType],
      color: CHECK_COLOR[checkIndex],
      height: widgetHeight / 6,
    ),
  );
}

// 괄호 그려주는 함수 1 : 괄호시작 2 : 괄호종료
void drawParForCustomMadi(List<Widget> widgets, double widgetHeight,
    double horizontalPosition, int parType) {
  if (parType != 1 && parType != 2) {
    return;
  }
  double whiteLeftValue = horizontalPosition + 0.5;
  if (parType == 2) {
    whiteLeftValue = horizontalPosition - 0.5;
  }

  widgets.add(Positioned(
      bottom: widgetHeight * 0.1,
      left: horizontalPosition,
      child: Container(
        width: widgetHeight * 0.2,
        height: 10,
        color: Colors.black,
      )));

  widgets.add(Positioned(
      bottom: widgetHeight * 0.1 + 0.5,
      left: whiteLeftValue,
      child: Container(
        width: widgetHeight * 0.2,
        height: 10,
        color: Colors.white,
      )));
}

void drawSlur(Stack stack, double deviceWidth, double widgetHeight,
    double zoomX, double posX, double posY, bool isDown) {
  // double zoomX = 0.04;
  // double posX = 0.03;
  // double posY = 0.287;
  double width = deviceWidth * zoomX;
  double height = widgetHeight * zoomX;
  double leftPosition = deviceWidth * posX;

  if (isDown) {
    stack.children.add(
      Positioned(
        height: height,
        left: leftPosition,
        bottom: 0 + widgetHeight * posY,
        child: Container(
          child: ShapeOfView(
            elevation: 0,
            height: height,
            width: width,
            shape: ArcShape(
                direction: ArcDirection.Outside,
                height: height,
                position: ArcPosition.Bottom),
            child: Container(
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
    stack.children.add(
      Positioned(
        height: height,
        left: leftPosition,
        bottom: 1 + widgetHeight * posY,
        child: Container(
          child: ShapeOfView(
            elevation: 0,
            height: height,
            width: width,
            shape: ArcShape(
                direction: ArcDirection.Outside,
                height: height,
                position: ArcPosition.Bottom),
            child: Container(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  } else {
    stack.children.add(
      Positioned(
          height: height,
          left: leftPosition,
          top: 0 + widgetHeight * posY,
          child: RotationTransition(
            turns: AlwaysStoppedAnimation(180 / 360),
            child: Container(
              child: ShapeOfView(
                elevation: 0,
                height: height,
                width: width,
                shape: ArcShape(
                    direction: ArcDirection.Outside,
                    height: height,
                    position: ArcPosition.Bottom),
                child: Container(
                  color: Colors.black,
                ),
              ),
            ),
          )),
    );
    stack.children.add(
      Positioned(
          height: height,
          left: leftPosition,
          top: 1 + widgetHeight * posY,
          child: RotationTransition(
            turns: AlwaysStoppedAnimation(180 / 360),
            child: Container(
              child: ShapeOfView(
                elevation: 0,
                height: height,
                width: width,
                shape: ArcShape(
                    direction: ArcDirection.Outside,
                    height: height,
                    position: ArcPosition.Bottom),
                child: Container(
                  color: Colors.white,
                ),
              ),
            ),
          )),
    );
    stack.children.add(
      Positioned(
          height: widgetHeight,
          width: deviceWidth,
          left: 0,
          top: 10 + widgetHeight * posY,
          child: Container(
              width: deviceWidth, height: widgetHeight, color: Colors.white)),
    );
  }
}
