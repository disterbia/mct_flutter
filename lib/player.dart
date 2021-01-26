import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sequencer/global_state.dart';
import 'package:flutter_sequencer/models/sample_descriptor.dart';
import 'package:flutter_sequencer/sequence.dart';
import 'package:flutter_sequencer/instrument.dart';
import 'package:dart_midi/dart_midi.dart';
import 'package:flutter/services.dart';
import 'package:aa_test/model/song.dart';
import 'package:path/path.dart';

class MidiPlayer {
  static final MidiPlayer _midiPlayer = MidiPlayer._internal();
  Sequence sequence;
  factory MidiPlayer() {
    return _midiPlayer;
  }

  void newSeq(String path, Song song, void toDo()) {
    sequence = Sequence(tempo: 120, endBeat: 100);
    midiInit(path, song, toDo);
  }

  void newSeqJustOnly() {
    //sequence.destroy();
    sequence = Sequence(tempo: 120, endBeat: 100);
  }

  MidiPlayer._internal() {
    sequence = Sequence(tempo: 120, endBeat: 100);
   // GlobalState().setKeepEngineRunning(true);
    //print("Sequence Init!!!");
  }
}

//쉼표리스트
List<int> REST_NOTES = [
  4000,
  3000,
  2000,
  1500,
  1000,
  750,
  500,
  375,
  250,
  187,
  125
];

List<int> NOW_TRACK_PITCH = [];
List<double> NOW_TRACK_ST_POS = [];
List<int> NOW_TRACK_DURATION = [];

Sequence midiInit(String path, Song song, void toDo()) {
  NOW_TRACK_PITCH = [];
  NOW_TRACK_ST_POS = [];
  NOW_TRACK_DURATION = [];
  Sequence seq = MidiPlayer().sequence;
  seq.getTracks().forEach((track) => seq.deleteTrack(track));
  int endBeat = 100;
  int ticksPerBit = 480;
  int nowBPM = 120;
  List<MidiNote> recorderMelodyArr = [];
  int recorderLineIndex = -1;
  bool isRhythmSet = false;
  bool isBpmSet = false;

  try {
    rootBundle.load(path).then((value) {
      // rootBundle.load("assets/aa111.mid").then((value) {
      // rootBundle.load("assets/aa1111.mid").then((value) {
      var parsedMidi = MidiParser().parseMidiFromBuffer(
          value.buffer.asUint8List(value.offsetInBytes, value.lengthInBytes));
      List<Instrument> instruments = [];

      var parsedMidiTracks = parsedMidi.tracks;
      int parsedMidiTracksCnt = parsedMidiTracks.length;

      /*
       * 미디분석 (트랙 갯수, 트랙악기명)
       */
      bool isScaleParsed = false;
      for (int i = 0; i < parsedMidiTracksCnt; i++) {
        Sf2Instrument sf2Inst = null;
        parsedMidiTracks[i].forEach((midiEvent) {
          if (midiEvent is KeySignatureEvent && !isScaleParsed) {
            song.scale = midiEvent.key;
            isScaleParsed = true;
          }
          if (midiEvent is TrackNameEvent) {
            String instName = (midiEvent as TrackNameEvent).text;
            if (instName.toLowerCase().contains("recorder")) {
              recorderLineIndex = i;

              instruments.add(
                  Sf2Instrument(path: "assets/sf/Recorder.sf2", isAsset: true));
            } else if (instName.toLowerCase().contains("metronome")) {
              instruments
                  .add(SamplerInstrument(id: "metronome", sampleDescriptors: [
                SampleDescriptor(
                    filename: "assets/sf/stick.wav",
                    isAsset: true,
                    noteNumber: 59),
                SampleDescriptor(
                    filename: "assets/sf/stick.wav",
                    isAsset: true,
                    noteNumber: 60),
                SampleDescriptor(
                    filename: "assets/sf/stick.wav",
                    isAsset: true,
                    noteNumber: 61)
              ]));
            } else {
              instruments.add(
                  Sf2Instrument(path: "assets/sf/ppp1.sf2", isAsset: true));
            }
          } else if (midiEvent is TimeSignatureEvent && !isRhythmSet) {
            TimeSignatureEvent tem = midiEvent;
            song.rhythmUpper = tem.numerator;
            song.rhythmUnder = tem.denominator;
          } else if (midiEvent is SetTempoEvent && !isBpmSet) {
            //박자는 디비에서 관리
            //SetTempoEvent tem = midiEvent;
            //song.tempo = (60000000 / tem.microsecondsPerBeat);
          }
        });
      }

      /*
       * 틱스퍼비트
       */
      ticksPerBit = parsedMidi.header.ticksPerBeat;

      /*
       * 앱 내 플레이어(시퀀서) 트랙만들기 시작
       */
      seq.createTracks(instruments).then((realTracks) {
        int trackIndex = 0;

        /*
         * 파싱된 미디를 분석 후 플레이어 트랙으로 만듦
         */
        parsedMidiTracks.forEach((midiTrack) {
          List<int> pitchs = [];
          List<double> startPositions = [];
          List<int> velocitys = [];
          List<double> durations = [];
          List<int> scales = [];
          int currentScale = 0;

          double pos = 0;
          int originPos = 0;

          // 20201201 수정됨(SetTempoEvent 추가 - 도돌이표에서 제대로 인식 안돼서)
          midiTrack.forEach((element) {
            if (element is KeySignatureEvent) {
              currentScale = element.key;
            }
            if (element is SetTempoEvent ||
                element is ControllerEvent ||
                element is NoteOnEvent ||
                element is NoteOffEvent ||
                element is KeySignatureEvent) {
              originPos = originPos + element.deltaTime;
              pos = pos + (element.deltaTime * (120 / nowBPM));
            }

            if (element is NoteOnEvent) {
              scales.add(currentScale);
              pitchs.add(element.noteNumber);
              velocitys.add(element.velocity);
              startPositions.add(pos);
              if (recorderLineIndex == trackIndex) {
                //here
                NOW_TRACK_ST_POS.add(pos / ticksPerBit);
                NOW_TRACK_PITCH.add(element.noteNumber);
              }
            }

            if (element is NoteOffEvent) {
              double tem = element.deltaTime == 0
                  ? durations[durations.length - 1]
                  : element.deltaTime * (120 / nowBPM);
              durations.add(tem);
              if (recorderLineIndex == trackIndex) {
                NOW_TRACK_DURATION.add(element.deltaTime);
              }
            }
          });

          if (pitchs.length > 0) {
            int index = pitchs.length;
            for (var i = 0; i < index; i++) {
              realTracks[trackIndex].addNote(
                  noteNumber: trackIndex == recorderLineIndex
                      ? pitchs[i] - 12
                      : pitchs[i],
                  velocity: (velocitys[i] / 100) > 1 ? 1 : velocitys[i] / 100,
                  startBeat: startPositions[i] / ticksPerBit,
                  durationBeats: trackIndex == recorderLineIndex
                      ? durations[i] / ticksPerBit
                      : durations[i] / ticksPerBit * 1.5);
              if (trackIndex == recorderLineIndex) {
                recorderMelodyArr.add(
                  MidiNote(
                      scale: scales[i],
                      pitch: pitchs[i] - 12,
                      startPosition: startPositions[i] / ticksPerBit * 1000,
                      dulation:
                          ((durations[i] / ticksPerBit) * 100).ceil() * 10),
                );
              }
            }
          }

          //반주만 - 2 :0 동시에 - 3 :0.25
          if (trackIndex != recorderLineIndex) {
            if (Platform.isAndroid)
              realTracks[trackIndex].addVolumeChange(volume: 3, beat: 0);
            else
              realTracks[trackIndex].addVolumeChange(volume: 1, beat: 0);
          } else {
            realTracks[trackIndex].addVolumeChange(volume: 1, beat: 0);
          }
          //EndBeat 처리
          if (durations.length > 0) {
            int lastDuration =
                ((durations.last / ticksPerBit) * 100).ceil() * 10;
            double lastPosition = startPositions.last / ticksPerBit * 1000;
            int nowEndBeat =
                ((lastDuration + lastPosition + 1001) / 1000).ceil();
            if (nowEndBeat > endBeat) {
              endBeat = nowEndBeat;
            }
          }
          trackIndex++;
        });
        seq.setEndBeat(endBeat.toDouble());

        song.notes = midiNoteToNote(
            recorderMelodyArr, song.rhythmUpper, song.rhythmUnder);
        List<int> pp = [];
        List<int> tt = [];
        song.notes.forEach((e) {
          pp.add(e.pitch);
          tt.add(e.leng);
        });
        //마지막마디 쉼표처리
        int notesCnt = song.notes.length;
        int nowMadiSize = 0;
        int maxSizeOfMadi = (song.rhythmUpper / song.rhythmUnder * 4000).ceil();
        for (int kk = 0; kk < notesCnt; kk++) {
          nowMadiSize += song.notes[kk].leng;
          //셋잇단음표 때문데 4 오차 허용
          if (nowMadiSize + 4 >= maxSizeOfMadi) {
            nowMadiSize = 0;
          }
        }
        // int lastRestSize = maxSizeOfMadi - nowMadiSize;
        // if (lastRestSize > 4 && lastRestSize < maxSizeOfMadi) {
        //   int restLoop = REST_NOTES.length;
        //   for (int kkk = 0; kkk < restLoop; kkk++) {
        //     if (lastRestSize >= REST_NOTES[kkk]) {
        //       int nowRestCnt = lastRestSize ~/ REST_NOTES[kkk];
        //       for (int restKK = 0; restKK < nowRestCnt; restKK++) {
        //         song.notes.add(Note(
        //             leng: REST_NOTES[kkk],
        //             pitch: -1,
        //             state: 0,
        //             scale: song.notes.last.scale));
        //         lastRestSize -= REST_NOTES[kkk];
        //       }
        //     }
        //   }
        // }
        int noteIndex = 0;
        song.notes.forEach((n) {
          n.id = noteIndex++;
        });
        toDo();
      });
    });
  } catch (e) {
    //print("ca");
  }
}

List<Note> midiNoteToNote(
    List<MidiNote> midiNote, int rhythmUpper, int rhythmUnder) {
  List<Note> notes = [];
  int maxLengthOfMadi = (4000 / rhythmUnder).round();
  int nowMadiLength = 0; //쉽표쪼개기용 1000|0111 일때 쉼표 4000으로 인식 안되게...
  maxLengthOfMadi *= rhythmUpper;
  int position = 0;
  midiNote.forEach((note) {
    switch (note.dulation) {
      case 130:
        note.dulation = 125;
        break;
      case 190:
        note.dulation = 187;
        break;
      case 380:
        note.dulation = 375;
        break;
      case 40:
        note.dulation = 41;
        break;
      case 90:
        note.dulation = 83;
        break;
      case 170:
        note.dulation = 166;
        break;
      case 340:
        note.dulation = 333;
        break;
      case 670:
        note.dulation = 666;
        break;
      case 1340:
        note.dulation = 1333;
        break;
    }
    //셋잇단음표때문에 1~2오차허용
    if (note.startPosition - position == 1) {
      position++;
      nowMadiLength++;
    } else if (note.startPosition - position == 2) {
      position += 2;
      nowMadiLength += 2;
    }
    if (position <= note.startPosition && position > note.startPosition - 20) {
      notes.add(Note(
          leng: note.dulation, pitch: note.pitch, state: 0, scale: note.scale));
      position = note.dulation + note.startPosition.toInt();
      if (nowMadiLength == maxLengthOfMadi) {
        nowMadiLength = note.dulation;
      } else {
        nowMadiLength = nowMadiLength + note.dulation > maxLengthOfMadi
            ? note.dulation //0 -> note.dulation 1110 0000 이슈
            : nowMadiLength + note.dulation;
      }
    } else {
      //쉼표처리

      int restLength = note.startPosition.toInt() - position;
      if (nowMadiLength == maxLengthOfMadi) {
        nowMadiLength = 0;
      }
      //셋 잇단음표 길이가 무리수라 정수로 만들어줌
      switch (nowMadiLength % 10) {
        case 9:
          nowMadiLength++;
          break;
        case 8:
          nowMadiLength += 2;
          break;
      }

      // 12/29 수정 (1110 0000 0000 일때 4분쉼표 온쉼표 온쉼표 이런식으로 생기게)
      int restLoop = REST_NOTES.length;

      if (restLength > 0) {
        for (int i = 0; i < restLoop; i++) {
          if (maxLengthOfMadi >= REST_NOTES[i] &&
              nowMadiLength + REST_NOTES[i] <= maxLengthOfMadi) {
            if (maxLengthOfMadi == 3000 && REST_NOTES[i] == 2000) {
              continue;
            }
            int cnt = (restLength / REST_NOTES[i]).floor();
            if (cnt > 0) {
              restLength -= REST_NOTES[i];
              notes.add(Note(
                  leng: REST_NOTES[i], pitch: -1, state: 0, scale: note.scale));
              nowMadiLength = nowMadiLength + REST_NOTES[i] >= maxLengthOfMadi
                  ? 0
                  : nowMadiLength + REST_NOTES[i];
              if (nowMadiLength == 0) {
                i = 0;
              }
              i--;
            }
          }
        }
      }

      // if (restLength > 0) {
      //   restNotes.forEach((nowRest) {
      //     if (maxLengthOfMadi >= nowRest &&
      //         nowMadiLength + nowRest <= maxLengthOfMadi) {
      //       int cnt = (restLength / nowRest).floor();
      //       if (cnt > 0) {
      //         restLength -= nowRest * cnt;
      //         for (int i = 0; i < cnt; i++) {
      //           notes.add(Note(leng: nowRest, pitch: -1, state: 0));
      //           nowMadiLength = nowMadiLength + nowRest >= maxLengthOfMadi
      //               ? 0
      //               : nowMadiLength + nowRest;
      //         }
      //       }
      //     }
      //   });
      // }

      //쉼표 후 노트삽입
      notes.add(Note(
          leng: note.dulation, pitch: note.pitch, state: 0, scale: note.scale));
      position = note.dulation + note.startPosition.toInt();
      nowMadiLength = nowMadiLength + note.dulation >= maxLengthOfMadi
          ? 0
          : nowMadiLength + note.dulation;
    }
  });
  return notes;
}

void test(List<Note> notes) {
  int maxLengthOfMadi = 4000;

  List<int> restNotes = [4000, 3000, 2000, 1500, 1000, 750, 500, 375, 250];
  int restLength = 7750;

  restNotes.forEach((nowRest) {
    if (maxLengthOfMadi >= nowRest) {
      int cnt = (restLength / nowRest).floor();
      if (cnt > 0) {
        restLength -= nowRest * cnt;
        for (int i = 0; i < cnt; i++) {
          notes.add(Note(leng: nowRest, pitch: -1, state: 0));
        }
      }
    }
  });
}

/*
 * 미디파일 파싱중 쓰는 노트객체
 */

class MidiNote {
  int pitch;
  double startPosition;
  int dulation = 0; // 400 온음표 / 200 2분음표 / 100 4분음표 / 50 8분음표 / 25 16분음표
  int scale;

  MidiNote({this.pitch, this.startPosition, this.dulation, this.scale});
}

/*
 * 악보그리는데 사용될 객체들
 */

// class Song {
//   int id;
//   String title;
//   List<Note> notes; // 음표의 배열 (화음 금지)
//   int tempo; // 템포(템포변경금지 , 4분음표만)
//   int rhythmUpper; // 박자 (위)
//   int rhythmUnder; // 박자 (아래)

//   Song(
//       {this.id,
//       this.title,
//       this.notes,
//       this.tempo,
//       this.rhythmUnder,
//       this.rhythmUpper});
// }

// class Note {
//   int pitch; // 음정 : 제너럴미디의 noteNumber 를 그대로 씁시다. 쉼표는 -1로.
//   int leng; // 길이 : 온음표(1) 2분음표(2) 점2분음표(3) 4분음표(4) 점4분음표(6) 8분음표(8)
//   int state;

//   Note({this.pitch, this.leng, this.state});
// }
