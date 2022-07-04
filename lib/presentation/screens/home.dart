import 'package:chat/presentation/bloc/home/chats_cubit.dart';
import 'package:chat/presentation/bloc/home/online_users_cubit.dart';
import 'package:chat/presentation/bloc/home/online_users_state.dart';
import 'package:chat/presentation/bloc/message/message_bloc.dart';
import 'package:chat/presentation/custom_widgets/common/header_status.dart';
import 'package:chat/presentation/custom_widgets/home/active_users.dart';
import 'package:chat/presentation/custom_widgets/home/avatar.dart';
import 'package:chat/presentation/custom_widgets/home/chats.dart';
import 'package:chat/presentation/screens/home_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat/chat.dart';

class Home extends StatefulWidget {
  final User _activeUser;
  final IHomeRouter router;

  const Home(this._activeUser, this.router);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with AutomaticKeepAliveClientMixin {
  late User _user;

  @override
  void initState() {
    super.initState();
    _user = widget._activeUser;
    _initialSetup();
  }

  _initialSetup() async {
    final user = (!_user.isActive
        ? await context.read<OnlineUsersCubit>().connect()
        : _user);

    context.read<ChatsCubit>().getChats();
    context.read<OnlineUsersCubit>().getActiveUsers(user);
    context.read<MessageBloc>().add(MessageEvent.onSubscribed(user));
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
              title: HeaderStatus(_user.username, _user.photoUrl, true),
              bottom: TabBar(
                  indicatorPadding: const EdgeInsets.only(top: 10, bottom: 10),
                  tabs: [
                    Tab(
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50)),
                          child: const Align(
                              alignment: Alignment.center, child: Text('Messages')),
                        )),
                    Tab(
                        child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50)),
                            child: Align(
                              alignment: Alignment.center,
                              child: BlocBuilder<OnlineUsersCubit,
                                  OnlineUsersState>(
                                  builder: (_, state) => state
                                  is OnlineUsersSuccess
                                      ? Text(
                                      'Active users (${state.onlineUsers.length})')
                                      : const Text('Active users (0)')),
                            )))
                  ])),
          body: TabBarView(children: [
            Container(child: Chats(_user, widget.router)),
            Container(child: ActiveUsers(_user, widget.router))
          ]),
        ));
  }
}