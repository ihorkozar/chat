import 'dart:async';

import 'package:flutter_chat/src/models/message.dart';
import 'package:flutter_chat/src/models/user.dart';
import 'package:flutter_chat/src/services/encryption/encryption_service.dart';
import 'package:flutter_chat/src/services/msg/msg_service.dart';
import 'package:flutter/material.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';

class MessageService implements IMessageService {
  final Connection _connection;
  final RethinkDb _rethinkdb;
  final IEncryptionService? _encryptionService;

  final _controller = StreamController<Message>.broadcast();

  StreamSubscription? _changefeed;

  MessageService(this._rethinkdb, this._connection,
      {IEncryptionService? encryptionService})
      : _encryptionService = encryptionService;

  @override
  dispose() {
    _controller.close();
    _changefeed?.cancel();
  }

  @override
  Stream<Message> getMessages({required User activeUser}) {
    _startReceivingMessages(activeUser);
    return _controller.stream;
  }

  @override
  Future<Message> send(Message message) async {
    var data = message.toJson();

    if (_encryptionService != null) {
      data['content'] = _encryptionService!.encrypt(message.content);
    }

    Map record = await _rethinkdb
        .table('messages')
        .insert(data, {'return_changes': true}).run(_connection);

    return Message.fromJson(record['changes'].first['new_val']);
  }

  _startReceivingMessages(User user) {
    _changefeed = _rethinkdb
        .table('messages')
        .filter({'to': user.id})
        .changes({'include_initial': true})
        .run(_connection)
        .asStream()
        .cast<Feed>()
        .listen((event) {
          event.forEach((feedData) {
            if (feedData['new_val'] == null) {
              return;
            } else {
              final message = _getMessageFromFeed(feedData);
              _controller.sink.add(message);
              _removeDeliveredMessage(message);
            }
          }).catchError((error) {
            debugPrint(error.toString());
          }).onError((error, stackTrace) => debugPrint(error.toString()));
        });
  }

  Message _getMessageFromFeed(feedData) {
    var data = feedData['new_val'];

    if (_encryptionService != null) {
      data['content'] = _encryptionService!.decrypt(data['content']);
    }

    return Message.fromJson(data);
  }

  _removeDeliveredMessage(Message message) {
    _rethinkdb
        .table('messages')
        .get(message.id)
        .delete({'return_changes': false}).run(_connection);
  }
}
