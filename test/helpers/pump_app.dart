import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:seafarer_bio_data/core/constants/app_routes.dart';
import 'package:seafarer_bio_data/core/constants/app_theme.dart';
import 'package:seafarer_bio_data/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:seafarer_bio_data/features/personal_details/presentation/bloc/personal_info_bloc.dart';
import 'package:seafarer_bio_data/features/subscription/presentation/bloc/subscription_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:seafarer_bio_data/core/utils/shared_preferences.dart';

import 'mocks.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class FakeRoute extends Fake implements Route<dynamic> {}

/// Registers the fallbacks needed by [MockNavigatorObserver] plus the shared
/// bloc/entity fallbacks.
void registerWidgetTestFallbacks() {
  registerTestFallbackValues();
  registerFallbackValue(FakeRoute());
}

/// Initialises [PreferenceService] against an in-memory store.
Future<void> initTestPreferences([Map<String, Object> values = const {}]) async {
  SharedPreferences.setMockInitialValues(values);
  await PreferenceService.init();
}

/// Wraps [child] in the app's theme, routing table and the three blocs every
/// screen in this app reads from `context`.
///
/// Real pages are used for navigation targets (via [AppRoutes.generatedRoutes])
/// so tests assert on the destination screen instead of a mocked route name.
/// Set [stubRoutes] to replace every navigation target with a placeholder page
/// showing `route: <name>`; use [routeStubText] to assert on it. That keeps a
/// navigation assertion from depending on whatever the destination screen needs
/// in order to build.
Widget testApp({
  required Widget child,
  required AuthBloc authBloc,
  required ProfileBloc profileBloc,
  required SubscriptionBloc subscriptionBloc,
  NavigatorObserver? navigatorObserver,
  bool stubRoutes = false,
}) {
  return MultiBlocProvider(
    providers: [
      BlocProvider<AuthBloc>.value(value: authBloc),
      BlocProvider<ProfileBloc>.value(value: profileBloc),
      BlocProvider<SubscriptionBloc>.value(value: subscriptionBloc),
    ],
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      home: child,
      onGenerateRoute:
          stubRoutes ? _stubRoute : AppRoutes.generatedRoutes,
      navigatorObservers: [
        ?navigatorObserver,
      ],
    ),
  );
}

/// The text rendered by a stubbed route, e.g. `routeStubText(AppRoutes.home)`.
String routeStubText(String routeName) => 'route: $routeName';

Route<dynamic> _stubRoute(RouteSettings settings) => MaterialPageRoute(
      settings: settings,
      builder: (_) => Scaffold(
        body: Center(child: Text(routeStubText(settings.name ?? ''))),
      ),
    );

/// Pumps [child] inside [testApp] and settles the first frame.
Future<void> pumpTestApp(
  WidgetTester tester, {
  required Widget child,
  required AuthBloc authBloc,
  required ProfileBloc profileBloc,
  required SubscriptionBloc subscriptionBloc,
  NavigatorObserver? navigatorObserver,
  bool stubRoutes = false,
}) async {
  await tester.pumpWidget(testApp(
    child: child,
    authBloc: authBloc,
    profileBloc: profileBloc,
    subscriptionBloc: subscriptionBloc,
    navigatorObserver: navigatorObserver,
    stubRoutes: stubRoutes,
  ));
  await tester.pump();
}

/// Scrolls [finder] into view before tapping it.
///
/// These screens are long forms inside a `SingleChildScrollView`, so the submit
/// button is usually below the test viewport.
///
/// The leading `pumpAndSettle` matters: after `enterText`, focusing a field
/// starts its own scroll-into-view animation, which would otherwise finish
/// *after* `ensureVisible` and scroll the target back off screen.
Future<void> scrollAndTap(WidgetTester tester, Finder finder) async {
  await tester.pumpAndSettle();
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
  await tester.pump();
}

/// Gives every test a phone-sized surface so overflow assertions are meaningful
/// and are not an artefact of the default 800x600 test window.
void useMobileSurface(WidgetTester tester, {Size size = const Size(390, 844)}) {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}
