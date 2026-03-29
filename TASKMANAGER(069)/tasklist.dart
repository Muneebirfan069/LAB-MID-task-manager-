import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

class SubtaskList extends StatelessWidget {
  final String taskId;
  final List<SubTask> subtasks;
  final bool readOnly;

  const SubtaskList({
    super.key,
    required this.taskId,
    required this.subtasks,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: subtasks.map((subtask) {
        return ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          leading: readOnly
              ? Icon(
            subtask.isCompleted
                ? Icons.check_box
                : Icons.check_box_outline_blank,
            size: 20,
            color: subtask.isCompleted ? Colors.green : Colors.grey,
          )
              : Checkbox(
            value: subtask.isCompleted,
            onChanged: (value) {
              context.read<TaskProvider>().toggleSubtask(taskId, subtask.id);
            },
          ),
          title: Text(
            subtask.title,
            style: TextStyle(
              fontSize: 14,
              decoration: subtask.isCompleted ? TextDecoration.lineThrough : null,
              color: subtask.isCompleted ? Colors.grey : null,
            ),
          ),
          trailing: !readOnly
              ? IconButton(
            icon: const Icon(Icons.delete, size: 18, color: Colors.red),
            onPressed: () {
              context.read<TaskProvider>().deleteSubtask(taskId, subtask.id);
            },
          )
              : null,
        );
      }).toList(),
    );
  }
}