import 'dart:async';
import 'package:flutter/material.dart';
import 'data/mock_data.dart';
import 'dialogs/archived_modal.dart';
import 'dialogs/help_modal.dart';
import 'dialogs/notifications_panel.dart';
import 'dialogs/settings_modal.dart';
import 'models/models.dart';
import 'screens/admin_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/ingestion_feed_screen.dart';
import 'screens/ontology_graph_screen.dart';
import 'screens/spec_history_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/sidebar.dart';
import 'widgets/top_nav_bar.dart';

void main() {
  runApp(const UnotuskApp());
}

class UnotuskApp extends StatefulWidget {
  const UnotuskApp({super.key});

  @override
  State<UnotuskApp> createState() => _UnotuskAppState();
}

class _UnotuskAppState extends State<UnotuskApp> {
  bool _isDark = false;

  void _toggleTheme() {
    setState(() {
      _isDark = !_isDark;
    });
  }

  void _setTheme(bool isDark) {
    setState(() {
      _isDark = isDark;
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = _isDark ? UnoPalette.dark : UnoPalette.light;

    return MaterialApp(
      title: 'Unotusk MVP',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: _isDark ? Brightness.dark : Brightness.light,
        scaffoldBackgroundColor: palette.bgBase,
        canvasColor: palette.bgSurface,
        dividerColor: palette.div,
      ),
      home: AppShell(
        isDark: _isDark,
        onToggleTheme: _toggleTheme,
        onSetTheme: _setTheme,
      ),
    );
  }
}

class AppShell extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;
  final Function(bool) onSetTheme;

  const AppShell({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
    required this.onSetTheme,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  bool _isAuthenticated = false;
  UserModel _user = const UserModel(name: 'Naren D', org: 'Acme Corp');

  bool _sidebarOpen = true;
  String _activeView = 'chat'; // chat, spec-history, graph, feed, admin
  String _defaultSettingsTab = 'general';

  final List<ChatMessage> _messages = [];
  bool _isGenerating = false;
  final List<Timer> _generationTimers = [];

  bool _notificationsOpen = false;
  late List<NotificationItem> _notifications;

  bool _settingsModalOpen = false;
  bool _archivedModalOpen = false;
  bool _helpModalOpen = false;

  @override
  void initState() {
    super.initState();
    _notifications = MockData.initialNotifications;
  }

  @override
  void dispose() {
    _clearTimers();
    super.dispose();
  }

  void _clearTimers() {
    for (final timer in _generationTimers) {
      timer.cancel();
    }
    _generationTimers.clear();
  }

  void _handleAuthenticated(String name, String org) {
    setState(() {
      _user = UserModel(name: name, org: org);
      _isAuthenticated = true;
    });
  }

  void _handleLogOut() {
    _clearTimers();
    setState(() {
      _messages.clear();
      _isAuthenticated = false;
    });
  }

  void _handleNewQuery() {
    _clearTimers();
    setState(() {
      _messages.clear();
      _isGenerating = false;
      _activeView = 'chat';
    });
  }

  void _handleSubmitQuery(String text) {
    if (text.trim().isEmpty || _isGenerating) return;

    final queryId = 'q-${DateTime.now().millisecondsSinceEpoch}';
    final genId = 'g-${DateTime.now().millisecondsSinceEpoch + 1}';

    final canned = MockData.cannedResponses[text.trim()] ??
        MockData.fallbackResponse;

    setState(() {
      _isGenerating = true;
      _messages.add(ChatMessage(
        id: queryId,
        kind: MessageKind.query,
        text: text.trim(),
      ));
      _messages.add(ChatMessage(
        id: genId,
        kind: MessageKind.generating,
        phase: 'ingesting',
      ));
    });

    _clearTimers();

    // Phase 1 -> Scoring at 1600ms
    _generationTimers.add(Timer(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      setState(() {
        final idx = _messages.indexWhere((m) => m.id == genId);
        if (idx != -1) {
          _messages[idx] = _messages[idx].copyWith(phase: 'scoring');
        }
      });
    }));

    // Phase 2 -> DeepScoring at 3200ms
    _generationTimers.add(Timer(const Duration(milliseconds: 3200), () {
      if (!mounted) return;
      setState(() {
        final idx = _messages.indexWhere((m) => m.id == genId);
        if (idx != -1) {
          _messages[idx] = _messages[idx].copyWith(phase: 'deepScoring');
        }
      });
    }));

    // Phase 3 -> Response at 4600ms
    _generationTimers.add(Timer(const Duration(milliseconds: 4600), () {
      if (!mounted) return;
      setState(() {
        _isGenerating = false;
        final idx = _messages.indexWhere((m) => m.id == genId);
        if (idx != -1) {
          _messages[idx] = ChatMessage(
            id: genId,
            kind: MessageKind.response,
            data: canned,
          );
        }
      });
    }));
  }

  void _loadRecentChat(int id) {
    final recent = MockData.recentChats.firstWhere(
      (c) => c.id == id,
      orElse: () => MockData.recentChats.first,
    );
    final response = MockData.cannedResponses[recent.title] ??
        MockData.fallbackResponse;

    _clearTimers();
    setState(() {
      _isGenerating = false;
      _messages.clear();
      _messages.add(ChatMessage(
        id: 'q-recent-$id',
        kind: MessageKind.query,
        text: recent.title,
      ));
      _messages.add(ChatMessage(
        id: 'r-recent-$id',
        kind: MessageKind.response,
        data: response,
      ));
      _activeView = 'chat';
    });
  }

  void _openSettingsTab(String tab) {
    if (tab == 'support') {
      setState(() => _helpModalOpen = true);
    } else {
      setState(() {
        _defaultSettingsTab = tab == 'settings' ? 'general' : tab;
        _settingsModalOpen = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.isDark ? UnoPalette.dark : UnoPalette.light;

    if (!_isAuthenticated) {
      return AuthScreen(
        palette: palette,
        onAuthenticated: _handleAuthenticated,
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final unreadCount = _notifications.where((n) => !n.read).length;

    return Scaffold(
      backgroundColor: palette.bgBase,
      body: Stack(
        children: [
          Row(
            children: [
              // Sidebar (Desktop / Wide screen)
              if (!isMobile)
                UnoSidebar(
                  open: _sidebarOpen,
                  onToggle: () => setState(() => _sidebarOpen = !_sidebarOpen),
                  onNewQuery: _handleNewQuery,
                  palette: palette,
                  activeView: _activeView,
                  onViewChange: (v) => setState(() {
                    _activeView = v;
                    _notificationsOpen = false;
                  }),
                  onLoadRecentChat: _loadRecentChat,
                  user: _user,
                  onLogOut: _handleLogOut,
                  onNavigateSettings: _openSettingsTab,
                  onOpenArchivedModal: () =>
                      setState(() => _archivedModalOpen = true),
                ),

              // Main Application Area
              Expanded(
                child: isMobile
                    ? SafeArea(
                        child: Column(
                          children: [
                            // Top sticky nav bar
                            TopNavBar(
                              palette: palette,
                              isDark: widget.isDark,
                              unreadCount: unreadCount,
                              notificationsOpen: _notificationsOpen,
                              onToggleNotifications: () => setState(
                                  () => _notificationsOpen = !_notificationsOpen),
                              onToggleTheme: widget.onToggleTheme,
                              showSidebarToggle: isMobile,
                              onToggleSidebar: () =>
                                  setState(() => _sidebarOpen = !_sidebarOpen),
                            ),

                            // Active Screen Content
                            Expanded(
                              child: _buildCurrentScreen(palette),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        children: [
                          // Top sticky nav bar
                          TopNavBar(
                            palette: palette,
                            isDark: widget.isDark,
                            unreadCount: unreadCount,
                            notificationsOpen: _notificationsOpen,
                            onToggleNotifications: () => setState(
                                () => _notificationsOpen = !_notificationsOpen),
                            onToggleTheme: widget.onToggleTheme,
                            showSidebarToggle: isMobile,
                            onToggleSidebar: () =>
                                setState(() => _sidebarOpen = !_sidebarOpen),
                          ),

                          // Active Screen Content
                          Expanded(
                            child: _buildCurrentScreen(palette),
                          ),
                        ],
                      ),
              ),
            ],
          ),

          // Mobile Drawer overlay (if mobile and sidebar open)
          if (isMobile && _sidebarOpen) ...[
            GestureDetector(
              onTap: () => setState(() => _sidebarOpen = false),
              child: Container(
                color: Colors.black.withValues(alpha: 0.5),
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: UnoSidebar(
                open: true,
                onToggle: () => setState(() => _sidebarOpen = false),
                onNewQuery: () {
                  setState(() => _sidebarOpen = false);
                  _handleNewQuery();
                },
                palette: palette,
                activeView: _activeView,
                onViewChange: (v) => setState(() {
                  _activeView = v;
                  _sidebarOpen = false;
                  _notificationsOpen = false;
                }),
                onLoadRecentChat: (id) {
                  setState(() => _sidebarOpen = false);
                  _loadRecentChat(id);
                },
                user: _user,
                onLogOut: _handleLogOut,
                onNavigateSettings: (tab) {
                  setState(() => _sidebarOpen = false);
                  _openSettingsTab(tab);
                },
                onOpenArchivedModal: () {
                  setState(() {
                    _sidebarOpen = false;
                    _archivedModalOpen = true;
                  });
                },
              ),
            ),
          ],

          // Notifications Drawer Popup
          if (_notificationsOpen)
            Positioned(
              top: isMobile ? MediaQuery.of(context).padding.top + 52 : 62,
              right: 20,
              child: NotificationsPanel(
                palette: palette,
                notifications: _notifications,
                onClearAll: () {
                  setState(() {
                    for (var n in _notifications) {
                      n.read = true;
                    }
                  });
                },
                onClose: () => setState(() => _notificationsOpen = false),
              ),
            ),

          // Settings Modal Overlay
          if (_settingsModalOpen)
            SettingsModal(
              palette: palette,
              isDark: widget.isDark,
              onThemeChange: widget.onSetTheme,
              onClose: () => setState(() => _settingsModalOpen = false),
              defaultTab: _defaultSettingsTab,
              user: _user,
            ),

          // Archived Modal Overlay
          if (_archivedModalOpen)
            ArchivedModal(
              palette: palette,
              onClose: () => setState(() => _archivedModalOpen = false),
              onSelectChat: (id) {
                // optionally load chat
              },
            ),

          // Help & Support Modal Overlay
          if (_helpModalOpen)
            HelpModal(
              palette: palette,
              onClose: () => setState(() => _helpModalOpen = false),
            ),
        ],
      ),
    );
  }

  Widget _buildCurrentScreen(UnoPalette palette) {
    switch (_activeView) {
      case 'spec-history':
        return SpecHistoryScreen(palette: palette);
      case 'graph':
        return OntologyGraphScreen(palette: palette);
      case 'feed':
        return IngestionFeedScreen(palette: palette);
      case 'admin':
        return AdminScreen(
          palette: palette,
          isDark: widget.isDark,
          onThemeChange: widget.onSetTheme,
          user: _user,
          defaultTab: _defaultSettingsTab,
        );
      case 'chat':
      default:
        return ChatScreen(
          palette: palette,
          messages: _messages,
          isGenerating: _isGenerating,
          onSubmitQuery: _handleSubmitQuery,
        );
    }
  }
}
