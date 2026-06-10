import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;


//1.

void main() {

  WidgetsFlutterBinding.ensureInitialized();
  runApp(const StudentManagementApp());
}

class StudentManagementApp extends StatelessWidget {
  const StudentManagementApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student Management System',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}


// 2.

class Student {
  final int? id;
  final String name;
  final String regNumber;
  final String course;
  final String email;

  Student({
    this.id,
    required this.name,
    required this.regNumber,
    required this.course,
    required this.email,
  });


  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'regNumber': regNumber,
      'course': course,
      'email': email,
    };
  }


  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'],
      name: map['name'],
      regNumber: map['regNumber'],
      course: map['course'],
      email: map['email'],
    );
  }
}


class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('student_management.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE students (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        regNumber TEXT NOT NULL UNIQUE,
        course TEXT NOT NULL,
        email TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertStudent(Student student) async {
    final db = await instance.database;
    return await db.insert('students', student.toMap());
  }

  Future<List<Student>> readAllStudents() async {
    final db = await instance.database;
    final result = await db.query('students', orderBy: 'id DESC');
    return result.map((json) => Student.fromMap(json)).toList();
  }
}

// 4. LOGIN SCREEN

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() {
    if (_formKey.currentState!.validate()) {

      if (_usernameController.text == "admin" && _passwordController.text == "admin123") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid Credentials! Try: admin / admin123')),
        );
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login Page'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              const SizedBox(height: 24),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),

                ),
                validator: (val) => val!.isEmpty ? 'Please enter your username' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val!.isEmpty ? 'Please enter your password' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                ),
                onPressed: _login,
                child: const Text('Login', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// 5. REGISTRATION SCREEN

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _regController = TextEditingController();
  final _courseController = TextEditingController();
  final _emailController = TextEditingController();

  Future<void> _saveData() async {
    if (_formKey.currentState!.validate()) {
      try {
        final student = Student(
          name: _nameController.text,
          regNumber: _regController.text,
          course: _courseController.text,
          email: _emailController.text,
        );

        await DatabaseHelper.instance.insertStudent(student);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Student Saved Locally!')),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Reg number might already exist.')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _regController.dispose();
    _courseController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register Student')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
                  validator: (v) => v!.isEmpty ? 'Full name is required' : null
              ),
              const SizedBox(height: 12),
              TextFormField(
                  controller: _regController,
                  decoration: const InputDecoration(labelText: 'Registration Number', border: OutlineInputBorder()),
                  validator: (v) => v!.isEmpty ? 'Registration number is required' : null
              ),
              const SizedBox(height: 12),
              TextFormField(
                  controller: _courseController,
                  decoration: const InputDecoration(labelText: 'Course of Study', border: OutlineInputBorder()),
                  validator: (v) => v!.isEmpty ? 'Course is required' : null
              ),
              const SizedBox(height: 12),
              TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email Address', border: OutlineInputBorder()),
                  validator: (v) => v!.isEmpty ? 'Email address is required' : null
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                onPressed: _saveData,
                child: const Text('Save Record', style: TextStyle(fontSize: 16)),
              )
            ],
          ),
        ),
      ),
    );
  }
}


// 6. USER INTERFACE: DASHBOARD SCREEN

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Student> _students = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshStudentList();
  }

  Future<void> _refreshStudentList() async {
    setState(() => _isLoading = true);
    final data = await DatabaseHelper.instance.readAllStudents();
    setState(() {
      _students = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshStudentList,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _students.isEmpty
          ? const Center(
        child: Text(
          'No students registered yet.\nTap the + button to add one.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : ListView.builder(
        itemCount: _students.length,
        itemBuilder: (context, index) {
          final student = _students[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            elevation: 2,
            child: ListTile(

              title: Text(student.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${student.regNumber}\n${student.course}'),
              isThreeLine: true,

            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        onPressed: () async {

          final shouldRefresh = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RegistrationScreen()),
          );
          if (shouldRefresh == true) {
            _refreshStudentList();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
