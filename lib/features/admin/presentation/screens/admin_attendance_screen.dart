import 'package:flutter/material.dart';

class AdminAttendanceScreen extends StatelessWidget {
  const AdminAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workforce Attendance'),
      ),
      body: const Center(
        child: Text('Live & Historical Attendance Records - Work in Progress'),
      ),
    );
  }
}
