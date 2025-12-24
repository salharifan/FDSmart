import 'package:flutter/material.dart';
import 'package:fdsmart/features/auth/viewmodels/auth_view_model.dart';
import 'package:provider/provider.dart';

class AppHeader extends StatelessWidget {
  final bool showBack;
  final VoidCallback? onBack;

  const AppHeader({super.key, this.showBack = false, this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFFF8F9FA), // Off-white
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          if (showBack || Navigator.canPop(context))
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFF333333), // Dark grey
                  size: 20,
                ),
                onPressed: onBack ?? () => Navigator.pop(context),
              ),
            ),
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: const DecorationImage(
                image: AssetImage('assets/images/logo.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Text(
                    'FDSmart',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF222222), // Near black
                    ),
                  ),
                  const SizedBox(width: 8),
                  Consumer<AuthViewModel>(
                    builder: (context, auth, child) {
                      final role = auth.currentUser?.role;
                      if (role == null) return const SizedBox.shrink();
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: role == 'admin' ? Colors.red : Colors.blue,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          role.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              Text(
                'Healthier Choices, Smarter Orders',
                style: TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: Color(0xFF666666), // Medium grey
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
