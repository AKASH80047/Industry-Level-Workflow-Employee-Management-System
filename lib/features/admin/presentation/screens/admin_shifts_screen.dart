import 'package:flutter/material.dart';

class AdminShiftsScreen extends StatelessWidget {
  const AdminShiftsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Shifts'),
      ),
      body: const Center(
        child: Text('Shifts schedule list - Work in Progress'),
      ),
    );
  }
}
