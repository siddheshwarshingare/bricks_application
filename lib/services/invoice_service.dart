import 'dart:io';
import 'dart:typed_data';

import 'package:bricks_application/models/customer_model.dart';
import 'package:bricks_application/models/factory_model.dart';
import 'package:bricks_application/models/sale_model.dart';
import 'package:bricks_application/services/pdf_theme.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:public_file_saver/public_file_saver.dart';

class InvoiceService {
  InvoiceService._();
  static Future<Uint8List> generateCustomerInvoicePdf({
    required FactoryModel factory,
    required CustomerModel customer,
  }) async {
    final pdf = pw.Document();

    await PdfThemeHelper.loadFonts();

    pdf.addPage(
      pw.MultiPage(
        pageTheme: PdfThemeHelper.pageTheme(),
        build: (context) => [
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

          pw.Text("Customer Invoice", style: PdfThemeHelper.headingStyle),

          pw.SizedBox(height: 20),

          sectionTitle("Customer Details"),

          pw.SizedBox(height: 10),

          detailRow("Customer", customer.name),
          detailRow("Mobile", customer.mobile),
          detailRow("Village", customer.village),

          invoiceDivider(),

          sectionTitle("Purchase Summary"),

          pw.SizedBox(height: 10),

          detailRow(
            "Total Bricks",
            "${customer.totalQuantity.toStringAsFixed(0)} Bricks",
          ),

          detailRow(
            "Total Purchase",
            "₹${customer.totalPurchase.toStringAsFixed(2)}",
          ),

          invoiceDivider(),

          pw.SizedBox(height: 20),

          pw.Text("Payment Summary", style: PdfThemeHelper.sectionTitleStyle),

          pw.SizedBox(height: 10),

          paymentRow(
            "Total Purchase",
            "₹${customer.totalPurchase.toStringAsFixed(2)}",
            PdfColors.black,
          ),

          paymentRow(
            "Paid",
            "₹${customer.totalPaid.toStringAsFixed(2)}",
            PdfColors.green,
          ),

          paymentRow(
            "Pending",
            "₹${customer.pendingBalance.toStringAsFixed(2)}",
            PdfColors.red,
          ),

          invoiceDivider(),

          pw.SizedBox(height: 30),

          signatureSection(),

          pw.SizedBox(height: 30),

          pw.Center(
            child: pw.Text(
              "Thank You! Visit Again",
              style: PdfThemeHelper.smallStyle,
            ),
          ),
        ],
      ),
    );

    final bytes = await pdf.save();

    return Uint8List.fromList(bytes);
  }

  static Future<void> downloadCustomerInvoice({
    required FactoryModel factory,
    required CustomerModel customer,
  }) async {
    final bytes = await generateCustomerInvoicePdf(
      factory: factory,
      customer: customer,
    );

    final result = await PublicFileSaver().saveBytes(
      bytes: bytes,
      fileName: "Customer_Invoice_${customer.id}.pdf",
      mimeType: "application/pdf",
      subDir: "Bricks Application",
    );

    if (result != null && result.isSuccess) {
      print("Customer invoice saved successfully");
    } else {
      print("Failed to save customer invoice");
    }
  }

  static Future<File> generateCustomerInvoice({
    required FactoryModel factory,
    required CustomerModel customer,
  }) async {
    final pdf = pw.Document();

    await PdfThemeHelper.loadFonts();

    pdf.addPage(
      pw.MultiPage(
        pageTheme: PdfThemeHelper.pageTheme(),
        build: (context) => [
          // Factory Header
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

          // Invoice Header
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text("Customer Invoice", style: PdfThemeHelper.headingStyle),

              pw.Text(
                "Date : ${DateTime.now().day}/"
                "${DateTime.now().month}/"
                "${DateTime.now().year}",
              ),
            ],
          ),

          pw.SizedBox(height: 25),

          // Customer Details
          sectionTitle("Customer Details"),

          pw.SizedBox(height: 10),

          detailRow("Customer", customer.name),
          detailRow("Mobile", customer.mobile),
          detailRow("Village", customer.village),

          invoiceDivider(),

          // Purchase Summary
          sectionTitle("Purchase Summary"),

          pw.SizedBox(height: 10),

          detailRow(
            "Total Bricks",
            "${customer.totalQuantity.toStringAsFixed(0)} Bricks",
          ),

          detailRow(
            "Total Purchase",
            "₹${customer.totalPurchase.toStringAsFixed(2)}",
          ),

          invoiceDivider(),

          pw.SizedBox(height: 20),

          // Payment Summary
          pw.Text("Payment Summary", style: PdfThemeHelper.sectionTitleStyle),

          pw.SizedBox(height: 10),

          paymentRow(
            "Total Purchase",
            "₹${customer.totalPurchase.toStringAsFixed(2)}",
            PdfColors.black,
          ),

          paymentRow(
            "Paid",
            "₹${customer.totalPaid.toStringAsFixed(2)}",
            PdfColors.green,
          ),

          paymentRow(
            "Pending",
            "₹${customer.pendingBalance.toStringAsFixed(2)}",
            PdfColors.red,
          ),

          invoiceDivider(),

          pw.SizedBox(height: 30),

          // Signature
          signatureSection(),

          pw.SizedBox(height: 30),

          pw.Center(
            child: pw.Text(
              "Thank You! Visit Again",
              style: PdfThemeHelper.smallStyle,
            ),
          ),
        ],
      ),
    );

    final bytes = await pdf.save();

    final directory = await Directory.systemTemp.createTemp();

    final file = File("${directory.path}/Customer_Invoice_${customer.id}.pdf");

    await file.writeAsBytes(bytes);

    return file;
  }

  static Future<void> shareCustomerInvoice({
    required FactoryModel factory,
    required CustomerModel customer,
  }) async {
    final bytes = await generateCustomerInvoicePdf(
      factory: factory,
      customer: customer,
    );

    await Printing.sharePdf(
      bytes: bytes,
      filename: "Customer_Invoice_${customer.id}.pdf",
    );
  }

  /// Generate PDF bytes
  static Future<Uint8List> generateInvoicePdf({
    required FactoryModel factory,
    required CustomerModel customer,
    required SaleModel sale,
  }) async {
    final pdf = pw.Document();

    await PdfThemeHelper.loadFonts();
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

          /// Invoice Header
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text("Invoice", style: PdfThemeHelper.headingStyle),

              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    "Invoice No : ${sale.id.length >= 6 ? sale.id.substring(0, 6) : sale.id}",
                  ),

                  pw.Text(
                    "Date : ${sale.saleDate.toDate().day}/"
                    "${sale.saleDate.toDate().month}/"
                    "${sale.saleDate.toDate().year}",
                  ),
                ],
              ),
            ],
          ),

          pw.SizedBox(height: 25),

          /// Customer Details
          sectionTitle("Customer Details"),

          pw.SizedBox(height: 10),

          detailRow("Customer", customer.name),
          detailRow("Mobile", customer.mobile),
          detailRow("Village", customer.village),

          invoiceDivider(),

          /// Sale Details
          sectionTitle("Sale Details"),

          pw.SizedBox(height: 10),

          detailRow("Brick Type", sale.brickType),
          detailRow("Quantity", "${sale.quantity.toStringAsFixed(0)} Bricks"),
          detailRow("Rate", "₹${sale.rate.toStringAsFixed(2)}"),
          detailRow("Vehicle", sale.vehicleNumber),

          invoiceDivider(),

          pw.SizedBox(height: 25),

          /// Payment Summary
          pw.Text("Payment Summary", style: PdfThemeHelper.sectionTitleStyle),

          pw.SizedBox(height: 10),

          paymentRow(
            "Total Amount",
            "₹${sale.totalAmount.toStringAsFixed(2)}",
            PdfColors.black,
          ),

          paymentRow(
            "Paid",
            "₹${sale.paidAmount.toStringAsFixed(2)}",
            PdfColors.green,
          ),

          paymentRow(
            "Pending",
            "₹${sale.pendingAmount.toStringAsFixed(2)}",
            PdfColors.red,
          ),

          invoiceDivider(),

          pw.SizedBox(height: 25),

          /// Remarks
          pw.Text("Remarks", style: PdfThemeHelper.sectionTitleStyle),

          pw.SizedBox(height: 10),

          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfThemeHelper.borderColor),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Text(sale.remarks.isEmpty ? "-" : sale.remarks),
          ),

          pw.SizedBox(height: 30),

          /// Signature
          signatureSection(),

          pw.SizedBox(height: 30),

          /// Footer
          pw.Center(
            child: pw.Text(
              "Thank You! Visit Again",
              style: PdfThemeHelper.smallStyle,
            ),
          ),
        ],
      ),
    );

    // IMPORTANT:
    // Convert List<int> to Uint8List.
    final List<int> pdfData = await pdf.save();

    return Uint8List.fromList(pdfData);
  }

  /// Download / Save invoice
  static Future<void> downloadInvoice({
    required FactoryModel factory,
    required CustomerModel customer,
    required SaleModel sale,
  }) async {
    final Uint8List bytes = await generateInvoicePdf(
      factory: factory,
      customer: customer,
      sale: sale,
    );

    final result = await PublicFileSaver().saveBytes(
      bytes: bytes,
      fileName: "Invoice_${sale.id}.pdf",
      mimeType: "application/pdf",
      subDir: "Bricks Application",
    );

    if (result != null && result.isSuccess) {
      print("PDF saved successfully");
    } else {
      print("Failed to save PDF");
    }
  }

  /// Share invoice
  static Future<void> shareInvoice({
    required FactoryModel factory,
    required CustomerModel customer,
    required SaleModel sale,
  }) async {
    final Uint8List bytes = await generateInvoicePdf(
      factory: factory,
      customer: customer,
      sale: sale,
    );
    await Printing.sharePdf(bytes: bytes, filename: "Invoice_${sale.id}.pdf");
  }

  /// Preview / Print invoice
  static Future<void> previewInvoice({
    required FactoryModel factory,
    required CustomerModel customer,
    required SaleModel sale,
  }) async {
    final Uint8List bytes = await generateInvoicePdf(
      factory: factory,
      customer: customer,
      sale: sale,
    );

    await Printing.layoutPdf(
      onLayout: (format) async {
        return bytes;
      },
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

/// Divider
pw.Widget invoiceDivider() {
  return pw.Divider(thickness: .6, color: PdfColors.grey400);
}

/// Payment row
pw.Widget paymentRow(String title, String value, PdfColor color) {
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

/// Signature section
pw.Widget signatureSection() {
  return pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
      pw.Column(
        children: [
          pw.Container(width: 140, height: 1, color: PdfColors.grey),
          pw.SizedBox(height: 5),
          pw.Text("Customer Signature"),
        ],
      ),

      pw.Column(
        children: [
          pw.Container(width: 140, height: 1, color: PdfColors.grey),
          pw.SizedBox(height: 5),
          pw.Text("Authorized Signature"),
        ],
      ),
    ],
  );
}
