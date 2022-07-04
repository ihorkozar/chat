import 'package:flutter/material.dart';
import 'package:flutter_chat/chat.dart';

abstract class IHomeRouter {
  Future<void> onShowMessageThread(
      BuildContext context, User receiver, User activeUser,
      {required String chatId});
}

class HomeRouter implements IHomeRouter {
  final Widget Function(User receiver, User activeUser,
      {required String chatId}) showMessageThread;

  HomeRouter({required this.showMessageThread});

  @override
  Future<void> onShowMessageThread(
      BuildContext context, User receiver, User activeUser,
      {required String chatId}) {
    return Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) =>
                showMessageThread(receiver, activeUser, chatId: chatId)));
  }
}