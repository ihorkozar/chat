import 'package:chat/presentation/bloc/home/online_users_state.dart';
import 'package:chat/util/local_cache.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat/chat.dart';

class OnlineUsersCubit extends Cubit<OnlineUsersState> {
  final IUserService _userService;
  final ILocalCache _localCache;

  OnlineUsersCubit(this._userService, this._localCache)
      : super(OnlineUsersInitial());

  Future<User> connect() async {
    final userJson = _localCache.fetch('user-cached');
    userJson['last_seen'] = DateTime.now();
    userJson['active'] = true;

    final user = User.fromJson(userJson);
    await _userService.connect(user);
    return user;
  }

  Future<void> getActiveUsers(User user) async {
    emit(OnlineUsersLoading());
    final users = await _userService.getOnlineUsers();
    users.removeWhere((element) => element.id == user.id);
    emit(OnlineUsersSuccess(users));
  }
}