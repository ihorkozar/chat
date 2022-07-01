import 'package:chat/src/models/typing_event.dart';
import 'package:chat/src/models/user.dart';
import 'package:chat/src/services/typing/typing_notification_service_impl.dart';
import 'package:chat/src/services/user/user_service_contract_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';

import '../helpers.dart';

void main() {
  RethinkDb rethinkdb = RethinkDb();
  late Connection connection;
  late TypingService typingService;
  late UserService userService;

  final user1 = User.fromJson({
    'id': '1',
    'username': 'user1',
    'photo_url':
    'https://s.dou.ua/CACHE/images/img/static/companies/dou/e7a0a2cb03acd45577dcc09a5fc8d565.png',
    'is_active': true,
    'last_seen': DateTime.now()
  });

  final user2 = User.fromJson({
    'id': '2',
    'username': 'user2',
    'photo_url':
    'https://s.dou.ua/CACHE/images/img/static/companies/dou/e7a0a2cb03acd45577dcc09a5fc8d565.png',
    'is_active': true,
    'last_seen': DateTime.now()
  });

  setUp(() async {
    connection = await rethinkdb.connect(host: "127.0.0.1", port: 28015);
    await createDb(rethinkdb, connection);
    userService = UserService(rethinkdb, connection);

    await userService.connect(user1);
    await userService.connect(user2);

    typingService = TypingService(rethinkdb, connection, userService);
  });

  tearDown(() async {
    typingService.dispose();
    cleanDb(rethinkdb, connection);
  });

  test('sent typing notification successfully', () async {
    TypingEvent typingEvent =
    TypingEvent(from: user2.id, to: user1.id, event: Typing.start);

    final result = await typingService.send(typingEvent: typingEvent);

    expect(result, true);
  });

  test('successfully subscribe and receive typing events', () async {
    TypingEvent typingEvent1 =
    TypingEvent(from: user1.id, to: user2.id, event: Typing.start);

    TypingEvent typingEvent2 =
    TypingEvent(from: user1.id, to: user2.id, event: Typing.stop);

    await typingService.send(typingEvent: typingEvent1);
    await typingService.send(typingEvent: typingEvent2);

    typingService
        .subscribe(user2, [user1.id]).listen(expectAsync1((typingEvent) {
      expect(typingEvent.from, user1.id);
    }, count: 2));
  });
}