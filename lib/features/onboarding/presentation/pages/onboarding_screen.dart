import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tradegenius/core/services/onboarding_service.dart';
import '../../../../core/routes/app_router.dart';
import '../../domain/entities/onboarding_page.dart';
import '../widgets/onboarding_page_widget.dart';
import '../widgets/page_indicator.dart';
import '../widgets/onboarding_buttons.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Master Trading Analysis',
      description:
          'Learn to read charts, identify patterns, and make informed trading decisions with our comprehensive analysis tools.',
      imagePath: 'assets/images/onboarding/trading_chart.jpg',
    ),
    OnboardingPage(
      title: 'Grow Your Portfolio',
      description:
          'Track your investments, monitor performance, and optimize your portfolio with real-time insights and analytics.',
      imagePath: 'assets/images/onboarding/portfolio_growth.png.webp',
    ),
    OnboardingPage(
      title: 'AI-Powered Learning',
      description: 'Start your trading journey with AI-guided lessons, personalized learning paths, and expert insights.',
      imagePath: 'assets/images/onboarding/ai-learning-path.webp',
    ),
  ];

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _onNext() {
  if (_currentPage < _pages.length - 1) {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  } else {
    OnboardingService.markCompleted();
    context.go(AppRoutes.login);
  }
}


  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => context.go(AppRoutes.login),
                child: Text(
                  'Skip',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return OnboardingPageWidget(page: _pages[index]);
                },
              ),
            ),
            // Page indicator
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: PageIndicator(
                currentPage: _currentPage,
                pageCount: _pages.length,
              ),
            ),
            // Navigation button
            OnboardingButtons(isLastPage: isLastPage, onNext: _onNext),
          ],
        ),
      ),
    );
  }
}
