import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

/// Project model for the dashboard.
class _Project {
  final String name;
  final String status;

  const _Project({required this.name, this.status = 'READY'});
}

/// Projects dashboard screen with top nav bar and project list.
/// Matches the reference design: Unotusk logo, Projects/Settings tabs,
/// Connected badge, theme toggle, Developer dropdown.
class ProjectsScreen extends StatefulWidget {
  final UnoPalette palette;
  final bool isDark;
  final VoidCallback onToggleTheme;
  final String userName;
  final void Function(String projectName) onOpenProject;
  final VoidCallback onLogOut;

  const ProjectsScreen({
    super.key,
    required this.palette,
    required this.isDark,
    required this.onToggleTheme,
    required this.userName,
    required this.onOpenProject,
    required this.onLogOut,
  });

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  String _activeTab = 'projects'; // 'projects' or 'settings'
  String _filterText = '';
  bool _userMenuOpen = false;
  bool _connectDialogOpen = false;

  // Connect Codebase form controllers
  final _repoUrlController = TextEditingController();
  final _projectNameController = TextEditingController();
  final _branchController = TextEditingController(text: 'main');
  final _slugController = TextEditingController();
  final _descriptionController = TextEditingController();

  final List<_Project> _projects = [];
  bool _isLoadingProjects = true;
  String? _projectsError;

  @override
  void initState() {
    super.initState();
    _fetchServerProjects();
  }

  void _fetchServerProjects() async {
    setState(() {
      _isLoadingProjects = true;
      _projectsError = null;
    });

    try {
      final serverProjects = await ApiService.fetchProjects();
      if (!mounted) return;
      setState(() {
        _isLoadingProjects = false;
        _projects.clear();
        for (final p in serverProjects) {
          _projects.add(_Project(
            name: p.name,
            status: p.upsStatus.toUpperCase(),
          ));
        }
        if (serverProjects.isEmpty && ApiService.lastError != null) {
          _projectsError = ApiService.lastError;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingProjects = false;
        _projects.clear();
        _projectsError = e.toString();
      });
    }
  }

  List<_Project> get _filteredProjects {
    if (_filterText.isEmpty) return _projects;
    return _projects
        .where((p) => p.name.toLowerCase().contains(_filterText.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    final screenWidth = MediaQuery.of(context).size.width;
    final isNarrow = screenWidth < 600;

    return Scaffold(
      backgroundColor: palette.bgBase,
      body: Stack(
        children: [
          Column(
            children: [
              // ─── Top Navigation Bar ───
              _buildTopBar(palette, isNarrow),

              // ─── Content Area ───
              Expanded(
                child: _activeTab == 'projects'
                    ? _buildProjectsContent(palette, isNarrow)
                    : _buildSettingsContent(palette),
              ),
            ],
          ),

          // User Menu Dropdown Overlay
          if (_userMenuOpen)
            _buildUserMenuDropdown(palette),

          // Connect Codebase Dialog Overlay
          if (_connectDialogOpen)
            _buildConnectCodebaseDialog(palette),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _repoUrlController.dispose();
    _projectNameController.dispose();
    _branchController.dispose();
    _slugController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _openConnectDialog() {
    _repoUrlController.clear();
    _projectNameController.clear();
    _branchController.text = 'main';
    _slugController.clear();
    _descriptionController.clear();
    setState(() => _connectDialogOpen = true);
  }

  void _handleConnectAndIngest() async {
    final name = _projectNameController.text.trim();
    final repoUrl = _repoUrlController.text.trim();
    final branch = _branchController.text.trim();
    if (name.isEmpty) return;

    setState(() {
      _projects.insert(0, _Project(name: name, status: 'INGESTING'));
      _connectDialogOpen = false;
    });

    try {
      await ApiService.createProject(
        name: name,
        repoUrl: repoUrl,
        branch: branch.isNotEmpty ? branch : 'main',
        slug: _slugController.text.trim(),
        description: _descriptionController.text.trim(),
      );
      _fetchServerProjects();
    } catch (_) {}
  }

  // ─────────────────────────────────────────────────
  //  Connect Codebase Dialog
  // ─────────────────────────────────────────────────
  Widget _buildConnectCodebaseDialog(UnoPalette palette) {
    return GestureDetector(
      onTap: () => setState(() => _connectDialogOpen = false),
      child: Container(
        color: Colors.black.withValues(alpha: 0.55),
        child: Center(
          child: GestureDetector(
            onTap: () {}, // Absorb taps inside dialog
            child: Container(
              width: 420,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: palette.bgBase,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: palette.div),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 30,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header Row ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Connect Codebase',
                        style: UnoTypography.body(
                          color: palette.text,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      InkWell(
                        onTap: () =>
                            setState(() => _connectDialogOpen = false),
                        borderRadius: BorderRadius.circular(6),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(Icons.close,
                              size: 20, color: palette.textSec),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Link a software repository to start grounding project intelligence.',
                    style: UnoTypography.body(
                      color: palette.textSec,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 22),

                  // ── Repository URL ──
                  _buildFieldLabel('Repository URL', palette),
                  const SizedBox(height: 6),
                  _buildInputField(
                    controller: _repoUrlController,
                    hint: 'https://github.com/owner/repository',
                    icon: Icons.link,
                    palette: palette,
                  ),

                  const SizedBox(height: 18),

                  // ── Project Name + Branch (side by side) ──
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFieldLabel('Project Name', palette),
                            const SizedBox(height: 6),
                            _buildInputField(
                              controller: _projectNameController,
                              hint: 'Requests',
                              icon: Icons.folder_outlined,
                              palette: palette,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFieldLabel('Branch', palette),
                            const SizedBox(height: 6),
                            _buildInputField(
                              controller: _branchController,
                              hint: 'main',
                              icon: Icons.fork_right,
                              palette: palette,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // ── Project Slug ──
                  _buildFieldLabel('Project Slug', palette),
                  const SizedBox(height: 6),
                  _buildInputField(
                    controller: _slugController,
                    hint: 'requests',
                    icon: Icons.tag,
                    palette: palette,
                  ),

                  const SizedBox(height: 18),

                  // ── Description (Optional) ──
                  _buildFieldLabel('Description (Optional)', palette),
                  const SizedBox(height: 6),
                  _buildInputField(
                    controller: _descriptionController,
                    hint: 'Python HTTP for humans',
                    icon: Icons.notes,
                    palette: palette,
                  ),

                  const SizedBox(height: 26),

                  // ── Action Buttons ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Cancel
                      InkWell(
                        onTap: () =>
                            setState(() => _connectDialogOpen = false),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: palette.div),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Cancel',
                            style: UnoTypography.body(
                              color: palette.textSec,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      // Connect & Ingest
                      InkWell(
                        onTap: _handleConnectAndIngest,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: palette.accent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Connect & Ingest',
                            style: UnoTypography.body(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label, UnoPalette palette) {
    return Text(
      label,
      style: UnoTypography.body(
        color: palette.textSec,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required UnoPalette palette,
  }) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: palette.bgSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: palette.div),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(icon, size: 16, color: palette.textSec),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              style: UnoTypography.body(
                color: palette.text,
                fontSize: 13,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: UnoTypography.body(
                  color: palette.textSec.withValues(alpha: 0.5),
                  fontSize: 13,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────
  //  Top Navigation Bar
  // ─────────────────────────────────────────────────
  Widget _buildTopBar(UnoPalette palette, bool isNarrow) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: palette.bgSurface,
        border: Border(
          bottom: BorderSide(color: palette.div, width: 1),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: isNarrow ? 12 : 20),
      child: Row(
        children: [
          // ── Logo ──
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: palette.accent,
              borderRadius: BorderRadius.circular(4),
            ),
            alignment: Alignment.center,
            child: Text(
              'U',
              style: UnoTypography.body(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Unotusk',
            style: UnoTypography.brandSerif(
              palette: palette,
              fontSize: 16,
            ),
          ),

          const SizedBox(width: 24),

          // ── Tab: Projects ──
          _buildTabButton('Projects', Icons.folder_outlined, 'projects', palette),
          const SizedBox(width: 4),
          // ── Tab: Settings ──
          _buildTabButton('Settings', Icons.settings_outlined, 'settings', palette),

          const Spacer(),

          // ── Connected Badge ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              border: Border.all(color: palette.live.withValues(alpha: 0.4)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: palette.live,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Connected (10.0.0.59:8000)',
                  style: UnoTypography.body(
                    color: palette.live,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // ── Theme Toggle ──
          InkWell(
            onTap: widget.onToggleTheme,
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(
                widget.isDark
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
                size: 18,
                color: palette.textSec,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // ── Developer Menu ──
          GestureDetector(
            onTap: () => setState(() => _userMenuOpen = !_userMenuOpen),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: palette.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    widget.userName.isNotEmpty
                        ? widget.userName[0].toUpperCase()
                        : 'D',
                    style: UnoTypography.body(
                      color: palette.accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (!isNarrow) ...[
                  const SizedBox(width: 8),
                  Text(
                    widget.userName,
                    style: UnoTypography.body(
                      color: palette.text,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 16,
                    color: palette.textSec,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(
      String label, IconData icon, String tab, UnoPalette palette) {
    final isActive = _activeTab == tab;

    return GestureDetector(
      onTap: () => setState(() => _activeTab = tab),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? palette.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isActive ? Colors.white : palette.textSec,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: UnoTypography.body(
                color: isActive ? Colors.white : palette.textSec,
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────
  //  Projects Content
  // ─────────────────────────────────────────────────
  Widget _buildProjectsContent(UnoPalette palette, bool isNarrow) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isNarrow ? 20 : 40,
        vertical: 32,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Row ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Projects',
                      style: UnoTypography.body(
                        color: palette.text,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Software projects available in your workspace',
                      style: UnoTypography.body(
                        color: palette.textSec,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              // ── Action Buttons ──
              Row(
                children: [
                  _buildActionButton(
                    icon: Icons.refresh,
                    label: 'Refresh',
                    palette: palette,
                    filled: false,
                    onTap: _fetchServerProjects,
                  ),
                  const SizedBox(width: 10),
                  _buildActionButton(
                    icon: Icons.add,
                    label: 'Connect Codebase',
                    palette: palette,
                    filled: true,
                    onTap: _openConnectDialog,
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Filter Input ──
          SizedBox(
            width: 280,
            height: 40,
            child: TextField(
              onChanged: (v) => setState(() => _filterText = v),
              style: UnoTypography.body(
                color: palette.text,
                fontSize: 13,
              ),
              decoration: InputDecoration(
                hintText: 'Filter projects...',
                hintStyle: UnoTypography.body(
                  color: palette.textSec.withValues(alpha: 0.6),
                  fontSize: 13,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  size: 18,
                  color: palette.textSec,
                ),
                filled: true,
                fillColor: palette.bgSurface,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: palette.div),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: palette.div),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: palette.accent, width: 1.5),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── Project Cards ──
          if (_isLoadingProjects)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Column(
                  children: [
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Loading projects from http://10.0.0.59:8000...',
                      style: UnoTypography.body(
                        color: palette.textSec,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (_filteredProjects.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
              decoration: BoxDecoration(
                color: palette.bgSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: palette.div),
              ),
              child: Column(
                children: [
                  Icon(
                    _projectsError != null
                        ? Icons.cloud_off_rounded
                        : Icons.folder_open_rounded,
                    size: 36,
                    color: _projectsError != null
                        ? const Color(0xFFD4725A)
                        : palette.textSec,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _projectsError != null
                        ? 'Backend Server Unreachable'
                        : 'No projects found in workspace',
                    style: UnoTypography.body(
                      color: palette.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _projectsError != null
                        ? 'Could not connect to http://10.0.0.59:8000.\nPlease verify the server is running.'
                        : 'Connect a codebase using the button above to start your first project.',
                    textAlign: TextAlign.center,
                    style: UnoTypography.body(
                      color: palette.textSec,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _fetchServerProjects,
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Retry Connection'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: palette.accent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            )
          else
            ..._filteredProjects
                .map((project) => _buildProjectCard(project, palette)),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required UnoPalette palette,
    required bool filled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: filled ? palette.accent : Colors.transparent,
          border: filled
              ? null
              : Border.all(color: palette.div),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: filled ? Colors.white : palette.textSec,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: UnoTypography.body(
                color: filled ? Colors.white : palette.text,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectCard(_Project project, UnoPalette palette) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: palette.bgSurface,
        border: Border.all(color: palette.div.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Code icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: palette.bgBase,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: palette.div),
            ),
            alignment: Alignment.center,
            child: Text(
              '<>',
              style: UnoTypography.mono(
                color: palette.textSec,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(width: 14),

          // Project name
          Text(
            project.name,
            style: UnoTypography.body(
              color: palette.text,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(width: 12),

          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: palette.live.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              project.status,
              style: UnoTypography.mono(
                color: palette.live,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
            ),
          ),

          const Spacer(),

          // Open button
          InkWell(
            onTap: () => widget.onOpenProject(project.name),
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Open',
                    style: UnoTypography.body(
                      color: palette.accent,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward,
                    size: 15,
                    color: palette.accent,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────
  //  User Menu Dropdown
  // ─────────────────────────────────────────────────
  Widget _buildUserMenuDropdown(UnoPalette palette) {
    return Positioned(
      top: 54,
      right: 16,
      child: GestureDetector(
        onTap: () {}, // Prevent closing when tapping inside
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: palette.bgSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: palette.div),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: palette.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      widget.userName.isNotEmpty
                          ? widget.userName[0].toUpperCase()
                          : 'U',
                      style: UnoTypography.body(
                        color: palette.accent,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.userName,
                          style: UnoTypography.body(
                            color: palette.text,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Acme Corp · LAN Pilot',
                          style: UnoTypography.body(
                            color: palette.textSec,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: palette.bgBase,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: palette.div.withValues(alpha: 0.5)),
                ),
                child: Column(
                  children: [
                    _buildUserDetailRow('Host IP', '10.0.0.104', palette),
                    const SizedBox(height: 4),
                    _buildUserDetailRow('Server', '10.0.0.59:8000', palette),
                    const SizedBox(height: 4),
                    _buildUserDetailRow('Role', 'Pilot Lead (Admin)', palette),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Divider(height: 1, color: palette.div),
              const SizedBox(height: 8),
              InkWell(
                onTap: () {
                  setState(() => _userMenuOpen = false);
                  widget.onLogOut();
                },
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  child: Row(
                    children: [
                      Icon(Icons.logout, size: 16, color: palette.inferred),
                      const SizedBox(width: 8),
                      Text(
                        'Sign Out',
                        style: UnoTypography.body(
                          color: palette.inferred,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserDetailRow(String label, String value, UnoPalette palette) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: UnoTypography.mono(
            color: palette.textSec,
            fontSize: 10,
          ),
        ),
        Text(
          value,
          style: UnoTypography.mono(
            color: palette.text,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────
  //  Settings Content (Real LAN Pilot Configuration)
  // ─────────────────────────────────────────────────
  Widget _buildSettingsContent(UnoPalette palette) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 820),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'LAN Pilot Environment Settings',
                style: UnoTypography.body(
                  color: palette.text,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Operational topology, Docker service status, and device allocation from LAN_PILOT_MATRIX.md',
                style: UnoTypography.body(
                  color: palette.textSec,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 24),

              // Server Status Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: palette.bgSurface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: palette.div),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.dns, size: 20, color: palette.accent),
                        const SizedBox(width: 10),
                        Text(
                          'Server Host & Health Probe',
                          style: UnoTypography.body(
                            color: palette.text,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: palette.live.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'ONLINE (v0.1.0)',
                            style: UnoTypography.mono(
                              color: palette.live,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _buildSettingsRow('Primary Server URL', 'http://10.0.0.59:8000', palette),
                    _buildSettingsRow('LAN Interface', 'wlo1 (Private Subnet 10.0.0.0/24)', palette),
                    _buildSettingsRow('Health Endpoints', '/health (200 OK) · /health/ready (200 OK)', palette),
                    _buildSettingsRow('Average Response Time', '28ms across 6 employee nodes', palette),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Docker Services
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: palette.bgSurface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: palette.div),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.layers_outlined, size: 20, color: palette.accent),
                        const SizedBox(width: 10),
                        Text(
                          'Docker Compose Services (4 Containers)',
                          style: UnoTypography.body(
                            color: palette.text,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _buildServiceItem('unotusk-api', 'FastAPI · Bound to 0.0.0.0:8000 · JWT & CORS active', 'Healthy', palette),
                    const SizedBox(height: 8),
                    _buildServiceItem('unotusk-worker', 'Async Ingestion · AST parsing & pgvector indexing', 'Up', palette),
                    const SizedBox(height: 8),
                    _buildServiceItem('unotusk-postgres', 'PostgreSQL with pgvector · Internal 5432 (isolated)', 'Healthy', palette),
                    const SizedBox(height: 8),
                    _buildServiceItem('unotusk-redis', 'Task Queue & Cache · Internal 6379 (isolated)', 'Healthy', palette),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Node Matrix
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: palette.bgSurface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: palette.div),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.devices, size: 20, color: palette.accent),
                        const SizedBox(width: 10),
                        Text(
                          'Pilot Hardware & Device Allocation',
                          style: UnoTypography.body(
                            color: palette.text,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _buildNodeRow('SRV-01', 'Linux x86_64 Host', '10.0.0.59', 'Docker Stack', palette),
                    _buildNodeRow('WIN-01', 'Windows 11 Laptop', '10.0.0.101', 'dev1@acme.com', palette),
                    _buildNodeRow('WIN-02', 'Windows 11 Laptop', '10.0.0.102', 'dev2@acme.com', palette),
                    _buildNodeRow('WIN-03', 'Windows 10 Laptop', '10.0.0.103', 'qa1@acme.com', palette),
                    _buildNodeRow('WIN-04', 'Windows 11 Laptop', '10.0.0.104', 'lead@acme.com (Admin)', palette),
                    _buildNodeRow('MAC-01', 'macOS 14 Apple Silicon', '10.0.0.105', 'dev3@acme.com', palette),
                    _buildNodeRow('MAC-02', 'macOS 13 Intel/M-series', '10.0.0.106', 'dev4@acme.com', palette),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsRow(String label, String value, UnoPalette palette) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 180,
            child: Text(
              label,
              style: UnoTypography.mono(
                color: palette.textSec,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: UnoTypography.mono(
                color: palette.text,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem(String name, String desc, String status, UnoPalette palette) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: palette.bgBase,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: palette.div.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Text(
            name,
            style: UnoTypography.mono(
              color: palette.text,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              desc,
              style: UnoTypography.body(
                color: palette.textSec,
                fontSize: 12,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: palette.live.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: UnoTypography.mono(
                color: palette.live,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNodeRow(String id, String device, String ip, String user, UnoPalette palette) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              id,
              style: UnoTypography.mono(
                color: palette.accent,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(
            width: 200,
            child: Text(
              device,
              style: UnoTypography.body(
                color: palette.text,
                fontSize: 12,
              ),
            ),
          ),
          SizedBox(
            width: 120,
            child: Text(
              ip,
              style: UnoTypography.mono(
                color: palette.textSec,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              user,
              style: UnoTypography.body(
                color: palette.text,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
