import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

class EditTaskScreen extends StatefulWidget {
  final Task task;

  const EditTaskScreen({super.key, required this.task});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  late final _titleController = TextEditingController(text: widget.task.title);
  late final _descriptionController = TextEditingController(text: widget.task.description);

  late DateTime _dueDate = widget.task.dueDate;
  late bool _isRepeated = widget.task.isRepeated;
  late String _repeatType = widget.task.repeatType;
  late List<int> _repeatDays = List.from(widget.task.repeatDays);
  late String _category = widget.task.category;
  late bool _notificationEnabled = widget.task.notificationEnabled;

  final List<String> _categories = [
    'General',
    'Work',
    'Personal',
    'Shopping',
    'Health',
    'Education',
  ];

  final List<String> _weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Future<void> _updateTask() async {
    final updatedTask = widget.task.copyWith(
      title: _titleController.text,
      description: _descriptionController.text,
      dueDate: _dueDate,
      isRepeated: _isRepeated,
      repeatType: _repeatType,
      repeatDays: _repeatDays,
      category: _category,
      notificationEnabled: _notificationEnabled,
    );

    await context.read<TaskProvider>().updateTask(updatedTask);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task updated successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Task'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Task?'),
                  content: const Text('This action cannot be undone.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );

              if (confirm == true && mounted) {
                await context.read<TaskProvider>().deleteTask(widget.task.id);
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Task Title',
              prefixIcon: Icon(Icons.title),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              prefixIcon: Icon(Icons.description),
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),

          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Due Date'),
            subtitle: Text(DateFormat('MMM dd, yyyy').format(_dueDate)),
            trailing: const Icon(Icons.edit),
            onTap: _selectDate,
          ),
          const Divider(),

          DropdownButtonFormField<String>(
            value: _category,
            decoration: const InputDecoration(
              labelText: 'Category',
              prefixIcon: Icon(Icons.category),
              border: OutlineInputBorder(),
            ),
            items: _categories.map((cat) {
              return DropdownMenuItem(value: cat, child: Text(cat));
            }).toList(),
            onChanged: (value) {
              setState(() {
                _category = value!;
              });
            },
          ),
          const SizedBox(height: 16),

          SwitchListTile(
            title: const Text('Repeat Task'),
            value: _isRepeated,
            onChanged: (value) {
              setState(() {
                _isRepeated = value;
              });
            },
          ),

          if (_isRepeated) ...[
            Row(
              children: [
                ChoiceChip(
                  label: const Text('Daily'),
                  selected: _repeatType == 'daily',
                  onSelected: (selected) {
                    if (selected) setState(() => _repeatType = 'daily');
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Weekly'),
                  selected: _repeatType == 'weekly',
                  onSelected: (selected) {
                    if (selected) setState(() => _repeatType = 'weekly');
                  },
                ),
              ],
            ),

            if (_repeatType == 'weekly') ...[
              const SizedBox(height: 8),
              const Text('Select Days:'),
              Wrap(
                spacing: 8,
                children: List.generate(7, (index) {
                  final isSelected = _repeatDays.contains(index);
                  return FilterChip(
                    label: Text(_weekDays[index]),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _repeatDays.add(index);
                        } else {
                          _repeatDays.remove(index);
                        }
                        _repeatDays.sort();
                      });
                    },
                  );
                }),
              ),
            ],
          ],

          const Divider(),

          SwitchListTile(
            title: const Text('Enable Notifications'),
            value: _notificationEnabled,
            onChanged: (value) {
              setState(() {
                _notificationEnabled = value;
              });
            },
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _updateTask,
              child: const Text('Update Task', style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }
}