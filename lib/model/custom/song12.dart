import 'package:aa_test/model/custom_song.dart';
import 'package:aa_test/model/songs.dart';

var SONG12 = {
  6: pt1,
  10: pt2,
  14: pt1,
  18: pt3,
};

var TIE12 = {
  2: [tie3],
  4: [tie1],
  5: [tie2],
  6: [tie3],
};

var tie1 = Tie(
    isDown: true, lineNum: 0, zoomX: 0.135, posX: 0.07, posY: 0.22, ckIndex: 0);

var tie2 = Tie(
    isDown: true,
    lineNum: 0,
    zoomX: 0.135,
    posX: 0.385,
    posY: 0.22,
    ckIndex: 0);

var tie3 = Tie(
    isDown: true, lineNum: 0, zoomX: 0.135, posX: 0.71, posY: 0.22, ckIndex: 0);

var pt3 = OptionMadi(
    id: 4,
    rhythmUpper: 3,
    rhythmUnder: 4,
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
          leng: 1500,
          verticalIndex: NP.G1.index,
          horihontalPos: 0.1 / 30,
          assetName: "note1500.svg"),
      OptionNote(
          id: 0,
          isRest: false,
          leng: 1000,
          verticalIndex: NP.G1.index,
          horihontalPos: 15 / 30,
          assetName: "note1000.svg"),
    ]);

var pt2 = OptionMadi(
    id: 4,
    rhythmUpper: 3,
    rhythmUnder: 4,
    isRhythmShown: false,
    isScaleShown: true,
    isClefShown: true,
    isTempoShown: false,
    scale: -1,
    endType: 0,
    notes: [
      // id,isRest,leng,verticalIndex,horihontalPos,accType,articType,is3Shown,parType,assetName
      OptionNote(
          id: 0,
          isRest: false,
          leng: 1500,
          verticalIndex: NP.G1.index,
          horihontalPos: 0.1 / 30,
          assetName: "note1500.svg"),
      OptionNote(
          id: 0,
          isRest: false,
          leng: 1000,
          verticalIndex: NP.G1.index,
          horihontalPos: 15 / 30,
          assetName: "note1000.svg"),
      OptionNote(
          id: 0,
          isRest: false,
          leng: 1000,
          verticalIndex: NP.G1.index,
          horihontalPos: 25 / 30,
          assetName: "note500.svg"),
    ]);

var pt1 = OptionMadi(
    id: 4,
    rhythmUpper: 3,
    rhythmUnder: 4,
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
          leng: 1500,
          verticalIndex: NP.A1.index,
          horihontalPos: 0.1 / 30,
          assetName: "note1500.svg"),
      OptionNote(
          id: 0,
          isRest: false,
          leng: 1000,
          verticalIndex: NP.A1.index,
          horihontalPos: 15 / 30,
          assetName: "note1000.svg"),
      OptionNote(
          id: 0,
          isRest: false,
          leng: 1000,
          verticalIndex: NP.D1.index,
          horihontalPos: 25 / 30,
          assetName: "note500.svg"),
    ]);
