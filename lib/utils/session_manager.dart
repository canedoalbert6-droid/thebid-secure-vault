import 'dart:async';
import 'package:flutter/material.dart';

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  Timer? _timer;
  final int _timeoutSeconds = 300; // 5 minutes Default
  bool _isActive = false;

  void startSession(BuildContext context) {
    if (_isActive) return;
    _isActive = true;
    _resetTimer(context);
  }

  void stopSession() {
    _timer?.cancel();
    _isActive = false;
  }

  void userInteracted(BuildContext context) {
    if (_isActive) {
      _resetTimer(context);
    }
  }

  void _resetTimer(BuildContext context) {
    _timer?.cancel();
    _timer = Timer(Duration(seconds: _timeoutSeconds), () {
      _handleTimeout(context);
    });
  }

  void _handleTimeout(BuildContext context) {
    stopSession();
    // Use Navigator to push replacement to login screen
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }
}

class UserInteractionListener extends StatelessWidget {
  final Widget child;

  const UserInteractionListener({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => SessionManager().userInteracted(context),
      onPointerMove: (_) => SessionManager().userInteracted(context),
      onPointerUp: (_) => SessionManager().userInteracted(context),
      child: child,
    );
  }
}
