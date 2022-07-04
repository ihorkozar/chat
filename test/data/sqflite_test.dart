import 'package:chat/data/datasources/sqflite_datasource_impl.dart';
import 'package:chat/models/chat.dart';
import 'package:chat/models/local_msg.dart';
import 'package:flutter_chat/chat.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';

import 'sqflite_test.mocks.dart';

@GenerateMocks([Database, Batch])
void main() {
  late SQFLiteDataSource sut;
  late MockDatabase database;
  late MockBatch batch;

  setUp(() {
    database = MockDatabase();
    batch = MockBatch();
    sut = SQFLiteDataSource(database);
  });

  final message = Message.fromJson({
    'from': '4444',
    'to': '1111',
    'content': 'Heyyyyy',
    'timestamp': DateTime.parse('2021-04-01'),
    'id': '4444'
  });

  test('should perform insert of chat to the database', () async {
    //arrange
    final chat = Chat('1111');
    when(database.insert(
      'chats',
      chat.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    )).thenAnswer((realInvocation) async {
      return 1;
    });

    //act
    await sut.addChat(chat);

    //assets
    verify(database.insert(
      'chats',
      chat.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    )).called(1);
  });

  test('should perform insert of message to the database', () async {
    //arrange
    final localMessage = LocalMessage('1111', message, ReceiptStatus.sent);

    when(database.insert(
      'messages',
      localMessage.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    )).thenAnswer((realInvocation) async {
      return 1;
    });

    //act
    await sut.addMessage(localMessage);

    //assets
    verify(database.insert(
      'messages',
      localMessage.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    )).called(1);
  });
}
