import 'package:equatable/equatable.dart';
import 'package:flutter_chat/chat.dart';

abstract class OnlineUsersState extends Equatable {}

class OnlineUsersInitial extends OnlineUsersState {
  @override
  List<Object?> get props => [];
}

class OnlineUsersLoading extends OnlineUsersState {
  @override
  List<Object?> get props => [];
}

class OnlineUsersSuccess extends OnlineUsersState {
  final List<User> onlineUsers;

  OnlineUsersSuccess(this.onlineUsers);

  @override
  List<Object?> get props => [onlineUsers];
}