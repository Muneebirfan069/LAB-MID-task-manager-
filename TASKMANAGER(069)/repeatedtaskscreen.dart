import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../widgets/task_card.dart';

class RepeatedTasksScreen extends StatelessWidget {
  const RepeatedTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final repeatedTasks = taskProvider.repeatedTasks;

        if (repeatedTasks.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.repeat, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No repeated tasks',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Create a task with repeat settings',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: repeatedTasks.length,
          itemBuilder: (context, index) {
            final task = repeatedTasks[index];
            return TaskCard(
              task: task,
              showRepeatInfo: true,
            );
          },
        );
      },
    );
  }
}