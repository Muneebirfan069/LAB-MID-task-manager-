import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../services/export_service.dart';
import '../widgets/task_card.dart';

class CompletedTasksScreen extends StatelessWidget {
  const CompletedTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final completedTasks = taskProvider.completedTasks;

        return Column(
          children: [
            // Export Options
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Export Completed Tasks',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildExportButton(
                            context,
                            'CSV',
                            Icons.table_chart,
                            Colors.green,
                                () => ExportService.exportToCSV(completedTasks),
                          ),
                          _buildExportButton(
                            context,
                            'PDF',
                            Icons.picture_as_pdf,
                            Colors.red,
                                () => ExportService.exportToPDF(completedTasks),
                          ),
                          _buildExportButton(
                            context,
                            'Email',
                            Icons.email,
                            Colors.blue,
                                () => ExportService.exportToEmail(completedTasks),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Completed Tasks List
            Expanded(
              child: completedTasks.isEmpty
                  ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No completed tasks yet',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: completedTasks.length,
                itemBuilder: (context, index) {
                  return TaskCard(task: completedTasks[index]);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildExportButton(
      BuildContext context,
      String label,
      IconData icon,
      Color color,
      VoidCallback onTap,
      ) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }
}