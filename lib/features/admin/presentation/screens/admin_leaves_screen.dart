import 'package:flutter/material.dart';

class AdminLeavesScreen extends StatelessWidget {
  const AdminLeavesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Leaves'),
      ),
      body: const Center(
        child: Text('Company-wide Leave Request Management - Work in Progress'),
      ),
    );
  }
}
