import 'package:chat/src/services/user_service_contract_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';

import 'package:chat/src/models/user.dart';

import 'helpers.dart';


void main() {
  RethinkDb rethinkdb = RethinkDb();

  late Connection connection;
  late UserService userService;

  setUp(() async {
    connection = await rethinkdb.connect(host: "127.0.0.1", port: 28015);
    await createDb(rethinkdb, connection);
    userService = UserService(rethinkdb, connection);
  });

  tearDown(() async {
    await cleanDb(rethinkdb, connection);
  });

  test('create a new user document in database', () async {
    final user = User(
        username: 'test',
        photoUrl: 'photoUrl',
        isActive: true,
        lastSeen: DateTime.now());

    final userWithId = await userService.connect(user);

    expect(userWithId.id, isNotEmpty);
  });

  test('get online users', () async {
    final user = User(
        username: 'test',
        photoUrl: 'photoUrl',
        isActive: true,
        lastSeen: DateTime.now());

    await userService.connect(user);

    final users = await userService.getOnlineUsers();

    expect(users.length, 1);
  });
}