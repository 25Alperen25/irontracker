import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService _firebaseService = FirebaseService();
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

  @override
  void initState() {
    super.initState();
    _fetchDailyProgress();
  }

  Future<void> _fetchDailyProgress() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    for (String day in _trainingDays.keys) {
      DocumentSnapshot snapshot = await _firebaseService.getDailyProgress(userId, day);
      if (snapshot.exists) {
        setState(() {
          _trainingDays[day] = List<String>.from(snapshot['exercises']);
        });
      }
    }
  }

  void _incrementCounter() {
    setState(() {
      _daysTrained++;
    });
  }

  void _addExercise(String day, String exercise) {
    setState(() {
      _trainingDays[day]!.add(exercise);
    });
    _firebaseService.updateDailyProgress(FirebaseAuth.instance.currentUser!.uid, day, {
      'exercises': _trainingDays[day],
    });
  }

  void _deleteExercise(String day, int index) {
    setState(() {
      _trainingDays[day]!.removeAt(index);
    });
    _firebaseService.updateDailyProgress(FirebaseAuth.instance.currentUser!.uid, day, {
      'exercises': _trainingDays[day],
    });
  }

  void _selectDayAndExercise(BuildContext context) {
    String selectedDay = 'Monday';
    String selectedExercise = 'Fitnessstudio';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
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
              backgroundImage: AssetImage('assets/Profil.jpg'),
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
