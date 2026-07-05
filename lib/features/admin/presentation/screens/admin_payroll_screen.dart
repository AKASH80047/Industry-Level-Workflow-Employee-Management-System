import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../payroll/domain/services/payroll_calculator.dart';
import '../../../../core/constants/firebase_collections.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/report_export_service.dart';

class AdminPayrollScreen extends StatefulWidget {
  const AdminPayrollScreen({super.key});

  @override
  State<AdminPayrollScreen> createState() => _AdminPayrollScreenState();
}

class _AdminPayrollScreenState extends State<AdminPayrollScreen> {
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;
  bool _isProcessing = false;

  final List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  Future<void> _runPayrollBatch() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final firestore = FirebaseFirestore.instance;
      final employeesSnap = await firestore.collection(FirebaseCollections.employees).get();
      
      if (employeesSnap.docs.isEmpty) {
        throw Exception('No employee profiles found in the registry to run payroll against.');
      }

      final batch = firestore.batch();
      double totalPayout = 0.0;

      for (var empDoc in employeesSnap.docs) {
        final empData = empDoc.data();
        final uid = empDoc.id;
        final basicSalary = (empData['basicSalary'] as num?)?.toDouble() ?? 25000.0;
        final allowance = (empData['allowance'] as num?)?.toDouble() ?? 2000.0;

        // Apply calculator with mock values for logs (In production, count from attendance/leave streams)
        final result = PayrollCalculator.calculate(
          basicSalary: basicSalary,
          allowance: allowance,
          workingDaysInMonth: 26,
          presentDays: 24,
          paidLeavesUsed: 1.0,
          unpaidLeavesUsed: 1.0,
          overtimeMinutes: 240, // 4 hours
          totalLateArrivals: 2,
        );

        final payslipId = '${uid}_${_selectedYear}_$_selectedMonth';
        final payslipRef = firestore.collection(FirebaseCollections.payslips).doc(payslipId);

        batch.set(payslipRef, {
          'id': payslipId,
          'employeeId': uid,
          'year': _selectedYear,
          'month': _selectedMonth,
          'basicSalary': result.basicSalary,
          'overtimePay': result.overtimePay,
          'bonus': result.bonus,
          'lateDeduction': result.lateDeduction,
          'unpaidLeaveDeduction': result.unpaidLeaveDeduction,
          'grossSalary': result.grossSalary,
          'netSalary': result.netSalary,
          'workingDays': 26,
          'presentDays': 24,
          'absentDays': 1,
          'approvedLeaves': 1.0,
          'pdfUrl': 'compiled_system_pdf',
          'createdAt': FieldValue.serverTimestamp(),
        });

        totalPayout += result.netSalary;
      }

      // Record Global Run
      final payrollId = '${_selectedYear}_$_selectedMonth';
      final payrollRef = firestore.collection(FirebaseCollections.payroll).doc(payrollId);
      
      batch.set(payrollRef, {
        'id': payrollId,
        'year': _selectedYear,
        'month': _selectedMonth,
        'status': 'approved',
        'generatedBy': 'admin_console',
        'generatedAt': FieldValue.serverTimestamp(),
        'totalPayout': totalPayout,
      });

      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Payroll batch processed successfully!\n'
              'Total payslips compiled: ${employeesSnap.docs.length}. Total Payout: ₹${totalPayout.toStringAsFixed(2)}',
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payroll run aborted: ${e.toString().replaceAll('Exception: ', '')}')),
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

  Future<void> _generatePayslipPDF() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final headers = ['Earnings Category', 'Amount (₹)', 'Deductions Category', 'Amount (₹)'];
      final rows = [
        ['Basic Salary', '25,000.00', 'Late Deduction', '200.00'],
        ['House Rent Allowance', '2,000.00', 'Unpaid Leave Cost', '961.54'],
        ['Overtime Incentives', '600.00', 'Income Tax W/H', '0.00'],
        ['Gross Earnings', '27,600.00', 'Total Deductions', '1,161.54'],
        ['NET PAYOUT', '₹26,438.46', '', ''],
      ];

      final file = await ReportExportService.generatePDF(
        title: 'PAYSLIP: Employee EMP001 (${_months[_selectedMonth - 1]} $_selectedYear)',
        headers: headers,
        rows: rows,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Demo PDF Payslip dispatched: ${file.path}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed compilation: $e')),
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
        title: const Text('Payroll Ledger'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.monetization_on_outlined, size: 64, color: AppTheme.primaryColor),
            const SizedBox(height: 16),
            Text(
              'Salary Disbursements',
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
                    const Text('Select Period', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            initialValue: _selectedMonth,
                            decoration: const InputDecoration(labelText: 'Month'),
                            items: List.generate(12, (index) => DropdownMenuItem(
                              value: index + 1,
                              child: Text(_months[index]),
                            )),
                            onChanged: (val) => setState(() => _selectedMonth = val!),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            initialValue: _selectedYear,
                            decoration: const InputDecoration(labelText: 'Year'),
                            items: [2026, 2027].map((y) => DropdownMenuItem(
                              value: y,
                              child: Text(y.toString()),
                            )).toList(),
                            onChanged: (val) => setState(() => _selectedYear = val!),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 48),

                    if (_isProcessing)
                      const Center(child: CircularProgressIndicator())
                    else ...[
                      ElevatedButton.icon(
                        onPressed: _runPayrollBatch,
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
                        icon: const Icon(Icons.run_circle_outlined),
                        label: const Text('Execute Monthly Payroll Run'),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _generatePayslipPDF,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryColor,
                          side: const BorderSide(color: AppTheme.primaryColor),
                        ),
                        icon: const Icon(Icons.picture_as_pdf_outlined),
                        label: const Text('Download Sample Payslip PDF'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
