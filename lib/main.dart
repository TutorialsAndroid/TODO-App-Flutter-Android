import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TODO List',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const TodoListScreen(),
    );
  }
}

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final List<String> _tasks = [];
  final List<bool> _taskCompletion = [];
  final Map<String, int> _taskTimers = {};
  final Map<String, Timer> _timers = {};
  final TextEditingController _controller = TextEditingController();

  void _addTask() {
    if (_controller.text.isNotEmpty) {
      String task = _controller.text;
      setState(() {
        _tasks.add(task);
        _taskCompletion.add(false);
        _taskTimers[task] = 60;
        _controller.clear();
      });
      _startTaskTimer(task);
    }
  }

  void _startTaskTimer(String task) {
    _timers[task] = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_taskTimers.containsKey(task)) {
        timer.cancel();
        return;
      }
      setState(() {
        _taskTimers[task] = (_taskTimers[task]! - 1).clamp(0, 60);
      });
      if (_taskTimers[task] == 0) {
        timer.cancel();
        _deleteTaskByName(task);
      }
    });
  }

  void _editTask(int index) {
    String oldTask = _tasks[index];
    TextEditingController editController = TextEditingController(text: oldTask);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Task'),
          content: TextField(
            controller: editController,
            decoration: const InputDecoration(hintText: 'Enter updated task'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                String newTask = editController.text;
                if (newTask.isNotEmpty && newTask != oldTask) {
                  setState(() {
                    _tasks[index] = newTask;
                    _taskTimers[newTask] = _taskTimers.remove(oldTask) ?? 60;
                    _timers[newTask] = _timers.remove(oldTask) ??
                        Timer(const Duration(seconds: 60),
                            () => _deleteTaskByName(newTask));
                  });
                  _startTaskTimer(newTask);
                }
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _toggleTaskCompletion(int index) {
    setState(() {
      _taskCompletion[index] = !_taskCompletion[index];
    });
  }

  void _deleteTask(int index) {
    if (index >= 0 && index < _tasks.length) {
      String task = _tasks[index];
      _deleteTaskByName(task);
    }
  }

  void _deleteTaskByName(String task) {
    setState(() {
      int taskIndex = _tasks.indexOf(task);
      if (taskIndex != -1) {
        _tasks.removeAt(taskIndex);
        _taskCompletion.removeAt(taskIndex);
      }
      _taskTimers.remove(task);
      _timers[task]?.cancel();
      _timers.remove(task);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text(
            'TODO LIST',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.purpleAccent),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Enter a task',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addTask,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  String task = _tasks[index];
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: ListTile(
                      leading: Checkbox(
                        value: _taskCompletion[index],
                        onChanged: (_) => _toggleTaskCompletion(index),
                      ),
                      title: Text(
                        task,
                        style: TextStyle(
                          decoration: _taskCompletion[index]
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      subtitle: Text('Time left: ${_taskTimers[task] ?? 0}s'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _editTask(index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteTask(index),
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
