import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Iron Tracker',
      theme: ThemeData.dark(),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/daily_progress') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) {
              return DailyProgressScreen(
                day: args['day'],
                exercises: args['exercises'],
                addExercise: args['addExercise'],
                deleteExercise: args['deleteExercise'],
              );
            },
          );
        }
        assert(false, 'Need to implement ${settings.name}');
        return null;
      },
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() {
    Navigator.pushNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/Logo-fixed.jpg'), 
              const SizedBox(height: 20),
              const Text(
                'The only APP you need to reach the next Level',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  filled: true,
                  fillColor: Colors.white,
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: const Text('Sign in with Email'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(onPressed: _login, child: const Text('Login')),
                  TextButton(onPressed: _login, child: const Text('Just want to see')),
                ],
              ),
              const Text('By continuing you agree to the Terms and Conditions'),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _daysTrained = 0;
  final Map<String, List<String>> _trainingDays = {
    'Monday': ['Squats', 'Butterfly', 'Bench Press', 'Bicep Curls', 'Triceps Cable'],
    'Tuesday': [],
    'Wednesday': [],
    'Thursday': [],
    'Friday': [],
    'Saturday': [],
    'Sunday': [],
  };

  void _incrementCounter() {
    setState(() {
      _daysTrained++;
    });
  }

  void _addExercise(String day, String exercise) {
    setState(() {
      _trainingDays[day]!.add(exercise);
    });
  }

  void _deleteExercise(String day, int index) {
    setState(() {
      _trainingDays[day]!.removeAt(index);
    });
  }

  void _selectDayAndExercise(BuildContext context) {
    String selectedDay = 'Monday';
    String selectedExercise = 'Fitnessstudio';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Day and Exercise'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                value: selectedDay,
                items: _trainingDays.keys.map((String day) {
                  return DropdownMenuItem<String>(
                    value: day,
                    child: Text(day),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedDay = newValue!;
                  });
                },
              ),
              DropdownButton<String>(
                value: selectedExercise,
                items: ['Fitnessstudio', 'Joggen', 'Kampfsport', 'Meditation']
                    .map((String exercise) {
                  return DropdownMenuItem<String>(
                    value: exercise,
                    child: Text(exercise),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedExercise = newValue!;
                  });
                },
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                _addExercise(selectedDay, selectedExercise);
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hello Alperen Kürücü'),
        actions: [
          IconButton(
            icon: const CircleAvatar(
              backgroundImage: AssetImage('assets/Profil.jpg'), // Assuming you have a profile picture asset
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Card(
              color: Colors.grey[850],
              child: ListTile(
                title: const Text('Daily progress'),
                subtitle: const Text('Here you can see your Exercises'),
                trailing: IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: _incrementCounter,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text('$_daysTrained days without a passout'),
            ),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                children: _trainingDays.keys.map((day) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/daily_progress',
                        arguments: {
                          'day': day,
                          'exercises': _trainingDays[day],
                          'addExercise': (exercise) => _addExercise(day, exercise),
                          'deleteExercise': (index) => _deleteExercise(day, index),
                        },
                      );
                    },
                    child: Card(
                      color: Colors.grey[850],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(day),
                          Text('Exercises: ${_trainingDays[day]!.length}'),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _selectDayAndExercise(context);
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.delete),
            label: 'Delete',
          ),
        ],
        onTap: (index) {
          // Handle bottom navigation bar tap
          if (index == 1) {
            setState(() {
              _trainingDays.forEach((day, exercises) {
                exercises.clear();
              });
            });
          }
        },
      ),
    );
  }
}

class DailyProgressScreen extends StatefulWidget {
  final String day;
  final List<String> exercises;
  final Function(String) addExercise;
  final Function(int) deleteExercise;

  const DailyProgressScreen({
    super.key,
    required this.day,
    required this.exercises,
    required this.addExercise,
    required this.deleteExercise,
  });

  @override
  _DailyProgressScreenState createState() => _DailyProgressScreenState();
}

class _DailyProgressScreenState extends State<DailyProgressScreen> {
  void _addExercise(BuildContext context) {
    TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Exercise'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Exercise name'),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                widget.addExercise(controller.text);
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.day),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('All'),
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: widget.exercises.length,
                itemBuilder: (context, index) {
                  return Dismissible(
                    key: Key(widget.exercises[index]),
                    onDismissed: (direction) {
                      widget.deleteExercise(index);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${widget.exercises[index]} dismissed')),
                      );
                    },
                    background: Container(color: Colors.red),
                    child: Card(
                      color: Colors.grey[850],
                      child: ListTile(title: Text(widget.exercises[index])),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addExercise(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _image;
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  Future<void> _addProfilePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: _image != null ? FileImage(_image!) : AssetImage('assets/Profil.jpg') as ImageProvider,
            ),
            const SizedBox(height: 20),
            const Text('Alperen Kürücü'),
            const Text('alperen.kurucu16@gmx.de'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
              child: Column(
                children: [
                  TextField(
                    controller: _weightController,
                    decoration: const InputDecoration(
                      labelText: 'Weight (kg)',
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _heightController,
                    decoration: const InputDecoration(
                      labelText: 'Height (cm)',
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: _addProfilePicture,
              child: const Text('Add Profile Picture'),
            ),
            const SizedBox(height: 20),
            const Text('Everyday is a new day to improve WHO YOU ARE!!!'),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Log out'),
            ),
          ],
        ),
      ),
    );
  }
}
