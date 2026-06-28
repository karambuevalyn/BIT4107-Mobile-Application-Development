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

// WEEK 8: CLASS-BASED VALIDATOR
class FormValidator {
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Student name is required.";
    }
    if (value.trim().length < 3) {
      return "Name must be at least 3 characters long.";
    }
    return null;
  }

  static String? validateCourse(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Course field cannot be empty.";
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Phone number is required.";
    }
    final phoneRegex = RegExp(r'^[0-9+\-\s]{7,15}$');
    if (!phoneRegex.hasMatch(value)) {
      return "Enter a valid phone number sequence.";
    }
    return null;
  }

  static String? validatePassword(String? value, bool isUpdating) {
    if (!isUpdating && (value == null || value.isEmpty)) {
      return "Password security parameter is required.";
    }
    if (value != null && value.isNotEmpty && value.length < 4) {
      return "Password must be at least 4 characters.";
    }
    return null;
  }
}

class StudentPage extends StatefulWidget {
  const StudentPage({super.key});

  @override
  State<StudentPage> createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  // Global Form Key for Week 8 Validation matching
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Input Field Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController courseController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
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

  // Week 4 & 7 Relational Database Initializer
  Future<void> initDatabase() async {
    database = await openDatabase(
      p.join(await getDatabasesPath(), 'students.db'),
      onCreate: (db, version) async {
        await db.execute("PRAGMA foreign_keys = ON;");

        // Table 1: Primary Master Student Record Table
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

        // Table 2: Relational Attendance Dependent Log Table
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
    setState(() {
      students = data;
    });
  }

  // Week 7 Cryptographic Security Utility (SHA-256)
  String _hashRawPassword(String rawText) {
    var encodedBytes = utf8.encode(rawText.isEmpty ? "FallbackUserPass55" : rawText);
    return sha256.convert(encodedBytes).toString();
  }

  // Week 8 Helper Method: Generalized Interaction Logger
  void _logGestureEvent(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Week 4 Create + Week 8 Form Validation Enforcement
  Future<void> addStudent() async {
    if (_formKey.currentState!.validate()) {
      await database!.insert(
        'students',
        {
          'name': nameController.text.trim(),
          'course': courseController.text.trim(),
          'phone_number': phoneController.text.trim(),
          'password_hash': _hashRawPassword(passwordController.text),
        },
      );
      _logGestureEvent("Event: Student record successfully added into database.");
      clearFields();
      loadStudents();
    } else {
      _logGestureEvent("Validation Error: Please correct the marked fields.");
    }
  }

  // Week 4 Update + Week 8 Form Validation
  Future<void> updateStudent() async {
    if (selectedId == null) return;

    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> updateData = {
        'name': nameController.text.trim(),
        'course': courseController.text.trim(),
        'phone_number': phoneController.text.trim(),
      };

      if (passwordController.text.isNotEmpty) {
        updateData['password_hash'] = _hashRawPassword(passwordController.text);
      }

      await database!.update(
        'students',
        updateData,
        where: 'id = ?',
        whereArgs: [selectedId],
      );
      _logGestureEvent("Event: Student ID $selectedId updated.");
      clearFields();
      loadStudents();
    }
  }

  // Week 4 Delete Process
  Future<void> deleteStudent(int id, String name) async {
    await database!.delete(
      'students',
      where: 'id = ?',
      whereArgs: [id],
    );
    _logGestureEvent("Event: Deleted record for $name.");
    loadStudents();
  }

  // Week 4 Query Filter Lookups
  Future<void> searchStudent() async {
    final data = await database!.query(
      'students',
      where: 'name LIKE ?',
      whereArgs: ['%${searchController.text}%'],
    );
    setState(() {
      students = data;
    });
  }

  // Week 7 Attendance Core Insertion
  Future<void> markAttendance(int studentId, String currentStatus) async {
    String formattedToday = DateTime.now().toIso8601String().substring(0, 10);

    await database!.insert('attendance_records', {
      'student_id': studentId,
      'date': formattedToday,
      'status': currentStatus,
    });
    _logGestureEvent("Logged attendance: $currentStatus");
  }

  // Week 7 Analytical Output: Multi-Table Relational INNER JOIN Inner Display
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
              ? const Center(child: Text("No tracking records logged yet."))
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
    setState(() {});
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
        child: Form(
          key: _formKey, // Form wrapper enforcing validator tracking hooks
          child: Column(
            children: [

              // WEEK 8 KEYBOARD CONTROLS: TEXT FORM FIELDS
              TextFormField(
                controller: nameController,
                textInputAction: TextInputAction.next, // Keyboard focus transitions forward
                validator: FormValidator.validateName, // Invokes the evaluation logic
                decoration: const InputDecoration(
                  labelText: 'Student Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: courseController,
                textInputAction: TextInputAction.next,
                validator: FormValidator.validateCourse,
                decoration: const InputDecoration(
                  labelText: 'Course',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.book),
                ),
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      validator: FormValidator.validatePhone,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      textInputAction: TextInputAction.done, // Closes the virtual keyboard panel
                      validator: (val) => FormValidator.validatePassword(val, selectedId != null),
                      onFieldSubmitted: (_) => selectedId == null ? addStudent() : updateStudent(), // Triggers action on 'Enter'
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
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
                  if (selectedId != null) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                        onPressed: clearFields,
                        child: const Text('Cancel'),
                      ),
                    ),
                  ]
                ],
              ),

              const SizedBox(height: 15),

              TextField(
                controller: searchController,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => searchStudent(),
                decoration: InputDecoration(
                  labelText: 'Search Student by Name',
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
                    ? const Center(child: Text("No records available. Add students manually."))
                    : ListView.builder(
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];

                    // ----------------------------------------------------
                    // WEEK 8 GESTURE CONTROL 1: SWIPE ACTION (DISMISSIBLE)
                    // ----------------------------------------------------
                    return Dismissible(
                      key: Key(student['id'].toString()),
                      direction: DismissDirection.endToStart, // Swipe right-to-left
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (direction) async {
                        return await showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text("Confirm Deletion"),
                            content: Text("Delete record for ${student['name']} via swipe gesture?"),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("No")),
                              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Yes")),
                            ],
                          ),
                        );
                      },
                      onDismissed: (direction) {
                        deleteStudent(student['id'], student['name']);
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: GestureDetector(
                          // ----------------------------------------------------
                          // WEEK 8 GESTURE CONTROL 2: LONG PRESS EVENT DETECTOR
                          // ----------------------------------------------------
                          onLongPress: () {
                            _logGestureEvent("Long Press Action: [ID: ${student['id']}] | Security Key Hash: ${student['password_hash'].toString().substring(0, 15)}...");
                          },
                          child: ListTile(
                            title: Text(student['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text("${student['course']}\n📞 ${student['phone_number']}"),
                            leading: CircleAvatar(
                              child: Text(student['id'].toString()),
                            ),
                            onTap: () {
                              // Standard Tap Gesture Event
                              setState(() {
                                selectedId = student['id'];
                                nameController.text = student['name'] ?? '';
                                courseController.text = student['course'] ?? '';
                                phoneController.text = student['phone_number'] ?? '';
                                passwordController.clear();
                              });
                              _logGestureEvent("Tap Event: Loaded data for ${student['name']}.");
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
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}