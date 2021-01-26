import 'package:aa_test/model/custom_song.dart';
import 'package:aa_test/model/songs.dart';

var SONG15 = {
  40: pt1(false),
  41: pt1(true),
  42: pt2,
};

var TIE15 = {
  8: [tie1, tie2],
  9: [tie3, tie4],
};

var tie1 = Tie(
    isDown: false, lineNum: 0, zoomX: 0.27, posX: 0.595, posY: 0.2, ckIndex: 0);

var tie2 = Tie(
    isDown: false, lineNum: 0, zoomX: 0.27, posX: 0.8, posY: 0.2, ckIndex: 0);

var tie3 = Tie(
    isDown: false, lineNum: 0, zoomX: 0.04, posX: 0.03, posY: 0.28, ckIndex: 0);

var tie4 = Tie(
    isDown: false, lineNum: 0, zoomX: 0.31, posX: 0.03, posY: 0.2, ckIndex: 0);
OptionMadi pt1(bool isFirstMadi) {
  return OptionMadi(
      id: 0,
      rhythmUpper: 3,
      rhythmUnder: 8,
      isRhythmShown: false,
      isScaleShown: isFirstMadi,
      isClefShown: isFirstMadi,
      isTempoShown: false,
      scale: -1,
      endType: 0,
      notes: [
        // id,isRest,leng,verticalIndex,horihontalPos,accType,articType,is3Shown,parType,assetName
        OptionNote(
            id: 0,
            isRest: false,
            leng: 1500,
            verticalIndex: NP.C2.index,
            horihontalPos: 0.1 / 30,
            assetName: "note1500_2.svg"),
      ]);
}

var pt2 = OptionMadi(
    id: 0,
    rhythmUpper: 3,
    rhythmUnder: 8,
    isRhythmShown: false,
    isScaleShown: false,
    isClefShown: false,
    isTempoShown: false,
    scale: -1,
    endType: 0,
    notes: [
      // id,isRest,leng,verticalIndex,horihontalPos,accType,articType,is3Shown,parType,assetName
      OptionNote(
          id: 0,
          isRest: false,
          leng: 1000,
          verticalIndex: NP.C2.index,
          horihontalPos: 0.1 / 30,
          assetName: "note1000_2.svg"),
      OptionNote(
          id: 0,
          isRest: false,
          leng: 1000,
          accType: -1,
          verticalIndex: NP.C2.index,
          horihontalPos: 20 / 30,
          assetName: "note500_2.svg"),
    ]);
