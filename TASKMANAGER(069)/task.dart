import 'dart:convert';

class SubTask {
  String id;
  String title;
  bool isCompleted;

  SubTask({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  // COPY WITH METHOD (ERROR FIX)
  SubTask copyWith({
    String? id,
    String? title,
    bool? isCompleted,
  }) {
    return SubTask(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'isCompleted': isCompleted,
  };

  factory SubTask.fromJson(Map<String, dynamic> json) => SubTask(
    id: json['id'],
    title: json['title'],
    isCompleted: json['isCompleted'],
  );
}

class Task {
  String id;
  String title;
  String description;
  DateTime dueDate;
  DateTime createdAt;
  bool isCompleted;
  bool isRepeated;
  String repeatType; // daily, weekly, none
  List<int> repeatDays;
  List<SubTask> subtasks;
  String category;
  bool notificationEnabled;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    required this.dueDate,
    required this.createdAt,
    this.isCompleted = false,
    this.isRepeated = false,
    this.repeatType = 'none',
    this.repeatDays = const [],
    this.subtasks = const [],
    this.category = 'General',
    this.notificationEnabled = true,
  });

  double get progressPercentage {
    if (subtasks.isEmpty) return isCompleted ? 1.0 : 0.0;
    final completed = subtasks.where((s) => s.isCompleted).length;
    return completed / subtasks.length;
  }

  int get progressPercent => (progressPercentage * 100).round();

  bool get isDueToday {
    final now = DateTime.now();
    return dueDate.year == now.year &&
        dueDate.month == now.month &&
        dueDate.day == now.day;
  }

  bool get isOverdue {
    final now = DateTime.now();
    return dueDate.isBefore(DateTime(now.year, now.month, now.day)) &&
        !isCompleted;
  }

  bool shouldRepeatToday() {
    if (!isRepeated || isCompleted) return false;

    final now = DateTime.now();
    final weekday = now.weekday - 1;

    switch (repeatType) {
      case 'daily':
        return true;
      case 'weekly':
        return repeatDays.contains(weekday);
      default:
        return false;
    }
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    DateTime? createdAt,
    bool? isCompleted,
    bool? isRepeated,
    String? repeatType,
    List<int>? repeatDays,
    List<SubTask>? subtasks,
    String? category,
    bool? notificationEnabled,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      isCompleted: isCompleted ?? this.isCompleted,
      isRepeated: isRepeated ?? this.isRepeated,
      repeatType: repeatType ?? this.repeatType,
      repeatDays: repeatDays ?? this.repeatDays,
      subtasks: subtasks ?? this.subtasks,
      category: category ?? this.category,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'dueDate': dueDate.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'isCompleted': isCompleted,
    'isRepeated': isRepeated,
    'repeatType': repeatType,
    'repeatDays': repeatDays,
    'subtasks': subtasks.map((s) => s.toJson()).toList(),
    'category': category,
    'notificationEnabled': notificationEnabled,
  };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    dueDate: DateTime.parse(json['dueDate']),
    createdAt: DateTime.parse(json['createdAt']),
    isCompleted: json['isCompleted'],
    isRepeated: json['isRepeated'],
    repeatType: json['repeatType'],
    repeatDays: List<int>.from(json['repeatDays']),
    subtasks: (json['subtasks'] as List)
        .map((s) => SubTask.fromJson(s))
        .toList(),
    category: json['category'],
    notificationEnabled: json['notificationEnabled'],
  );
}