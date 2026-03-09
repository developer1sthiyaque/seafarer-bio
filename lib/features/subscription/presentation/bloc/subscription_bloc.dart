import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seafarer_bio_data/core/services/revenuecat_service.dart';
import '../../data/models/subscription_package.dart';
import 'subscription_event.dart';
import 'subscription_state.dart';

import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter/foundation.dart';

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final RevenueCatService _revenueCatService;

  SubscriptionBloc({required RevenueCatService revenueCatService})
      : _revenueCatService = revenueCatService,
        super(SubscriptionInitial()) {
    on<FetchPlans>(_onFetchPlans);
    on<PurchasePlan>(_onPurchasePlan);
    on<RestorePurchase>(_onRestorePurchase);
  }

  Future<void> _onFetchPlans(
    FetchPlans event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionLoading());
    try {
      final packages = await _revenueCatService.getOfferings();

      final plans = SubscriptionPackage.staticPlans.map((staticPlan) {
        Package? matchingPackage;
        try {
          if (staticPlan.id == 'weekly_plan') {
            matchingPackage =
                packages.firstWhere((p) => p.packageType == PackageType.weekly);
          } else if (staticPlan.id == 'monthly_plan') {
            matchingPackage = packages
                .firstWhere((p) => p.packageType == PackageType.monthly);
          } else if (staticPlan.id == 'yearly_plan') {
            matchingPackage =
                packages.firstWhere((p) => p.packageType == PackageType.annual);
          }
        } catch (_) {}

        if (matchingPackage != null) {
          return staticPlan.copyWith(
            price: matchingPackage.storeProduct.price,
            currency: matchingPackage.storeProduct.currencyCode,
            priceString: matchingPackage.storeProduct.priceString,
            rcPackage: matchingPackage,
          );
        }
        return staticPlan;
      }).toList();

      emit(PlansLoaded(plans));
    } catch (e) {
      debugPrint('Failed to fetch plans: $e');
      emit(PlansLoaded(SubscriptionPackage.staticPlans));
    }
  }

  Future<void> _onPurchasePlan(
    PurchasePlan event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionLoading());
    try {
      if (event.package.rcPackage != null) {
        final purchaseResult =
            await Purchases.purchasePackage(event.package.rcPackage!);
        final isPro =
            _revenueCatService.isProSubscriber(purchaseResult.customerInfo);

        if (isPro) {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            log("USER ID:${user.uid}");
            await FirebaseFirestore.instance
                .collection('profiles')
                .doc(user.uid)
                .set({'isPremium': true}, SetOptions(merge: true));
          }
          emit(SubscriptionActive(event.package));
        } else {
          emit(
              const SubscriptionError('Purchase did not unlock Pro features.'));
          add(FetchPlans());
        }
      } else {
        emit(const SubscriptionError(
            'RevenueCat package not found for this plan.'));
        add(FetchPlans());
      }
    } catch (e) {
      emit(SubscriptionError('Failed to purchase plan: $e'));
      add(FetchPlans());
    }
  }

  Future<void> _onRestorePurchase(
    RestorePurchase event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionLoading());
    try {
      final customerInfo = await Purchases.restorePurchases();
      final isPro = _revenueCatService.isProSubscriber(customerInfo);

      if (isPro) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('profiles')
              .doc(user.uid)
              .set({'isPremium': true}, SetOptions(merge: true));
        }
        emit(SubscriptionActive(SubscriptionPackage
            .staticPlans.last)); // Placeholder for active plan if needed
      } else {
        emit(const SubscriptionError(
            'No active subscriptions found to restore.'));
        add(FetchPlans());
      }
    } catch (e) {
      emit(SubscriptionError('Failed to restore purchases: $e'));
      add(FetchPlans());
    }
  }
}
