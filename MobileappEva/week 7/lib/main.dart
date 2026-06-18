import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student Record Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const StudentPage(),
    );
  }
}

class StudentPage extends StatefulWidget {
  const StudentPage({super.key});

  @override
  State<StudentPage> createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  // Week 4 core controller text fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController courseController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  // Week 7 database security and relational fields
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Database? database;

  List<Map<String, dynamic>> students = [];
  int? selectedId;

  @override
  void initState() {
    super.initState();
    initDatabase();
  }

  // Week 4 and Week 7
  Future<void> initDatabase() async {
    database = await openDatabase(
      p.join(await getDatabasesPath(), 'students.db'),
      onCreate: (db, version) async {
        // Enforce relational table referencing mechanics
        await db.execute("PRAGMA foreign_keys = ON;");

        // Table 1: Students data
        await db.execute(
          '''
          CREATE TABLE students(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            course TEXT,
            phone_number TEXT,
            password_hash TEXT
          )
          ''',
        );

        // Attendance tracking
        await db.execute(
          '''
          CREATE TABLE attendance_records(
            record_id INTEGER PRIMARY KEY AUTOINCREMENT,
            student_id INTEGER NOT NULL,
            date TEXT NOT NULL,
            status TEXT NOT NULL,
            FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE
          )
          ''',
        );
      },
      version: 1,
    );

    loadStudents();
  }

  Future<void> loadStudents() async {
    final data = await database!.query('students');
    if (!mounted) return;
    setState(() {
      students = data;
    });
  }

  // Week 7 security hashing rule
  String _hashRawPassword(String rawText) {
    var encodedBytes = utf8.encode(rawText.isEmpty ? "FallbackUserPass55" : rawText);
    return sha256.convert(encodedBytes).toString();
  }

  // Week 4 Create Operation and Week 7 Security Parameters
  Future<void> addStudent() async {
    if (nameController.text.isEmpty || courseController.text.isEmpty) {
      return;
    }

    await database!.insert(
      'students',
      {
        'name': nameController.text,
        'course': courseController.text,
        'phone_number': phoneController.text.isEmpty ? 'None provided' : phoneController.text,
        'password_hash': _hashRawPassword(passwordController.text),
      },
    );

    clearFields();
    loadStudents();
  }

  // Week 4 Update 
  Future<void> updateStudent() async {
    if (selectedId == null) return;

    await database!.update(
      'students',
      {
        'name': nameController.text,
        'course': courseController.text,
        'phone_number': phoneController.text,
        'password_hash': _hashRawPassword(passwordController.text),
      },
      where: 'id = ?',
      whereArgs: [selectedId],
    );

    clearFields();
    loadStudents();
  }

  // Delete
  Future<void> deleteStudent(int id) async {
    await database!.delete(
      'students',
      where: 'id = ?',
      whereArgs: [id],
    );

    loadStudents();
  }

  // search 
  Future<void> searchStudent() async {
    final data = await database!.query(
      'students',
      where: 'name LIKE ?',
      whereArgs: ['%${searchController.text}%'],
    );
    if (!mounted) return;
    setState(() {
      students = data;
    });
  }

  // Week 7 Task: Insert records referencing foreign keys
  Future<void> markAttendance(int studentId, String currentStatus) async {
    String formattedToday = DateTime.now().toIso8601String().substring(0, 10);

    await database!.insert('attendance_records', {
      'student_id': studentId,
      'date': formattedToday,
      'status': currentStatus,
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Attendance status: $currentStatus')),
    );
  }

  // Week 7 to execute multi-table INNER JOIN query
  Future<void> showAttendanceReports() async {
    final List<Map<String, dynamic>> results = await database!.rawQuery('''
      SELECT s.name, s.course, a.date, a.status 
      FROM students s
      INNER JOIN attendance_records a ON s.id = a.student_id
      ORDER BY a.record_id DESC
    ''');

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("SQLite INNER JOIN Attendance Logs"),
        content: SizedBox(
          width: double.maxFinite,
          height: 250,
          child: results.isEmpty
              ? const Center(child: Text("No records exist. Track attendance on your students first."))
              : ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, resIndex) {
              final log = results[resIndex];
              return ListTile(
                title: Text(log['name']),
                subtitle: Text("${log['course']} | ${log['date']}"),
                trailing: Text(
                  log['status'],
                  style: TextStyle(
                      color: log['status'] == 'Present' ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close")
          )
        ],
      ),
    );
  }

  void clearFields() {
    nameController.clear();
    courseController.clear();
    phoneController.clear();
    passwordController.clear();
    selectedId = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Record Management'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.assignment_turned_in),
            tooltip: "View Inner Join Report",
            onPressed: showAttendanceReports,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Student Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: courseController,
              decoration: const InputDecoration(
                labelText: 'Course',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),

            // Week 7 implementation fields
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password (Hashed)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: addStudent,
                    child: const Text('Add'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: updateStudent,
                    child: const Text('Update'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search Student',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: searchStudent,
                ),
              ),
            ),

            const SizedBox(height: 15),

            Expanded(
              child: students.isEmpty
                  ? const Center(child: Text("No records available. Please register students manually."))
                  : ListView.builder(
                itemCount: students.length,
                itemBuilder: (context, index) {
                  final student = students[index];

                  return Card(
                    child: ListTile(
                      title: Text(student['name']),
                      subtitle: Text(student['course']),
                      leading: CircleAvatar(
                        child: Text(student['id'].toString()),
                      ),
                      onTap: () {
                        setState(() {
                          selectedId = student['id'];
                          nameController.text = student['name'] ?? '';
                          courseController.text = student['course'] ?? '';
                          phoneController.text = student['phone_number'] ?? '';
                          passwordController.clear();
                        });
                      },
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check_circle, color: Colors.green),
                            tooltip: "Mark Present",
                            onPressed: () => markAttendance(student['id'], 'Present'),
                          ),
                          IconButton(
                            icon: const Icon(Icons.cancel, color: Colors.orange),
                            tooltip: "Mark Absent",
                            onPressed: () => markAttendance(student['id'], 'Absent'),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            onPressed: () => deleteStudent(student['id']),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}