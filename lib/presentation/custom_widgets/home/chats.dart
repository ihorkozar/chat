import 'package:chat/models/chat.dart';
import 'package:chat/presentation/bloc/home/chats_cubit.dart';
import 'package:chat/presentation/bloc/message/message_bloc.dart';
import 'package:chat/presentation/bloc/typing/typing_notification_bloc.dart';
import 'package:chat/presentation/custom_widgets/home/avatar.dart';
import 'package:chat/presentation/screens/home_router.dart';
import 'package:chat/util/colors.dart';
import 'package:chat/util/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat/chat.dart';
import 'package:intl/intl.dart';

class Chats extends StatefulWidget {
  final User activeUser;
  final IHomeRouter router;

  const Chats(this.activeUser, this.router, {Key? key}) : super(key: key);

  @override
  State<Chats> createState() => _ChatsState();
}

class _ChatsState extends State<Chats> {
  var chats = [];
  var typingEvents = [];

  @override
  void initState() {
    super.initState();
    _updateChatsOnReceivedMessage();
  }

  _updateChatsOnReceivedMessage() {
    final chatsCubit = context.read<ChatsCubit>();
    context.read<MessageBloc>().stream.listen((state) async {
      if (state is MessageReceivedSuccess) {
        await chatsCubit.chatsViewModel.receivedMessage(state.message);
        chatsCubit.getChats();
      }
    });
  }

  _chatItem(Chat chat) => ListTile(
      leading:
      Avatar(imageUrl: chat.from!.photoUrl, isOnline: chat.from!.isActive),
      title: Text(chat.from!.username,
          style: Theme.of(context).textTheme.subtitle2?.copyWith(
              fontWeight: FontWeight.bold,
              color: isLightTheme(context) ? Colors.black : Colors.white)),
      subtitle: BlocBuilder<TypingNotificationBloc, TypingNotificationState>(
          builder: (_, state) {
            if (state is TypingReceivedSuccess &&
                state.typingEvent.event == Typing.start &&
                state.typingEvent.from == chat.from!.id) {
              typingEvents.add(state.typingEvent.from);
            }

            if (state is TypingReceivedSuccess &&
                state.typingEvent.event == Typing.stop &&
                state.typingEvent.from == chat.from!.id) {
              typingEvents.remove(state.typingEvent.from);
            }

            if (typingEvents.contains(chat.from!.id)) {
              return Text('typing...',
                  style: Theme.of(context).textTheme.caption!.copyWith(
                      fontStyle: FontStyle.italic,
                      color:
                      isLightTheme(context) ? Colors.black54 : Colors.white70));
            } else {
              return Text(chat.mostRecent?.message.content ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                  style: Theme.of(context).textTheme.overline?.copyWith(
                      color:
                      isLightTheme(context) ? Colors.black54 : Colors.white70,
                      fontWeight:
                      chat.unread > 0 ? FontWeight.bold : FontWeight.normal));
            }
          }),
      trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                DateFormat('h:mm: a')
                    .format(chat.mostRecent!.message.timestamp),
                style: Theme.of(context).textTheme.overline?.copyWith(
                    color: isLightTheme(context)
                        ? Colors.black54
                        : Colors.white70)),
            Padding(
                padding: const EdgeInsets.only(top: 8),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: chat.unread > 0
                        ? Container(
                        height: 20,
                        width: 20,
                        color: appColor,
                        alignment: Alignment.center,
                        child: Text(chat.unread.toString(),
                            style: Theme.of(context)
                                .textTheme
                                .overline
                                ?.copyWith(color: Colors.white)))
                        : const SizedBox.shrink()))
          ]));

  _buildListView() {
    return ListView.separated(
        itemBuilder: (_, index) => GestureDetector(
            child: _chatItem(chats[index]),
            onTap: () async {
              await widget.router.onShowMessageThread(
                  context, chats[index].from, widget.activeUser,
                  chatId: chats[index].id);

              await context.read<ChatsCubit>().getChats();
            }),
        separatorBuilder: (_, __) => const Divider(),
        itemCount: chats.length);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatsCubit, List<Chat>>(builder: (_, chats) {
      this.chats = chats;

      if (this.chats.isEmpty) return Container();

      context.read<TypingNotificationBloc>().add(
          TypingNotificationEvent.onSubscribed(widget.activeUser,
              usersWithChat: chats.map((e) => e.from!.id).toList()));
      return _buildListView();
    });
  }
}