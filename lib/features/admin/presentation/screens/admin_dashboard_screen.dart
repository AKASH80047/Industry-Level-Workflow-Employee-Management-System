import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../../app/router/route_constants.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Console'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              await ref.read(authRepositoryProvider).signOut();
              if (context.mounted) {
                context.go(RoutePaths.login);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('System Overview', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 16),

            // Overview Cards
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildSummaryCard('Total Workforce', '140', Icons.people_rounded, Colors.indigo),
                _buildSummaryCard('Present Today', '98', Icons.check_circle_rounded, Colors.green),
                _buildSummaryCard('Late Arrivals', '12', Icons.warning_amber_rounded, Colors.orange),
                _buildSummaryCard('Leave Absence', '6', Icons.info_outline_rounded, Colors.blue),
              ],
            ),
            const SizedBox(height: 32),

            Text('Administrative Core Modules', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 16),

            // Modules Menu list
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.badge_outlined, color: Colors.indigo),
                    title: const Text('Workforce Directories'),
                    subtitle: const Text('Manage employees details, roles & access'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push(RoutePaths.adminEmployees),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.map_outlined, color: Colors.blue),
                    title: const Text('Geofencing & Offices'),
                    subtitle: const Text('Configure offices and tracking radius'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push(RoutePaths.adminSettings), // Temp or settings
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.watch_later_outlined, color: Colors.amber),
                    title: const Text('Shift Scheduler'),
                    subtitle: const Text('Create shifts and roster hours'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push(RoutePaths.adminShifts),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.analytics_outlined, color: Colors.teal),
                    title: const Text('Analytics & Reports'),
                    subtitle: const Text('Generate CSV/Excel/PDF reports'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push(RoutePaths.adminReports),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.monetization_on_outlined, color: Colors.purple),
                    title: const Text('Payroll Console'),
                    subtitle: const Text('Review salary records and payslips'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push(RoutePaths.adminPayroll),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.history_edu_rounded, color: Colors.grey),
                    title: const Text('System Audit Logs'),
                    subtitle: const Text('Append-only records of administrator actions'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push(RoutePaths.adminAuditLogs),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                Icon(icon, color: color, size: 28),
              ],
            ),
            Text(title, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
