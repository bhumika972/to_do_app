import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw; // Import the PDF package

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'To-Do App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black), // Default text color
        ),
      ),
      home: TodoList(),
    );
  }
}

class TodoList extends StatefulWidget {
  const TodoList({super.key});

  @override
  _TodoListState createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  List<String> _tasks = [];
  final TextEditingController _taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTasks(); // Load tasks from SharedPreferences
  }

  // Load tasks from SharedPreferences
  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _tasks = prefs.getStringList('tasks') ?? [];
    });
    print("Tasks loaded: $_tasks");
  }

  // Save tasks to SharedPreferences
  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('tasks', _tasks);
    print("Tasks saved: $_tasks");
  }

  // Add a task
  void _addTask() {
    if (_taskController.text.isNotEmpty) {
      setState(() {
        _tasks.add(_taskController.text.trim());
        _taskController.clear();
      });
      _saveTasks();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Task added successfully!")));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Please enter a task.")));
    }
  }

  // Delete a task
  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
    _saveTasks();
  }

  // Mark a task as completed
  void _toggleComplete(int index) {
    setState(() {
      _tasks[index] = _tasks[index].endsWith("(Completed)")
          ? _tasks[index].replaceAll(" (Completed)", "")
          : "${_tasks[index]} (Completed)";
    });
    _saveTasks();
  }

  // Generate and save the PDF report
  Future<String> getFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<void> generateAndSavePDF() async {
    final filePath = await getFilePath();
    final file = File('$filePath/report.pdf');

    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text('To-Do Report', style: pw.TextStyle(fontSize: 24)),
              ..._tasks.map((task) => pw.Text(task)).toList(),
            ],
          );
        },
      ),
    );

    // Save the PDF to the device
    await file.writeAsBytes(await pdf.save());
    print("PDF saved to: $filePath/report.pdf");

    // Notify the user
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Report generated and saved!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'To-Do App',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Task Input Field
            TextField(
              controller: _taskController,
              decoration: const InputDecoration(
                labelText: 'Enter task',
                labelStyle: TextStyle(color: Colors.blue),
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(color: Colors.blueAccent),
            ),
            const SizedBox(height: 10),
            // Add Task Button
            ElevatedButton(
              onPressed: _addTask,
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
              child: const Text('Add Task'),
            ),
            const SizedBox(height: 20),
            // List of Tasks
            Expanded(
              child: ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      _tasks[index],
                      style: TextStyle(
                        color: Colors.black,
                        decoration: _tasks[index].contains("(Completed)")
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    leading: IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: () => _toggleComplete(index),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteTask(index),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // Floating Action Button for PDF Generation
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_tasks.isNotEmpty) {
            generateAndSavePDF(); // Call the PDF generation method
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Generating report...")),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text("No tasks to include in the report.")),
            );
          }
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.picture_as_pdf),
      ),
    );
  }
}
