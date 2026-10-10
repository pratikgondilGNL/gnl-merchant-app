import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../domain/models/subscription_plan.dart';

class SelectSubscriptionScreen extends StatefulWidget {
  const SelectSubscriptionScreen({super.key});

  @override
  State<SelectSubscriptionScreen> createState() =>
      _SelectSubscriptionScreenState();
}

class _SelectSubscriptionScreenState
    extends State<SelectSubscriptionScreen> {
  SubscriptionPlan selectedPlan = SubscriptionPlanX.professional;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
        title: const Text(
          "Choose Your Plan",
          style: TextStyle(color: AppColors.textPrimary),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Select Subscription",
                    style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Choose the plan that suits your needs",
                  style: TextStyle(color: AppColors.hint, fontSize: 12),
                  ),
                  const SizedBox(height: 20),
                  ...SubscriptionPlanX.all.map(_planCard),
                  const SizedBox(height: 10),
                  const Text(
                    "30-day money-back guarantee\nCancel anytime, no questions asked",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.hint, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
          _bottomBar(),
        ],
      ),
    );
  }

  Widget _planCard(SubscriptionPlan plan) {
    final isSelected = selectedPlan == plan;

    return GestureDetector(
      onTap: () => setState(() => selectedPlan = plan),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primaryDark : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.flash_on,
                  color: isSelected ? AppColors.primaryDark : AppColors.hint,
                ),
                const SizedBox(width: 8),
                Text(
                  plan.title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (plan.isHighlighted)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Most Popular",
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 10),
                    ),
                  ),
                const SizedBox(width: 6),
                Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: AppColors.primaryDark,
                ),
              ],
            ),
            const SizedBox(height: 10),
            RichText(
              text: TextSpan(
                text: plan.price,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                children: const [
                  TextSpan(
                    text: " /month",
                    style: TextStyle(color: AppColors.hint, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ...plan.features.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(Icons.check, color: AppColors.primaryDark, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        e,
                        style: const TextStyle(
                          color: AppColors.hint,
                          fontSize: 12,
                        ),
                      ),
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

  Widget _bottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.card)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Selected Plan",
            style: TextStyle(color: AppColors.hint, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            "${selectedPlan.title} - ${selectedPlan.price}/mo",
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {},
              child: const Text(
                "Continue to Payment",
                style: TextStyle(color: AppColors.textPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
