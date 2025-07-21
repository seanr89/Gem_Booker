import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../services/auth/auth_service.dart';

class CustomAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);

    return AppBar(
      title: const Text('Booker'),
      actions: [
        if (authState.value == null) ...[
          TextButton(
            onPressed: () => context.go('/login'),
            child: const Text('Login'),
          ),
          TextButton(
            onPressed: () => context.go('/signup'),
            child: const Text('Sign Up'),
          ),
        ] else ...[
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authServiceProvider).signOut();
            },
          ),
        ],
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
