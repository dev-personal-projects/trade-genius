# tradegenius

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

onboarding 
lib/features/onboarding/
├── domain/
│   ├── entities/
│   │   └── onboarding_page.dart          # Entity representing onboarding page data
│   └── repositories/
│       └── onboarding_repository.dart    # Abstract repository interface
├── application/
│   ├── onboarding_controller.dart        # Business logic controller
│   └── onboarding_state.dart            # State management
└── presentation/
    ├── pages/
    │   └── onboarding_screen.dart        # Main onboarding screen with PageView
    └── widgets/
        ├── onboarding_page_widget.dart   # Individual page widget
        ├── page_indicator.dart           # Dots indicator widget
        └── onboarding_buttons.dart       # Navigation buttons widget

assets/
├── images/
│   ├── onboarding/
│   │   ├── trading_chart.png            # Screen 1: Trading analysis
│   │   ├── portfolio_growth.png         # Screen 2: Portfolio management
│   │   └── learning_path.png            # Screen 3: Learning journey
└── icons/
    └── (existing files)
