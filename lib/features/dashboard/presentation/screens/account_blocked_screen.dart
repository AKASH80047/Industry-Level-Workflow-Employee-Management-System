import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../../app/router/route_constants.dart';

class AccountBlockedScreen extends ConsumerWidget {
  const AccountBlockedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.block_flipped,
                size: 80,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 24),
              Text(
                'Account Suspended',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 12),
              const Text(
                'Your company account has been deactivated or blocked by the system administrator. Please contact your Human Resources department for reconciliation.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  ref.read(authRepositoryProvider).signOut();
                  context.go(RoutePaths.login);
                },
                icon: const Icon(Icons.logout),
                label: const Text('Return to Login'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
