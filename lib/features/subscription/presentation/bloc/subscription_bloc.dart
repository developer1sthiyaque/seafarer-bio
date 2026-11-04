import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:seafarer_bio_data/core/constants/payment_constants.dart';
import 'package:seafarer_bio_data/core/services/revenuecat_service.dart';
import '../../data/models/subscription_package.dart';
import 'subscription_event.dart';
import 'subscription_state.dart';

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final RevenueCatService _revenueCatService;
  StreamSubscription<CustomerInfo>? _customerInfoSubscription;

  SubscriptionBloc({required RevenueCatService revenueCatService})
      : _revenueCatService = revenueCatService,
        super(SubscriptionInitial()) {
    on<FetchPlans>(_onFetchPlans);
    on<PurchasePlanRequested>(_onPurchasePlanRequested);
    on<RestorePurchase>(_onRestorePurchase);
    on<ResetSubscriptionState>(_onResetSubscriptionState);
    on<CustomerInfoUpdated>(_onCustomerInfoUpdated);

    _customerInfoSubscription =
        _revenueCatService.customerInfoStream.listen((customerInfo) {
      add(CustomerInfoUpdated(customerInfo));
    });
  }

  @override
  Future<void> close() {
    _customerInfoSubscription?.cancel();
    return super.close();
  }

  void _onResetSubscriptionState(
    ResetSubscriptionState event,
    Emitter<SubscriptionState> emit,
  ) {
    emit(SubscriptionInitial());
  }

  void _applyCustomerInfo(
    CustomerInfo? customerInfo,
    Emitter<SubscriptionState> emit, {
    SubscriptionPackage? purchasedPackage,
  }) {
    final active = customerInfo?.entitlements.active;
    final isPro = (active != null &&
            active.containsKey(PaymentConstants.kProEntitlementId) &&
            (active[PaymentConstants.kProEntitlementId]?.isActive ?? false)) ||
        _revenueCatService.isProSubscriber(customerInfo);

    if (isPro) {
      final planToEmit =
          purchasedPackage ?? SubscriptionPackage.staticPlans.first;
      if (state is! SubscriptionActive) {
        emit(SubscriptionActive(planToEmit));
      }
    } else {
      if (state is SubscriptionActive) {
        add(FetchPlans());
      }
    }
  }

  Future<void> _onCustomerInfoUpdated(
    CustomerInfoUpdated event,
    Emitter<SubscriptionState> emit,
  ) async {
    _applyCustomerInfo(event.customerInfo, emit);
  }

  Future<void> _onFetchPlans(
    FetchPlans event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionLoading());
    try {
      final customerInfo = await _revenueCatService.getCustomerInfo();
      final active = customerInfo?.entitlements.active;
      final isPro = (active != null &&
              active.containsKey(PaymentConstants.kProEntitlementId) &&
              (active[PaymentConstants.kProEntitlementId]?.isActive ?? false)) ||
          _revenueCatService.isProSubscriber(customerInfo);

      if (isPro) {
        emit(SubscriptionActive(SubscriptionPackage.staticPlans.first));
        return;
      }

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

  Future<void> _onPurchasePlanRequested(
    PurchasePlanRequested event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionLoading());
    try {
      if (event.package.rcPackage == null) {
        emit(
          const SubscriptionError('RevenueCat package not found for this plan.'),
        );
        add(FetchPlans());
        return;
      }

      // Ensure user ID is bound before purchase
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null && currentUser.uid.isNotEmpty) {
        debugPrint(
            '🔑 [SubscriptionBloc] Ensuring identified user before purchase: ${currentUser.uid}');
        await _revenueCatService.logIn(currentUser.uid);
      }

      await _revenueCatService.purchasePackage(
        event.package.rcPackage!,
      );

      // Transition to verifying state to avoid optimistic offline entitlement flicker
      emit(const SubscriptionVerifying('Verifying purchase with store...'));

      bool verified = false;
      CustomerInfo? verifiedInfo;

      for (int attempt = 1; attempt <= 3; attempt++) {
        await Future.delayed(Duration(milliseconds: 1000 * attempt));
        try {
          await Purchases.syncPurchases();
        } catch (_) {}
        verifiedInfo = await _revenueCatService.getCustomerInfo();
        final active = verifiedInfo?.entitlements.active;
        if (active != null &&
            active.containsKey(PaymentConstants.kProEntitlementId) &&
            (active[PaymentConstants.kProEntitlementId]?.isActive ?? false)) {
          verified = true;
          break;
        }
      }

      if (verified && verifiedInfo != null) {
        _applyCustomerInfo(
          verifiedInfo,
          emit,
          purchasedPackage: event.package,
        );
      } else {
        emit(
          const SubscriptionError(
            'Purchase could not be verified by the store. Please tap "Restore Purchases" if charged.',
          ),
        );
        add(FetchPlans());
      }
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        add(FetchPlans());
        return;
      }
      emit(SubscriptionError('Failed to purchase plan: ${e.message ?? e.code}'));
      add(FetchPlans());
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
      final customerInfo = await _revenueCatService.restorePurchases();
      final active = customerInfo?.entitlements.active;
      final isPro = active != null &&
          active.containsKey(PaymentConstants.kProEntitlementId) &&
          (active[PaymentConstants.kProEntitlementId]?.isActive ?? false);

      if (isPro && customerInfo != null) {
        _applyCustomerInfo(customerInfo, emit);
      } else {
        emit(
          const SubscriptionError('No active subscriptions found to restore.'),
        );
        add(FetchPlans());
      }
    } catch (e) {
      emit(SubscriptionError('Failed to restore purchases: $e'));
      add(FetchPlans());
    }
  }
}
