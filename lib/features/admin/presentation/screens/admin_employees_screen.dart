import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firebase_collections.dart';
import '../../../../core/theme/app_theme.dart';

class AdminEmployeesScreen extends StatefulWidget {
  const AdminEmployeesScreen({super.key});

  @override
  State<AdminEmployeesScreen> createState() => _AdminEmployeesScreenState();
}

class _AdminEmployeesScreenState extends State<AdminEmployeesScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddEmployeeDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddEmployeeDialog(),
    );
  }

  Future<void> _toggleEmployeeStatus(String uid, bool currentActive) async {
    try {
      final batch = FirebaseFirestore.instance.batch();
      final userRef = FirebaseFirestore.instance.collection(FirebaseCollections.users).doc(uid);
      final empRef = FirebaseFirestore.instance.collection(FirebaseCollections.employees).doc(uid);

      batch.update(userRef, {
        'isActive': !currentActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      batch.update(empRef, {
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Employee profile status updated successfully.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed updating employee status: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Employees'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEmployeeDialog,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Search input bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by employee name or email...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.trim().toLowerCase();
                });
              },
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection(FirebaseCollections.employees).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Database error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data?.docs ?? [];
                
                // Client-side search filtering
                final filtered = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = (data['fullName'] as String? ?? '').toLowerCase();
                  final email = (data['email'] as String? ?? '').toLowerCase();
                  return name.contains(_searchQuery) || email.contains(_searchQuery);
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('No employees found.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final doc = filtered[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final uid = doc.id;
                    final name = data['fullName'] as String? ?? 'No Name';
                    final email = data['email'] as String? ?? '';
                    final empId = data['employeeId'] as String? ?? '';
                    final role = data['role'] as String? ?? 'employee';

                    return StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance.collection(FirebaseCollections.users).doc(uid).snapshots(),
                      builder: (context, userSnap) {
                        bool isActive = true;
                        if (userSnap.hasData && userSnap.data!.exists) {
                          final userData = userSnap.data!.data() as Map<String, dynamic>;
                          isActive = userData['isActive'] as bool? ?? true;
                        }

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                              child: Text(name.substring(0, 1).toUpperCase()),
                            ),
                            title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('ID: ${empId.toUpperCase()} • $email • ${role.toUpperCase()}'),
                            trailing: PopupMenuButton<String>(
                              onSelected: (action) {
                                if (action == 'toggle_active') {
                                  _toggleEmployeeStatus(uid, isActive);
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'toggle_active',
                                  child: Text(isActive ? 'Deactivate Employee' : 'Reactivate Employee'),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AddEmployeeDialog extends StatefulWidget {
  const AddEmployeeDialog({super.key});

  @override
  State<AddEmployeeDialog> createState() => _AddEmployeeDialogState();
}

class _AddEmployeeDialogState extends State<AddEmployeeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _empIdController = TextEditingController();
  final _salaryController = TextEditingController();

  String _employmentType = 'full_time';
  String _role = 'employee';
  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _empIdController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate User Creation in custom system (Writes records directly, let auth link later)
      final uid = 'emp_${DateTime.now().millisecondsSinceEpoch}'; // Temporary auth UID placeholder for manual entries
      final batch = FirebaseFirestore.instance.batch();

      final userRef = FirebaseFirestore.instance.collection(FirebaseCollections.users).doc(uid);
      final empRef = FirebaseFirestore.instance.collection(FirebaseCollections.employees).doc(uid);

      batch.set(userRef, {
        'uid': uid,
        'employeeId': _empIdController.text.trim(),
        'email': _emailController.text.trim(),
        'role': _role,
        'isActive': true,
        'isBlocked': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      batch.set(empRef, {
        'employeeId': _empIdController.text.trim(),
        'fullName': _fullNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'joiningDate': Timestamp.fromDate(DateTime.now()),
        'departmentId': 'engineering_hq',
        'designationId': 'engineer_01',
        'managerId': null,
        'shiftId': 'morning_std',
        'officeId': 'headquarters',
        'employmentType': _employmentType,
        'basicSalary': double.parse(_salaryController.text.trim()),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Employee profile created successfully.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Submission failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Employee Profile'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _empIdController,
                decoration: const InputDecoration(labelText: 'Employee ID (e.g. EMP101)'),
                validator: (val) => val == null || val.isEmpty ? 'Field required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (val) => val == null || val.isEmpty ? 'Field required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email Address'),
                validator: (val) => val == null || !val.contains('@') ? 'Invalid email' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                validator: (val) => val == null || val.isEmpty ? 'Field required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _salaryController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Basic Salary (Monthly)'),
                validator: (val) => val == null || double.tryParse(val) == null ? 'Invalid number' : null,
              ),
              const SizedBox(height: 16),
              
              // Employment Type Dropdown
              DropdownButtonFormField<String>(
                initialValue: _employmentType,
                decoration: const InputDecoration(labelText: 'Employment Type'),
                items: const [
                  DropdownMenuItem(value: 'full_time', child: Text('Full-Time')),
                  DropdownMenuItem(value: 'part_time', child: Text('Part-Time')),
                  DropdownMenuItem(value: 'intern', child: Text('Internship')),
                  DropdownMenuItem(value: 'contract', child: Text('Contractor')),
                ],
                onChanged: (val) => setState(() => _employmentType = val!),
              ),
              const SizedBox(height: 16),

              // Role Dropdown
              DropdownButtonFormField<String>(
                initialValue: _role,
                decoration: const InputDecoration(labelText: 'System Access Role'),
                items: const [
                  DropdownMenuItem(value: 'employee', child: Text('Employee')),
                  DropdownMenuItem(value: 'manager', child: Text('Manager')),
                  DropdownMenuItem(value: 'admin', child: Text('Administrator')),
                ],
                onChanged: (val) => setState(() => _role = val!),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
          child: _isLoading ? const CircularProgressIndicator() : const Text('Register'),
        ),
      ],
    );
  }
}
