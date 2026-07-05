import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../attendance/presentation/controllers/attendance_providers.dart';
import '../../../../app/router/route_constants.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:intl/intl.dart';

class EmployeeDashboardScreen extends ConsumerWidget {
  const EmployeeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentUserProfileProvider);
    final attendanceAsync = ref.watch(todayAttendanceProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
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
      body: profileAsync.when(
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('Profile record not initialized.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome header
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                      backgroundImage: profile.profilePhotoUrl != null
                          ? NetworkImage(profile.profilePhotoUrl!)
                          : null,
                      child: profile.profilePhotoUrl == null
                          ? Text(
                              profile.fullName.substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome Back,',
                          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                        ),
                        Text(
                          '${profile.fullName} 👋',
                          style: theme.textTheme.headlineMedium,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Shift & Timing Dynamic Card
                attendanceAsync.when(
                  data: (attendance) {
                    final isCheckedIn = attendance?.checkIn != null;
                    final isCheckedOut = attendance?.checkOut != null;
                    final activeBreak = attendance?.breaks.cast<dynamic>().firstWhere(
                          (b) => b.endTime == null,
                          orElse: () => null,
                        );
                    final isOnBreak = activeBreak != null;

                    // Compute Status Text
                    String statusText = 'Not Checked In';
                    Color statusColor = AppTheme.statusLate;
                    if (isCheckedOut) {
                      statusText = 'Checked Out';
                      statusColor = AppTheme.statusPending;
                    } else if (isOnBreak) {
                      statusText = 'On Break';
                      statusColor = AppTheme.statusLeave;
                    } else if (isCheckedIn) {
                      statusText = 'Checked In';
                      statusColor = AppTheme.statusPresent;
                    }

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Shift Schedule', style: TextStyle(color: Colors.grey)),
                                    SizedBox(height: 4),
                                    Text(
                                      '09:30 AM – 06:30 PM',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    statusText,
                                    style: TextStyle(color: statusColor, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 32),
                            
                            // Break Timers and Log displays
                            if (isOnBreak) ...[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Break Duration (${activeBreak.breakType.toString().toUpperCase()})',
                                        style: const TextStyle(color: Colors.grey),
                                      ),
                                      const SizedBox(height: 4),
                                      Consumer(
                                        builder: (context, ref, child) {
                                          final seconds = ref.watch(activeBreakTimerProvider).value ?? 0;
                                          final mins = seconds ~/ 60;
                                          final secs = seconds % 60;
                                          return Text(
                                            '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}',
                                            style: theme.textTheme.headlineMedium?.copyWith(
                                              fontFamily: 'monospace',
                                              color: AppTheme.statusLeave,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      final dateKey = DateFormat('yyyyMMdd').format(DateTime.now());
                                      await ref.read(attendanceRepositoryProvider).endBreak(
                                            employeeId: profile.uid,
                                            dateKey: dateKey,
                                          );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.statusLate,
                                      minimumSize: const Size(130, 48),
                                    ),
                                    icon: const Icon(Icons.free_breakfast_rounded),
                                    label: const Text('End Break'),
                                  ),
                                ],
                              ),
                            ] else ...[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Current Time', style: TextStyle(color: Colors.grey)),
                                      const SizedBox(height: 4),
                                      StreamBuilder(
                                        stream: Stream.periodic(const Duration(seconds: 1)),
                                        builder: (context, snapshot) {
                                          return Text(
                                            DateFormat('hh:mm:ss a').format(DateTime.now()),
                                            style: theme.textTheme.headlineSmall?.copyWith(
                                              fontFamily: 'monospace',
                                              fontWeight: FontWeight.bold,
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  
                                  // Contextual Action Buttons
                                  if (!isCheckedIn)
                                    ElevatedButton.icon(
                                      onPressed: () => context.push(RoutePaths.employeePunch),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.primaryColor,
                                        minimumSize: const Size(130, 48),
                                      ),
                                      icon: const Icon(Icons.fingerprint_rounded),
                                      label: const Text('Check In'),
                                    )
                                  else if (!isCheckedOut)
                                    Row(
                                      children: [
                                        OutlinedButton.icon(
                                          onPressed: () {
                                            showModalBottomSheet(
                                              context: context,
                                              shape: const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                              ),
                                              builder: (context) {
                                                final dateKey = DateFormat('yyyyMMdd').format(DateTime.now());
                                                return Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 20.0),
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                                    children: [
                                                      Text(
                                                        'Select Break Type',
                                                        style: theme.textTheme.headlineMedium,
                                                        textAlign: TextAlign.center,
                                                      ),
                                                      const SizedBox(height: 20),
                                                      ListTile(
                                                        leading: const Icon(Icons.restaurant, color: Colors.orange),
                                                        title: const Text('Lunch Break'),
                                                        subtitle: const Text('Allow up to 45 mins'),
                                                        onTap: () async {
                                                          Navigator.pop(context);
                                                          await ref.read(attendanceRepositoryProvider).startBreak(
                                                                employeeId: profile.uid,
                                                                dateKey: dateKey,
                                                                breakType: 'lunch',
                                                              );
                                                        },
                                                      ),
                                                      ListTile(
                                                        leading: const Icon(Icons.coffee, color: Colors.brown),
                                                        title: const Text('Tea Break'),
                                                        subtitle: const Text('Allow up to 15 mins'),
                                                        onTap: () async {
                                                          Navigator.pop(context);
                                                          await ref.read(attendanceRepositoryProvider).startBreak(
                                                                employeeId: profile.uid,
                                                                dateKey: dateKey,
                                                                breakType: 'tea',
                                                              );
                                                        },
                                                      ),
                                                      ListTile(
                                                        leading: const Icon(Icons.timer_outlined, color: Colors.blue),
                                                        title: const Text('Custom Break'),
                                                        subtitle: const Text('Ad-hoc resting periods'),
                                                        onTap: () async {
                                                          Navigator.pop(context);
                                                          await ref.read(attendanceRepositoryProvider).startBreak(
                                                                employeeId: profile.uid,
                                                                dateKey: dateKey,
                                                                breakType: 'custom',
                                                              );
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                          style: OutlinedButton.styleFrom(
                                            minimumSize: const Size(100, 48),
                                            side: const BorderSide(color: AppTheme.primaryColor),
                                          ),
                                          icon: const Icon(Icons.coffee_outlined),
                                          label: const Text('Break'),
                                        ),
                                        const SizedBox(width: 8),
                                        ElevatedButton.icon(
                                          onPressed: () => context.push(RoutePaths.employeePunch), // Reuses same view to clock out
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.redAccent,
                                            minimumSize: const Size(110, 48),
                                          ),
                                          icon: const Icon(Icons.logout_rounded),
                                          label: const Text('Check Out'),
                                        ),
                                      ],
                                    )
                                  else
                                    const Text(
                                      'Completed Today 🎉',
                                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                                    ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                  loading: () => const Card(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
                  error: (err, stack) => Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text('Error loading today\'s logs: $err'),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Grid Actions
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildMenuCard(
                      context,
                      icon: Icons.date_range_rounded,
                      title: 'Leave Portal',
                      subtitle: 'Apply & Track Requests',
                      color: Colors.blue,
                      onTap: () => context.push(RoutePaths.employeeLeaves),
                    ),
                    _buildMenuCard(
                      context,
                      icon: Icons.history_toggle_off_rounded,
                      title: 'Attendance Logs',
                      subtitle: 'Punch Card History',
                      color: Colors.green,
                      onTap: () => context.push(RoutePaths.employeeHistory),
                    ),
                    _buildMenuCard(
                      context,
                      icon: Icons.receipt_long_rounded,
                      title: 'Payslips',
                      subtitle: 'Salary Statements',
                      color: Colors.purple,
                      onTap: () => context.push(RoutePaths.employeePayslips),
                    ),
                    _buildMenuCard(
                      context,
                      icon: Icons.person_outline_rounded,
                      title: 'My Profile',
                      subtitle: 'Job & Device Info',
                      color: Colors.orange,
                      onTap: () => context.push(RoutePaths.employeeProfile),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading profile: $err')),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
