# PERMANENT PROJECT RULE (applies to every task, every session, no exceptions)

PROTECTED FILE: lib/core/constants/payment_constants.dart

The following code is intentionally designed and MUST NEVER be modified:

```dart
  static final String kProEntitlementId =
      Environment.instance.isDev ? 'premium' : 'pro';
  static final String kOfferingId =
      Environment.instance.isDev ? 'seafarer_pro' : 'seafarer';
```

Reason: the RevenueCat dev app and prod app use different entitlement and
offering identifiers. The dev values are 'premium' and 'seafarer_pro'. The
prod values are 'pro' and 'seafarer'.

Rules:
1. Do NOT edit, rename, reformat, refactor, "clean up", merge, unify, or move
   these two constants or their values, even if a bug, lint, analyzer warning,
   test, or another task seems to require it.
2. Do NOT replace them with hardcoded strings or other constants. Other code
   must keep reading them via PaymentConstants.kProEntitlementId and
   PaymentConstants.kOfferingId.
3. Do NOT "fix" a mismatch between dev and prod values. It is intentional.
4. If a task seems to need a change to this file, STOP, do not edit it, and
   tell me what you wanted to change and why. Wait for my explicit approval
   written in the chat. Approval given in an earlier session does not carry
   over.
5. Do not delete or weaken the guard comment or the guard test described below.

