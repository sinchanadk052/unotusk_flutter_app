import 'dart:io';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import '../theme/app_theme.dart';
import 'unotusk_logo.dart';

/// Custom window title bar that replaces the native Windows title bar.
/// Displays the Unotusk logo + brand name on the left, and
/// minimize / maximize / close controls on the right.
///
/// The entire bar is draggable to move the window.
class WindowTitleBar extends StatelessWidget {
  final UnoPalette palette;

  /// Optional trailing widgets shown between brand and window controls
  /// (e.g. an OIDC badge on the auth screen).
  final Widget? trailing;

  const WindowTitleBar({
    super.key,
    required this.palette,
    this.trailing,
  });

  static const double height = 32.0;

  @override
  Widget build(BuildContext context) {
    // Only show custom title bar on desktop platforms
    if (!Platform.isWindows && !Platform.isLinux && !Platform.isMacOS) {
      return const SizedBox.shrink();
    }

    final isDark = palette.isDark;

    return GestureDetector(
      onPanStart: (_) => windowManager.startDragging(),
      onDoubleTap: () async {
        final isMaximized = await windowManager.isMaximized();
        if (isMaximized) {
          windowManager.unmaximize();
        } else {
          windowManager.maximize();
        }
      },
      child: Container(
        height: height,
        color: palette.bgBase,
        padding: const EdgeInsets.only(left: 12),
        child: Row(
          children: [
            // ── Logo + Brand Name ──
            UnotuskLogo(size: 16, onDark: isDark),
            const SizedBox(width: 7),
            Text(
              'Unotusk',
              style: UnoTypography.brandSerif(
                palette: palette,
                fontSize: 13,
              ),
            ),

            // ── Optional trailing (e.g. badge) ──
            if (trailing != null) ...[
              const SizedBox(width: 10),
              trailing!,
            ],

            const Spacer(),

            // ── Window Controls ──
            _WindowButton(
              icon: Icons.remove,
              iconSize: 14,
              onTap: () => windowManager.minimize(),
              hoverColor: palette.textSec.withValues(alpha: 0.12),
              iconColor: palette.textSec,
            ),
            _WindowButton(
              icon: Icons.crop_square,
              iconSize: 13,
              onTap: () async {
                final isMaximized = await windowManager.isMaximized();
                if (isMaximized) {
                  windowManager.unmaximize();
                } else {
                  windowManager.maximize();
                }
              },
              hoverColor: palette.textSec.withValues(alpha: 0.12),
              iconColor: palette.textSec,
            ),
            _WindowButton(
              icon: Icons.close,
              iconSize: 16,
              onTap: () => windowManager.close(),
              hoverColor: const Color(0xFFE81123),
              iconColor: palette.textSec,
              hoverIconColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual window control button with hover effect.
class _WindowButton extends StatefulWidget {
  final IconData icon;
  final double iconSize;
  final VoidCallback onTap;
  final Color hoverColor;
  final Color iconColor;
  final Color? hoverIconColor;

  const _WindowButton({
    required this.icon,
    required this.iconSize,
    required this.onTap,
    required this.hoverColor,
    required this.iconColor,
    this.hoverIconColor,
  });

  @override
  State<_WindowButton> createState() => _WindowButtonState();
}

class _WindowButtonState extends State<_WindowButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: 46,
          height: WindowTitleBar.height,
          color: _hovering ? widget.hoverColor : Colors.transparent,
          alignment: Alignment.center,
          child: Icon(
            widget.icon,
            size: widget.iconSize,
            color: _hovering && widget.hoverIconColor != null
                ? widget.hoverIconColor
                : widget.iconColor,
          ),
        ),
      ),
    );
  }
}
