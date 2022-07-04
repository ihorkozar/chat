import 'package:chat/data/datasources/datasource.dart';
import 'package:chat/models/chat.dart';
import 'package:chat/models/local_msg.dart';
import 'package:flutter_chat/chat.dart';

import 'base_view_model.dart';

class ChatsViewModel extends BaseViewModel {
  final IDataSource _dataSource;
  final IUserService _userService;

  ChatsViewModel(this._dataSource, this._userService) : super(_dataSource);

  Future<List<Chat>> getChats() async {
    final chats = await _dataSource.findAllChats();
    await Future.forEach(chats, (Chat chat) async {
      final user = await _userService.fetch(chat.id);
      chat.from = user;
    });

    return chats;
  }

  Future<void> receivedMessage(Message message) async {
    LocalMessage localMessage =
    LocalMessage(message.from, message, ReceiptStatus.delivered);

    await super.addMessage(localMessage);
  }
}