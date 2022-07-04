import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabaseFactory {
  Future<Database> createDatabase() async {
    String databasesPath = await getDatabasesPath();
    String dbPath = join(databasesPath, 'chat-app.db');

    return await openDatabase(dbPath, version: 1, onCreate: populateDatabase);
  }

  void populateDatabase(Database db, int version) async {
    await _createChatTable(db);
    await _createMessagesTable(db);
  }

  _createChatTable(Database db) async {
    await db
        .execute("""CREATE TABLE chats(
          id TEXT PRIMARY KEY, 
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
          )""")
        .then((_) => debugPrint('Chats table created...'))
        .catchError((error) => debugPrint('Error creating chats table: $error'));
  }

  _createMessagesTable(Database db) async {
    await db
        .execute("""CREATE TABLE messages(
      chat_id TEXT NOT NULL,
      id TEXT PRIMARY KEY,
      sender TEXT NOT NULL,
      receiver TEXT NOT NULL,
      content TEXT NOT NULL,
      receipt TEXT NOT NULL,
      received_at TIMESTAMP NOT NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
    )""")
        .then((_) => debugPrint('Messages table created...'))
        .catchError((error) => debugPrint('Error creating messages table: $error'));
  }
}