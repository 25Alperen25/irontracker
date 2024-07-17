import 'package:flutter/material.dart';

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
