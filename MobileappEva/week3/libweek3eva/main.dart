import 'package:flutter/material.dart';

void main() {
  runApp(const SimpleMusicApp());
}

class SimpleMusicApp extends StatelessWidget {
  const SimpleMusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(), // Simple built-in dark theme
      home: const RegisterScreen(), // Starts at Screen 1
    );
  }
}

// SCREEN 1: REGISTER SCREEN

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Music App Registration',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Enter Your Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Enter Your Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GenreScreen()),
                );
              },
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}


// SCREEN 2: SELECT GENRE SCREEN

class GenreScreen extends StatelessWidget {
  const GenreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Genre')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Pick a style of music:',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SongSelectionScreen())),
              child: const Text('Amapiano'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SongSelectionScreen())),
              child: const Text('Urban'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SongSelectionScreen())),
              child: const Text('Hip-hop'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SongSelectionScreen())),
              child: const Text('K-pop'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SongSelectionScreen())),
              child: const Text('Trap'),
            ),
          ],
        ),
      ),
    );
  }
}


// SCREEN 3: SONG SELECTION SCREEN

class SongSelectionScreen extends StatelessWidget {
  const SongSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select a Song')),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            ListTile(
              title: const Text('Song Option 1'),
              subtitle: const Text('Artist Name A'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MusicPlayingScreen())),
            ),
            ListTile(
              title: const Text('Song Option 2'),
              subtitle: const Text('Artist Name B'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MusicPlayingScreen())),
            ),
            ListTile(
              title: const Text('Song Option 3'),
              subtitle: const Text('Artist Name C'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MusicPlayingScreen())),
            ),
          ],
        ),
      ),
    );
  }
}


// SCREEN 4: MUSIC PLAYING SCREEN
class MusicPlayingScreen extends StatelessWidget {
  const MusicPlayingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Now Playing')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Playing Your Track',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Music is streaming...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Pause'),
            ),
            const SizedBox(height: 40),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const QuoteScreen()),
                );
              },
              child: const Text('Go to Next Screen'),
            ),
          ],
        ),
      ),
    );
  }
}


// SCREEN 5: QUOTE SCREEN
class QuoteScreen extends StatelessWidget {
  const QuoteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Message')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(30.0),
          child: Text(
            'music is the medicine to the soul just that simple',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.normal,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ),
    );
  }
}