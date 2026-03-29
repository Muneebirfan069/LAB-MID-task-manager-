import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import 'package:provider/provider.dart';
import '../screens/edit_task_screen.dart';
import 'progress_bar.dart';
import 'subtask_list.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final bool showRepeatInfo;

  const TaskCard({
    super.key,
    required this.task,
    this.showRepeatInfo = false,
  });

  Color _getPriorityColor() {
    if (task.isCompleted) return Colors.green;
    if (task.isOverdue) return Colors.red;
    if (task.isDueToday) return Colors.blue;
    return Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    final priorityColor = _getPriorityColor();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditTaskScreen(task: task),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Checkbox
                  Checkbox(
                    value: task.isCompleted,
                    onChanged: (value) {
                      context.read<TaskProvider>().toggleTaskCompletion(task.id);
                    },
                  ),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            color: task.isCompleted ? Colors.grey : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: priorityColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('MMM dd, yyyy').format(task.dueDate),
                              style: TextStyle(
                                fontSize: 12,
                                color: priorityColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                task.category,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Repeat indicator
                  if (task.isRepeated)
                    const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Icon(Icons.repeat, size: 20, color: Colors.purple),
                    ),
                ],
              ),

              if (task.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  task.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // Progress Bar
              if (task.subtasks.isNotEmpty) ...[
                const SizedBox(height: 12),
                ProgressBar(progress: task.progressPercentage),
                const SizedBox(height: 4),
                Text(
                  '${task.progressPercent}% Complete (${task.subtasks.where((s) => s.isCompleted).length}/${task.subtasks.length} subtasks)',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],

              // Repeat Info
              if (showRepeatInfo && task.isRepeated) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.repeat, size: 16, color: Colors.purple),
                      const SizedBox(width: 8),
                      Text(
                        'Repeats: ${task.repeatType == 'daily' ? 'Daily' : 'Weekly'}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Subtasks Preview (expandable)
              if (task.subtasks.isNotEmpty && !task.isCompleted) ...[
                const SizedBox(height: 8),
                SubtaskList(
                  taskId: task.id,
                  subtasks: task.subtasks,
                  readOnly: true,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}