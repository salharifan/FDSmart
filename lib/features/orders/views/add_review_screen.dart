import 'package:fdsmart/core/theme/app_colors.dart';
import 'package:fdsmart/core/widgets/app_header.dart';
import 'package:fdsmart/core/widgets/custom_button.dart';
import 'package:fdsmart/features/auth/viewmodels/auth_view_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddReviewScreen extends StatefulWidget {
  final String orderId;
  const AddReviewScreen({super.key, required this.orderId});

  @override
  State<AddReviewScreen> createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  final TextEditingController _reviewController = TextEditingController();
  final TextEditingController _imageLinkController = TextEditingController();
  double _rating = 5.0;
  bool _isSubmitting = false;

  void _submitReview() async {
    if (_reviewController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please write some text for the review")),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final user = Provider.of<AuthViewModel>(context, listen: false).currentUser;

    try {
      await FirebaseFirestore.instance.collection('reviews').add({
        'userId': user?.uid,
        'userName': user?.name ?? 'Anonymous',
        'orderId': widget.orderId,
        'rating': _rating.toString(),
        'text': _reviewController.text,
        'imageUrl': _imageLinkController.text.isNotEmpty
            ? _imageLinkController.text
            : null,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Review submitted! Thank you.")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error submitting review: $e")));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Review Your Food",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Tell us what you think about your order.",
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 32),

                    const Text(
                      "Rating",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Slider(
                      value: _rating,
                      min: 1,
                      max: 5,
                      divisions: 4,
                      label: _rating.toString(),
                      onChanged: (val) => setState(() => _rating = val),
                      activeColor: AppColors.primary,
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      "Description",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _reviewController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: "How was the taste, quality, packaging?",
                        fillColor: AppColors.surfaceLight,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      "Add Picture (Image URL)",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _imageLinkController,
                      decoration: InputDecoration(
                        hintText: "Paste an image link here",
                        fillColor: AppColors.surfaceLight,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    CustomButton(
                      text: "SUBMIT REVIEW",
                      isLoading: _isSubmitting,
                      onPressed: _submitReview,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
