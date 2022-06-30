import 'package:chat/src/models/user.dart';
import 'package:chat/src/services/user_service_contract.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';

class UserService implements IUserService {
  final Connection connection;
  final RethinkDb rethinkdb;

  UserService(this.rethinkdb, this.connection);

  @override
  Future<User> connect(User user) async {
    var data = user.toJson();
    if (user.id != null) {
      data['id'] = user.id;
    }

    final result = await rethinkdb.table('users').insert(
        data, {'conflict': 'update', 'return_changes': true}).run(connection);

    return User.fromJson(result['changes'].first['new_val']);
  }

  @override
  Future<void> disconnect(User user) async {
    await rethinkdb.table('users').update({
      'id': user.id,
      'is_active': false,
      'last_seen': DateTime.now()
    }).run(connection);

    connection.close();
  }

  @override
  Future<User?> fetch(String id) async {
    final user = await rethinkdb.table('users').get(id).run(connection);
    if (user != null) {
      return User.fromJson(user);
    }
  }

  @override
  Future<List<User>> getOnlineUsers() async {
    Cursor users = await rethinkdb
        .table('users')
        .filter({'is_active': true}).run(connection);

    final usersList = await users.toList();
    return usersList.map((item) => User.fromJson(item)).toList();
  }
}
