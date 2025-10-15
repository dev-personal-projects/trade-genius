import 'package:flutter/material.dart';
import '../domain/entities/onboarding_page.dart';
import '../domain/repositories/onboarding_repository.dart';
import 'onboarding_state.dart';

class OnboardingController extends ValueNotifier<OnboardingState> {
  final OnboardingRepository _repository;
  final PageController pageController = PageController();

  OnboardingController(this._repository) : super(const OnboardingState());

  List<OnboardingPage> get pages => _repository.getOnboardingPages();

  void nextPage() {
    if (value.isLastPage) {
      _completeOnboarding();
    } else {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void onPageChanged(int index) {
    value = value.copyWith(
      currentPage: index,
      isLastPage: index == pages.length - 1,
    );
  }

  Future<void> _completeOnboarding() async {
    await _repository.markOnboardingComplete();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
