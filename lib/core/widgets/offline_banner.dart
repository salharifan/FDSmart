import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fdsmart/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ConnectivityResult>>(
      stream: Connectivity().onConnectivityChanged,
      builder: (context, snapshot) {
        // Default to assuming online if no data yet, or check initial state properly
        // For simplicity in this stream builder:
        final results = snapshot.data;
        bool isOffline =
            results != null && results.contains(ConnectivityResult.none);

        if (!isOffline) return const SizedBox.shrink();

        return Container(
          color: AppColors.error,
          padding: const EdgeInsets.symmetric(vertical: 8),
          width: double.infinity,
          child: const Text(
            "You are offline. Showing cached data.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }
}
