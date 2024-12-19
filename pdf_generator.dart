import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

class PDFGenerator {
  // Generate and Share PDF Report
  static Future<void> generateAndSharePDF(List<String> tasks) async {
    final pdf = pw.Document();

    // Separate completed and pending tasks
    final completedTasks =
        tasks.where((task) => task.contains("(Completed)")).toList();
    final pendingTasks =
        tasks.where((task) => !task.contains("(Completed)")).toList();

    // Add content to the PDF
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text("To-Do App Task Report",
                style:
                    pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.Divider(),
            pw.Text("Total Tasks: ${tasks.length}"),
            pw.Text("Completed Tasks: ${completedTasks.length}"),
            pw.Text("Pending Tasks: ${pendingTasks.length}"),
            pw.SizedBox(height: 20),
            pw.Text("Task Details:",
                style:
                    pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return pw.Text("- ${tasks[index]}");
              },
            ),
            pw.Spacer(),
            pw.Text("Generated on: ${DateTime.now()}",
                style:
                    pw.TextStyle(fontSize: 12, fontStyle: pw.FontStyle.italic)),
          ],
        ),
      ),
    );

    // Save the PDF locally
    final outputDir = await getApplicationDocumentsDirectory();
    final file = File("${outputDir.path}/Task_Report.pdf");
    await file.writeAsBytes(await pdf.save());

    // Share the PDF
    await Share.shareFiles([file.path],
        text: "Here is your To-Do Task Report.");
  }
}
