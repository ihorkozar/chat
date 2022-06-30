import 'package:chat/src/models/user.dart';

abstract class IUserService {
  Future<User> connect(User user);

  Future<void> disconnect(User user);

  Future<User?> fetch(String id);

  Future<List<User>> getOnlineUsers();
}
