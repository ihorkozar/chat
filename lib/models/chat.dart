import 'package:flutter_chat/chat.dart';

import 'local_msg.dart';

class Chat {
  String id;
  int unread = 0;
  List<LocalMessage> messages = [];
  LocalMessage? mostRecent;
  User? from;

  Chat(this.id, {messages, mostRecent, from});

  toMap() => {
        'id': id,
      };

  factory Chat.fromMap(Map<String, dynamic> json) => Chat(json['id']);
}
