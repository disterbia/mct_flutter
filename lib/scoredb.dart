import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  //database name
  static final _databaseName = "ScoreHistory";
  static final _databaseVersion = 1;

  //table name
  static final table = 'scoreHistory';

  //column(field) name
  static final columnId = '_id';
  static final columnSongId = 'songId';
  static final columnSongName = 'songName';
  static final columnScore = 'score';
  static final columnDate = 'date';

  // make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // only have a single app-wide reference to the database
  static Database _database;
  Future<Database> get database async {
    if (_database != null) {
      return _database;
    }
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    print("-----initDatabase-----");
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate);

  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY,
            $columnSongId INTEGER NOT NULL,
            $columnSongName TEXT NOT NULL,
            $columnScore INTEGER NOT NULL,
            $columnDate TEXT NOT NULL
          )
          ''');
    print("-----Table onCreate-----");
  }

  Future<int> insert(int songId, String songName, int score, String date) async {
    print("inserted");
    Map<String, dynamic> row = {
      DatabaseHelper.columnSongId : songId,
      DatabaseHelper.columnSongName : songName,
      DatabaseHelper.columnScore : score,
      DatabaseHelper.columnDate  : date
    };

    Database db = await instance.database;
    List<Map<String, dynamic>> currentdb = await db.query(table, where: '$columnSongId = ?', whereArgs: [songId]);
    if(currentdb.length == 10) {
      await deleteAnOldRecord(currentdb[0]['_id']);
    }
    return await db.insert(table, row);
  }

  Future<List<Map<String, dynamic>>> queryAllRows(int songid) async {
    Database db = await instance.database;
    return await db.query(table, where: '$columnSongId = ?', whereArgs: [songid]);
  }

  Future<Map<dynamic,dynamic>> readAllRecentScores() async{
    Map results = {};
    Database db = await instance.database;
    var result = await db.rawQuery('SELECT score, $columnSongId FROM $table');
    result.forEach((element) {
      results[element['songId']] = element['score'];
    });
    return results;
  }
  Future<int> deleteAll() async {
    Database db = await instance.database;
    return await db.delete(table);
  }

  Future<void> deleteAnOldRecord(int id) async {
    Database db = await instance.database;
    await db.delete(table, where: '$columnId = ?', whereArgs:  [id]);
  }
}