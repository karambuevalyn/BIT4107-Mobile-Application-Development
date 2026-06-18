import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class DBHelper {
  static const _databaseName = "UniversityDatabase.db";
  static const _databaseVersion = 1;

  // Singleton instance
  DBHelper._privateConstructor();
  static final DBHelper instance = DBHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = p.join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path, version: _databaseVersion, onCreate: _onCreate);
  }

  // Relational Tables Creation
  Future<void> _onCreate(Database db, int version) async {
    // Enable Foreign Key support in SQLite
    await db.execute("PRAGMA foreign_keys = ON;");

    await db.execute('''
          CREATE TABLE students (
            student_id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            course TEXT NOT NULL,
            phone_number TEXT UNIQUE,
            password_hash TEXT NOT NULL
          )
          ''');

    // Attendance Records Table
    await db.execute('''
          CREATE TABLE attendance_records (
            record_id INTEGER PRIMARY KEY AUTOINCREMENT,
            student_id TEXT NOT NULL,
            date TEXT NOT NULL,
            status TEXT NOT NULL,
            FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE
          )
          ''');
  }

  // Security Requirement: SHA-256 Password Hashing Utility
  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  // Manual Student Registration with Hashed Passwords
  Future<int> registerStudent(Map<String, dynamic> studentData) async {
    Database db = await instance.database;

    // Hash the password before it touches the local disk
    String rawPassword = studentData['password'] ?? 'default123';
    String secureHash = _hashPassword(rawPassword);

    return await db.insert('students', {
      'student_id': studentData['student_id'],
      'name': studentData['name'],
      'course': studentData['course'],
      'phone_number': studentData['phone_number'],
      'password_hash': secureHash, // Saving hashed evidence
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> syncNetworkStudents(List<dynamic> networkUsers) async {
    Database db = await instance.database;
    Batch batch = db.batch();

    for (var user in networkUsers) {
      batch.insert(
        'students',
        {
          'student_id': 'REG-${user['id']}',
          'name': user['name'],
          'course': 'Computing & IT',
          'phone_number': user['phone'] ?? '0700000000',
          'password_hash': _hashPassword('StudentSystemPass!'), // for default safe hash
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  //Marking Attendance for a specific student
  Future<int> recordAttendance(String studentId, String status) async {
    Database db = await instance.database;
    String today = DateTime.now().toIso8601String().substring(0, 10); // YYYY-MM-DD

    return await db.insert('attendance_records', {
      'student_id': studentId,
      'date': today,
      'status': status,
    });
  }

  // for fetching records
  Future<List<Map<String, dynamic>>> getAllStudents() async {
    Database db = await instance.database;
    return await db.query('students');
  }

  // Relational Inner Join query for reports
  Future<List<Map<String, dynamic>>> getAttendanceReport() async {
    Database db = await instance.database;
    return await db.rawQuery('''
      SELECT s.student_id, s.name, s.course, a.date, a.status 
      FROM students s
      INNER JOIN attendance_records a ON s.student_id = a.student_id
      ORDER BY a.date DESC
    ''');
  }
}