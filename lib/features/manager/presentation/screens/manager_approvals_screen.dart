import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../leave/presentation/controllers/leave_providers.dart';
import '../../../regularization/presentation/controllers/regularization_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../../core/theme/app_theme.dart';

class ManagerApprovalsScreen extends ConsumerStatefulWidget {
  const ManagerApprovalsScreen({super.key});

  @override
  ConsumerState<ManagerApprovalsScreen> createState() => _ManagerApprovalsScreenState();
}

class _ManagerApprovalsScreenState extends ConsumerState<ManagerApprovalsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _remarksController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _actionLeave(String id, String status) async {
    final remarks = _remarksController.text.trim();
    if (status == 'rejected' && remarks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a rejection reason in the remarks field.')),
      );
      return;
    }

    try {
      final managerId = ref.read(currentUserIdProvider)!;
      await ref.read(leaveRepositoryProvider).updateLeaveRequestStatus(
            requestId: id,
            status: status,
            rejectionReason: remarks.isNotEmpty ? remarks : null,
            managerId: managerId,
          );
      _remarksController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Leave successfully $status.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Action failed: $e')),
        );
      }
    }
  }

  Future<void> _actionRegularization(String id, String status) async {
    final remarks = _remarksController.text.trim();
    if (status == 'rejected' && remarks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a rejection reason in the remarks.')),
      );
      return;
    }

    try {
      final managerId = ref.read(currentUserIdProvider)!;
      await ref.read(regularizationRepositoryProvider).updateRegularizationStatus(
            requestId: id,
            status: status,
            rejectionReason: remarks.isNotEmpty ? remarks : null,
            managerId: managerId,
          );
      _remarksController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Correction successfully $status.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Action failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final leavesAsync = ref.watch(managerLeaveRequestsProvider);
    final regularizationsAsync = ref.watch(managerRegularizationsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Center'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryColor,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(icon: Icon(Icons.beach_access_rounded), text: 'Leaves'),
            Tab(icon: Icon(Icons.edit_calendar_rounded), text: 'Corrections'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Leaves Tab
          leavesAsync.when(
            data: (requests) {
              if (requests.isEmpty) {
                return const Center(child: Text('No pending leave requests.'));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final req = requests[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Employee ID: ${req.employeeId.substring(0, 5).toUpperCase()}',
                                style: theme.textTheme.titleMedium,
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  req.leaveType.toUpperCase(),
                                  style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Period: ${DateFormat('dd MMM').format(req.startDate)} - ${DateFormat('dd MMM yyyy').format(req.endDate)} (${req.totalDays} Days)',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          Text('Reason: ${req.reason}', style: const TextStyle(color: Colors.grey)),
                          const Divider(height: 24),
                          
                          // Remarks Field
                          TextField(
                            controller: _remarksController,
                            decoration: const InputDecoration(
                              labelText: 'Manager Remarks / Audit Reason',
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton(
                                onPressed: () => _actionLeave(req.id, 'rejected'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.redAccent,
                                  side: const BorderSide(color: Colors.redAccent),
                                ),
                                child: const Text('Reject'),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: () => _actionLeave(req.id, 'approved'),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                child: const Text('Approve'),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error loading leaves: $err')),
          ),

          // Corrections Tab
          regularizationsAsync.when(
            data: (requests) {
              if (requests.isEmpty) {
                return const Center(child: Text('No pending correction requests.'));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final req = requests[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Employee ID: ${req.employeeId.substring(0, 5).toUpperCase()}',
                                style: theme.textTheme.titleMedium,
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  req.issueType.replaceAll('_', ' ').toUpperCase(),
                                  style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Date: ${req.dateKey.substring(6, 8)}/${req.dateKey.substring(4, 6)}/${req.dateKey.substring(0, 4)}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          if (req.requestedCheckIn != null)
                            Text('Req Check-In: ${DateFormat('hh:mm a').format(req.requestedCheckIn!)}'),
                          if (req.requestedCheckOut != null)
                            Text('Req Check-Out: ${DateFormat('hh:mm a').format(req.requestedCheckOut!)}'),
                          const SizedBox(height: 8),
                          Text('Justification: ${req.reason}', style: const TextStyle(color: Colors.grey)),
                          const Divider(height: 24),

                          // Remarks Field
                          TextField(
                            controller: _remarksController,
                            decoration: const InputDecoration(
                              labelText: 'Manager Remarks / Audit Reason',
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton(
                                onPressed: () => _actionRegularization(req.id, 'rejected'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.redAccent,
                                  side: const BorderSide(color: Colors.redAccent),
                                ),
                                child: const Text('Reject'),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: () => _actionRegularization(req.id, 'approved'),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                child: const Text('Approve'),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error loading corrections: $err')),
          ),
        ],
      ),
    );
  }
}
