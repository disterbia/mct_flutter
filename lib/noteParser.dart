//셋잇단음표 박자 밀리는 현상때문에 셋잇단음표 길이원위치하는 함수
//temp - toTempo Arr에 사용
import 'package:aa_test/model/song.dart';

List<double> getTempos(List<Note> lengArr, double bpm) {
  List<double> resultArr = [];
  lengArr.forEach((note) {
    double tempLeng = note.leng * 0.994;
    // switch (tempLeng) {
    //   case 125:
    //     tempLeng = 124;
    //     break;
    //   case 250:
    //     tempLeng = 248;
    //     break;
    //   case 187:
    //     tempLeng = 185;
    //     break;
    //   case 375:
    //     tempLeng = 372;
    //     break;
    //   case 41:
    //     tempLeng = 41;
    //     break;
    //   case 83:
    //     tempLeng = 82;
    //     break;
    //   case 166:
    //     tempLeng = 165;
    //     break;
    //   case 333:
    //     tempLeng = 330;
    //     break;
    //   case 666:
    //     tempLeng = 660;
    //     break;
    //   case 500:
    //     tempLeng = 495;
    //     break;
    //   case 1000:
    //     tempLeng = 990;
    //     break;
    //   case 1333:
    //     tempLeng = 1320;
    //     break;
    //   case 2000:
    //     tempLeng = 1980;
    //     break;
    //   case 3000:
    //     tempLeng = 2970;
    //     break;
    //   case 4000:
    //     tempLeng = 3800;
    //     break;
    // }
    resultArr.add(tempLeng * 60 / bpm);
  });

  return resultArr;
}

//첫음과 끝음의 절대포지션 비교해서 우측이 크면 0.15 좌측이 크면 -0.15 같을 시 0
//0104 조건하나추가 : 두음이상 같을 시 일직선
double getAngleForTriplet(List<int> pitchArr, int scale) {
  int eqCnt = 0;
  int arrSize = pitchArr.length;
  for (int i = 0; i < arrSize; i++) {
    if (i + 1 < arrSize) {
      for (int j = i + 1; j < 3; j++) {
        if (getPitchPosition(pitchArr[i], scale) ==
            getPitchPosition(pitchArr[j], scale)) {
          eqCnt++;
        }
      }
    }
  }
  if (eqCnt > 0) {
    return 0;
  }
  int startPitch = getPitchPosition(pitchArr[0], scale);
  int endPitch = getPitchPosition(pitchArr[2], scale);
  if (startPitch == endPitch) {
    return 0;
  } else {
    return startPitch > endPitch ? 5 / 360 : -5 / 360;
  }
}
// double getAngleForTriplet(int startPitch, int endPitch) {
//   if (startPitch == endPitch) {
//     return 0;
//   } else {
//     return startPitch > endPitch ? 5 / 360 : -5 / 360;
//   }
// }

// 절대위치
int getAbsPosition(
    int pitch, int scale, bool isAcc, bool isFlat, bool isNature) {
  List<int> scaleList = getScaleList(scale);
  //해당 스케일 안에 있을경우
  for (int i = 0; i < scaleList.length; i++) {
    if (pitch == scaleList[i]) {
      return i;
    }
  }
  //해당 스케일 안에 없는경우 스케일에 따라 1 증감시킨 후 다시 반복문
  if (isAcc) {
    if (isNature) {
      pitch += scale < 0 ? -1 : 1;
    } else {
      if (isFlat) {
        pitch += scale < 0 ? 1 : -1;
      } else {
        pitch += scale < 0 ? 1 : -1;
      }
    }
  }
  for (int i = 0; i < scaleList.length; i++) {
    if (pitch == scaleList[i]) {
      return i;
    }
  }
  return -1;
}

// 스케일이 적용된 악보상 절대포지션 리턴
int getPitchPosition(int pitch, int scale, {bool isPrint = false}) {
  List<int> scaleList = getScaleList(scale);
  //해당 스케일 안에 있을경우
  if (isPrint) {
   // print(pitch);
   // print(scaleList);
  }
  for (int i = 0; i < scaleList.length; i++) {
    if (pitch == scaleList[i]) {
      return i;
    }
  }
  //해당 스케일 안에 없는경우 스케일에 따라 1 증감시킨 후 다시 반복문
  if (scale < 0) {
    pitch++;
  } else {
    pitch--;
  }
  for (int i = 0; i < scaleList.length; i++) {
    if (pitch == scaleList[i]) {
      return i;
    }
  }
  return -1;
}

List<int> getScaleList(int scale) {
  // #개수 별 G D A E B F# C#
  if (scale > 7 || scale < -7) {
    scale = 0;
  }
  if (scale < 0) {
    scale *= -1;
    scale += 7;
  }
  List<int> basePitchs = [
    60,
    55,
    50,
    57,
    52,
    59,
    54,
    49,
    53,
    58,
    51,
    56,
    49,
    54,
    59
  ];

  int basePitch = basePitchs[scale];

  List<int> majorScale = [2, 2, 1, 2, 2, 2, 1];

  List<int> returnScale = [];
  int loopIndex = 0;
  while (basePitch < 100) {
    if (basePitch > 59) {
      returnScale.add(basePitch);
    }
    basePitch += majorScale[loopIndex % 7];
    loopIndex++;
  }
  return returnScale;
}

double NOTE_POS_FOR_PITCH_PARSER = 8.5;
int RES_POS_FOR_PITCH_PARSER = 16;
List<double> SHEET_POSITIONS = [
  1 / NOTE_POS_FOR_PITCH_PARSER, //도(60), 도#(61)
  2 / NOTE_POS_FOR_PITCH_PARSER, //레(62), 레#(63)
  3 / NOTE_POS_FOR_PITCH_PARSER, //미(64)
  4 / NOTE_POS_FOR_PITCH_PARSER, //파(65), 파#(66)
  5 / NOTE_POS_FOR_PITCH_PARSER, //솔(67), 솔#(68)
  6 / NOTE_POS_FOR_PITCH_PARSER, //라(69), 라#(70)
  0.01, //시(71)
  1 / NOTE_POS_FOR_PITCH_PARSER, //도(72), 도#(73)
  2 / NOTE_POS_FOR_PITCH_PARSER, //레(74), 레#(75)
  3 / NOTE_POS_FOR_PITCH_PARSER, //미(76)
  4 / NOTE_POS_FOR_PITCH_PARSER, //파(77), 파#(78)
  4.9 / NOTE_POS_FOR_PITCH_PARSER, //솔(79), 솔#(80)
  6 / NOTE_POS_FOR_PITCH_PARSER, //라(81), 라#(82)
  7 / NOTE_POS_FOR_PITCH_PARSER, //시(83)
  7.85 / NOTE_POS_FOR_PITCH_PARSER, //도(84), 도#(85)
  1 //레(86)
];

double getPositionByAbsPos(int absPos) {
  return SHEET_POSITIONS[absPos];
}

double pitchParser(int pitch, int scale) {
  double verticalPosition = 0;
  double notePos = NOTE_POS_FOR_PITCH_PARSER;
  int restPos = RES_POS_FOR_PITCH_PARSER;
  List<int> scaleList = getScaleList(scale);
  int pitchIndex = -1;

  //피치가 해당 스케일안에 들면 해당 계이름의 인덱스를 기준으로 높이를 정하자!
  if (pitch < 0) {
    //쉼표일경우
    verticalPosition = pitch == -1
        ? verticalPosition = 5 / restPos
        : verticalPosition = 7 / restPos;
    return verticalPosition;
  } else {
    //음정이 해당스케일 안에 들어올경우
    int cnt = scaleList.length;
    for (int i = 0; i < cnt; i++) {
      if (scaleList[i] == pitch) {
        pitchIndex = i;
        verticalPosition = SHEET_POSITIONS[pitchIndex];
        return verticalPosition;
      }
    }
    if (pitchIndex < 0) {
      // 다장조 일때는 그냥 샵붙임
      if (scale == 0) {
        for (int i = 0; i < cnt; i++) {
          if (scaleList[i] == pitch - 1) {
            pitchIndex = i;
            verticalPosition = SHEET_POSITIONS[pitchIndex] + 1;
            return verticalPosition;
          }
        }
      } else {
        //다장조가 아닐 경우 플랫이나 샵붙을경우
        int positionPitch = scale < 0 ? pitch - 1 : pitch + 1; //더할수
        int scaleLoopIndex = scale < 0 ? scale * -1 : scale;
        List<int> addArr = scale < 0
            ? [71, 64, 69, 62, 67, 72, 65]
            : [65, 72, 67, 62, 69, 64, 71];
        //제자리표
        for (int i = 0; i < scaleLoopIndex; i++) {
          if (pitch == addArr[i] ||
              pitch == addArr[i] * 2 ||
              pitch == addArr[i] * 3) {
            for (int j = 0; j < cnt; j++) {
              if (scaleList[j] == positionPitch) {
                pitchIndex = j;
                verticalPosition = SHEET_POSITIONS[pitchIndex] + 2;
                return scale < 0 ? verticalPosition * -1 : verticalPosition;
              }
            }
          }
        }
        //샵이나 플랫붙임
        int positionPitch2 = scale < 0 ? pitch + 1 : pitch - 1; //더할수
        for (int j = 0; j < cnt; j++) {
          if (scaleList[j] == positionPitch2) {
            pitchIndex = j;
            verticalPosition = SHEET_POSITIONS[pitchIndex] + 1;
            return scale < 0 ? verticalPosition * -1 : verticalPosition;
          }
        }
      }
    }
  }
}

// double pitchParser(int pitch, int scale) {
//   double verticalPosition = 0;
//   double notePos = 8.5;
//   int restPos = 16;
//   switch (pitch) {
//     case -1:
//       verticalPosition = 5 / restPos;
//       break;
//     case -2:
//       verticalPosition = 7 / restPos;
//       break;
//     case 60:
//       verticalPosition = 1 / notePos; //도
//       break;
//     case 61:
//       verticalPosition = 1 / notePos; //도#
//       break;
//     case 62:
//       verticalPosition = 2 / notePos; //레
//       break;
//     case 63:
//       verticalPosition = 2 / notePos; //레#
//       break;
//     case 64:
//       verticalPosition = 3 / notePos; //미
//       break;
//     case 65:
//       verticalPosition = 4 / notePos; //파
//       break;
//     case 66:
//       verticalPosition = 4 / notePos; //파#
//       break;
//     case 67:
//       verticalPosition = 5 / notePos; //솔
//       break;
//     case 68:
//       verticalPosition = 5 / notePos; //솔#
//       break;
//     case 69:
//       verticalPosition = 6 / notePos; //라
//       break;
//     case 70:
//       verticalPosition = 6 / notePos; //라#
//       break;
//     case 71:
//       verticalPosition = -0.01; //시
//       break;
//     case 72:
//       verticalPosition = 1 / notePos; //도
//       break;
//     case 73:
//       verticalPosition = 1 / notePos; //도#
//       break;
//     case 74:
//       verticalPosition = 2 / notePos; //레
//       break;
//     case 75:
//       verticalPosition = 2 / notePos; //레#
//       break;
//     case 76:
//       verticalPosition = 3 / notePos; //미
//       break;
//     case 77:
//       verticalPosition = 4 / notePos; //파
//       break;
//     case 78:
//       verticalPosition = 4 / notePos; //파#
//       break;
//     case 79:
//       verticalPosition = 4.9 / notePos; //솔
//       break;
//     case 80:
//       verticalPosition = 4.9 / notePos; //솔#
//       break;
//     case 81:
//       verticalPosition = 6 / notePos; //라
//       break;
//     case 82:
//       verticalPosition = 6 / notePos; //라#
//       break;
//     case 83:
//       verticalPosition = 7 / notePos; //시
//       break;
//     case 84:
//       verticalPosition = 7.85 / notePos; //도
//       break;
//     case 85:
//       verticalPosition = 7.85 / notePos; //도#
//       break;
//     case 86:
//       verticalPosition = 1; //레
//       break;
//   }
//   if (verticalPosition == 0) {
//     verticalPosition = 7 / 16;
//   }

//   //여기서부터 스케일 이외의 음에 샵(+1) 더하기
//   bool isHalf = true;
//   bool isNature = false;
//   getScaleList(scale).forEach((p) {
//     if (pitch == p) {
//       isHalf = false;
//     }
//   });
//   getScaleList(0).forEach((p) {
//     if (pitch == p && isHalf) {
//       isNature = true;
//     }
//   });
//   if (pitch < 0) {
//     isHalf = false;
//   }
//   if (isNature) {
//     return verticalPosition + 2;
//   } else {
//     return isHalf ? verticalPosition + 1 : verticalPosition;
//   }
// }

double pitchScore(int pitch) {
  switch (pitch) {
    case -1:
      return 0;
    case -2:
      return 0;
    case 60:
      return 523; //도
      break;
    case 61:
      return 554; //도#
      break;
    case 62:
      return 587; //레
      break;
    case 63:
      return 622; //레#
      break;
    case 64:
      return 659; //미
      break;
    case 65:
      return 698; //파
      break;
    case 66:
      return 739; //파#
      break;
    case 67:
      return 784; //솔
      break;
    case 68:
      return 830; //솔#
      break;
    case 69:
      return 880; //라
      break;
    case 70:
      return 932; //라#
      break;
    case 71:
      return 987; //시
      break;
    case 72:
      return 1046; //도
      break;
    case 73:
      return 1108; //도#
      break;
    case 74:
      return 1174; //레
      break;
    case 75:
      return 1244; //레#
      break;
    case 76:
      return 1318; //미
      break;
    case 77:
      return 1396; //파
      break;
    case 78:
      return 1479; //파#
      break;
    case 79:
      return 1567; //솔
      break;
    case 80:
      return 1661; //솔#
      break;
    case 81:
      return 1760; //라
      break;
    case 82:
      return 1864; //라#
      break;
    case 83:
      return 1975; //시
      break;
    case 84:
      return 2093; //도
      break;
    case 85:
      return 2093; //도
      break;
    case 86:
      return 2217; //도#
      break;
    case 87:
      return 2349; //레
      break;
  }
}

double gameScore(int pitch) {
  switch (pitch) {
    case 0:
      return 523; //도
      break;
    case 1:
      return 554; //도#
      break;
    case 2:
      return 587; //레
      break;
    case 3:
      return 622; //레#
      break;
    case 4:
      return 659; //미
      break;
    case 5:
      return 698; //파
      break;
    case 6:
      return 739; //파#
      break;
    case 7:
      return 784; //솔
      break;
    case 8:
      return 830; //솔#
      break;
    case 9:
      return 880; //라
      break;
    case 10:
      return 932; //라#
      break;
    case 11:
      return 987; //시
      break;
    case 12:
      return 1046; //도
      break;
    case 13:
      return 1108; //도#
      break;
    case 14:
      return 1174; //레
      break;
    case 15:
      return 1244; //레#
      break;
    case 16:
      return 1318; //미
      break;
    case 17:
      return 1396; //파
      break;
    case 18:
      return 1479; //파#
      break;
    case 19:
      return 1567; //솔
      break;
    case 20:
      return 1661; //솔#
      break;
    case 21:
      return 1760; //라
      break;
    case 22:
      return 1864; //라#
      break;
    case 23:
      return 1975; //시
      break;
    case 24:
      return 2093; //도
      break;
    case 25:
      return 2093; //도
      break;
    case 26:
      return 2217; //도#
      break;
    case 27:
      return 2349; //레
      break;
  }
}
