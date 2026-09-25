import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../data/mock_data.dart';
import '../theme/app_theme.dart';
import '../widgets/unotusk_logo.dart';

class AuthScreen extends StatefulWidget {
  final UnoPalette palette;
  final Function(String name, String org) onAuthenticated;
  final String? sessionMsg;

  const AuthScreen({
    super.key,
    required this.palette,
    required this.onAuthenticated,
    this.sessionMsg,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  String _state = 'entry'; // entry, checking, denied, oidc-consent, oidc-token-exchange, new-org, authenticating
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _orgController = TextEditingController();
  bool _termsAgreed = false;
  String _errorMsg = '';
  int _tokenExchangeStep = 1;

  Map<String, String> _providerInfo = {
    'name': 'Google OpenID Provider',
    'issuer': 'https://accounts.google.com',
    'type': 'google',
  };

  void _verifyEmail() {
    final email = _emailController.text.trim();
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$').hasMatch(email)) {
      return;
    }

    final domain = email.split('@').last.toLowerCase();

    setState(() {
      _state = 'checking';
    });

    Timer(const Duration(milliseconds: 1100), () {
      if (!mounted) return;

      if (MockData.blockedDomains.contains(domain)) {
        setState(() {
          _errorMsg =
              'Unotusk requires workplace OpenID Connect (OIDC) authentication. Sign in with your work email address.';
          _state = 'denied';
        });
        return;
      }

      final known = MockData.knownOrganizations[domain];
      if (known != null) {
        setState(() {
          _providerInfo = known;
          _state = 'oidc-consent';
        });
      } else {
        final guessedOrg = domain.split('.').first;
        final formattedOrg = guessedOrg.isNotEmpty
            ? guessedOrg[0].toUpperCase() + guessedOrg.substring(1)
            : 'Workspace';
        _orgController.text = formattedOrg;
        setState(() {
          _state = 'new-org';
        });
      }
    });
  }

  void _selectQuickProvider(String name, String issuer, String type) {
    setState(() {
      _providerInfo = {
        'name': name,
        'issuer': issuer,
        'type': type,
      };
      _state = 'oidc-consent';
    });
  }

  void _startTokenExchange() {
    setState(() {
      _state = 'oidc-token-exchange';
      _tokenExchangeStep = 1;
    });

    Timer(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _tokenExchangeStep = 2);
    });
    Timer(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => _tokenExchangeStep = 3);
    });
  }

  void _finishAuthentication() {
    setState(() {
      _state = 'authenticating';
    });

    Timer(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      final email = _emailController.text.trim();
      final defaultName = email.isNotEmpty
          ? email.split('@').first[0].toUpperCase() +
              email.split('@').first.substring(1)
          : 'Naren D';
      final userName =
          _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : defaultName;
      final userOrg = _orgController.text.trim().isNotEmpty
          ? _orgController.text.trim()
          : (_providerInfo['name']?.split(' ').first ?? 'Acme Corp');

      widget.onAuthenticated(userName, userOrg);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.palette.bgBase == const Color(0xFF181816);

    if (_state == 'authenticating') {
      return Scaffold(
        backgroundColor: const Color(0xFF0D0A08),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Color(0xFF6EC8B8),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Establishing OIDC Session...',
                style: UnoTypography.mono(
                  color: const Color(0xFFA89070),
                  fontSize: 13,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: widget.palette.bgBase,
      body: Stack(
        children: [
          // Top Left Brand Bar — web: position fixed, top 24, left 28
          Positioned(
            top: 24,
            left: 28,
            child: Row(
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
                const SizedBox(width: 14),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: widget.palette.accent.withValues(alpha: 0.125), // accent20
                    border: Border.all(
                      color: widget.palette.accent.withValues(alpha: 0.25), // accent40
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'OIDC 1.0 SSO',
                    style: UnoTypography.mono(
                      color: widget.palette.accent,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Center Card — web: padding 80px 24px 48px, centered
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 80, 24, 48),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: _state == 'oidc-token-exchange' ? 480 : 420,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal:
                      MediaQuery.of(context).size.width < 450 ? 20 : 32,
                  vertical: 32,
                ),
                decoration: BoxDecoration(
                  color: widget.palette.bgElevated,
                  border: Border.all(color: widget.palette.div),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.24),
                      blurRadius: 56,
                      offset: const Offset(0, 24),
                    ),
                  ],
                ),
                child: _buildStateContent(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStateContent() {
    switch (_state) {
      case 'checking':
        return _buildChecking();
      case 'denied':
        return _buildDenied();
      case 'oidc-consent':
        return _buildOidcConsent();
      case 'oidc-token-exchange':
        return _buildTokenExchange();
      case 'new-org':
        return _buildNewOrg();
      case 'entry':
      default:
        return _buildEntry();
    }
  }

  // Google "G" icon widget matching web SVG exactly
  Widget _buildGoogleIcon({double size = 17}) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GoogleIconPainter()),
    );
  }

  // Microsoft 4-square icon matching web SVG exactly
  Widget _buildMicrosoftIcon({double size = 17}) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _MicrosoftIconPainter()),
    );
  }

  Widget _buildEntry() {
    final isEmailValid =
        RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$').hasMatch(_emailController.text.trim());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Badge — matches web: inline-flex, gap 6, padding 4px 10px
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: widget.palette.accent.withValues(alpha: 0.08), // accent14 hex
              border: Border.all(
                color: widget.palette.accent.withValues(alpha: 0.20), // accent33 hex
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.shield,
                    size: 12, color: widget.palette.accent),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'OpenID Connect Authentication',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: UnoTypography.mono(
                      color: widget.palette.text,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Title — web: Young Serif, 24px, weight 400, letterSpacing -0.02em
        Text(
          'Sign in to Unotusk',
          style: UnoTypography.brandSerif(
            palette: widget.palette,
            fontSize: 24,
          ),
        ),
        const SizedBox(height: 8),

        // Subtitle — web: Inter 13px, textSec, lineHeight 1.55
        Text(
          'Authenticating via OpenID Connect (OIDC) identity provider for single sign-on security.',
          style: UnoTypography.body(
            color: widget.palette.textSec,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 20),

        // Label — web: Inter 12px fontWeight 500, "Work Email Address"
        Text(
          'Work Email Address',
          style: UnoTypography.body(
            color: widget.palette.textSec,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 5),

        // Input — web: padding 11px 14px, bgSurface, border div, borderRadius 12
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: widget.palette.bgSurface,
            border: Border.all(color: widget.palette.div),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _emailController,
            style: UnoTypography.body(color: widget.palette.text, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'you@company.com',
              hintStyle:
                  UnoTypography.body(color: widget.palette.textSec, fontSize: 14),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 11),
            ),
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _verifyEmail(),
          ),
        ),
        const SizedBox(height: 12),

        // Continue Button — web: height 40, borderRadius 9, accent bg, #0D0A08 text
        SizedBox(
          height: 40,
          child: ElevatedButton(
            onPressed: isEmailValid ? _verifyEmail : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: isEmailValid
                  ? widget.palette.accent
                  : widget.palette.accent.withValues(alpha: 0.25),
              foregroundColor: isEmailValid
                  ? const Color(0xFF0D0A08)
                  : widget.palette.textSec,
              elevation: 0,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9),
              ),
            ),
            child: Text(
              'Continue with OIDC Discovery',
              style: UnoTypography.body(
                color: isEmailValid
                    ? const Color(0xFF0D0A08)
                    : widget.palette.textSec,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        // Divider — web: margin 20px 0 16px, gap 10
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: Container(height: 1, color: widget.palette.div)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                'OR SIGN IN VIA OIDC PROVIDER',
                style: UnoTypography.mono(
                  color: widget.palette.textSec,
                  fontSize: 10,
                ).copyWith(letterSpacing: 0.6),
              ),
            ),
            Expanded(child: Container(height: 1, color: widget.palette.div)),
          ],
        ),
        const SizedBox(height: 16),

        // Provider buttons — web: height 40, centered, gap 9, bgSurface, border div, borderRadius 9
        _buildProviderButton(
          icon: _buildGoogleIcon(size: 17),
          label: 'Sign in with Google OIDC',
          onTap: () {
            _emailController.text = 'naren@unotusk.com';
            _selectQuickProvider('Google OIDC',
                'https://accounts.google.com', 'google');
          },
        ),
        const SizedBox(height: 9),
        _buildProviderButton(
          icon: _buildMicrosoftIcon(size: 17),
          label: 'Sign in with Microsoft Entra OIDC',
          onTap: () {
            _emailController.text = 'sarah@microsoft.com';
            _selectQuickProvider('Microsoft Entra OIDC',
                'https://login.microsoftonline.com/common/v2.0', 'microsoft');
          },
        ),
        const SizedBox(height: 9),
        _buildProviderButton(
          icon: Icon(LucideIcons.lock, size: 14, color: widget.palette.textSec),
          label: 'Custom OpenID Provider (Issuer URL)',
          onTap: () {
            // Could navigate to custom issuer entry
            _selectQuickProvider('Custom Enterprise OIDC',
                'https://auth.acme-corp.com/realms/production', 'custom');
          },
        ),

        const SizedBox(height: 28),
        Text(
          '© 2026 Unotusk Pvt. Ltd. · OpenID Connect 1.0 SSO',
          textAlign: TextAlign.center,
          style: UnoTypography.mono(
            color: widget.palette.textSec,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  // Provider button matching web exactly: height 40, centered icon+text, bgSurface, border div, borderRadius 9
  Widget _buildProviderButton({
    required Widget icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 40,
      child: Material(
        color: widget.palette.bgSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9),
          side: BorderSide(color: widget.palette.div),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(9),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                icon,
                const SizedBox(width: 9),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: UnoTypography.body(
                      color: widget.palette.text,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChecking() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 20),
        SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(widget.palette.accent),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          _emailController.text,
          style: UnoTypography.mono(
            color: widget.palette.text,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Verifying work domain & OIDC discovery endpoint…',
          textAlign: TextAlign.center,
          style: UnoTypography.body(
            color: widget.palette.textSec,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildDenied() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(LucideIcons.alertTriangle,
            size: 32, color: widget.palette.inferred),
        const SizedBox(height: 14),
        Text(
          'Personal Email Blocked',
          textAlign: TextAlign.center,
          style: UnoTypography.brandSerif(
            palette: widget.palette,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          _errorMsg,
          textAlign: TextAlign.center,
          style: UnoTypography.body(
            color: widget.palette.textSec,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 24),
        OutlinedButton(
          onPressed: () => setState(() => _state = 'entry'),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: widget.palette.div),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Try another email',
            style: UnoTypography.body(
              color: widget.palette.text,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOidcConsent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Authorize Unotusk via OpenID Connect',
          style: UnoTypography.body(
            color: widget.palette.text,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'The Relying Party (Unotusk) is requesting identity claims from your OpenID Provider using Authorization Code Flow with PKCE.',
          style: UnoTypography.body(
            color: widget.palette.textSec,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 16),

        // Provider Details Card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: widget.palette.bgSurface,
            border: Border.all(color: widget.palette.div),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMetaRow('Provider', _providerInfo['name'] ?? 'Google'),
              _buildMetaRow('Issuer', _providerInfo['issuer'] ?? 'https://accounts.google.com'),
              _buildMetaRow('Client ID', 'unotusk-client-id-prod'),
              _buildMetaRow('Scope', 'openid profile email groups'),
              _buildMetaRow('Flow', 'Authorization Code + PKCE (S256)'),
            ],
          ),
        ),
        const SizedBox(height: 20),

        ElevatedButton(
          onPressed: _startTokenExchange,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.palette.accent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Authorize & Continue',
            style: UnoTypography.body(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => setState(() => _state = 'entry'),
          child: Text(
            'Cancel',
            style: UnoTypography.body(
              color: widget.palette.textSec,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: UnoTypography.mono(
                color: widget.palette.textSec,
                fontSize: 10,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: UnoTypography.mono(
                color: widget.palette.text,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTokenExchange() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'PKCE Token Exchange',
          style: UnoTypography.body(
            color: widget.palette.text,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Verifying authorization code at token endpoint...',
          style: UnoTypography.body(
            color: widget.palette.textSec,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 20),

        _buildStepItem(1, 'Validating authorization code & state parameter'),
        const SizedBox(height: 10),
        _buildStepItem(2, 'Exchanging code at token endpoint via PKCE (S256)'),
        const SizedBox(height: 10),
        _buildStepItem(3, 'Verifying ID Token signature & claims (RS256)'),
        const SizedBox(height: 24),

        ElevatedButton(
          onPressed: _tokenExchangeStep >= 3 ? _finishAuthentication : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.palette.accent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'Complete OIDC Sign In → Enter Unotusk',
              maxLines: 1,
              softWrap: false,
              style: UnoTypography.body(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepItem(int stepNumber, String title) {
    final done = _tokenExchangeStep >= stepNumber;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.palette.bgSurface,
        border: Border.all(
          color: done
              ? widget.palette.live.withValues(alpha: 0.4)
              : widget.palette.div,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            done ? LucideIcons.checkCircle2 : LucideIcons.circle,
            size: 16,
            color: done ? widget.palette.live : widget.palette.textSec,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: UnoTypography.body(
                color: done ? widget.palette.text : widget.palette.textSec,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewOrg() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Setup Workspace',
          style: UnoTypography.brandSerif(
            palette: widget.palette,
            fontSize: 22,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Complete initial single sign-on workspace registration for your team.',
          style: UnoTypography.body(
            color: widget.palette.textSec,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 18),

        Text('YOUR NAME',
            style: UnoTypography.mono(
                color: widget.palette.textSec, fontSize: 11)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: widget.palette.bgSurface,
            border: Border.all(color: widget.palette.div),
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: _nameController,
            style: UnoTypography.body(color: widget.palette.text, fontSize: 13),
            decoration: const InputDecoration(
                hintText: 'Naren D', border: InputBorder.none),
          ),
        ),
        const SizedBox(height: 14),

        Text('WORKSPACE / ORGANIZATION',
            style: UnoTypography.mono(
                color: widget.palette.textSec, fontSize: 11)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: widget.palette.bgSurface,
            border: Border.all(color: widget.palette.div),
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: _orgController,
            style: UnoTypography.body(color: widget.palette.text, fontSize: 13),
            decoration: const InputDecoration(
                hintText: 'Acme Corp', border: InputBorder.none),
          ),
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Checkbox(
              value: _termsAgreed,
              activeColor: widget.palette.accent,
              onChanged: (val) => setState(() => _termsAgreed = val ?? false),
            ),
            Expanded(
              child: Text(
                'I agree to Unotusk Terms of Service & Privacy Policy',
                style: UnoTypography.body(
                    color: widget.palette.textSec, fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        ElevatedButton(
          onPressed: _termsAgreed ? _startTokenExchange : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.palette.accent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Create Workspace & Continue',
            style: UnoTypography.body(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

/// Google "G" icon — exact SVG paths from web source
class _GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.width / 24;

    // Blue
    final blue = Path()
      ..moveTo(22.56 * s, 12.25 * s)
      ..cubicTo(22.56 * s, 11.47 * s, 22.49 * s, 10.72 * s, 22.36 * s, 10 * s)
      ..lineTo(12 * s, 10 * s)
      ..lineTo(12 * s, 14.26 * s)
      ..lineTo(17.92 * s, 14.26 * s)
      ..cubicTo(17.66 * s, 15.63 * s, 16.88 * s, 16.79 * s, 15.71 * s, 17.57 * s)
      ..lineTo(15.71 * s, 20.34 * s)
      ..lineTo(19.28 * s, 20.34 * s)
      ..cubicTo(21.36 * s, 18.17 * s, 22.56 * s, 15.42 * s, 22.56 * s, 12.25 * s)
      ..close();
    canvas.drawPath(blue, Paint()..color = const Color(0xFF4285F4));

    // Green
    final green = Path()
      ..moveTo(12 * s, 23 * s)
      ..cubicTo(14.97 * s, 23 * s, 17.46 * s, 22.02 * s, 19.28 * s, 20.34 * s)
      ..lineTo(15.71 * s, 17.57 * s)
      ..cubicTo(14.73 * s, 18.23 * s, 13.48 * s, 18.63 * s, 12 * s, 18.63 * s)
      ..cubicTo(9.14 * s, 18.63 * s, 6.71 * s, 16.70 * s, 5.84 * s, 14.10 * s)
      ..lineTo(2.18 * s, 14.10 * s)
      ..lineTo(2.18 * s, 16.94 * s)
      ..cubicTo(3.99 * s, 20.53 * s, 7.70 * s, 23 * s, 12 * s, 23 * s)
      ..close();
    canvas.drawPath(green, Paint()..color = const Color(0xFF34A853));

    // Yellow
    final yellow = Path()
      ..moveTo(5.84 * s, 14.09 * s)
      ..cubicTo(5.62 * s, 13.43 * s, 5.49 * s, 12.73 * s, 5.49 * s, 12 * s)
      ..cubicTo(5.49 * s, 11.27 * s, 5.62 * s, 10.57 * s, 5.84 * s, 9.91 * s)
      ..lineTo(5.84 * s, 7.07 * s)
      ..lineTo(2.18 * s, 7.07 * s)
      ..cubicTo(1.43 * s, 8.55 * s, 1 * s, 10.22 * s, 1 * s, 12 * s)
      ..cubicTo(1 * s, 13.78 * s, 1.43 * s, 15.45 * s, 2.18 * s, 16.93 * s)
      ..lineTo(5.84 * s, 14.09 * s)
      ..close();
    canvas.drawPath(yellow, Paint()..color = const Color(0xFFFBBC05));

    // Red
    final red = Path()
      ..moveTo(12 * s, 5.38 * s)
      ..cubicTo(13.62 * s, 5.38 * s, 15.06 * s, 5.94 * s, 16.21 * s, 7.02 * s)
      ..lineTo(19.36 * s, 3.87 * s)
      ..cubicTo(17.45 * s, 2.09 * s, 14.97 * s, 1 * s, 12 * s, 1 * s)
      ..cubicTo(7.70 * s, 1 * s, 3.99 * s, 3.47 * s, 2.18 * s, 7.07 * s)
      ..lineTo(5.84 * s, 9.91 * s)
      ..cubicTo(6.71 * s, 7.31 * s, 9.14 * s, 5.38 * s, 12 * s, 5.38 * s)
      ..close();
    canvas.drawPath(red, Paint()..color = const Color(0xFFEA4335));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Microsoft 4-square icon — exact SVG from web source
class _MicrosoftIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.width / 21;

    // Red (top-left)
    canvas.drawRect(
      Rect.fromLTWH(0, 0, 10 * s, 10 * s),
      Paint()..color = const Color(0xFFF25022),
    );
    // Green (top-right)
    canvas.drawRect(
      Rect.fromLTWH(11 * s, 0, 10 * s, 10 * s),
      Paint()..color = const Color(0xFF7FBA00),
    );
    // Blue (bottom-left)
    canvas.drawRect(
      Rect.fromLTWH(0, 11 * s, 10 * s, 10 * s),
      Paint()..color = const Color(0xFF00A4EF),
    );
    // Yellow (bottom-right)
    canvas.drawRect(
      Rect.fromLTWH(11 * s, 11 * s, 10 * s, 10 * s),
      Paint()..color = const Color(0xFFFFB900),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
