import 'package:flutter_chat/src/models/typing_event.dart';
import 'package:flutter_chat/src/models/user.dart';

abstract class ITypingNotificationService {
  Future<bool> send({required TypingEvent typingEvent});
  Stream<TypingEvent> subscribe(User user, List<String> userIds);
  void dispose();
}