import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import 'today_tasks_screen.dart';
import 'completed_tasks_screen.dart';
import 'repeated_tasks_screen.dart';
import 'add_task_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const TodayTasksScreen(),
    const CompletedTasksScreen(),
    const RepeatedTasksScreen(),
    const SettingsScreen(),
  ];

  final List<String> _titles = [
    'Today\'s Tasks',
    'Completed',
    'Repeated Tasks',
    'Settings',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        elevation: 0,
        actions: [
          if (_currentIndex == 0)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddTaskScreen()),
                );
              },
            ),
        ],
      ),
      body: _screens[_currentIndex],
      floatingActionButton: _currentIndex == 0 ? FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTaskScreen()),
          );
        },
        child: const Icon(Icons.add),
      ) : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.today),
            label: 'Today',
          ),
          NavigationDestination(
            icon: Icon(Icons.check_circle),
            label: 'Completed',
          ),
          NavigationDestination(
            icon: Icon(Icons.repeat),
            label: 'Repeated',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}