import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/services/report_export_service.dart';
import '../../../../core/constants/firebase_collections.dart';
import '../../../../core/theme/app_theme.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  String _selectedReportType = 'attendance_summary';
  bool _isProcessing = false;

  final List<String> _headers = ['Employee ID', 'Date', 'Shift ID', 'Status', 'Gross Mins', 'Net Mins', 'Overtime Mins'];

  Future<void> _exportReport(String format) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // 1. Fetch attendance records from database
      final querySnapshot = await FirebaseFirestore.instance
          .collection(FirebaseCollections.attendance)
          .orderBy('dateKey', descending: true)
          .limit(50)
          .get();

      final List<List<dynamic>> rawRows = [];
      final List<List<String>> stringRows = [];

      if (querySnapshot.docs.isEmpty) {
        // If empty, generate high-quality mock data for testing/demo
        final mockData = [
          ['EMP001', '20260701', 'morning_std', 'present', '540', '480', '0'],
          ['EMP002', '20260701', 'morning_std', 'late', '510', '450', '0'],
          ['EMP003', '20260701', 'morning_std', 'present', '600', '540', '60'],
          ['EMP004', '20260701', 'morning_std', 'half_day', '230', '200', '0'],
          ['EMP001', '20260702', 'morning_std', 'present', '540', '480', '0'],
        ];
        
        for (var row in mockData) {
          rawRows.add(row);
          stringRows.add(row.map((e) => e.toString()).toList());
        }
      } else {
        for (var doc in querySnapshot.docs) {
          final data = doc.data();
          final row = [
            (data['employeeId'] as String? ?? '').substring(0, 5).toUpperCase(),
            data['dateKey'] as String? ?? '',
            data['shiftId'] as String? ?? '',
            data['status'] as String? ?? 'absent',
            (data['grossDurationMinutes'] ?? 0).toString(),
            (data['netWorkingMinutes'] ?? 0).toString(),
            (data['overtimeMinutes'] ?? 0).toString(),
          ];
          rawRows.add(row);
          stringRows.add(row.map((e) => e.toString()).toList());
        }
      }

      // 2. Export based on format
      if (format == 'csv') {
        final csvString = ReportExportService.generateCSV(headers: _headers, rows: rawRows);
        // Show success sheet containing CSV
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('CSV Export Created'),
              content: SingleChildScrollView(
                child: Text(
                  csvString,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        }
      } else if (format == 'pdf') {
        final file = await ReportExportService.generatePDF(
          title: 'Workforce Attendance Report',
          headers: _headers,
          rows: stringRows,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('PDF compiled and saved successfully: ${file.path}'),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports Center'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.analytics_outlined, size: 64, color: AppTheme.primaryColor),
            const SizedBox(height: 16),
            Text(
              'Compile Enterprise Analytics',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Select Report Category', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedReportType,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'attendance_summary', child: Text('Attendance Log Summary')),
                        DropdownMenuItem(value: 'overtime_ledger', child: Text('Accumulated Overtime Ledger')),
                        DropdownMenuItem(value: 'leave_balances', child: Text('Accrued Leave Consumptions')),
                      ],
                      onChanged: (val) => setState(() => _selectedReportType = val!),
                    ),
                    const Divider(height: 48),

                    if (_isProcessing)
                      const Center(child: CircularProgressIndicator())
                    else ...[
                      ElevatedButton.icon(
                        onPressed: () => _exportReport('pdf'),
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
                        icon: const Icon(Icons.picture_as_pdf_rounded),
                        label: const Text('Compile Print-Ready PDF'),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => _exportReport('csv'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryColor,
                          side: const BorderSide(color: AppTheme.primaryColor),
                        ),
                        icon: const Icon(Icons.table_rows_rounded),
                        label: const Text('Compile Spreadsheet CSV'),
                      ),
                    ],
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
