import 'dart:async';
import '../../../core/constants/app_constants.dart';

enum NextRoute { onboarding, home }

final class SplashController {
  Future<NextRoute> resolveNext() async {
    // TODO: Insert real checks later: first-run, auth session, deep links, etc.
    await Future<void>.delayed(
      const Duration(milliseconds: AppConstants.splashMinMs),
    );
    return NextRoute.onboarding;
  }
}
