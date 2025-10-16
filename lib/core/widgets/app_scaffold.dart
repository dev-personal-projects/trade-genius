import 'package:flutter/material.dart';
import 'package:tradegenius/core/navigation/bottom_nav_bar.dart';
import '../../features/portfolio/presentation/pages/portfolio_screen.dart';
import '../../features/market/presentation/pages/market_screen.dart';
import '../../features/chat/presentation/pages/chat_screen.dart';
import '../../features/profile/presentation/pages/profile_screen.dart';

class AppScaffold extends StatefulWidget {
  const AppScaffold({super.key});

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    MarketScreen(),
    PortfolioScreen(),

    ChatScreen(),
    ProfileScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
