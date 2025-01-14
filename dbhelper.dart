import 'dart:convert'; // For JSON encoding and decoding
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'user_database.db');
    //await deleteDatabase(path);

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE,
            contacts TEXT
          )
        ''');
      },
    );
  }

  // Add a user
  Future<int> addUser(String username, List<Map<String, String>> contacts) async {
    final db = await database;
    final contactsJson = jsonEncode(contacts); // Convert contacts to JSON string
    return await db.insert('users', {
      'username': username,
      'contacts': contactsJson,
    });
  }

  // Check if the username exists
  Future<bool> loginUser(String username) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );

    return result.isNotEmpty;
  }

  // Get contacts for a user
  Future<List<Map<String, String>>> getContacts(String username) async {
    final db = await database;
    final result = await db.query(
      'users',
      columns: ['contacts'],
      where: 'username = ?',
      whereArgs: [username],
    );

    if (result.isNotEmpty) {
      final contactsJson = result.first['contacts'] as String;
      final decodedContacts = jsonDecode(contactsJson) as List;
      return decodedContacts.map((contact) => Map<String, String>.from(contact)).toList();
    }

    return [];
  }

  // Update contacts for a user
  Future<int> updateContacts(String username, List<Map<String, String>> contacts) async {
    final db = await database;
    final contactsJson = jsonEncode(contacts); // Convert contacts to JSON string
    print(contactsJson);
    return await db.update(
      'users',
      {'contacts': contactsJson},
      where: 'username = ?',
      whereArgs: [username],
    );
  }
}
