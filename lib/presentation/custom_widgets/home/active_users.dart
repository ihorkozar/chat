import 'package:chat/presentation/bloc/home/online_users_cubit.dart';
import 'package:chat/presentation/bloc/home/online_users_state.dart';
import 'package:chat/presentation/custom_widgets/home/avatar.dart';
import 'package:chat/presentation/screens/home_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat/chat.dart';

class ActiveUsers extends StatefulWidget {
  final User activeUser;
  final IHomeRouter router;

  const ActiveUsers(this.activeUser, this.router);

  @override
  State<ActiveUsers> createState() => _ActiveUsersState();
}

class _ActiveUsersState extends State<ActiveUsers> {
  _listItem(User user) => ListTile(
      leading: Avatar(imageUrl: user.photoUrl, isOnline: user.isActive),
      title: Text(user.username,
          style: Theme.of(context)
              .textTheme
              .caption
              ?.copyWith(fontSize: 14, fontWeight: FontWeight.bold)));

  _buildList(List<User> users) => ListView.separated(
      padding: const EdgeInsets.only(top: 8),
      itemBuilder: (BuildContext context, index) => GestureDetector(
          child: _listItem(users[index]),
          onTap: () => {
            widget.router.onShowMessageThread(
                context, users[index], widget.activeUser,
                chatId: users[index].id)
          }),
      separatorBuilder: (_, __) => const Divider(),
      itemCount: users.length);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnlineUsersCubit, OnlineUsersState>(builder: (_, state) {
      if (state is OnlineUsersLoading) {
        return const Center(child: CircularProgressIndicator());
      } else if (state is OnlineUsersSuccess) {
        return _buildList(state.onlineUsers);
      } else {
        return Container();
      }
    });
  }
}