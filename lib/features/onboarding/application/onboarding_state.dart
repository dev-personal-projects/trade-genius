class OnboardingState {
  final int currentPage;
  final bool isLastPage;

  const OnboardingState({this.currentPage = 0, this.isLastPage = false});

  OnboardingState copyWith({int? currentPage, bool? isLastPage}) {
    return OnboardingState(
      currentPage: currentPage ?? this.currentPage,
      isLastPage: isLastPage ?? this.isLastPage,
    );
  }
}
