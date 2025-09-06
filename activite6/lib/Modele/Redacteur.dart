import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';



class User {
  int? id;
  String username;
  String password;

  User({this.id, required this.username, required this.password});
  User.withoutId({required this.username, required this.password});


  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
    };
  }

  @override
  String toString() {
    return 'User{id: $id, username: $username, password: $password}';
  }
}


class Note {
  int? id;
  String title;
  String content;

  Note({this.id, required this.title, required this.content});
  Note.withoutId({required this.title, required this.content});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
    };
  }

   @override
  String toString() {
    return 'Note{id: $id, title: $title, content: $content}';
  }
}

class DatabaseManager {
  static final DatabaseManager _instance = DatabaseManager._internal();
  late Database _database;
  bool _isInitialized = false;

  DatabaseManager._internal();
  factory DatabaseManager() => _instance;

  Future<void> initialize() async {
    if (_isInitialized) return;

    if (kIsWeb) {
      // Web : IndexedDB via sqflite_common_ffi_web
      databaseFactory = databaseFactoryFfiWeb;
      _database = await databaseFactory.openDatabase('app_database.db');

      // 👉 création manuelle des tables (pas de version/onCreate)
      await _createTables(_database);
    } else {
      // Android/iOS/Desktop : SQLite natif
      final dbPath = join(await getDatabasesPath(), 'app_database.db');
      _database = await openDatabase(
        dbPath,
        version: 1,
        onCreate: (db, version) async {
          await _createTables(db);
        },
      );
    }

    _isInitialized = true;
  }

  Future<void> _createTables(Database db) async {
    // Table users
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE,
        password TEXT
      )
    ''');

    // Table notes
    await db.execute('''
      CREATE TABLE IF NOT EXISTS notes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        content TEXT
      )
    ''');
  }

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) await initialize();
  }

  // -------------------- Users CRUD --------------------
  Future<void> insertUser(User user) async {
    await _ensureInitialized();
    await _database.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<User?> getUserByUsername(String username) async {
    await _ensureInitialized();
    final List<Map<String, dynamic>> maps = await _database.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    if (maps.isNotEmpty) {
      return User(
        id: maps.first['id'],
        username: maps.first['username'],
        password: maps.first['password'],
      );
    }
    return null;
  }

  // -------------------- Notes CRUD --------------------
  Future<void> insertNote(Note note) async {
    await _ensureInitialized();
    await _database.insert(
      'notes',
      note.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Note>> getAllNotes() async {
    await _ensureInitialized();
    final List<Map<String, dynamic>> maps = await _database.query('notes');
    return List.generate(maps.length, (i) {
      return Note(
        id: maps[i]['id'],
        title: maps[i]['title'],
        content: maps[i]['content'],
      );
    });
  }

  Future<void> updateNote(Note note) async {
    await _ensureInitialized();
    await _database.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<void> deleteNote(int id) async {
    await _ensureInitialized();
    await _database.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
