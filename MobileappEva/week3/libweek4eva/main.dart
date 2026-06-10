import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
  final TextEditingController nameController = TextEditingController();
  final TextEditingController courseController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  Database? database;

  List<Map<String, dynamic>> students = [];
  int? selectedId;

  @override
  void initState() {
    super.initState();
    initDatabase();
  }

  Future<void> initDatabase() async {
    database = await openDatabase(
      join(await getDatabasesPath(), 'students.db'),
      onCreate: (db, version) {
        return db.execute(
          '''
          CREATE TABLE students(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            course TEXT
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

  Future<void> addStudent() async {
    if (nameController.text.isEmpty ||
        courseController.text.isEmpty) {
      return;
    }

    await database!.insert(
      'students',
      {
        'name': nameController.text,
        'course': courseController.text,
      },
    );

    clearFields();
    loadStudents();
  }

  Future<void> updateStudent() async {
    if (selectedId == null) return;

    await database!.update(
      'students',
      {
        'name': nameController.text,
        'course': courseController.text,
      },
      where: 'id = ?',
      whereArgs: [selectedId],
    );

    clearFields();
    loadStudents();
  }

  Future<void> deleteStudent(int id) async {
    await database!.delete(
      'students',
      where: 'id = ?',
      whereArgs: [id],
    );

    loadStudents();
  }

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

  void clearFields() {
    nameController.clear();
    courseController.clear();
    selectedId = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Record Management'),
        centerTitle: true,
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
              child: ListView.builder(
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
                          nameController.text =
                          student['name'];
                          courseController.text =
                          student['course'];
                        });
                      },
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        onPressed: () =>
                            deleteStudent(student['id']),
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