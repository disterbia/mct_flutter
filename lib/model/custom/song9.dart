import 'package:aa_test/model/custom_song.dart';
import 'package:aa_test/model/songs.dart';

var SONG9 = {
  8: pt1,
  16: pt1,
  26: pt1,
  28: pt1,
  11: pt2,
  19: pt2,
  23: pt3,
  31: pt4,
};

var TIE9 = {
  2: [tie1],
  4: [tie1],
  7: [tie1, tie1_2],
  3: [tie2],
  5: [tie2],
  6: [tie2],
  8: [tie2],
};

var tie1 = Tie(
    isDown: true, lineNum: 0, zoomX: 0.1, posX: 0.785, posY: 0.27, ckIndex: 0);

var tie1_2 = Tie(
    isDown: true, lineNum: 0, zoomX: 0.1, posX: 0.3, posY: 0.27, ckIndex: 0);

var tie2 = Tie(
    isDown: true, lineNum: 0, zoomX: 0.1, posX: 0.61, posY: 0.22, ckIndex: 0);

var pt4 = OptionMadi(
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
          leng: 1000,
          verticalIndex: NP.D1.index,
          horihontalPos: 0.1 / 30,
          assetName: "note1000.svg"),
      OptionNote(
          id: 0,
          isRest: false,
          leng: 1500,
          verticalIndex: NP.F1.index,
          horihontalPos: 10 / 30,
          assetName: "note1500.svg"),
      OptionNote(
          id: 0,
          isRest: false,
          leng: 250,
          verticalIndex: NP.F1.index,
          horihontalPos: 24 / 30,
          assetName: "note250.svg"),
      OptionNote(
          id: 0,
          isRest: false,
          leng: 250,
          verticalIndex: NP.D2.index,
          horihontalPos: 27.5 / 30,
          assetName: "note250_2.svg"),
    ]);

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
          leng: 1000,
          verticalIndex: NP.F1.index,
          horihontalPos: 0.1 / 30,
          assetName: "note1000.svg"),
      OptionNote(
          id: 0,
          isRest: false,
          leng: 1500,
          verticalIndex: NP.F1.index,
          horihontalPos: 10 / 30,
          assetName: "note1500.svg"),
      OptionNote(
          id: 0,
          isRest: false,
          leng: 250,
          verticalIndex: NP.F1.index,
          horihontalPos: 25 / 30,
          assetName: "note250.svg"),
      OptionNote(
          id: 0,
          isRest: false,
          leng: 250,
          verticalIndex: NP.G1.index,
          horihontalPos: 27.5 / 30,
          assetName: "note250.svg"),
    ]);

var pt2 = OptionMadi(
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
          leng: 1000,
          verticalIndex: NP.D1.index,
          horihontalPos: 0.1 / 30,
          assetName: "note1000.svg"),
      OptionNote(
          id: 0,
          isRest: false,
          leng: 1500,
          verticalIndex: NP.F1.index,
          horihontalPos: 10 / 30,
          assetName: "note1500.svg"),
      OptionNote(
          id: 0,
          isRest: false,
          leng: 250,
          verticalIndex: NP.F1.index,
          horihontalPos: 25 / 30,
          assetName: "note250.svg"),
      OptionNote(
          id: 0,
          isRest: false,
          leng: 250,
          verticalIndex: NP.D1.index,
          horihontalPos: 27.5 / 30,
          assetName: "note250.svg"),
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
          leng: 250,
          verticalIndex: NP.A1.index,
          horihontalPos: 15 / 30,
          assetName: "note250.svg"),
      OptionNote(
          id: 0,
          isRest: false,
          leng: 250,
          verticalIndex: NP.G1.index,
          horihontalPos: 17.5 / 30,
          assetName: "note250.svg"),
      OptionNote(
          id: 0,
          isRest: false,
          leng: 1000,
          verticalIndex: NP.F1.index,
          horihontalPos: 20 / 30,
          assetName: "note1000.svg"),
    ]);
