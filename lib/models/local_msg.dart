import 'package:flutter_chat/chat.dart';

class LocalMessage {
  late String _id;
  String chatId;
  Message message;
  ReceiptStatus receipt;

  String get id => _id;

  LocalMessage(this.chatId, this.message, this.receipt);

  Map<String, dynamic> toMap() => {
    'chat_id': chatId,
    'id': message.id,
    'sender': message.from,
    'receiver': message.to,
    'content': message.content,
    'receipt': receipt.value(),
    'received_at': message.timestamp.toString()
  };

  factory LocalMessage.fromMap(Map<String, dynamic> json) {
    final message = Message(
        from: json['sender'],
        to: json['receiver'],
        content: json['content'],
        timestamp: DateTime.parse(json['received_at']));

    final localMessage = LocalMessage(json['chat_id'], message,
        ReceiptStatusParsing.fromString(json['receipt']));

    localMessage._id = json['id'];

    return localMessage;
  }
}