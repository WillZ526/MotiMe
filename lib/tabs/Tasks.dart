import 'package:flutter/material.dart';

class Task extends StatefulWidget {
  const Task({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => TaskState();
}

/// The state for DetailsScreen
class TaskState extends State<Task> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Text('Task'),
      ),
    );
  }
}