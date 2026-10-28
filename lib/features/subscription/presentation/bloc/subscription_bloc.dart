import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter/foundation.dart';
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
    on<PurchasePlan>(_onPurchasePlan);
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

  Future<void> _onCustomerInfoUpdated(
    CustomerInfoUpdated event,
    Emitter<SubscriptionState> emit,
  ) async {
    final isPro = _revenueCatService.isProSubscriber(event.customerInfo);
    if (isPro) {
      if (state is! SubscriptionActive) {
        emit(SubscriptionActive(SubscriptionPackage.staticPlans.first));
      }
    } else {
      if (state is SubscriptionActive) {
        add(FetchPlans());
      }
    }
  }

  Future<void> _onFetchPlans(
    FetchPlans event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionLoading());
    try {
      final customerInfo = await _revenueCatService.getCustomerInfo();
      if (_revenueCatService.isProSubscriber(customerInfo)) {
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

  Future<void> _onPurchasePlan(
    PurchasePlan event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionLoading());
    try {
      if (event.package.rcPackage != null) {
        final purchaseResult = await Purchases.purchase(
          PurchaseParams.package(event.package.rcPackage!),
        );
        final isPro =
            _revenueCatService.isProSubscriber(purchaseResult.customerInfo);

        if (isPro) {
          emit(SubscriptionActive(event.package));
        } else {
          emit(
            const SubscriptionError('Purchase did not unlock Pro features.'),
          );
          add(FetchPlans());
        }
      } else {
        emit(
          const SubscriptionError('RevenueCat package not found for this plan.'),
        );
        add(FetchPlans());
      }
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        // User intentionally cancelled the purchase flow - dismiss quietly without an error SnackBar
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
      final customerInfo = await Purchases.restorePurchases();
      final isPro = _revenueCatService.isProSubscriber(customerInfo);

      if (isPro) {
        emit(SubscriptionActive(SubscriptionPackage.staticPlans.last));
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
