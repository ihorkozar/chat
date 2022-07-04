import 'package:flutter_chat/src/models/user.dart';
import 'package:flutter_chat/src/services/user/user_service.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';

class UserService implements IUserService {
  final Connection _connection;
  final RethinkDb _rethinkdb;

  UserService(this._rethinkdb, this._connection);

  @override
  Future<User> connect(User user) async {
    var data = user.toJson();
    if (user.id.isNotEmpty) {
      data['id'] = user.id;
    }

    final result = await _rethinkdb.table('users').insert(
        data, {'conflict': 'update', 'return_changes': true}).run(_connection);

    return User.fromJson(result['changes'].first['new_val']);
  }

  @override
  Future<void> disconnect(User user) async {
    await _rethinkdb.table('users').update({
      'id': user.id,
      'is_active': false,
      'last_seen': DateTime.now()
    }).run(_connection);

    _connection.close();
  }

  @override
  Future<User?> fetch(String id) async {
    final user = await _rethinkdb.table('users').get(id).run(_connection);
    return user != null ? User.fromJson(user) : null;
  }

  @override
  Future<List<User>> getOnlineUsers() async {
    Cursor users = await _rethinkdb
        .table('users')
        .filter({'is_active': true}).run(_connection);

    final usersList = await users.toList();
    return usersList.map((item) => User.fromJson(item)).toList();
  }
}
