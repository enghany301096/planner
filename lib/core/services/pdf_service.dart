import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../models/project.dart';
import '../../models/project_task.dart';

class PdfService {
  Future<pw.Font> _getArabicFont() async {
    return pw.Font.ttf(
      await rootBundle.load("assets/fonts/Almarai-Regular.ttf"),
    );
  }

  Future<void> printProjectInvoice(
    Project project,
    List<ProjectTask> tasks,
    Locale locale, {
    required String currency,
    bool showHourCost = true,
    bool showTaskType = true,
    bool showTaskTime = true,
    bool showSubtasks = true,
    String? documentName,
  }) async {
    final pdf = await _generateProjectPdf(
      project,
      tasks,
      locale,
      currency: currency,
      showHourCost: showHourCost,
      showTaskType: showTaskType,
      showTaskTime: showTaskTime,
      showSubtasks: showSubtasks,
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: documentName ?? 'Invoice_${project.name}',
    );
  }

  Future<void> shareProjectInvoice(
    Project project,
    List<ProjectTask> tasks,
    Locale locale, {
    required String currency,
    bool showHourCost = true,
    bool showTaskType = true,
    bool showTaskTime = true,
    bool showSubtasks = true,
    String? documentName,
  }) async {
    final pdf = await _generateProjectPdf(
      project,
      tasks,
      locale,
      currency: currency,
      showHourCost: showHourCost,
      showTaskType: showTaskType,
      showTaskTime: showTaskTime,
      showSubtasks: showSubtasks,
    );

    final output = await getTemporaryDirectory();
    final prefix = documentName ?? 'Invoice_${project.name}';
    final fileName = "${prefix}_${DateTime.now().millisecondsSinceEpoch}.pdf";
    final file = File("${output.path}/$fileName");
    await file.writeAsBytes(await pdf.save());

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text: 'invoiceShareText'.tr(namedArgs: {'name': project.name}),
      ),
    );
  }

  Future<pw.Document> _generateProjectPdf(
    Project project,
    List<ProjectTask> tasks,
    Locale locale, {
    required String currency,
    required bool showHourCost,
    required bool showTaskType,
    required bool showTaskTime,
    bool showSubtasks = true,
    bool isDraft = false,
  }) async {
    final pdf = pw.Document();
    final arabicFont = await _getArabicFont();
    final isArabic = locale.languageCode == 'ar';

    // Create a theme that supports Arabic globally
    final theme = pw.ThemeData.withFont(
      base: arabicFont,
      bold: arabicFont, // Using same font if bold version not found
      italic: arabicFont,
    );

    // Load logo
    pw.MemoryImage? logoImage;
    try {
      final logoData = await rootBundle.load('assets/images/logo.png');
      logoImage = pw.MemoryImage(logoData.buffer.asUint8List());
    } catch (e) {
      // Fallback if logo not found
    }

    pdf.addPage(
      pw.MultiPage(
        theme: theme,
        textDirection: isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr,
        pageFormat: PdfPageFormat.a4,
        // Optimized margins for printing (20mm on all sides)
        margin: const pw.EdgeInsets.all(56.69), // 20mm in points
        header: (context) => _buildHeader(project, logoImage, isArabic),
        footer: (context) => _buildFooter(context, isArabic),
        build: (context) => [
          // Add watermark for draft versions
          if (isDraft) _buildWatermark(isArabic),
          pw.SizedBox(height: 10),
          _buildProjectSummary(project, tasks, isArabic, currency),
          pw.SizedBox(height: 20),
          _buildTaskDetailsSection(
            tasks,
            isArabic,
            currency,
            showTaskType,
            showTaskTime,
            showSubtasks,
            showHourCost,
          ),
        ],
      ),
    );

    return pdf;
  }

  pw.Widget _buildWatermark(bool isArabic) {
    return pw.Transform.rotate(
      angle: -0.5, // Diagonal watermark
      child: pw.Center(
        child: pw.Opacity(
          opacity: 0.1,
          child: pw.Text(
            'draft'.tr(),
            style: pw.TextStyle(
              fontSize: 80,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey,
            ),
          ),
        ),
      ),
    );
  }

  pw.Widget _buildHeader(
    Project project,
    pw.MemoryImage? logoImage,
    bool isArabic,
  ) {
    return pw.Container(
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColor.fromInt(0xFFF08010), width: 2),
        ),
      ),
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Column(
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Logo section
              if (logoImage != null)
                pw.Container(height: 50, width: 50, child: pw.Image(logoImage)),
              // Project info section
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      project.name,
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                        color: const PdfColor.fromInt(0xFFF08010),
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                    if (project.customer != null &&
                        project.customer!.isNotEmpty) ...[
                      pw.SizedBox(height: 4),
                      pw.Text(
                        '${'projectCustomer'.tr()}: ${project.customer}',
                        style: const pw.TextStyle(
                          fontSize: 11,
                          color: PdfColors.grey800,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ],
                    pw.SizedBox(height: 4),
                    pw.Text(
                      project.description,
                      style: const pw.TextStyle(
                        fontSize: 11,
                        color: PdfColors.grey700,
                      ),
                      textAlign: pw.TextAlign.center,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              // Date section
              pw.Container(
                width: 100,
                child: pw.Column(
                  crossAxisAlignment: isArabic
                      ? pw.CrossAxisAlignment.start
                      : pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'createdAt'.tr(),
                      style: pw.TextStyle(
                        fontSize: 8,
                        color: PdfColors.grey600,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      DateFormat('yyyy-MM-dd').format(DateTime.now()),
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildProjectSummary(
    Project project,
    List<ProjectTask> tasks,
    bool isArabic,
    String currency,
  ) {
    final totalCost = tasks.fold(0.0, (sum, t) => sum + t.cost);
    final totalPaid = tasks
        .where((t) => t.isPaid)
        .fold(0.0, (sum, t) => sum + t.cost);
    final totalRemaining = totalCost - totalPaid;
    final completedTasks = tasks.where((t) => t.isCompleted).length;
    final completionRate = tasks.isEmpty
        ? 0.0
        : (completedTasks / tasks.length) * 100;

    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300, width: 1),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      padding: const pw.EdgeInsets.all(12),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Container(
                width: 4,
                height: 18,
                decoration: const pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFFF08010),
                  borderRadius: pw.BorderRadius.all(pw.Radius.circular(2)),
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Text(
                'projectSummary'.tr(),
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: const PdfColor.fromInt(0xFFF08010),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 12),
          // Main info table - using print-friendly colors
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(
                  color: PdfColor.fromInt(
                    0xFFE3F2FD,
                  ), // Light blue for printing
                ),
                children: isArabic
                    ? [
                        _buildSummaryHeaderCell('status'.tr()),
                        _buildSummaryHeaderCell('totalCost'.tr()),
                        _buildSummaryHeaderCell('completionRate'.tr()),
                        _buildSummaryHeaderCell('tasksCount'.tr()),
                      ]
                    : [
                        _buildSummaryHeaderCell('tasksCount'.tr()),
                        _buildSummaryHeaderCell('completionRate'.tr()),
                        _buildSummaryHeaderCell('totalCost'.tr()),
                        _buildSummaryHeaderCell('status'.tr()),
                      ],
              ),
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.white),
                children: isArabic
                    ? [
                        _buildSummaryDataCell(project.status.tr()),
                        _buildSummaryDataCell(
                          '$currency ${totalCost.toStringAsFixed(2)}',
                        ),
                        _buildSummaryDataCell(
                          '${completionRate.toStringAsFixed(1)}%',
                        ),
                        _buildSummaryDataCell(tasks.length.toString()),
                      ]
                    : [
                        _buildSummaryDataCell(tasks.length.toString()),
                        _buildSummaryDataCell(
                          '${completionRate.toStringAsFixed(1)}%',
                        ),
                        _buildSummaryDataCell(
                          '$currency ${totalCost.toStringAsFixed(2)}',
                        ),
                        _buildSummaryDataCell(project.status.tr()),
                      ],
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          // Payment info table - using print-friendly colors
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(
                  color: PdfColor.fromInt(
                    0xFFE8F5E9,
                  ), // Light green for printing
                ),
                children: isArabic
                    ? [
                        _buildSummaryHeaderCell('totalPaid'.tr()),
                        _buildSummaryHeaderCell('totalRemaining'.tr()),
                      ]
                    : [
                        _buildSummaryHeaderCell('totalRemaining'.tr()),
                        _buildSummaryHeaderCell('totalPaid'.tr()),
                      ],
              ),
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.white),
                children: isArabic
                    ? [
                        _buildSummaryDataCell(
                          '$currency ${totalPaid.toStringAsFixed(2)}',
                        ),
                        _buildSummaryDataCell(
                          '$currency ${totalRemaining.toStringAsFixed(2)}',
                        ),
                      ]
                    : [
                        _buildSummaryDataCell(
                          '$currency ${totalRemaining.toStringAsFixed(2)}',
                        ),
                        _buildSummaryDataCell(
                          '$currency ${totalPaid.toStringAsFixed(2)}',
                        ),
                      ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildSummaryHeaderCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Center(
        child: pw.Text(
          text,
          style: pw.TextStyle(
            color: PdfColors.grey800,
            fontWeight: pw.FontWeight.bold,
            fontSize: 10,
          ),
        ),
      ),
    );
  }

  pw.Widget _buildSummaryDataCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Center(
        child: pw.Text(
          text,
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.black,
          ),
        ),
      ),
    );
  }

  pw.Widget _buildTaskDetailsSection(
    List<ProjectTask> tasks,
    bool isArabic,
    String currency,
    bool showTaskType,
    bool showTaskTime,
    bool showSubtasks,
    bool showHourCost,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          children: [
            pw.Container(
              width: 4,
              height: 18,
              decoration: const pw.BoxDecoration(
                color: PdfColor.fromInt(0xFFF08010),
                borderRadius: pw.BorderRadius.all(pw.Radius.circular(2)),
              ),
            ),
            pw.SizedBox(width: 8),
            pw.Text(
              'tasksDetails'.tr(),
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: const PdfColor.fromInt(0xFFF08010),
              ),
            ),
            pw.SizedBox(width: 8),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 2,
              ),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey200,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
              ),
              child: pw.Text(
                '${tasks.length} ${'tasks'.tr()}',
                style: const pw.TextStyle(
                  fontSize: 9,
                  color: PdfColors.grey700,
                ),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 12),
        ...tasks.map(
          (task) => _buildTaskCard(
            task,
            isArabic,
            currency,
            showTaskType,
            showTaskTime,
            showSubtasks,
            showHourCost,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildTaskCard(
    ProjectTask task,
    bool isArabic,
    String currency,
    bool showTaskType,
    bool showTaskTime,
    bool showSubtasks,
    bool showHourCost,
  ) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 15),
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300, width: 1),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                task.name,
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              if (showHourCost)
                _buildPriceLabel(task.cost, currency, task.isPaid),
            ],
          ),
          pw.SizedBox(height: 4),
          if (showTaskType)
            pw.Row(
              children: [
                _buildPaymentStatus(task.isPaid, true),
                pw.SizedBox(width: 4),
                _buildTaskBadge(task.type),
              ],
            ),
          if (showTaskTime) ...[
            pw.SizedBox(height: 4),
            pw.Text(
              '${'timeSpent'.tr()}: ${_formatSeconds(task.timeSpentInSeconds)}',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.black),
            ),
          ],
          pw.SizedBox(height: 4),
          pw.Text(
            task.details,
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 4),
          if (showTaskTime)
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  '${'startDate'.tr()}: ${DateFormat('yyyy-MM-dd').format(task.startDate)} ${task.endDate != null ? ' - ${'endDate'.tr()}: ${DateFormat('yyyy-MM-dd').format(task.endDate!)}' : ''}',
                  style: const pw.TextStyle(
                    fontSize: 8,
                    color: PdfColors.grey600,
                  ),
                ),
                if (task.timerStartAt != null)
                  pw.Text(
                    '${'timerStart'.tr()}: ${DateFormat('yyyy-MM-dd HH:mm').format(task.timerStartAt!)} ${task.timerEndAt != null ? ' - ${'timerEnd'.tr()}: ${DateFormat('yyyy-MM-dd HH:mm').format(task.timerEndAt!)}' : ''}',
                    style: const pw.TextStyle(
                      fontSize: 8,
                      color: PdfColors.grey600,
                    ),
                  ),
              ],
            ),
          if (showSubtasks && task.subTasks.isNotEmpty) ...[
            pw.SizedBox(height: 10),
            pw.Divider(thickness: 0.5, color: PdfColors.grey300),
            pw.SizedBox(height: 5),
            pw.Text(
              '${'subtasksList'.tr()} (${task.subTasks.where((s) => s['isDone'] == true || s['isDone'] == 1).length}/${task.subTasks.length})',
              style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 5),
            ...task.subTasks.map((st) => _buildSubtaskItem(st, isArabic)),
          ],
        ],
      ),
    );
  }

  pw.Widget _buildPriceLabel(double amount, String currency, bool isPaid) {
    return pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: pw.BoxDecoration(
            color: isPaid ? PdfColors.green100 : PdfColors.orange100,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
            border: pw.Border.all(
              color: isPaid ? PdfColors.green700 : PdfColors.orange700,
              width: 0.5,
            ),
          ),
          child: pw.Text(
            '$amount $currency',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: isPaid ? PdfColors.green700 : PdfColors.orange700,
            ),
          ),
        ),
      ],
    );
  }

  pw.Widget _buildSubtaskCheck(bool isDone) {
    return pw.Container(
      width: 7,
      height: 7,
      margin: const pw.EdgeInsets.symmetric(horizontal: 4),
      decoration: pw.BoxDecoration(
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(1.5)),
        border: pw.Border.all(
          color: isDone ? PdfColors.green700 : PdfColors.grey400,
          width: 0.5,
        ),
        color: isDone ? PdfColors.green700 : null,
      ),
      child: isDone
          ? pw.Center(
              child: pw.Text(
                'v',
                style: pw.TextStyle(
                  fontSize: 5,
                  color: PdfColors.white,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            )
          : null,
    );
  }

  pw.Widget _buildPaymentStatus(bool isPaid, bool isArabic) {
    final color = isPaid ? PdfColors.green700 : PdfColors.red700;
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: pw.BoxDecoration(
        color: isPaid ? PdfColors.green50 : PdfColors.red50,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Text(
        (isPaid ? 'paid' : 'unpaid').tr(),
        style: pw.TextStyle(
          fontSize: 7,
          color: color,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  pw.Widget _buildFooter(pw.Context context, bool isArabic) {
    return pw.Container(
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfColor.fromInt(0xFFF08010), width: 1.5),
        ),
      ),
      padding: const pw.EdgeInsets.only(top: 8),
      child: pw.Column(
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              // Left side - Generated info
              pw.Column(
                crossAxisAlignment: isArabic
                    ? pw.CrossAxisAlignment.end
                    : pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Generated by Smart Planner',
                    style: pw.TextStyle(
                      color: PdfColors.grey600,
                      fontSize: 7,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
                    style: const pw.TextStyle(
                      color: PdfColors.grey500,
                      fontSize: 6,
                    ),
                  ),
                ],
              ),
              // Center - Page number
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: pw.BoxDecoration(
                  color: const PdfColor.fromInt(0xFFF08010),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(3),
                  ),
                ),
                child: pw.Text(
                  '${'page'.tr()} ${context.pageNumber} ${'of'.tr()} ${context.pagesCount}',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 8,
                  ),
                ),
              ),
              // Right side - Contact info placeholder
              pw.Column(
                crossAxisAlignment: isArabic
                    ? pw.CrossAxisAlignment.start
                    : pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'Smart Planner',
                    style: const pw.TextStyle(
                      color: PdfColors.grey600,
                      fontSize: 7,
                    ),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    'smartplanner.app',
                    style: const pw.TextStyle(
                      color: PdfColors.grey500,
                      fontSize: 6,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildTaskBadge(String type) {
    PdfColor color;
    switch (type) {
      case 'bug':
        color = PdfColors.red700;
        break;
      case 'enhancement':
        color = PdfColors.blue700;
        break;
      default:
        color = PdfColors.orange700;
    }

    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
        border: pw.Border.all(color: color, width: 0.5),
      ),
      child: pw.Text(
        type.tr(),
        style: pw.TextStyle(
          fontSize: 8,
          color: color,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  pw.Widget _buildSubtaskItem(Map<String, dynamic> subtask, bool isArabic) {
    final isDone = subtask['isDone'] == true || subtask['isDone'] == 1;
    final title = subtask['title']?.toString() ?? '';

    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: pw.Row(
        children: [
          if (!isArabic) _buildSubtaskCheck(isDone),
          pw.Expanded(
            child: pw.Text(
              title,
              style: pw.TextStyle(
                fontSize: 8,
                color: isDone ? PdfColors.grey600 : PdfColors.black,
                decoration: isDone ? pw.TextDecoration.lineThrough : null,
              ),
            ),
          ),
          if (isArabic) _buildSubtaskCheck(isDone),
        ],
      ),
    );
  }

  String _formatSeconds(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${secs}s';
    } else {
      return '${secs}s';
    }
  }

  /// Save PDF to a specific file path
  Future<File> saveProjectInvoiceToFile(
    Project project,
    List<ProjectTask> tasks,
    Locale locale,
    String filePath, {
    required String currency,
    bool showHourCost = true,
    bool showTaskType = true,
    bool showTaskTime = true,
    bool showSubtasks = true,
    bool isDraft = false,
  }) async {
    final pdf = await _generateProjectPdf(
      project,
      tasks,
      locale,
      currency: currency,
      showHourCost: showHourCost,
      showTaskType: showTaskType,
      showTaskTime: showTaskTime,
      showSubtasks: showSubtasks,
      isDraft: isDraft,
    );

    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  /// Preview PDF before printing with custom settings
  Future<void> previewProjectInvoice(
    Project project,
    List<ProjectTask> tasks,
    Locale locale, {
    required String currency,
    bool showHourCost = true,
    bool showTaskType = true,
    bool showTaskTime = true,
    bool showSubtasks = true,
    bool isDraft = false,
  }) async {
    final pdf = await _generateProjectPdf(
      project,
      tasks,
      locale,
      currency: currency,
      showHourCost: showHourCost,
      showTaskType: showTaskType,
      showTaskTime: showTaskTime,
      showSubtasks: showSubtasks,
      isDraft: isDraft,
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename:
          'Invoice_${project.name}_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.pdf',
    );
  }

  /// Get PDF bytes for custom handling
  Future<List<int>> getProjectInvoiceBytes(
    Project project,
    List<ProjectTask> tasks,
    Locale locale, {
    required String currency,
    bool showHourCost = true,
    bool showTaskType = true,
    bool showTaskTime = true,
    bool showSubtasks = true,
    bool isDraft = false,
  }) async {
    final pdf = await _generateProjectPdf(
      project,
      tasks,
      locale,
      currency: currency,
      showHourCost: showHourCost,
      showTaskType: showTaskType,
      showTaskTime: showTaskTime,
      showSubtasks: showSubtasks,
      isDraft: isDraft,
    );

    return pdf.save();
  }
}
