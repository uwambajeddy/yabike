import 'package:flutter/material.dart';
import '../../data/services/security_service.dart';
import '../../features/security/screens/unlock_screen.dart';

/// Wrapper widget that shows unlock screen if security is enabled
class SecureApp extends StatefulWidget {
  final Widget child;

  const SecureApp({
    super.key,
    required this.child,
  });

  @override
  State<SecureApp> createState() => _SecureAppState();
}

class _SecureAppState extends State<SecureApp> with WidgetsBindingObserver {
  final SecurityService _securityService = SecurityService();
  bool _isLocked = false;
  bool _shouldShowUnlock = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkSecurity();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // Lock app when it goes to background
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      if (_securityService.isSecurityEnabled() && !_securityService.isSecurityPaused) {
        setState(() {
          _isLocked = true;
        });
      }
    }
    
    // Show unlock screen when app resumes
    if (state == AppLifecycleState.resumed) {
      if (_isLocked && _securityService.isSecurityEnabled()) {
        _showUnlockScreen();
      }
    }
  }

  void _checkSecurity() {
    // Check if security is enabled on first load
    if (_securityService.isSecurityEnabled()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _shouldShowUnlock) {
          _showUnlockScreen();
        }
      });
    }
  }

  Future<void> _showUnlockScreen() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const UnlockScreen(),
        fullscreenDialog: true,
      ),
    );
    
    if (result == true) {
      setState(() {
        _isLocked = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
