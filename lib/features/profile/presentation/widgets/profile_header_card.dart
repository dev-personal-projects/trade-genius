/*
 * ═══════════════════════════════════════════════════════════════════════════
 * PROFILE HEADER CARD - Enhanced User Profile Display
 * ═══════════════════════════════════════════════════════════════════════════
 * 
 * FEATURES:
 * - Gradient background
 * - Tappable to edit profile
 * - Profile picture with camera icon overlay
 * - Animated transitions
 * 
 * CONCEPTS:
 * - GestureDetector: Handle taps
 * - Stack: Layered widgets
 * - Positioned: Absolute positioning
 * - LinearGradient: Color gradients
 * 
 * ═══════════════════════════════════════════════════════════════════════════
 */

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../../../../core/theme/app_theme.dart';

class ProfileHeaderCard extends StatelessWidget {
  final String name;
  final String email;
  final DateTime joinDate;
  final String? profileImagePath;
  final VoidCallback onTap;
  final Function(String) onImageSelected;

  const ProfileHeaderCard({
    super.key,
    required this.name,
    required this.email,
    required this.joinDate,
    this.profileImagePath,
    required this.onTap,
    required this.onImageSelected,
  });

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      final image = await picker.pickImage(source: source, maxWidth: 512, maxHeight: 512);
      if (image != null) {
        onImageSelected(image.path);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // ═══════════════════════════════════════════════════════════════════════
    // GESTUREDETECTOR: Handle tap events
    // ═══════════════════════════════════════════════════════════════════════
    // WHAT: Detects gestures (tap, long press, swipe, etc.)
    // WHY: Make entire card tappable for better UX
    // WHEN: Need custom tap handling beyond button widgets
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          // ═══════════════════════════════════════════════════════════════════
          // LINEARGRADIENT: Color gradient background
          // ═══════════════════════════════════════════════════════════════════
          // WHAT: Smooth color transition
          // WHY: Modern, visually appealing design
          // HOW: Define colors and direction
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primary.withOpacity(0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // ═══════════════════════════════════════════════════════════════════
            // STACK: Layered widgets
            // ═══════════════════════════════════════════════════════════════════
            // WHAT: Overlapping widgets (like FrameLayout in Android)
            // WHY: Place camera icon on top of avatar
            // HOW: Children are stacked in order (first = bottom)
            Stack(
              children: [
                // Profile avatar
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  backgroundImage: profileImagePath != null
                      ? FileImage(File(profileImagePath!))
                      : null,
                  child: profileImagePath == null
                      ? Text(
                          name.isNotEmpty ? name[0].toUpperCase() : 'U',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        )
                      : null,
                ),
                
                // ═══════════════════════════════════════════════════════════════
                // POSITIONED: Absolute positioning within Stack
                // ═══════════════════════════════════════════════════════════════
                // WHAT: Position widget at specific coordinates
                // WHY: Place camera icon at bottom-right of avatar
                // PROPERTIES: right, left, top, bottom (like CSS)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onTap: () => _pickImage(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        size: 20,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Name
            Text(
              name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            
            // Email
            Text(
              email,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 8),
            
            // Join date with icon
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: Colors.white.withOpacity(0.8),
                ),
                const SizedBox(width: 6),
                Text(
                  'Member since ${DateFormat('MMM yyyy').format(joinDate)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Edit profile hint
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.edit,
                    size: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Tap to edit profile',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
