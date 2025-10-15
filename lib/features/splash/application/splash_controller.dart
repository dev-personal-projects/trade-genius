import 'dart:async';
import '../../../core/constants/app_constants.dart';

enum NextRoute { home /* , onboarding, auth */ }

final class SplashController {
  Future<NextRoute> resolveNext() async {
    // TODO: Insert real checks later: first-run, auth session, deep links, etc.
    await Future<void>.delayed(
      const Duration(milliseconds: AppConstants.splashMinMs),
    );
    return NextRoute.home;
  }
}
