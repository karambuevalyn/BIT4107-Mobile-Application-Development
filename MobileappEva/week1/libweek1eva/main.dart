import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My First App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// 1. Changed to a StatefulWidget so it can remember data (state)
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  int _counter = 0;
  String _message = 'Click the button below';

  void _incrementCounter() {

    setState(() {
      _counter++;


      if (_counter == 1) {
        _message = 'You took your first step!';
      } else if (_counter == 5) {
        _message = 'High five! 🖐️';
      } else if (_counter == 10) {
        _message = 'Double digits! You are unstoppable!';
      } else {
        _message = 'Keep going!';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('week one mobile App'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFF0A192F),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Displays our changing message
            Text(
              _message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: Colors.amber,
              ),
            ),
            const SizedBox(height: 10),

            Text(
              'Number of time you clicked the button: $_counter',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _incrementCounter,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: Text(
                // The button text changes context dynamically
                _counter == 0 ? 'Click Me' : 'Clicked $_counter ${_counter == 1 ? 'time' : 'times'}',
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}