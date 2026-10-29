import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:seafarer_bio_data/core/constants/app_colors.dart';
import 'package:seafarer_bio_data/core/constants/app_routes.dart';
import 'package:seafarer_bio_data/core/di/injection_container.dart';
import 'package:seafarer_bio_data/core/services/revenuecat_service.dart';
import 'package:seafarer_bio_data/features/personal_details/domain/entities/profile_entity.dart';
import 'package:seafarer_bio_data/features/personal_details/presentation/bloc/personal_info_bloc.dart';
import 'package:seafarer_bio_data/features/personal_details/presentation/bloc/personal_info_event.dart';
import 'package:seafarer_bio_data/features/subscription/data/models/subscription_status_details.dart';
import 'package:seafarer_bio_data/features/subscription/presentation/bloc/subscription_bloc.dart';
import 'package:seafarer_bio_data/features/subscription/presentation/bloc/subscription_event.dart';
import 'package:seafarer_bio_data/features/subscription/presentation/bloc/subscription_state.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileSubscriptionCard extends StatefulWidget {
  final Profile profile;
  final SubscriptionStatusDetails? initialDetails;

  const ProfileSubscriptionCard({
    super.key,
    required this.profile,
    this.initialDetails,
  });

  @override
  State<ProfileSubscriptionCard> createState() =>
      _ProfileSubscriptionCardState();
}

class _ProfileSubscriptionCardState extends State<ProfileSubscriptionCard> {
  SubscriptionStatusDetails? _details;
  bool _isLoading = true;

  String? get _currentUserEmail {
    try {
      return FirebaseAuth.instance.currentUser?.email;
    } catch (_) {
      return null;
    }
  }

  String? get _currentUserId {
    try {
      return FirebaseAuth.instance.currentUser?.uid;
    } catch (_) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialDetails != null) {
      _details = widget.initialDetails;
      _isLoading = false;
    }
    _loadSubscriptionDetails();
  }

  Future<void> _loadSubscriptionDetails() async {
    if (!mounted) return;
    if (!sl.isRegistered<RevenueCatService>()) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final details =
          await sl<RevenueCatService>().getSubscriptionDetails();
      if (!mounted) return;

      setState(() {
        _details = details;
        _isLoading = false;
      });

      // Sync Firestore isPremium if pro is inactive but profile says true
      final uid = _currentUserId;
      if (uid != null &&
          uid.isNotEmpty &&
          !details.isActive &&
          widget.profile.isPremiumPaid) {
        if (!mounted) return;
        context.read<ProfileBloc>().add(
              SyncSubscriptionStatusEvent(
                isPremium: false,
                userId: uid,
              ),
            );
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _openManageSubscription(String? customUrl) async {
    final fallbackUrl = Platform.isIOS
        ? 'https://apps.apple.com/account/subscriptions'
        : 'https://play.google.com/store/account/subscriptions';

    final targetUrl = customUrl != null && customUrl.isNotEmpty
        ? customUrl
        : fallbackUrl;

    try {
      final uri = Uri.parse(targetUrl);
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open subscription page: $targetUrl')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to open link: $e')),
        );
      }
    }
  }

  Future<void> _restorePurchases() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Restoring purchases...')),
    );

    try {
      final customerInfo = await Purchases.restorePurchases();
      if (!mounted) return;

      final isPro = sl.isRegistered<RevenueCatService>()
          ? sl<RevenueCatService>().isProSubscriber(customerInfo)
          : customerInfo.entitlements.active.isNotEmpty;

      final uid = _currentUserId;

      if (isPro) {
        context.read<SubscriptionBloc>().add(CustomerInfoUpdated(customerInfo));
        if (uid != null && uid.isNotEmpty) {
          context.read<ProfileBloc>().add(
                SyncSubscriptionStatusEvent(
                  isPremium: true,
                  userId: uid,
                ),
              );
        }
        await _loadSubscriptionDetails();

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Purchases restored successfully! Pro unlocked.'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        context.read<SubscriptionBloc>().add(CustomerInfoUpdated(customerInfo));
        if (uid != null && uid.isNotEmpty) {
          context.read<ProfileBloc>().add(
                SyncSubscriptionStatusEvent(
                  isPremium: false,
                  userId: uid,
                ),
              );
        }
        await _loadSubscriptionDetails();

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No active subscriptions found to restore.'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to restore purchases: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayName =
        '${widget.profile.personalDetails.firstname} ${widget.profile.personalDetails.lastname}'
            .trim();
    final email = _currentUserEmail ?? '';
    final uid = _currentUserId ?? 'N/A';

    return BlocListener<SubscriptionBloc, SubscriptionState>(
      listener: (context, state) {
        _loadSubscriptionDetails();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── USER DETAILS CARD ───────────────────────────────────────────────
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            color: const Color(0xFF1E293B), // Dark Slate
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.appScaffold.withValues(alpha: 0.2),
                    child: Text(
                      displayName.isNotEmpty
                          ? displayName[0].toUpperCase()
                          : 'S',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName.isNotEmpty ? displayName : 'Seafarer User',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (email.isNotEmpty)
                          Text(
                            email,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                        const SizedBox(height: 2),
                        Text(
                          'UID: ${uid.length > 12 ? '${uid.substring(0, 10)}...' : uid}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── SUBSCRIPTION CARD ──────────────────────────────────────────────
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            color: const Color(0xFF0F172A),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _isLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    )
                  : _buildSubscriptionContent(),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSubscriptionContent() {
    final details = _details ?? SubscriptionStatusDetails.freeTier;
    final isPro = details.isActive;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                'Subscription',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isPro
                    ? const Color(0xFF10B981).withValues(alpha: 0.2) // Emerald
                    : Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isPro
                      ? const Color(0xFF10B981)
                      : Colors.white.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isPro ? Icons.verified : Icons.lock_outline,
                    size: 14,
                    color: isPro ? const Color(0xFF10B981) : Colors.white70,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isPro ? 'Pro Active' : 'Free Tier',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isPro ? const Color(0xFF10B981) : Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        if (isPro) ...[
          // Pro active details
          Text(
            details.planName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.amber,
            ),
          ),
          const SizedBox(height: 4),
          if (details.expirationDate != null)
            Text(
              details.willRenew
                  ? 'Renews on: ${details.expirationDate}'
                  : 'Expires on: ${details.expirationDate}',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () =>
                      _openManageSubscription(details.managementUrl),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    foregroundColor: Colors.white70,
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.settings, size: 16),
                      SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'Manage',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: _restorePurchases,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    foregroundColor: Colors.white70,
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.restore, size: 16),
                      SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'Restore',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ] else ...[
          // Free Tier details
          Text(
            'Unlock advanced DOCX export and pro features.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.subscription);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    backgroundColor: AppColors.appScaffold,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, size: 16),
                      SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'Upgrade to Pro',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: _restorePurchases,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    foregroundColor: Colors.white70,
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.restore, size: 16),
                      SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'Restore',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],


        // Transaction history if past purchases exist
        if (details.allPurchases.isNotEmpty) ...[
          const SizedBox(height: 14),
          const Divider(color: Colors.white12),
          const SizedBox(height: 8),
          Text(
            'Purchase History',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 6),
          ...details.allPurchases.map(
            (p) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Row(
                children: [
                  const Icon(Icons.receipt_long, size: 14, color: Colors.white38),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      p,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

