import '../entities/onboarding_page.dart';

abstract class OnboardingRepository {
  List<OnboardingPage> getOnboardingPages();
  Future<void> markOnboardingComplete();
  Future<bool> isOnboardingComplete();
}
