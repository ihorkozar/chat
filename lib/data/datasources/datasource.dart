import 'package:chat/models/chat.dart';
import 'package:chat/models/local_msg.dart';
import 'package:flutter_chat/chat.dart';

abstract class IDataSource {
  Future<void> addChat(Chat chat);
  Future<void> addMessage(LocalMessage localMessage);

  Future<Chat?> findChat(String chatId);
  Future<List<Chat>> findAllChats();

  Future<void> updateMessage(LocalMessage message);
  Future<List<LocalMessage>> findMessages(String chatId);

  Future<void> deleteChat(String chatId);

  Future<void> updateMessageReceipt(
      String messageId, ReceiptStatus receiptStatus);
}