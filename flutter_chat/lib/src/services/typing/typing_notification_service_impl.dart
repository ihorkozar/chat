import 'dart:async';

import 'package:flutter_chat/src/models/typing_event.dart';
import 'package:flutter_chat/src/models/user.dart';
import 'package:flutter_chat/src/services/typing/typing_notification_service.dart';
import 'package:flutter_chat/src/services/user/user_service_contract.dart';
import 'package:flutter/material.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';

class TypingService implements ITypingNotificationService {
  final Connection _connection;
  final RethinkDb _rethinkdb;

  final _controller = StreamController<TypingEvent>.broadcast();

  StreamSubscription? _changeFeed;
  IUserService _userService;

  TypingService(this._rethinkdb, this._connection, this._userService);

  @override
  void dispose() {
    _controller.close();
    _changeFeed?.cancel();
  }

  @override
  Future<bool> send({required TypingEvent typingEvent}) async {
    final receiver = await _userService.fetch(typingEvent.to);
    if (receiver == null || !receiver.isActive) {
      return false;
    } else {
      Map record = await _rethinkdb.table("typing_events").insert(
          typingEvent.toJson(), {'conflict': 'update'}).run(_connection);
      return record['inserted'] == 1;
    }
  }

  @override
  Stream<TypingEvent> subscribe(User user, List<String> userIds) {
    _startReceivingTypingEvents(user, userIds);
    return _controller.stream;
  }

  _startReceivingTypingEvents(User user, List<String> userIds) {
    _changeFeed = _rethinkdb
        .table('typing_events')
        .filter((event) {
      return event('to')
          .eq(user.id)
          .and(_rethinkdb.expr(userIds).contains(event('from')));
    })
        .changes({'include_initial': true})
        .run(_connection)
        .asStream()
        .cast<Feed>()
        .listen((event) {
      event
          .forEach((feedData) {
        if (feedData['new_val'] == null) return;
        final typing = TypingEvent.fromJson(feedData['new_val']);
        _controller.sink.add(typing);
        _removeTypingEvent(typing);
      })
          .catchError((err) => debugPrint(err.toString()))
          .onError((error, stackTrace) => debugPrint(error.toString()));
    });
  }

  _removeTypingEvent(TypingEvent event) {
    _rethinkdb
        .table('typing_events')
        .get(event.id)
        .delete({'return_changes': false}).run(_connection);
  }
}