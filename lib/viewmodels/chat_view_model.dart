import 'package:chat/data/datasources/datasource.dart';
import 'package:chat/models/local_msg.dart';
import 'package:flutter_chat/chat.dart';

import 'base_view_model.dart';

class ChatViewModel extends BaseViewModel {
  final IDataSource _dataSource;

  String _chatId = '';
  int otherMessages = 0;

  String get chatId => _chatId;

  ChatViewModel(this._dataSource) : super(_dataSource);

  Future<List<LocalMessage>> getMessages(String chatId) async {
    final messages = await _dataSource.findMessages(chatId);
    if (messages.isNotEmpty) {
      _chatId = chatId;
    }

    return messages;
  }

  Future<void> sentMessage(Message message) async {
    LocalMessage localMessage =
    LocalMessage(message.to, message, ReceiptStatus.sent);

    if (_chatId.isNotEmpty) {
      return await _dataSource.addMessage(localMessage);
    } else {
      _chatId = localMessage.chatId;
      await super.addMessage(localMessage);
    }
  }

  Future<void> receivedMessage(Message message) async {
    LocalMessage localMessage =
    LocalMessage(message.from, message, ReceiptStatus.delivered);

    if (_chatId.isEmpty) {
      _chatId = localMessage.chatId;
    }

    if (localMessage.chatId != _chatId) {
      otherMessages++;
    }

    await super.addMessage(localMessage);
  }

  Future<void> updateMessageReceipt(Receipt receipt) async {
    await _dataSource.updateMessageReceipt(receipt.messageId, receipt.status);
  }
}