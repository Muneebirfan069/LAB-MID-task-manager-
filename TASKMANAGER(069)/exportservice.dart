import 'dart:io';
import 'package:csv/csv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';

class ExportService {
  // Export to CSV
  static Future<void> exportToCSV(List<Task> tasks) async {
    final List<List<dynamic>> rows = [];

    // Header
    rows.add(['Title', 'Description', 'Due Date', 'Category', 'Status', 'Progress']);

    // Data
    for (var task in tasks) {
      rows.add([
        task.title,
        task.description,
        DateFormat('yyyy-MM-dd').format(task.dueDate),
        task.category,
        task.isCompleted ? 'Completed' : 'Pending',
        '${task.progressPercent}%',
      ]);
    }

    final csv = const ListToCsvConverter().convert(rows);
    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/tasks.csv';
    final file = File(path);
    await file.writeAsString(csv);

    await Share.shareXFiles(
      [XFile(path)],
      text: 'Task Export - CSV',
    );
  }

  // Export to PDF
  static Future<void> exportToPDF(List<Task> tasks) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text('Task Report', style: pw.TextStyle(fontSize: 24)),
          ),
          pw.SizedBox(height: 20),
          pw.Table.fromTextArray(
            headers: ['Title', 'Due Date', 'Category', 'Status', 'Progress'],
            data: tasks.map((t) => [
              t.title,
              DateFormat('yyyy-MM-dd').format(t.dueDate),
              t.category,
              t.isCompleted ? 'Completed' : 'Pending',
              '${t.progressPercent}%',
            ]).toList(),
          ),
        ],
      ),
    );

    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/tasks.pdf';
    final file = File(path);
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles(
      [XFile(path)],
      text: 'Task Export - PDF',
    );
  }

  // Export via Email (shares text)
  static Future<void> exportToEmail(List<Task> tasks) async {
    final StringBuffer buffer = StringBuffer();
    buffer.writeln('My Task List\n');
    buffer.writeln('Generated: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}\n');

    for (var task in tasks) {
      buffer.writeln('📌 ${task.title}');
      buffer.writeln('   Due: ${DateFormat('yyyy-MM-dd').format(task.dueDate)}');
      buffer.writeln('   Category: ${task.category}');
      buffer.writeln('   Status: ${task.isCompleted ? "✅ Completed" : "⏳ Pending"}');
      buffer.writeln('   Progress: ${task.progressPercent}%');
      if (task.description.isNotEmpty) {
        buffer.writeln('   Description: ${task.description}');
      }
      buffer.writeln('');
    }

    await Share.share(
      buffer.toString(),
      subject: 'My Task List Export',
    );
  }
}