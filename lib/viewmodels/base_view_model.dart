import 'package:chat/data/datasources/datasource.dart';
import 'package:chat/models/chat.dart';
import 'package:chat/models/local_msg.dart';
import 'package:flutter/material.dart';

abstract class BaseViewModel {
  final IDataSource _dataSource;

  BaseViewModel(this._dataSource);

  @protected
  Future<void> addMessage(LocalMessage localMessage) async {
    if (!await _isExistingChat(localMessage.chatId)) {
      await _createNewChat(localMessage.chatId);
    }

    await _dataSource.addMessage(localMessage);
  }

  Future<bool> _isExistingChat(String chatId) async {
    return await _dataSource.findChat(chatId) != null;
  }

  Future<void> _createNewChat(String chatId) async {
    final chat = Chat(chatId);
    await _dataSource.addChat(chat);
  }
}