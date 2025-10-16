import 'dart:async';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/services/onboarding_service.dart';

enum NextRoute { onboarding, login, home }

final class SplashController {

  Future<NextRoute> resolveNext() async {
    await Future<void>.delayed(
      const Duration(milliseconds: AppConstants.splashMinMs),
    );

    final user = SupabaseService.client.auth.currentUser;
    
    if (user != null) {
      return NextRoute.home;
    }
    
    final onboardingCompleted = await OnboardingService.isCompleted();
    return onboardingCompleted ? NextRoute.login : NextRoute.onboarding;
  }
}
