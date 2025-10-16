import 'package:flutter/material.dart';

class NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final Widget screen;

  const NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.screen,
  });
}
