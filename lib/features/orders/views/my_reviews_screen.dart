import 'package:fdsmart/core/theme/app_colors.dart';
import 'package:fdsmart/core/widgets/app_header.dart';
import 'package:fdsmart/features/auth/viewmodels/auth_view_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fdsmart/features/orders/views/order_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class MyReviewsScreen extends StatelessWidget {
  const MyReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthViewModel>(context).currentUser;

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
                    "My Reviews",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Select a completed order from your history to add a review.",
                          ),
                        ),
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const OrderHistoryScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text("Add Review"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: user == null
                  ? const Center(child: Text("Please login"))
                  : StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('reviews')
                          .where('userId', isEqualTo: user.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Text("Error: ${snapshot.error}"),
                          );
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        // Sort locally to avoid Firebase index requirement
                        final docs = snapshot.data?.docs ?? [];
                        final sortedDocs = List<DocumentSnapshot>.from(docs)
                          ..sort((a, b) {
                            final aTS =
                                (a.data() as Map<String, dynamic>)['createdAt']
                                    as Timestamp?;
                            final bTS =
                                (b.data() as Map<String, dynamic>)['createdAt']
                                    as Timestamp?;
                            if (aTS == null) return 1;
                            if (bTS == null) return -1;
                            return bTS.compareTo(aTS);
                          });

                        if (sortedDocs.isEmpty) {
                          return const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.rate_review_outlined,
                                  size: 64,
                                  color: AppColors.textSecondary,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  "No reviews yet",
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: sortedDocs.length,
                          separatorBuilder: (c, i) =>
                              const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final data =
                                sortedDocs[index].data()
                                    as Map<String, dynamic>;
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: List.generate(5, (i) {
                                          double rate =
                                              double.tryParse(
                                                data['rating'].toString(),
                                              ) ??
                                              0;
                                          return Icon(
                                            i < rate.floor()
                                                ? Icons.star_rounded
                                                : Icons.star_outline_rounded,
                                            color: Colors.orange,
                                            size: 18,
                                          );
                                        }),
                                      ),
                                      Text(
                                        data['createdAt'] != null
                                            ? DateFormat('MMM dd, yyyy').format(
                                                (data['createdAt'] as Timestamp)
                                                    .toDate(),
                                              )
                                            : "",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    data['text'] ?? "",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  if (data['imageUrl'] != null) ...[
                                    const SizedBox(height: 12),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        data['imageUrl'],
                                        height: 150,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (c, e, s) =>
                                            const SizedBox.shrink(),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          },
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
