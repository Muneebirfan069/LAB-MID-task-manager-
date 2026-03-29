import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../services/export_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final stats = taskProvider.getStatistics();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Statistics Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Task Statistics',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _buildStatRow('Total Tasks', stats['total']!, Colors.blue),
                    _buildStatRow('Completed', stats['completed']!, Colors.green),
                    _buildStatRow('Due Today', stats['today']!, Colors.orange),
                    _buildStatRow('Overdue', stats['overdue']!, Colors.red),
                    _buildStatRow('Repeated', stats['repeated']!, Colors.purple),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Appearance Settings
            Card(
              child: Column(
                children: [
                  const ListTile(
                    leading: Icon(Icons.palette),
                    title: Text('Appearance'),
                  ),
                  SwitchListTile(
                    secondary: const Icon(Icons.dark_mode),
                    title: const Text('Dark Mode'),
                    subtitle: const Text('Enable dark theme'),
                    value: taskProvider.isDarkMode,
                    onChanged: (value) {
                      taskProvider.toggleDarkMode();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Notification Settings
            Card(
              child: Column(
                children: [
                  const ListTile(
                    leading: Icon(Icons.notifications),
                    title: Text('Notifications'),
                  ),
                  SwitchListTile(
                    secondary: const Icon(Icons.notifications_active),
                    title: const Text('Task Reminders'),
                    subtitle: const Text('Get notified about upcoming tasks'),
                    value: taskProvider.notificationsEnabled,
                    onChanged: (value) {
                      taskProvider.toggleNotifications();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Export All Tasks
            Card(
              child: Column(
                children: [
                  const ListTile(
                    leading: Icon(Icons.share),
                    title: Text('Export All Tasks'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.table_chart, color: Colors.green),
                    title: const Text('Export as CSV'),
                    onTap: () => ExportService.exportToCSV(taskProvider.tasks),
                  ),
                  ListTile(
                    leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                    title: const Text('Export as PDF'),
                    onTap: () => ExportService.exportToPDF(taskProvider.tasks),
                  ),
                  ListTile(
                    leading: const Icon(Icons.email, color: Colors.blue),
                    title: const Text('Share via Email'),
                    onTap: () => ExportService.exportToEmail(taskProvider.tasks),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // About
            const Center(
              child: Text(
                'Task Manager v1.0',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatRow(String label, int value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(width: 8),
              Text(label),
            ],
          ),
          Text(
            value.toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}