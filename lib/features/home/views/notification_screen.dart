import 'package:fdsmart/core/theme/app_colors.dart';
import 'package:fdsmart/core/widgets/app_header.dart';
import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock notifications for now
    final notifications = [
      {
        'title': 'Order Ready!',
        'body': 'Your Token #104 is ready for pickup at the counter.',
        'time': '2 mins ago',
        'isNew': true,
      },
      {
        'title': 'New Special Offer',
        'body': 'Buy 1 Get 1 free on all Cool Drinks today!',
        'time': '1 hour ago',
        'isNew': true,
      },
      {
        'title': 'Payment Confirmed',
        'body': 'Your payment of Rs. 450 has been confirmed.',
        'time': '3 hours ago',
        'isNew': false,
      },
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Notifications",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  if (notifications.any((n) => n['isNew'] as bool))
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "NEW",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: notifications.isEmpty
                  ? const Center(child: Text("No notifications yet"))
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: notifications.length,
                      separatorBuilder: (c, i) =>
                          const Divider(color: Colors.white10),
                      itemBuilder: (context, index) {
                        final note = notifications[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.all(8),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: (note['isNew'] as bool)
                                  ? AppColors.primary.withOpacity(0.1)
                                  : AppColors.surfaceLight,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.notifications_active_rounded,
                              color: (note['isNew'] as bool)
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                          ),
                          title: Text(
                            note['title'] as String,
                            style: TextStyle(
                              fontWeight: (note['isNew'] as bool)
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                note['body'] as String,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                note['time'] as String,
                                style: TextStyle(
                                  color: AppColors.textSecondary.withOpacity(
                                    0.6,
                                  ),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
