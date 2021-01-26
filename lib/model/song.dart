class Song {
  int id;
  String title;
  List<Note> notes; // 음표의 배열 (화음 금지)
  double tempo; // 템포(템포변경금지 , 4분음표만)
  int scale; //조표 플랫(-7~-1) 샵(1~7)
  int rhythmUpper; // 박자 (위)
  int rhythmUnder; // 박자 (아래)
  int isGood;
  int history;
  String midPath;
  int level;

  Song(
      {this.id,
      this.title,
      this.notes,
      this.tempo,
      this.rhythmUnder,
      this.rhythmUpper,
      this.isGood,
      this.midPath,
      this.scale,
      this.history,
      this.level});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isGood': isGood,
      'tempo': tempo,
      'midPath': midPath,
      "history": history,
      "level": level
    };
  }
}

class Note {
  int id; // 특정 음 컨트롤용
  int pitch; // 음정 : 제너럴미디의 noteNumber 를 그대로 씁시다. 쉼표는 -1로.
  int leng; // 길이 : 온음표(1) 2분음표(2) 점2분음표(3) 4분음표(4) 점4분음표(6) 8분음표(8)
  int sheetLeng; //악보그릴때 쓰일 Leng
  int state;
  int accType; // 0 : 아무것도 X, 1 : 샵, -1 : 플랫, 2 : 제자리표
  int scale;

  Note({this.id, this.pitch, this.leng, this.state, this.accType, this.scale});
}
