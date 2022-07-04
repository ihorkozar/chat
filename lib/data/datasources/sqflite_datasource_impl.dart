import 'package:chat/data/datasources/datasource.dart';
import 'package:chat/models/chat.dart';
import 'package:chat/models/local_msg.dart';
import 'package:flutter_chat/chat.dart';
import 'package:sqflite/sqflite.dart';

class SQFLiteDataSource implements IDataSource {
  final Database _database;

  SQFLiteDataSource(this._database);

  @override
  Future<void> addChat(Chat chat) async {
    await _database.transaction((txn) async {
      await txn.insert('chats', chat.toMap(),
          conflictAlgorithm: ConflictAlgorithm.rollback);
    });
  }

  @override
  Future<void> addMessage(LocalMessage localMessage) async {
    await _database.transaction((txn) async {
      await txn.insert('messages', localMessage.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  @override
  Future<void> deleteChat(String chatId) async {
    final batch = _database.batch();
    batch.delete('messages', where: 'chat_id = ?', whereArgs: [chatId]);
    batch.delete('chats', where: 'id = ?', whereArgs: [chatId]);
    await batch.commit(noResult: true);
  }

  @override
  Future<List<Chat>> findAllChats() {
    return _database.transaction((txn) async {
      final chatsWithLatestMessage =
          await txn.rawQuery(''' SELECT messages.* FROM 
      (SELECT
        chat_id, MAX(created_at) AS created_at
        FROM messages
        GROUP BY chat_id
      ) AS latest_messages
      INNER JOIN messages
      ON messages.chat_id = latest_messages.chat_id 
      AND messages.created_at = latest_messages.created_at
      ORDER BY messages.created_at DESC
      ''');

      if (chatsWithLatestMessage.isEmpty) return [];

      final chatsWithUnreadMessages =
          await txn.rawQuery(''' SELECT chat_id, count(*) as unread
      FROM messages
      WHERE receipt = ?
      GROUP BY chat_id
      ''', ['DELIVERED']);

      return chatsWithLatestMessage.map<Chat>((row) {
        var unread = 0;
        var chatWithUnreadMessages = chatsWithUnreadMessages.firstWhere(
            (e) => row['chat_id'] == e['chat_id'],
            orElse: () => {'unread': 0});

        if (chatWithUnreadMessages['unread'] != null) {
          unread = chatWithUnreadMessages['unread'] as int;
        }

        final chat = Chat.fromMap({"id": row["chat_id"]});
        chat.unread = unread;
        chat.mostRecent = LocalMessage.fromMap(row);

        return chat;
      }).toList();
    });
  }

  @override
  Future<Chat?> findChat(String chatId) async {
    return await _database.transaction((txn) async {
      final listOfChatMaps =
          await txn.query('chats', where: 'id = ?', whereArgs: [chatId]);

      if (listOfChatMaps.isEmpty) return null;

      final unread = Sqflite.firstIntValue(await txn.rawQuery(
              'SELECT count(*) FROM messages WHERE chat_id = ? AND receipt = ?',
              [chatId, 'DELIVERED'])) ??
          0;

      final mostRecentMessage = await txn.query('messages',
          where: 'chat_id = ?',
          whereArgs: [chatId],
          orderBy: 'created_at DESC',
          limit: 1);

      final chat = Chat.fromMap(listOfChatMaps.first);
      chat.unread = unread;
      chat.mostRecent = LocalMessage.fromMap(mostRecentMessage.first);
      return chat;
    });
  }

  @override
  Future<List<LocalMessage>> findMessages(String chatId) async {
    final listOfMessagesMaps = await _database
        .query('messages', where: 'chat_id = ?', whereArgs: [chatId]);

    return listOfMessagesMaps
        .map<LocalMessage>((row) => LocalMessage.fromMap(row))
        .toList();
  }

  @override
  Future<void> updateMessage(LocalMessage message) async {
    await _database.update('messages', message.toMap(),
        where: 'id = ?',
        whereArgs: [message.message.id],
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> updateMessageReceipt(
    String messageId,
    ReceiptStatus receiptStatus,
  ) {
    return _database.transaction(((txn) async {
      await txn.update('messages', {'receipt': receiptStatus.value()},
          where: 'id = ?',
          whereArgs: [messageId],
          conflictAlgorithm: ConflictAlgorithm.replace);
    }));
  }
}
