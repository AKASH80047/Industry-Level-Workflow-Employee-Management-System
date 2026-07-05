import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../../app/router/route_constants.dart';
import '../../../../core/theme/app_theme.dart';

class ManagerDashboardScreen extends ConsumerWidget {
  const ManagerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manager Console'),
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
            Text('Team Summary Today', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 16),
            
            // Stats Grid
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    title: 'Present',
                    value: '12',
                    color: AppTheme.statusPresent,
                    icon: Icons.check_circle_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    title: 'Late',
                    value: '3',
                    color: AppTheme.statusLate,
                    icon: Icons.timer_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    title: 'On Leave',
                    value: '2',
                    color: AppTheme.statusLeave,
                    icon: Icons.calendar_today_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Pending tasks notification card
            Card(
              color: AppTheme.primaryColor.withValues(alpha: 0.05),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: AppTheme.primaryColor.withValues(alpha: 0.15)),
              ),
              child: ListTile(
                leading: const Icon(Icons.pending_actions_rounded, color: AppTheme.primaryColor, size: 36),
                title: const Text('Approvals Pending', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('You have 3 leave applications and 1 correction request waiting for response.'),
                trailing: TextButton(
                  onPressed: () => context.push(RoutePaths.managerApprovals),
                  child: const Text('Review Now'),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Text('Management Directories', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 16),

            // List of sections
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.people_outline_rounded, color: Colors.blue),
                    title: const Text('My Team Members'),
                    subtitle: const Text('View and manage team profiles'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push(RoutePaths.managerTeam),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.approval_rounded, color: Colors.indigo),
                    title: const Text('Review Center'),
                    subtitle: const Text('Approve leaves and corrections'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push(RoutePaths.managerApprovals),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(value, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(title, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
