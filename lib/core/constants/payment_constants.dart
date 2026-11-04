import 'package:seafarer_bio_data/core/config/environment.dart';

class PaymentConstants {
  // RevenueCat Entitlement & Offering configuration
  // PROTECTED: DO NOT MODIFY. Dev and prod RevenueCat IDs intentionally
  // differ. See project rules (AGENTS.md).
  static final String kProEntitlementId =Environment.instance.isDev?'premium':'pro';
  static final String kOfferingId = Environment.instance.isDev?'seafarer_pro':'seafarer';

  // RevenueCat Product IDs
  static const String kProductWeekly = 'seafarer_pro_weekly';
  static const String kProductMonthly = 'seafarer_pro_monthly';
  static const String kProductYearly = 'seafarer_pro_yearly';

  // Compliance & Legal URLs (TODO: Provide production URLs)
  static const String kTermsOfUseUrl = 'https://example.com/terms'; // TODO: Replace with live Terms of Use (EULA) URL
  static const String kPrivacyPolicyUrl = 'https://example.com/privacy'; // TODO: Replace with live Privacy Policy URL
}
