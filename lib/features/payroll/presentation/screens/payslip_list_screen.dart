import 'package:flutter/material.dart';

class PayslipListScreen extends StatelessWidget {
  const PayslipListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Payslips'),
      ),
      body: const Center(
        child: Text('Payslip generation list - Work in Progress'),
      ),
    );
  }
}
