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
    EntitlementInfos? entitlements;
    try {
      entitlements = customerInfo?.entitlements;
    } catch (_) {}
    final active = entitlements?.active;
    final isPro = (active != null &&
            active.containsKey(PaymentConstants.kProEntitlementId) &&
            (active[PaymentConstants.kProEntitlementId]?.isActive ?? false)) ||
        _revenueCatService.isProSubscriber(customerInfo);

    final currentOfferings = state.offerings;

    if (isPro) {
      DateTime? expDate;
      final proEntitlement = active?[PaymentConstants.kProEntitlementId];
      if (proEntitlement?.expirationDate != null) {
        expDate = DateTime.tryParse(proEntitlement!.expirationDate!);
      }

      final planToEmit =
          purchasedPackage ??
          (currentOfferings.isNotEmpty
              ? currentOfferings.first
              : SubscriptionPackage.staticPlans.first);
      if (state is! SubscriptionActive) {
        emit(SubscriptionActive(
          planToEmit,
          expirationDate: expDate,
          offerings: currentOfferings,
        ));
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
    emit(SubscriptionLoading(offerings: state.offerings));
    try {
      await _revenueCatService.invalidateCustomerInfoCache();
      final customerInfo = await _revenueCatService.getCustomerInfo();
      EntitlementInfos? entitlements;
      try {
        entitlements = customerInfo?.entitlements;
      } catch (_) {}
      final active = entitlements?.active;
      final isPro = (active != null &&
              active.containsKey(PaymentConstants.kProEntitlementId) &&
              (active[PaymentConstants.kProEntitlementId]?.isActive ?? false)) ||
          _revenueCatService.isProSubscriber(customerInfo);

      DateTime? expDate;
      final proEntitlement = active?[PaymentConstants.kProEntitlementId];
      if (proEntitlement?.expirationDate != null) {
        expDate = DateTime.tryParse(proEntitlement!.expirationDate!);
      }
      final isExpired = expDate != null && expDate.isBefore(DateTime.now());

      // Fetch live offerings
      List<Package> packages = [];
      try {
        packages = await _revenueCatService.getOfferings();
      } catch (e) {
        debugPrint('⚠️ [SubscriptionBloc] Error fetching offerings: $e');
        if (isPro && !isExpired) {
          emit(SubscriptionActive(
            SubscriptionPackage.staticPlans.first,
            expirationDate: expDate,
            offerings: state.offerings,
          ));
          return;
        }
        emit(SubscriptionError(
          'Failed to load subscription plans: $e',
          offerings: state.offerings,
        ));
        return;
      }

      List<SubscriptionPackage> plans = [];
      if (packages.isNotEmpty) {
        plans = SubscriptionPackage.staticPlans.map((staticPlan) {
          Package? matchingPackage;
          try {
            if (staticPlan.id == 'weekly_plan') {
              matchingPackage = packages.firstWhere(
                (p) =>
                    p.packageType == PackageType.weekly ||
                    p.identifier.toLowerCase().contains('weekly'),
              );
            } else if (staticPlan.id == 'monthly_plan') {
              matchingPackage = packages.firstWhere(
                (p) =>
                    p.packageType == PackageType.monthly ||
                    p.identifier.toLowerCase().contains('monthly'),
              );
            } else if (staticPlan.id == 'yearly_plan') {
              matchingPackage = packages.firstWhere(
                (p) =>
                    p.packageType == PackageType.annual ||
                    p.identifier.toLowerCase().contains('yearly') ||
                    p.identifier.toLowerCase().contains('annual'),
              );
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
      }

      if (isPro && !isExpired) {
        emit(SubscriptionActive(
          SubscriptionPackage.staticPlans.first,
          expirationDate: expDate,
          offerings: plans.isNotEmpty ? plans : state.offerings,
        ));
        return;
      }

      if (plans.isEmpty || packages.isEmpty) {
        debugPrint('⚠️ [SubscriptionBloc] Offerings packages are empty');
        emit(SubscriptionError(
          'No subscription plans available at this time. Please try again later.',
          offerings: state.offerings,
        ));
        return;
      }

      emit(PlansLoaded(plans));
    } catch (e) {
      debugPrint('Failed to fetch plans: $e');
      emit(SubscriptionError(
        'Failed to load subscription plans: $e',
        offerings: state.offerings,
      ));
    }
  }

  Future<void> _onPurchasePlanRequested(
    PurchasePlanRequested event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionLoading(offerings: state.offerings));
    try {
      if (event.package.rcPackage == null) {
        emit(
          SubscriptionError(
            'RevenueCat package not found for this plan.',
            offerings: state.offerings,
          ),
        );
        add(FetchPlans());
        return;
      }

      // Ensure user ID is bound before purchase
      try {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null && currentUser.uid.isNotEmpty) {
          debugPrint(
              '🔑 [SubscriptionBloc] Ensuring identified user before purchase: ${currentUser.uid}');
          await _revenueCatService.logIn(currentUser.uid);
        }
      } catch (_) {}

      await _revenueCatService.purchasePackage(
        event.package.rcPackage!,
      );

      // Transition to verifying state to avoid optimistic offline entitlement flicker
      emit(SubscriptionVerifying(
        'Verifying purchase with store...',
        state.offerings,
      ));

      bool verified = false;
      CustomerInfo? verifiedInfo = await _revenueCatService.getCustomerInfo();
      EntitlementInfos? vEntitlements;
      try {
        vEntitlements = verifiedInfo?.entitlements;
      } catch (_) {}
      final initialActive = vEntitlements?.active;
      if ((initialActive != null &&
              initialActive.containsKey(PaymentConstants.kProEntitlementId) &&
              (initialActive[PaymentConstants.kProEntitlementId]?.isActive ?? false)) ||
          _revenueCatService.isProSubscriber(verifiedInfo)) {
        verified = true;
      }

      if (!verified) {
        for (int attempt = 1; attempt <= 3; attempt++) {
          await Future.delayed(Duration(milliseconds: 200 * attempt));
          try {
            await Purchases.syncPurchases();
          } catch (_) {}
          verifiedInfo = await _revenueCatService.getCustomerInfo();
          EntitlementInfos? retryEntitlements;
          try {
            retryEntitlements = verifiedInfo?.entitlements;
          } catch (_) {}
          final active = retryEntitlements?.active;
          if ((active != null &&
                  active.containsKey(PaymentConstants.kProEntitlementId) &&
                  (active[PaymentConstants.kProEntitlementId]?.isActive ?? false)) ||
              _revenueCatService.isProSubscriber(verifiedInfo)) {
            verified = true;
            break;
          }
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
          SubscriptionError(
            'Purchase could not be verified by the store. Please tap "Restore Purchases" if charged.',
            offerings: state.offerings,
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
      emit(SubscriptionError(
        'Failed to purchase plan: ${e.message ?? e.code}',
        offerings: state.offerings,
      ));
      add(FetchPlans());
    } catch (e) {
      emit(SubscriptionError(
        'Failed to purchase plan: $e',
        offerings: state.offerings,
      ));
      add(FetchPlans());
    }
  }

  Future<void> _onRestorePurchase(
    RestorePurchase event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionLoading(offerings: state.offerings));
    try {
      final customerInfo = await _revenueCatService.restorePurchases();
      EntitlementInfos? entitlements;
      try {
        entitlements = customerInfo?.entitlements;
      } catch (_) {}
      final active = entitlements?.active;
      final isPro = (active != null &&
              active.containsKey(PaymentConstants.kProEntitlementId) &&
              (active[PaymentConstants.kProEntitlementId]?.isActive ?? false)) ||
          _revenueCatService.isProSubscriber(customerInfo);

      if (isPro && customerInfo != null) {
        _applyCustomerInfo(customerInfo, emit);
      } else {
        emit(
          SubscriptionError(
            'No active subscriptions found to restore.',
            offerings: state.offerings,
          ),
        );
        add(FetchPlans());
      }
    } catch (e) {
      emit(SubscriptionError(
        'Failed to restore purchases: $e',
        offerings: state.offerings,
      ));
      add(FetchPlans());
    }
  }
}
