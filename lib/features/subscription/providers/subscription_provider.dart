import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/subscription_plan.dart';

class SubscriptionState {
  final SubscriptionPlan selectedPlan;
  final bool isLoading;

  const SubscriptionState({
    this.selectedPlan = const SubscriptionPlan(type: PlanType.professional, title: 'Professional', price: '₹7,999', features: [
      'Unlimited bookings',
      'Advanced analytics',
      'Priority support 24/7',
      'QR code scanner',
      'Up to 3 venues',
      'Custom branding',
    ], isHighlighted: true),
    this.isLoading = false,
  });

  SubscriptionState copyWith({
    SubscriptionPlan? selectedPlan,
    bool? isLoading,
  }) {
    return SubscriptionState(
      selectedPlan: selectedPlan ?? this.selectedPlan,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  SubscriptionNotifier() : super(const SubscriptionState());

  void selectPlan(SubscriptionPlan plan) {
    state = state.copyWith(selectedPlan: plan);
  }
}

final subscriptionProvider =
    StateNotifierProvider<SubscriptionNotifier, SubscriptionState>((ref) {
  return SubscriptionNotifier();
});
