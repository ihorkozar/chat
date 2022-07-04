import 'package:flutter/material.dart';
import 'package:flutter_chat/chat.dart';

abstract class IOnboardingRouter {
  void onSessionSuccess(BuildContext context, User user);
}

class OnboardingRouter implements IOnboardingRouter {
  final Widget Function(User user) onSessionConnected;

  OnboardingRouter(this.onSessionConnected);

  @override
  onSessionSuccess(BuildContext context, User user) {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => onSessionConnected(user)),
            (Route<dynamic> route) => false);
  }
}