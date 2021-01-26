import 'package:aa_test/model/song.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SongDb {
  var _db;

  Future<Database> get database async {
    if (_db != null) return _db;
    _db = openDatabase(join(await getDatabasesPath(), 'song_database.db'),
        onCreate: (db, version) {
          return db.execute(
              "CREATE TABLE songs(id INTEGER PRIMARY KEY,title TEXT ,isGood INTEGER DEFAULT 0,midPath TEXT,tempo DOUBLE NOT NULL,history INTEGER DEFAULT 0,level INTEGER NOT NULL)");
        }, version: 1);
    return _db;
  }

  Future<void> insertSong(Song song) async {
    final Database db = await database;
    await db.insert('songs', song.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<List<Song>> getAllSongs(int level) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('songs',where: "level =?",
      whereArgs: [level],);
    return List.generate(maps.length, (i) {
      return Song(
          id: maps[i]['id'],
          title: maps[i]['title'],
          isGood: maps[i]['isGood'],
          tempo: maps[i]['tempo'],
          midPath: maps[i]['midPath'],
          history: maps[i]['history'],
          level :  maps[i]['level']
      );
    });
  }

  Future<List<Song>> getGoodSongs() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'songs',
      where: "isGood =?",
      whereArgs: [1],
    );
    return List.generate(maps.length, (i) {
      return Song(
          id: maps[i]['id'],
          title: maps[i]['title'],
          tempo: maps[i]['tempo'],
          isGood: maps[i]['isGood'],
          midPath: maps[i]['midPath'],
          history: maps[i]['history'],
          level :  maps[i]['level']
      );
    });
  }

  Future<List<Song>> getHistorySongs() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'songs',
      where: "history =?",
      whereArgs: [1],
    );
    return List.generate(maps.length, (i) {
      return Song(
          id: maps[i]['id'],
          title: maps[i]['title'],
          tempo: maps[i]['tempo'],
          isGood: maps[i]['isGood'],
          midPath: maps[i]['midPath'],
          history: maps[i]['history'],
          level :  maps[i]['level']
      );
    });
  }

  Future<void> updateSong(Song song) async {
    final db = await database;
    await db
        .update('songs', song.toMap(), where: "id= ?", whereArgs: [song.id]);
  }
}
