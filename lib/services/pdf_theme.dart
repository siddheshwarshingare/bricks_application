import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfThemeHelper {
  PdfThemeHelper._();

  static pw.Font? _regularFont;
  static pw.Font? _boldFont;

  static Future<void>? _loadingFonts;

  static Future<void> loadFonts() {
    return _loadingFonts ??= _loadFonts();
  }

  static Future<void> _loadFonts() async {
    final regularData = await rootBundle.load(
      //  'assets/fonts/Noto_Sans/static/NotoSans_Condensed-Regular.ttf',
      'assets/fonts/Poppins/Noto_Sans/static/NotoSans_Condensed-Regular.ttf',
    );

    final boldData = await rootBundle.load(
      // 'assets/fonts/Noto_Sans/static/NotoSans_Condensed-Bold.ttf',
      'assets/fonts/Poppins/Noto_Sans/static/NotoSans_Condensed-Bold.ttf',
    );
    _regularFont = pw.Font.ttf(regularData);
    _boldFont = pw.Font.ttf(boldData);
  }

  static pw.Font get regularFont {
    if (_regularFont == null) {
      throw Exception(
        'PDF fonts are not loaded. Call await PdfThemeHelper.loadFonts() first.',
      );
    }

    return _regularFont!;
  }

  static pw.Font get boldFont {
    if (_boldFont == null) {
      throw Exception(
        'PDF fonts are not loaded. Call await PdfThemeHelper.loadFonts() first.',
      );
    }

    return _boldFont!;
  }

  static const PdfColor primaryColor = PdfColor.fromInt(0xff2563EB);

  static const PdfColor borderColor = PdfColor.fromInt(0xffD1D5DB);

  static pw.TextStyle get normalStyle {
    return pw.TextStyle(font: regularFont, fontSize: 11);
  }

  static pw.TextStyle get boldStyle {
    return pw.TextStyle(font: boldFont, fontSize: 11);
  }

  static pw.TextStyle get smallStyle {
    return pw.TextStyle(font: regularFont, fontSize: 9);
  }

  static pw.TextStyle get companyTitleStyle {
    return pw.TextStyle(
      font: boldFont,
      fontSize: 24,
      fontWeight: pw.FontWeight.bold,
    );
  }

  static pw.TextStyle get headingStyle {
    return pw.TextStyle(
      font: boldFont,
      fontSize: 20,
      fontWeight: pw.FontWeight.bold,
    );
  }

  static pw.TextStyle get sectionTitleStyle {
    return pw.TextStyle(
      font: boldFont,
      fontSize: 13,
      fontWeight: pw.FontWeight.bold,
    );
  }

  static pw.PageTheme pageTheme() {
    return pw.PageTheme(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      theme: pw.ThemeData.withFont(base: regularFont, bold: boldFont),
    );
  }
}
