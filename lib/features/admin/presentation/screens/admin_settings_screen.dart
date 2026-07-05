import 'package:flutter/material.dart';

class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Company Settings'),
      ),
      body: const Center(
        child: Text('Offices, Geofence configuration, defaults - Work in Progress'),
      ),
    );
  }
}
