import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../core/services/pdf_service.dart';
import '../models/project.dart';
import '../models/project_task.dart';

/// Example usage of the enhanced PDF service
class PdfServiceExamples {
  final PdfService _pdfService = PdfService();

  /// Example 1: Print invoice with default settings
  Future<void> printBasicInvoice(
    Project project,
    List<ProjectTask> tasks,
    BuildContext context,
  ) async {
    await _pdfService.printProjectInvoice(
      project,
      tasks,
      context.locale,
      currency: 'USD',
      showHourCost: true,
      showTaskType: true,
    );
  }

  /// Example 2: Print draft invoice with watermark
  Future<void> printDraftInvoice(
    Project project,
    List<ProjectTask> tasks,
    BuildContext context,
  ) async {
    await _pdfService.printProjectInvoice(
      project,
      tasks,
      context.locale,
      currency: 'SAR', // Saudi Riyal
      showHourCost: true,
      showTaskType: true,
      // Note: isDraft parameter needs to be added to printProjectInvoice method
    );
  }

  /// Example 3: Save invoice to Downloads folder
  Future<void> saveInvoiceToDownloads(
    Project project,
    List<ProjectTask> tasks,
    BuildContext context,
  ) async {
    final fileName =
        'Invoice_${project.name}_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.pdf';
    final downloadsPath =
        '/Users/hany/Downloads/$fileName'; // Update path as needed

    final file = await _pdfService.saveProjectInvoiceToFile(
      project,
      tasks,
      context.locale,
      downloadsPath,
      currency: 'USD',
      showHourCost: true,
      showTaskType: true,
      isDraft: false,
    );

    print('Invoice saved to: ${file.path}');
  }

  /// Example 4: Preview invoice before printing
  Future<void> previewInvoice(
    Project project,
    List<ProjectTask> tasks,
    BuildContext context,
  ) async {
    await _pdfService.previewProjectInvoice(
      project,
      tasks,
      context.locale,
      currency: 'EUR',
      showHourCost: true,
      showTaskType: true,
      isDraft: false,
    );
  }

  /// Example 5: Share invoice via email/apps
  Future<void> shareInvoice(
    Project project,
    List<ProjectTask> tasks,
    BuildContext context,
  ) async {
    await _pdfService.shareProjectInvoice(
      project,
      tasks,
      context.locale,
      currency: 'USD',
      showHourCost: true,
      showTaskType: true,
    );
  }

  /// Example 6: Get PDF bytes for custom handling
  Future<void> customPdfHandling(
    Project project,
    List<ProjectTask> tasks,
    BuildContext context,
  ) async {
    final bytes = await _pdfService.getProjectInvoiceBytes(
      project,
      tasks,
      context.locale,
      currency: 'GBP',
      showHourCost: true,
      showTaskType: true,
      isDraft: false,
    );

    // Do something with bytes
    // e.g., upload to server, send via API, etc.
    print('Generated PDF with ${bytes.length} bytes');
  }

  /// Example 7: Print invoice without task types (simplified)
  Future<void> printSimplifiedInvoice(
    Project project,
    List<ProjectTask> tasks,
    BuildContext context,
  ) async {
    await _pdfService.printProjectInvoice(
      project,
      tasks,
      context.locale,
      currency: 'USD',
      showHourCost: false,
      showTaskType: false, // Hide task type badges
    );
  }

  /// Example 8: Save draft for internal review
  Future<void> saveDraftForReview(
    Project project,
    List<ProjectTask> tasks,
    BuildContext context,
  ) async {
    final fileName =
        'DRAFT_${project.name}_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.pdf';
    final path = '/Users/hany/Documents/$fileName';

    await _pdfService.saveProjectInvoiceToFile(
      project,
      tasks,
      context.locale,
      path,
      currency: 'USD',
      showHourCost: true,
      showTaskType: true,
      isDraft: true, // Adds watermark
    );
  }

  /// Example 9: Multi-currency support
  Future<void> printInvoiceInDifferentCurrencies(
    Project project,
    List<ProjectTask> tasks,
    BuildContext context,
  ) async {
    // USD version
    await _pdfService.saveProjectInvoiceToFile(
      project,
      tasks,
      context.locale,
      '/path/to/invoice_usd.pdf',
      currency: 'USD',
    );

    // EUR version
    await _pdfService.saveProjectInvoiceToFile(
      project,
      tasks,
      context.locale,
      '/path/to/invoice_eur.pdf',
      currency: 'EUR',
    );

    // SAR version (Saudi Riyal)
    await _pdfService.saveProjectInvoiceToFile(
      project,
      tasks,
      context.locale,
      '/path/to/invoice_sar.pdf',
      currency: 'SAR',
    );
  }

  /// Example 10: Bilingual invoices (Arabic and English)
  Future<void> generateBilingualInvoices(
    Project project,
    List<ProjectTask> tasks,
  ) async {
    // Arabic version
    await _pdfService.saveProjectInvoiceToFile(
      project,
      tasks,
      const Locale('ar'),
      '/path/to/invoice_ar.pdf',
      currency: 'SAR',
    );

    // English version
    await _pdfService.saveProjectInvoiceToFile(
      project,
      tasks,
      const Locale('en'),
      '/path/to/invoice_en.pdf',
      currency: 'USD',
    );
  }
}

/// Widget example: Print button with loading state
class PrintInvoiceButton extends StatefulWidget {
  final Project project;
  final List<ProjectTask> tasks;

  const PrintInvoiceButton({
    super.key,
    required this.project,
    required this.tasks,
  });

  @override
  State<PrintInvoiceButton> createState() => _PrintInvoiceButtonState();
}

class _PrintInvoiceButtonState extends State<PrintInvoiceButton> {
  final PdfService _pdfService = PdfService();
  bool _isLoading = false;

  Future<void> _handlePrint() async {
    setState(() => _isLoading = true);

    try {
      await _pdfService.printProjectInvoice(
        widget.project,
        widget.tasks,
        context.locale,
        currency: 'USD',
        showHourCost: true,
        showTaskType: true,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invoice sent to printer')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _isLoading ? null : _handlePrint,
      icon: _isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.print),
      label: Text(_isLoading ? 'Generating...' : 'Print Invoice'),
    );
  }
}

/// Widget example: PDF action menu
class PdfActionMenu extends StatelessWidget {
  final Project project;
  final List<ProjectTask> tasks;

  const PdfActionMenu({super.key, required this.project, required this.tasks});

  @override
  Widget build(BuildContext context) {
    final pdfService = PdfService();

    return PopupMenuButton<String>(
      icon: const Icon(Icons.picture_as_pdf),
      onSelected: (value) async {
        switch (value) {
          case 'print':
            await pdfService.printProjectInvoice(
              project,
              tasks,
              context.locale,
              currency: 'USD',
            );
            break;
          case 'preview':
            await pdfService.previewProjectInvoice(
              project,
              tasks,
              context.locale,
              currency: 'USD',
            );
            break;
          case 'share':
            await pdfService.shareProjectInvoice(
              project,
              tasks,
              context.locale,
              currency: 'USD',
            );
            break;
          case 'save':
            final fileName = 'Invoice_${project.name}.pdf';
            await pdfService.saveProjectInvoiceToFile(
              project,
              tasks,
              context.locale,
              '/Users/hany/Downloads/$fileName',
              currency: 'USD',
            );
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Invoice saved to Downloads')),
              );
            }
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'print',
          child: ListTile(
            leading: Icon(Icons.print),
            title: Text('Print'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuItem(
          value: 'preview',
          child: ListTile(
            leading: Icon(Icons.preview),
            title: Text('Preview'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuItem(
          value: 'share',
          child: ListTile(
            leading: Icon(Icons.share),
            title: Text('Share'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuItem(
          value: 'save',
          child: ListTile(
            leading: Icon(Icons.save),
            title: Text('Save to Downloads'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}
