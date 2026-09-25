import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import 'unotusk_logo.dart';
import 'user_menu_popup.dart';

class UnoSidebar extends StatefulWidget {
  final bool open;
  final VoidCallback onToggle;
  final VoidCallback onNewQuery;
  final UnoPalette palette;
  final String activeView;
  final Function(String) onViewChange;
  final Function(int) onLoadRecentChat;
  final UserModel user;
  final VoidCallback onLogOut;
  final Function(String) onNavigateSettings;
  final VoidCallback onOpenArchivedModal;

  const UnoSidebar({
    super.key,
    required this.open,
    required this.onToggle,
    required this.onNewQuery,
    required this.palette,
    required this.activeView,
    required this.onViewChange,
    required this.onLoadRecentChat,
    required this.user,
    required this.onLogOut,
    required this.onNavigateSettings,
    required this.onOpenArchivedModal,
  });

  @override
  State<UnoSidebar> createState() => _UnoSidebarState();
}

class _UnoSidebarState extends State<UnoSidebar> {
  bool _userMenuOpen = false;

  // Web source: zh array — same nav items
  final List<Map<String, dynamic>> _navItems = const [
    {'id': 'chat', 'label': 'Ask', 'icon': LucideIcons.zap},
    {'id': 'spec-history', 'label': 'Spec History', 'icon': LucideIcons.clipboardList},
    {'id': 'graph', 'label': 'Ontology Graph', 'icon': LucideIcons.gitBranch},
    {'id': 'feed', 'label': 'Ingestion Feed', 'icon': LucideIcons.download},
  ];

  @override
  Widget build(BuildContext context) {
    // Web: Pc=264 for open, Ec=72 for closed
    final width = widget.open ? 264.0 : 72.0;
    final isDark = widget.palette.bgBase == const Color(0xFF181816);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: const Cubic(0.4, 0.0, 0.2, 1.0),
      width: width,
      decoration: BoxDecoration(
        color: widget.palette.bgSurface,
        border: Border(right: BorderSide(color: widget.palette.div)),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRect(
            child: SizedBox(
              width: width,
              height: double.infinity,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                switchInCurve: Curves.easeIn,
                switchOutCurve: Curves.easeOut,
                layoutBuilder: (currentChild, previousChildren) {
                  return Stack(
                    alignment: Alignment.topLeft,
                    children: [
                      ...previousChildren,
                      ?currentChild,
                    ],
                  );
                },
                child: widget.open
                    ? KeyedSubtree(
                        key: const ValueKey('expanded'),
                        child: OverflowBox(
                          alignment: Alignment.topLeft,
                          minWidth: 264.0,
                          maxWidth: 264.0,
                          child: _buildExpanded(isDark),
                        ),
                      )
                    : KeyedSubtree(
                        key: const ValueKey('narrow'),
                        child: OverflowBox(
                          alignment: Alignment.topLeft,
                          minWidth: 72.0,
                          maxWidth: 72.0,
                          child: _buildNarrow(isDark),
                        ),
                      ),
              ),
            ),
          ),
          if (_userMenuOpen)
            Positioned(
              left: widget.open ? 12 : 80,
              bottom: widget.open ? 64 : 16,
              child: UserMenuPopup(
                palette: widget.palette,
                user: widget.user,
                onNavigateSettings: widget.onNavigateSettings,
                onLogOut: widget.onLogOut,
                onClose: () => setState(() => _userMenuOpen = false),
              ),
            ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  //  EXPANDED — web: width Pc(264), padding "14px 0"
  // ═══════════════════════════════════════════════════════
  Widget _buildExpanded(bool isDark) {
    return SizedBox(
      width: 264.0,
      height: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
        // Brand Header — web: padding "0 14px", marginBottom "12px"
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  UnotuskLogo(size: 22, onDark: isDark),
                  const SizedBox(width: 9),
                  Text(
                    'Unotusk',
                    style: UnoTypography.brandSerif(
                      palette: widget.palette,
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
              // Collapse button — web: 28×28, borderRadius 6, border div
              InkWell(
                onTap: widget.onToggle,
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    border: Border.all(color: widget.palette.div),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    LucideIcons.chevronLeft,
                    size: 13,
                    color: widget.palette.textSec,
                  ),
                ),
              ),
            ],
          ),
        ),

        // New Query Button — web: padding "0 12px", marginBottom "10px", height 38, borderRadius 8
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
          child: InkWell(
            onTap: widget.onNewQuery,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 38,
              decoration: BoxDecoration(
                color: widget.palette.accent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.plus,
                      size: 15, color: Colors.white, weight: 2.5),
                  const SizedBox(width: 7),
                  Text(
                    'New Query',
                    style: UnoTypography.body(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Nav items — web: padding "4px 0"
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            children: _navItems.map((item) {
              final active = widget.activeView == item['id'];
              return InkWell(
                onTap: () => widget.onViewChange(item['id']),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: active
                        ? widget.palette.bgElevated
                        : Colors.transparent,
                    border: Border(
                      left: BorderSide(
                        color: active
                            ? widget.palette.accent
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        item['icon'] as IconData,
                        size: 15,
                        color: active
                            ? widget.palette.accent
                            : widget.palette.textSec,
                      ),
                      const SizedBox(width: 11),
                      Text(
                        item['label'] as String,
                        style: UnoTypography.body(
                          color: active
                              ? widget.palette.accent
                              : widget.palette.textSec,
                          fontSize: 13,
                          fontWeight:
                              active ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        // Divider — web: height 1, margin "8px 0"
        Container(
          height: 1,
          color: widget.palette.div,
          margin: const EdgeInsets.symmetric(vertical: 8),
        ),

        // Recent Chats — web: padding "0 14px", flex 1, overflowY auto
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // web: Geist Mono 10px, uppercase, letterSpacing 0.06em
                Text(
                  'RECENT',
                  style: UnoTypography.mono(
                    color: widget.palette.textSec,
                    fontSize: 10,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: MockData.recentChats.length,
                    itemBuilder: (context, index) {
                      final chat = MockData.recentChats[index];
                      // web: padding 8px 8px, borderRadius 6, hover bgElevated
                      return InkWell(
                        onTap: () => widget.onLoadRecentChat(chat.id),
                        borderRadius: BorderRadius.circular(6),
                        hoverColor: widget.palette.bgElevated,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                          child: Text(
                            chat.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            // web: Geist 12px, fontWeight 500, lineHeight 1.3
                            style: UnoTypography.body(
                              color: widget.palette.text,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        // Archived Chats — web: padding "4px 12px 6px"
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 6),
          child: InkWell(
            onTap: widget.onOpenArchivedModal,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.archive,
                    size: 15,
                    color: widget.palette.accent,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Archived chats',
                    style: UnoTypography.body(
                      color: widget.palette.textSec,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // User Footer — web: padding "8px 12px 4px", borderTop
        Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: widget.palette.div)),
          ),
          child: InkWell(
            onTap: () => setState(() => _userMenuOpen = !_userMenuOpen),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                children: [
                  // web: 30×30, borderRadius 50%, accent bg
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: widget.palette.accent,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(LucideIcons.user,
                          size: 14, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // web: Geist 13px, fontWeight 600
                        Text(
                          widget.user.name.isNotEmpty
                              ? widget.user.name
                              : 'User',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: UnoTypography.body(
                            color: widget.palette.text,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (widget.user.org.isNotEmpty)
                          // web: Geist Mono 10px
                          Text(
                            widget.user.org,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: UnoTypography.mono(
                              color: widget.palette.textSec,
                              fontSize: 10,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Icon(
                    _userMenuOpen
                        ? LucideIcons.chevronUp
                        : LucideIcons.chevronDown,
                    size: 13,
                    color: widget.palette.textSec,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
      ],
    ),
  );
}

  // ═══════════════════════════════════════════════════════
  //  COLLAPSED — web: width Ec(72), padding "14px 0 16px"
  // ═══════════════════════════════════════════════════════
  Widget _buildNarrow(bool isDark) {
    return SizedBox(
      width: 72.0,
      height: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
        const SizedBox(height: 14),
        // Logo
        UnotuskLogo(size: 22, onDark: isDark),
        const SizedBox(height: 12),

        // Expand button — web: tc component, 36×36, borderRadius 10, bgElevated, border div
        _buildCollapsedButton(
          onTap: widget.onToggle,
          tooltip: 'Expand sidebar',
          child: Icon(LucideIcons.chevronRight,
              size: 14, color: widget.palette.textSec),
        ),

        // Divider
        Container(
          width: 24,
          height: 1,
          color: widget.palette.div,
          margin: const EdgeInsets.symmetric(vertical: 10),
        ),

        // New Query — web: tc highlight, accent bg, white icon
        _buildCollapsedButton(
          onTap: widget.onNewQuery,
          tooltip: 'New Query',
          highlight: true,
          child: const Icon(LucideIcons.plus, size: 15, color: Colors.white),
        ),

        // Divider
        Container(
          width: 24,
          height: 1,
          color: widget.palette.div,
          margin: const EdgeInsets.symmetric(vertical: 10),
        ),

        // Nav items — web: hk component, 36×36, borderRadius 10
        // gap 6 between items
        ..._navItems.map((item) {
          final active = widget.activeView == item['id'];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: _buildCollapsedNavItem(
              icon: item['icon'] as IconData,
              label: item['label'] as String,
              active: active,
              onTap: () => widget.onViewChange(item['id']),
            ),
          );
        }),

        const Spacer(),

        // Archived chats — web: tc component
        _buildCollapsedButton(
          onTap: widget.onOpenArchivedModal,
          tooltip: 'Archived chats',
          child: Icon(LucideIcons.archive,
              size: 15, color: widget.palette.textSec),
        ),

        // Divider
        Container(
          width: 24,
          height: 1,
          color: widget.palette.div,
          margin: const EdgeInsets.symmetric(vertical: 10),
        ),

        // User avatar — web: mk component, 34×34, borderRadius 50%, accent bg
        InkWell(
          onTap: () => setState(() => _userMenuOpen = !_userMenuOpen),
          borderRadius: BorderRadius.circular(17),
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: widget.palette.accent,
              shape: BoxShape.circle,
              border: Border.all(
                color: _userMenuOpen
                    ? widget.palette.text
                    : widget.palette.div,
                width: 2,
              ),
            ),
            child: const Center(
              child: Icon(LucideIcons.user, size: 15, color: Colors.white),
            ),
          ),
        ),

        const SizedBox(height: 16),
      ],
    ),
  );
}

  // ─── Collapsed icon button (tc component from web) ─────────
  // web: 36×36, borderRadius 10, bgElevated (or accent if highlight), border div (or accent)
  Widget _buildCollapsedButton({
    required VoidCallback onTap,
    required Widget child,
    String? tooltip,
    bool highlight = false,
  }) {
    final button = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: highlight
              ? widget.palette.accent
              : widget.palette.bgElevated,
          border: Border.all(
            color: highlight
                ? widget.palette.accent
                : widget.palette.div,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(child: child),
      ),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip,
        preferBelow: false,
        child: button,
      );
    }
    return button;
  }

  // ─── Collapsed nav item (hk component from web) ─────────
  // web: 36×36, borderRadius 10
  // active: bg accent20, border accent60, icon accent, strokeWidth 2.2
  // inactive: bg transparent, border transparent, icon textSec, strokeWidth 1.7
  Widget _buildCollapsedNavItem({
    required IconData icon,
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: label,
      preferBelow: false,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: active
                ? widget.palette.accent.withValues(alpha: 0.125) // accent20
                : Colors.transparent,
            border: active
                ? Border.all(
                    color: widget.palette.accent.withValues(alpha: 0.375), // accent60
                  )
                : null,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Icon(
              icon,
              size: 16,
              color: active
                  ? widget.palette.accent
                  : widget.palette.textSec,
            ),
          ),
        ),
      ),
    );
  }
}
