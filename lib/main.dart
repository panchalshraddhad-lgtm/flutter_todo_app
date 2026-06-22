import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Todo + Weather App',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class Task {
  String title;
  bool isCompleted;

  Task({
    required this.title,
    this.isCompleted = false,
  });
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "My Productivity App",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.purple],
              ),
            ),
          ),
          bottom: const TabBar(
            labelColor: Colors.white,
            tabs: [
              Tab(
                icon: Icon(Icons.task),
                text: "Tasks",
              ),
              Tab(
                icon: Icon(Icons.cloud),
                text: "Weather",
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            TodoScreen(),
            WeatherScreen(),
          ],
        ),
      ),
    );
  }
}

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final TextEditingController controller = TextEditingController();

  List<Task> tasks = [];

  void addTask() {
    if (controller.text.trim().isNotEmpty) {
      setState(() {
        tasks.add(Task(title: controller.text.trim()));
      });
      controller.clear();
    }
  }

  void deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: "Enter a new task",
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(Icons.task_alt),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),

          const SizedBox(height: 15),

          ElevatedButton.icon(
            onPressed: addTask,
            icon: const Icon(Icons.add),
            label: const Text("Add Task"),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: tasks.isEmpty
                ? const Center(
              child: Text(
                "No Tasks Added",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
            )
                : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    leading: Checkbox(
                      value: tasks[index].isCompleted,
                      onChanged: (value) {
                        setState(() {
                          tasks[index].isCompleted = value!;
                        });
                      },
                    ),
                    title: Text(
                      tasks[index].title,
                      style: TextStyle(
                        decoration: tasks[index].isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      onPressed: () => deleteTask(index),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String city = "Bangalore";
  String temperature = "";
  String weather = "";
  bool isLoading = false;

  Future<void> getWeather() async {
    setState(() {
      isLoading = true;
    });

    const apiKey = "9b8ddb80dc6383a12dfa6be9a62a6295";

    final response = await http.get(
      Uri.parse(
        "https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric",
      ),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      setState(() {
        temperature = data["main"]["temp"].toString();
        weather = data["weather"][0]["main"];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: isLoading
          ? const CircularProgressIndicator()
          : Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.cloud,
            size: 100,
            color: Colors.blue,
          ),

          const SizedBox(height: 20),

          Text(
            city,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            "$temperature°C",
            style: const TextStyle(
              fontSize: 35,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            weather,
            style: const TextStyle(
              fontSize: 22,
            ),
          ),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: getWeather,
            child: const Text("Refresh Weather"),
          ),
        ],
      ),
    );
  }
}