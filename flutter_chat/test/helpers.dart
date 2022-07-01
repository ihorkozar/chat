import 'package:rethink_db_ns/rethink_db_ns.dart';

Future<void> createDb(RethinkDb rethinkdb, Connection connection) async {
  await rethinkdb.dbCreate('test').run(connection).catchError((err) => {});
  await rethinkdb.tableCreate('users').run(connection).catchError((err) => {});
  await rethinkdb
      .tableCreate('receipts')
      .run(connection)
      .catchError((err) => {});

  await rethinkdb
      .tableCreate('messages')
      .run(connection)
      .catchError((err) => {});

  await rethinkdb
      .tableCreate('typing_events')
      .run(connection)
      .catchError((err) => {});
}

Future<void> cleanDb(RethinkDb rethinkdb, Connection connection) async {
  await rethinkdb.table('users').delete().run(connection);
  await rethinkdb.table('messages').delete().run(connection);
  await rethinkdb.table('receipts').delete().run(connection);
  await rethinkdb.table('typing_events').delete().run(connection);
}
