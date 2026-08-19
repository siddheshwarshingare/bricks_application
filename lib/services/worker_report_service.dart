import 'dart:typed_data';

import 'package:bricks_application/models/factory_model.dart';
import 'package:bricks_application/models/production_model.dart';
import 'package:bricks_application/models/worker_model.dart';
import 'package:bricks_application/services/pdf_theme.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:public_file_saver/public_file_saver.dart';

class WorkerReportService {
  WorkerReportService._();

  /// Generate Worker Production History PDF
  static Future<Uint8List> generateWorkerReportPdf({
    required FactoryModel factory,
    required WorkerModel worker,
    required List<ProductionModel> productions,
  }) async {
    await PdfThemeHelper.loadFonts();
    final pdf = pw.Document();

    double totalBricks = 0;
    double totalEarned = 0;
    double totalPaid = 0;
    double totalReturned = 0;

    for (final production in productions) {
      totalBricks += production.bricksProduced;
      totalEarned += production.salaryEarned;
      totalPaid += production.salaryPaid;
      totalReturned += production.cashReturned;
    }

    final pending = totalEarned - totalPaid;

    pdf.addPage(
      pw.MultiPage(
        pageTheme: PdfThemeHelper.pageTheme(),
        build: (context) => [
          /// Factory Header
          pw.Center(
            child: pw.Column(
              children: [
                pw.Text(factory.name, style: PdfThemeHelper.companyTitleStyle),

                pw.SizedBox(height: 5),

                pw.Text(factory.location, style: PdfThemeHelper.smallStyle),
              ],
            ),
          ),

          pw.SizedBox(height: 20),

          pw.Divider(),

          /// Report Header
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                "Worker Production Report",
                style: PdfThemeHelper.headingStyle,
              ),

              pw.Text(
                "Date : ${DateTime.now().day}/"
                "${DateTime.now().month}/"
                "${DateTime.now().year}",
              ),
            ],
          ),

          pw.SizedBox(height: 25),

          /// Worker Details
          sectionTitle("Worker Details"),

          pw.SizedBox(height: 10),

          detailRow("Worker", worker.name),
          detailRow("Mobile", worker.mobile),
          detailRow("Work Type", worker.workType),
          detailRow("Rate", "₹${worker.ratePer1000}/1000 Bricks"),

          invoiceDivider(),

          /// Summary
          sectionTitle("Production Summary"),

          pw.SizedBox(height: 10),

          summaryRow(
            "Total Bricks",
            "${totalBricks.toStringAsFixed(0)} Bricks",
            PdfColors.orange,
          ),

          summaryRow(
            "Total Earned",
            "₹${totalEarned.toStringAsFixed(2)}",
            PdfColors.green,
          ),

          summaryRow(
            "Salary Paid",
            "₹${totalPaid.toStringAsFixed(2)}",
            PdfColors.blue,
          ),

          summaryRow(
            "Pending",
            "₹${pending.toStringAsFixed(2)}",
            PdfColors.red,
          ),

          summaryRow(
            "Cash Returned",
            "₹${totalReturned.toStringAsFixed(2)}",
            PdfColors.red,
          ),

          pw.SizedBox(height: 25),

          /// Production History
          sectionTitle("Production History"),

          pw.SizedBox(height: 10),

          if (productions.isEmpty)
            pw.Center(
              child: pw.Padding(
                padding: const pw.EdgeInsets.all(20),
                child: pw.Text("No production history found."),
              ),
            )
          else
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey400),

              columnWidths: {
                0: const pw.FlexColumnWidth(1.2),
                1: const pw.FlexColumnWidth(1.5),
                2: const pw.FlexColumnWidth(1.5),
                3: const pw.FlexColumnWidth(1.5),
                4: const pw.FlexColumnWidth(1.5),
              },

              children: [
                /// Header
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    tableHeader("Date"),
                    tableHeader("Bricks"),
                    tableHeader("Salary"),
                    tableHeader("Paid"),
                    tableHeader("Returned"),
                  ],
                ),

                /// Production rows
                ...productions.map((production) {
                  final date = production.productionDate.toDate();

                  return pw.TableRow(
                    children: [
                      tableCell("${date.day}/${date.month}/${date.year}"),

                      tableCell(production.bricksProduced.toStringAsFixed(0)),

                      tableCell(
                        "₹${production.salaryEarned.toStringAsFixed(0)}",
                      ),

                      tableCell("₹${production.salaryPaid.toStringAsFixed(0)}"),

                      tableCell(
                        "₹${production.cashReturned.toStringAsFixed(0)}",
                      ),
                    ],
                  );
                }),
              ],
            ),

          pw.SizedBox(height: 30),

          /// Footer
          pw.Center(
            child: pw.Text(
              "Worker Production Report",
              style: PdfThemeHelper.smallStyle,
            ),
          ),

          pw.SizedBox(height: 5),

          pw.Center(
            child: pw.Text(
              "Generated from Bricks Application",
              style: PdfThemeHelper.smallStyle,
            ),
          ),
        ],
      ),
    );

    final List<int> pdfData = await pdf.save();

    return Uint8List.fromList(pdfData);
  }

  /// Download PDF
  static Future<void> downloadWorkerReport({
    required FactoryModel factory,
    required WorkerModel worker,
    required List<ProductionModel> productions,
  }) async {
    final Uint8List bytes = await generateWorkerReportPdf(
      factory: factory,
      worker: worker,
      productions: productions,
    );

    final result = await PublicFileSaver().saveBytes(
      bytes: bytes,
      fileName: "Worker_Report_${worker.id}.pdf",
      mimeType: "application/pdf",
      subDir: "Bricks Application",
    );

    if (result != null && result.isSuccess) {
      print("Worker report saved successfully");
    } else {
      print("Failed to save worker report");
    }
  }

  /// Share PDF
  static Future<void> shareWorkerReport({
    required FactoryModel factory,
    required WorkerModel worker,
    required List<ProductionModel> productions,
  }) async {
    final Uint8List bytes = await generateWorkerReportPdf(
      factory: factory,
      worker: worker,
      productions: productions,
    );

    await Printing.sharePdf(
      bytes: bytes,
      filename: "Worker_Report_${worker.id}.pdf",
    );
  }
}

/// Section title
pw.Widget sectionTitle(String title) {
  return pw.Container(
    width: double.infinity,
    padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
    decoration: pw.BoxDecoration(
      color: PdfThemeHelper.primaryColor,
      borderRadius: pw.BorderRadius.circular(6),
    ),
    child: pw.Text(
      title,
      style: pw.TextStyle(
        color: PdfColors.white,
        fontSize: 13,
        fontWeight: pw.FontWeight.bold,
      ),
    ),
  );
}

/// Detail row
pw.Widget detailRow(String title, String value) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 4),
    child: pw.Row(
      children: [
        pw.SizedBox(
          width: 120,
          child: pw.Text(title, style: PdfThemeHelper.normalStyle),
        ),
        pw.Expanded(child: pw.Text(value, style: PdfThemeHelper.boldStyle)),
      ],
    ),
  );
}

/// Summary row
pw.Widget summaryRow(String title, String value, PdfColor color) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 5),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(title, style: PdfThemeHelper.normalStyle),
        pw.Text(
          value,
          style: pw.TextStyle(
            color: color,
            fontWeight: pw.FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    ),
  );
}

/// Table header
pw.Widget tableHeader(String text) {
  return pw.Padding(
    padding: const pw.EdgeInsets.all(7),
    child: pw.Text(
      text,
      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
    ),
  );
}

/// Table cell
pw.Widget tableCell(String text) {
  return pw.Padding(
    padding: const pw.EdgeInsets.all(7),
    child: pw.Text(text, style: const pw.TextStyle(fontSize: 9)),
  );
}

/// Divider
pw.Widget invoiceDivider() {
  return pw.Divider(thickness: .6, color: PdfColors.grey400);
}
