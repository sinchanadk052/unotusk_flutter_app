import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_theme.dart';

class TopNavBar extends StatelessWidget {
  final UnoPalette palette;
  final bool isDark;
  final int unreadCount;
  final bool notificationsOpen;
  final VoidCallback onToggleNotifications;
  final VoidCallback onToggleTheme;
  final bool showSidebarToggle;
  final VoidCallback? onToggleSidebar;

  const TopNavBar({
    super.key,
    required this.palette,
    required this.isDark,
    required this.unreadCount,
    required this.notificationsOpen,
    required this.onToggleNotifications,
    required this.onToggleTheme,
    this.showSidebarToggle = false,
    this.onToggleSidebar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: showSidebarToggle
          ? const EdgeInsets.fromLTRB(10, 0, 16, 0)
          : const EdgeInsets.symmetric(horizontal: 28),
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (showSidebarToggle && onToggleSidebar != null)
            InkWell(
              onTap: onToggleSidebar,
              borderRadius: BorderRadius.circular(6),
              child: Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                child: Icon(
                  LucideIcons.menu,
                  size: 20,
                  color: palette.textSec,
                ),
              ),
            )
          else
            const SizedBox.shrink(),
          Row(
            children: [
              // Notification bell button
              Stack(
                clipBehavior: Clip.none,
                children: [
                  InkWell(
                    onTap: onToggleNotifications,
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: notificationsOpen
                            ? palette.accent.withValues(alpha: 0.12)
                            : Colors.transparent,
                        border: Border.all(
                          color: notificationsOpen
                              ? palette.accent
                              : palette.div,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        LucideIcons.bell,
                        size: 13,
                        color: notificationsOpen
                            ? palette.accent
                            : palette.textSec,
                      ),
                    ),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      top: 3,
                      right: 3,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: palette.inferred,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: palette.bgBase,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              // Theme toggle button
              InkWell(
                onTap: onToggleTheme,
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(color: palette.div),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    isDark ? LucideIcons.sun : LucideIcons.moon,
                    size: 14,
                    color: palette.textSec,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
