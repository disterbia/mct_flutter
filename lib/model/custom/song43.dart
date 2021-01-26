import 'package:aa_test/model/custom_song.dart';
import 'package:aa_test/model/songs.dart';

var SONG43 = {
  27: pt1,
  66: pt1,
  72: pt72,
  73: pt2,
  10: ptF1,
  11: ptF1,
  12: ptF1,
  20: ptE1,
  21: ptE1st,
  26: ptD2,
  31: ptD2,
  49: ptF1st,
  50: ptF1,
  51: ptF1,
  59: ptE1,
  60: ptE1,
  65: ptD2st,
  70: ptD2,
};

var TIE43 = {
  18: [
    Tie(
        isDown: false,
        lineNum: 0,
        zoomX: 0.3,
        posX: 0.04,
        posY: 0.2,
        ckIndex: 0),
  ],
  16: [
    Tie(
        isDown: false,
        lineNum: 0,
        zoomX: 0.28,
        posX: 0.75,
        posY: 0.2,
        ckIndex: 0),
  ],
  17: [
    Tie(
        isDown: false,
        lineNum: 0,
        zoomX: 0.06,
        posX: 0.02,
        posY: 0.2,
        ckIndex: 0),
  ],
  15: [
    Tie(
        isDown: true,
        lineNum: 0,
        zoomX: 0.23,
        posX: 0.305,
        posY: 0.07,
        ckIndex: 0),
    Tie(
        isDown: true,
        lineNum: 0,
        zoomX: 0.23,
        posX: 0.55,
        posY: 0.07,
        ckIndex: 0)
  ],
  13: [
    Tie(
        isDown: true,
        lineNum: 0,
        zoomX: 0.05,
        posX: 0.02,
        posY: 0.2,
        ckIndex: 0),
    Tie(
        isDown: true,
        lineNum: 0,
        zoomX: 0.21,
        posX: 0.08,
        posY: 0.07,
        ckIndex: 0),
    Tie(
        isDown: true,
        lineNum: 0,
        zoomX: 0.23,
        posX: 0.3,
        posY: 0.07,
        ckIndex: 0)
  ],
  12: [
    Tie(
        isDown: true,
        lineNum: 0,
        zoomX: 0.23,
        posX: 0.79,
        posY: 0.07,
        ckIndex: 0),
  ],
  8: [
    Tie(
        isDown: false,
        lineNum: 0,
        zoomX: 0.35,
        posX: 0.25,
        posY: 0.2,
        ckIndex: 0),
  ],
  7: [
    Tie(
        isDown: false,
        lineNum: 0,
        zoomX: 0.3,
        posX: 0.04,
        posY: 0.2,
        ckIndex: 0),
  ],
  5: [
    Tie(
        isDown: true,
        lineNum: 0,
        zoomX: 0.23,
        posX: 0.79,
        posY: 0.07,
        ckIndex: 0),
    Tie(
        isDown: true,
        lineNum: 0,
        zoomX: 0.23,
        posX: 0.55,
        posY: 0.07,
        ckIndex: 0)
  ],
  6: [
    Tie(
        isDown: true,
        lineNum: 0,
        zoomX: 0.05,
        posX: 0.02,
        posY: 0.2,
        ckIndex: 0),
  ],
  3: [
    Tie(
        isDown: true,
        lineNum: 0,
        zoomX: 0.21,
        posX: 0.08,
        posY: 0.07,
        ckIndex: 0),
    Tie(
        isDown: true,
        lineNum: 0,
        zoomX: 0.23,
        posX: 0.305,
        posY: 0.07,
        ckIndex: 0),
    Tie(
        isDown: true,
        lineNum: 0,
        zoomX: 0.23,
        posX: 0.55,
        posY: 0.07,
        ckIndex: 0)
  ],
};

var ptD2 = OptionMadi(
    id: 4,
    rhythmUpper: 3,
    rhythmUnder: 4,
    isRhythmShown: false,
    isScaleShown: false,
    isClefShown: false,
    isTempoShown: false,
    scale: 2,
    endType: 0,
    notes: [
      // id,isRest,leng,verticalIndex,horihontalPos,accType,articType,is3Shown,parType,assetName
      OptionNote(
          id: 0,
          isRest: false,
          leng: 2000,
          verticalIndex: NP.D2.index,
          horihontalPos: 0.1 / 30,
          assetName: "note2000_2.svg"),
      OptionNote(
          id: 0,
          isRest: false,
          leng: 0,
          verticalIndex: NP.D2.index,
          horihontalPos: 10 / 30,
          assetName: "opa.svg"),
      OptionNote(
          id: 0,
          isRest: false,
          leng: 1000,
          verticalIndex: NP.D2.index,
          horihontalPos: 20 / 30,
          assetName: "note1000_2.svg"),
    ]);

var ptD2st = OptionMadi(
    id: 4,
    rhythmUpper: 3,
    rhythmUnder: 4,
    isRhythmShown: false,
    isScaleShown: true,
    isClefShown: true,
    isTempoShown: false,
    scale: 2,
    endType: 0,
    notes: [
      // id,isRest,leng,verticalIndex,horihontalPos,accType,articType,is3Shown,parType,assetName
      OptionNote(
          id: 0,
          isRest: false,
          leng: 2000,
          verticalIndex: NP.D2.index,
          horihontalPos: 0.1 / 30,
          assetName: "note2000_2.svg"),
      OptionNote(
          id: 0,
          isRest: false,
          leng: 1000,
          verticalIndex: NP.D2.index,
          horihontalPos: 10 / 30,
          assetName: "opa.svg"),
      OptionNote(
          id: 0,
          isRest: false,
          leng: 1000,
          verticalIndex: NP.D2.index,
          horihontalPos: 20 / 30,
          assetName: "note1000_2.svg"),
    ]);

var ptF1 = OptionMadi(
    id: 4,
    rhythmUpper: 3,
    rhythmUnder: 4,
    isRhythmShown: false,
    isScaleShown: false,
    isClefShown: false,
    isTempoShown: false,
    scale: 2,
    endType: 0,
    notes: [
      // id,isRest,leng,verticalIndex,horihontalPos,accType,articType,is3Shown,parType,assetName
      OptionNote(
          id: 0,
          isRest: false,
          leng: 3000,
          verticalIndex: NP.F1.index,
          horihontalPos: 0.1 / 30,
          assetName: "note3000.svg"),
    ]);
var ptF1st = OptionMadi(
    id: 4,
    rhythmUpper: 3,
    rhythmUnder: 4,
    isRhythmShown: false,
    isScaleShown: true,
    isClefShown: true,
    isTempoShown: false,
    scale: 2,
    endType: 0,
    notes: [
      // id,isRest,leng,verticalIndex,horihontalPos,accType,articType,is3Shown,parType,assetName
      OptionNote(
          id: 0,
          isRest: false,
          leng: 3000,
          verticalIndex: NP.F1.index,
          horihontalPos: 0.1 / 30,
          assetName: "note3000.svg"),
    ]);
var ptE1 = OptionMadi(
    id: 4,
    rhythmUpper: 3,
    rhythmUnder: 4,
    isRhythmShown: false,
    isScaleShown: false,
    isClefShown: false,
    isTempoShown: false,
    scale: 2,
    endType: 0,
    notes: [
      // id,isRest,leng,verticalIndex,horihontalPos,accType,articType,is3Shown,parType,assetName
      OptionNote(
          id: 0,
          isRest: false,
          leng: 3000,
          verticalIndex: NP.E1.index,
          horihontalPos: 0.1 / 30,
          assetName: "note3000.svg"),
    ]);
var ptE1st = OptionMadi(
    id: 4,
    rhythmUpper: 3,
    rhythmUnder: 4,
    isRhythmShown: false,
    isScaleShown: true,
    isClefShown: true,
    isTempoShown: false,
    scale: 2,
    endType: 0,
    notes: [
      // id,isRest,leng,verticalIndex,horihontalPos,accType,articType,is3Shown,parType,assetName
      OptionNote(
          id: 0,
          isRest: false,
          leng: 3000,
          verticalIndex: NP.E1.index,
          horihontalPos: 0.1 / 30,
          assetName: "note3000.svg"),
    ]);

var pt72 = OptionMadi(
    id: 4,
    rhythmUpper: 3,
    rhythmUnder: 4,
    isRhythmShown: false,
    isScaleShown: false,
    isClefShown: false,
    isTempoShown: false,
    scale: 2,
    endType: 0,
    notes: [
      // id,isRest,leng,verticalIndex,horihontalPos,accType,articType,is3Shown,parType,assetName
      OptionNote(
          id: 0,
          isRest: false,
          leng: 3000,
          verticalIndex: NP.F2.index,
          horihontalPos: 0.1 / 30,
          accType: 2,
          assetName: "note3000_2.svg"),
    ]);

var pt2 = OptionMadi(
    id: 4,
    rhythmUpper: 3,
    rhythmUnder: 4,
    isRhythmShown: false,
    isScaleShown: true,
    isClefShown: true,
    isTempoShown: false,
    scale: 2,
    endType: 0,
    notes: [
      // id,isRest,leng,verticalIndex,horihontalPos,accType,articType,is3Shown,parType,assetName
      OptionNote(
          id: 0,
          isRest: false,
          leng: 1000,
          verticalIndex: NP.B1.index,
          horihontalPos: 0.1 / 30,
          assetName: "note1000_2.svg"),
      OptionNote(
          id: 0,
          isRest: false,
          leng: 1000,
          verticalIndex: NP.C2.index,
          horihontalPos: 10 / 30,
          assetName: "note1000_2.svg"),
      OptionNote(
          id: 0,
          isRest: false,
          leng: 1000,
          verticalIndex: NP.F2.index,
          horihontalPos: 20 / 30,
          accType: 2,
          assetName: "note1000_2.svg"),
    ]);
var pt1 = OptionMadi(
    id: 4,
    rhythmUpper: 3,
    rhythmUnder: 4,
    isRhythmShown: false,
    isScaleShown: false,
    isClefShown: false,
    isTempoShown: false,
    scale: 2,
    endType: 0,
    notes: [
      // id,isRest,leng,verticalIndex,horihontalPos,accType,articType,is3Shown,parType,assetName
      OptionNote(
          id: 0,
          isRest: false,
          leng: 1000,
          verticalIndex: NP.E2.index,
          horihontalPos: 0.1 / 30,
          assetName: "note1000_2.svg"),
      OptionNote(
          id: 0,
          isRest: false,
          leng: 1000,
          verticalIndex: NP.F2.index,
          horihontalPos: 10 / 30,
          accType: 2,
          assetName: "note1000_2.svg"),
      OptionNote(
          id: 0,
          isRest: false,
          leng: 1000,
          verticalIndex: NP.G2.index,
          horihontalPos: 20 / 30,
          assetName: "note1000_2.svg"),
    ]);
