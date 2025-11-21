import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/services/security_service.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  final SecurityService _securityService = SecurityService();
  bool _isPinSet = false;
  bool _isBiometricEnabled = false;
  bool _isBiometricAvailable = false;
  List<BiometricType> _availableBiometrics = [];
  bool _isLoading = true;
  bool _authenticating = false;
  bool _tipsExpanded = false;
  String? _biometricStatusMessage;

  @override
  void initState() {
    super.initState();
    _loadSecurityStatus();
  }

  Future<void> _loadSecurityStatus() async {
    setState(() => _isLoading = true);
    
    _isPinSet = _securityService.isPinSet();
    _isBiometricEnabled = _securityService.isBiometricEnabled();
    _isBiometricAvailable = await _securityService.isBiometricAvailable();
    _availableBiometrics = await _securityService.getAvailableBiometrics();
    
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 1.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Security',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: _isLoading
            ? _buildLoadingSkeleton()
            : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Security Status Card
                  _buildSecurityStatusCard(),
                  const SizedBox(height: 24),

                  // PIN Section
                  _buildSectionTitle('PIN Security'),
                  const SizedBox(height: 12),
                  _buildPinCard(),
                  const SizedBox(height: 24),

                  // Biometric Section
                  if (_isBiometricAvailable) ...[
                    _buildSectionTitle('Biometric Authentication'),
                    const SizedBox(height: 12),
                    _buildBiometricCard(),
                    const SizedBox(height: 24),
                  ],

                  // Info Section
                  _buildInfoCard(),
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildSecurityStatusCard() {
    final isSecure = _isPinSet || _isBiometricEnabled;
    return Semantics(
      container: true,
      label: isSecure ? 'App security enabled' : 'App security disabled',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSecure
                ? [
                    AppColors.primary.withOpacity(0.12),
                    AppColors.primary.withOpacity(0.05),
                  ]
                : [
                    Colors.orange.withOpacity(0.15),
                    Colors.orange.withOpacity(0.06),
                  ],
          ),
          border: Border.all(
            color: (isSecure ? AppColors.primary : Colors.orange).withOpacity(0.25),
            width: 1.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon Circle
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (isSecure ? AppColors.primary : Colors.orange).withOpacity(0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isSecure
                      ? [AppColors.primary, AppColors.primary.withOpacity(0.85)]
                      : [Colors.orange, Colors.orange.shade600],
                ),
              ),
              child: Icon(
                isSecure ? Icons.lock : Icons.lock_open,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 20),
            // Text & Pill
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          isSecure ? 'App is Secured' : 'App is Not Secured',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                            color: isSecure ? AppColors.primary : Colors.orange.shade800,
                          ),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: (isSecure ? AppColors.primary : Colors.orange).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: (isSecure ? AppColors.primary : Colors.orange).withOpacity(0.35),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isSecure ? Icons.verified_user : Icons.warning_amber_rounded,
                              size: 16,
                              color: isSecure ? AppColors.primary : Colors.orange.shade700,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isSecure ? 'SECURED' : 'UNSECURED',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.8,
                                color: isSecure ? AppColors.primary : Colors.orange.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isSecure
                        ? 'Protected with ${_isPinSet ? 'PIN' : ''}${_isPinSet && _isBiometricEnabled ? ' + ' : ''}${_isBiometricEnabled ? _securityService.getBiometricTypeName(_availableBiometrics) : ''}'
                        : 'Enable a PIN and optional biometric to safeguard your financial data.',
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.35,
                      color: (isSecure ? AppColors.primary : Colors.orange).withOpacity(0.85),
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildPinCard() {
    return Semantics(
      label: _isPinSet ? 'PIN is active' : 'No PIN set',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.grayPrimary),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _isPinSet ? _showPinOptions() : _setupPin(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primary.withOpacity(0.15),
                            AppColors.primary.withOpacity(0.05),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          _isPinSet ? Icons.key : Icons.add_moderator,
                          color: AppColors.primary,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isPinSet ? '4‑Digit PIN' : 'Set up PIN',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isPinSet
                                ? 'Your PIN protects access to the app.'
                                : 'Create a simple 4‑digit code to secure the app.',
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.3,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: _isPinSet
                          ? Icon(Icons.check_circle, key: const ValueKey('pin-active'), color: AppColors.primary)
                          : Icon(Icons.chevron_right, key: const ValueKey('pin-inactive'), color: Colors.grey.shade500),
                    ),
                  ],
                ),
                if (_isPinSet) ...[
                  const SizedBox(height: 14),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    child: Row(
                      children: [
                        _buildPinActionChip(Icons.edit, 'Change', _changePin),
                        const SizedBox(width: 8),
                        _buildPinActionChip(Icons.delete_outline, 'Remove', _confirmRemovePin, isDestructive: true),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBiometricCard() {
    final biometricName = _securityService.getBiometricTypeName(_availableBiometrics);
    final disabledReason = !_isPinSet
        ? 'Set up a PIN first to enable $biometricName.'
        : !_isBiometricAvailable
            ? 'No biometric hardware available.'
            : null;

    return Semantics(
      label: 'Biometric authentication ${_isBiometricEnabled ? 'enabled' : 'disabled'}',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.grayPrimary),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary.withOpacity(0.15),
                          AppColors.primary.withOpacity(0.05),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        _availableBiometrics.contains(BiometricType.face)
                            ? Icons.face
                            : Icons.fingerprint,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          biometricName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: Text(
                            _isBiometricEnabled
                                ? 'Unlock with $biometricName.'
                                : disabledReason ?? 'Use $biometricName as a quick secure unlock.',
                            key: ValueKey(_isBiometricEnabled.toString() + (disabledReason ?? '')), 
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.3,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _authenticating
                      ? const SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(strokeWidth: 2.4),
                        )
                      : Switch(
                          value: _isBiometricEnabled,
                          activeColor: AppColors.primary,
                          onChanged: (_isPinSet && _isBiometricAvailable && !_authenticating)
                              ? (v) => _toggleBiometric(v)
                              : null,
                        ),
                ],
              ),
              if (_biometricStatusMessage != null) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _biometricStatusMessage!,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary.withOpacity(0.9),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Semantics(
      label: 'Security tips',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blue.shade100),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => setState(() => _tipsExpanded = !_tipsExpanded),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AnimatedRotation(
                      turns: _tipsExpanded ? 0.25 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Security Tips',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ),
                    Icon(
                      _tipsExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.blue.shade700,
                    ),
                  ],
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      '• You must set up a PIN before enabling biometric authentication\n'
                      '• PIN is required as a fallback if biometric fails\n'
                      '• Your PIN is stored securely and cannot be recovered',
                      style: TextStyle(
                        fontSize: 12.5,
                        height: 1.55,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ),
                  crossFadeState: _tipsExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 300),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _setupPin() async {
    final result = await Navigator.pushNamed(context, AppRoutes.setupPin);
    if (result == true) {
      _loadSecurityStatus();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PIN set up successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _showPinOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.edit, color: AppColors.primary),
              title: const Text('Change PIN'),
              onTap: () {
                Navigator.pop(context);
                _changePin();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Remove PIN', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _confirmRemovePin();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _changePin() async {
    final result = await Navigator.pushNamed(context, AppRoutes.changePin);
    if (result == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PIN changed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _confirmRemovePin() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove PIN?'),
        content: const Text(
          'This will disable all security features including biometric authentication. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _removePin();
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _removePin() async {
    await _securityService.disableSecurity();
    _loadSecurityStatus();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Security disabled'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _toggleBiometric(bool value) async {
    if (value) {
      // Test biometric before enabling
      setState(() {
        _authenticating = true;
        _biometricStatusMessage = 'Authenticating…';
      });
      final authenticated = await _securityService.authenticateWithBiometrics();
      if (authenticated) {
        await _securityService.enableBiometric();
        _loadSecurityStatus();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${_securityService.getBiometricTypeName(_availableBiometrics)} enabled!',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
        setState(() {
          _biometricStatusMessage = '${_securityService.getBiometricTypeName(_availableBiometrics)} successfully enabled';
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Authentication failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() {
          _biometricStatusMessage = 'Authentication failed';
        });
      }
    } else {
      await _securityService.disableBiometric();
      _loadSecurityStatus();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${_securityService.getBiometricTypeName(_availableBiometrics)} disabled',
            ),
          ),
        );
      }
      setState(() {
        _biometricStatusMessage = '${_securityService.getBiometricTypeName(_availableBiometrics)} disabled';
      });
    }
    setState(() {
      _authenticating = false;
    });
  }

  // Helper for PIN action chips
  Widget _buildPinActionChip(IconData icon, String label, VoidCallback onTap, {bool isDestructive = false}) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: isDestructive
                ? Colors.red.withOpacity(0.08)
                : AppColors.primary.withOpacity(0.10),
            border: Border.all(
              color: isDestructive
                  ? Colors.red.withOpacity(0.35)
                  : AppColors.primary.withOpacity(0.35),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: isDestructive ? Colors.red : AppColors.primary),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: isDestructive ? Colors.red : AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Loading skeleton
  Widget _buildLoadingSkeleton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _skeletonBox(height: 110),
          const SizedBox(height: 24),
          _skeletonBox(height: 100),
          const SizedBox(height: 24),
          _skeletonBox(height: 100),
          const SizedBox(height: 24),
          _skeletonBox(height: 80),
        ],
      ),
    );
  }

  Widget _skeletonBox({required double height}) {
    return _Shimmer(
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

// Simple shimmer widget (no external dependency)
class _Shimmer extends StatefulWidget {
  final Widget child;
  const _Shimmer({required this.child});

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (rect) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.grey.shade300,
                Colors.grey.shade100,
                Colors.grey.shade300,
              ],
              stops: [
                (_controller.value - 0.3).clamp(0.0, 1.0),
                _controller.value.clamp(0.0, 1.0),
                (_controller.value + 0.3).clamp(0.0, 1.0),
              ],
            ).createShader(rect);
          },
          blendMode: BlendMode.srcATop,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
