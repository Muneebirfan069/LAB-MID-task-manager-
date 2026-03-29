import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../services/notification_service.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime _dueDate = DateTime.now();
  TimeOfDay _dueTime = TimeOfDay.now();
  bool _isRepeated = false;
  String _repeatType = 'none';
  List<int> _repeatDays = [];
  String _category = 'General';
  bool _notificationEnabled = true;
  final List<String> _subtasks = [];

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

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _dueTime,
    );
    if (picked != null) {
      setState(() {
        _dueTime = picked;
      });
    }
  }

  void _addSubtask() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Add Subtask'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Subtask name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  setState(() {
                    _subtasks.add(controller.text);
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveTask() async {
    if (_formKey.currentState!.validate()) {
      final dueDateTime = DateTime(
        _dueDate.year,
        _dueDate.month,
        _dueDate.day,
        _dueTime.hour,
        _dueTime.minute,
      );

      final task = Task(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        description: _descriptionController.text,
        dueDate: dueDateTime,
        createdAt: DateTime.now(),
        isRepeated: _isRepeated,
        repeatType: _repeatType,
        repeatDays: _repeatDays,
        category: _category,
        notificationEnabled: _notificationEnabled,
        subtasks: _subtasks.map((title) => SubTask(
          id: DateTime.now().millisecondsSinceEpoch.toString() + title,
          title: title,
        )).toList(),
      );

      await context.read<TaskProvider>().addTask(task);

      // Schedule notification if enabled
      if (_notificationEnabled) {
        await NotificationService.scheduleNotification(
          id: int.parse(task.id.substring(task.id.length - 10)),
          title: 'Task Due: ${task.title}',
          body: task.description.isNotEmpty ? task.description : 'Your task is due now!',
          scheduledDate: dueDateTime,
        );
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task added successfully!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Task'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Task Title',
                prefixIcon: Icon(Icons.title),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                prefixIcon: Icon(Icons.description),
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Due Date & Time
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Due Date'),
                    subtitle: Text(DateFormat('MMM dd, yyyy').format(_dueDate)),
                    onTap: _selectDate,
                  ),
                ),
                Expanded(
                  child: ListTile(
                    leading: const Icon(Icons.access_time),
                    title: const Text('Time'),
                    subtitle: Text(_dueTime.format(context)),
                    onTap: _selectTime,
                  ),
                ),
              ],
            ),
            const Divider(),

            // Category
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

            // Repeat Settings
            SwitchListTile(
              title: const Text('Repeat Task'),
              subtitle: Text(_isRepeated ? 'Task will repeat' : 'One-time task'),
              value: _isRepeated,
              onChanged: (value) {
                setState(() {
                  _isRepeated = value;
                  if (value && _repeatType == 'none') {
                    _repeatType = 'daily';
                  }
                });
              },
            ),

            if (_isRepeated) ...[
              const SizedBox(height: 8),
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

            // Notifications
            SwitchListTile(
              title: const Text('Enable Notifications'),
              subtitle: const Text('Get reminded when task is due'),
              value: _notificationEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationEnabled = value;
                });
              },
            ),

            const Divider(),

            // Subtasks
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Subtasks',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: _addSubtask,
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                ),
              ],
            ),
            if (_subtasks.isNotEmpty)
              Card(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _subtasks.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const Icon(Icons.check_box_outline_blank),
                      title: Text(_subtasks[index]),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _subtasks.removeAt(index);
                          });
                        },
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveTask,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Task',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}