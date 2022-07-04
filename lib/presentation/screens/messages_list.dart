import 'dart:async';

import 'package:chat/models/local_msg.dart';
import 'package:chat/presentation/bloc/home/chats_cubit.dart';
import 'package:chat/presentation/bloc/message/message_bloc.dart';
import 'package:chat/presentation/bloc/message/message_thread_cubit.dart';
import 'package:chat/presentation/bloc/receipt/receipt_bloc.dart';
import 'package:chat/presentation/bloc/typing/typing_notification_bloc.dart';
import 'package:chat/presentation/custom_widgets/common/header_status.dart';
import 'package:chat/presentation/custom_widgets/msg/receiver_message.dart';
import 'package:chat/presentation/custom_widgets/msg/sender_message.dart';
import 'package:chat/util/colors.dart';
import 'package:chat/util/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat/chat.dart';

class MessagesList extends StatefulWidget {
  final User receiver;
  final User activeUser;
  final String chatId;
  final MessageBloc messageBloc;
  final TypingNotificationBloc typingNotificationBloc;
  final ChatsCubit chatsCubit;

  const MessagesList(this.receiver, this.activeUser, this.messageBloc,
      this.chatsCubit, this.typingNotificationBloc,
      {required this.chatId});

  @override
  State<MessagesList> createState() => _MessagesListState();
}

class _MessagesListState extends State<MessagesList> {
  final ScrollController _scrollController = ScrollController();

  final TextEditingController _textEditingController = TextEditingController();

  List<LocalMessage> messages = [];

  late String chatId;
  late User receiver;
  late StreamSubscription? _subscription;

  Timer? _startTypingTimer;
  Timer? _stopTypingTimer;

  @override
  void initState() {
    super.initState();

    chatId = widget.chatId;
    receiver = widget.receiver;

    _updateOnMessageReceived();
    _updateOnReceiptReceived();

    context
        .read<ReceiptBloc>()
        .add(ReceiptEvent.onSubscribed(widget.activeUser));

    widget.typingNotificationBloc.add(TypingNotificationEvent.onSubscribed(
        widget.activeUser,
        usersWithChat: [receiver.id]));
  }

  void _updateOnMessageReceived() {
    final messageThreadCubit = context.read<MessageThreadCubit>();
    if (chatId.isNotEmpty) {
      messageThreadCubit.getMessages(chatId);
    }

    _subscription = widget.messageBloc.stream.listen((state) async {
      if (state is MessageReceivedSuccess) {
        await messageThreadCubit.viewModel.receivedMessage(state.message);

        final receipt = Receipt(
            recipient: state.message.from,
            messageId: state.message.id,
            status: ReceiptStatus.read,
            timestamp: DateTime.now());

        context.read<ReceiptBloc>().add(ReceiptEvent.onReceiptSent(receipt));
      }

      if (state is MessageSentSuccess) {
        await messageThreadCubit.viewModel.sentMessage(state.message);
      }

      if (chatId.isEmpty) {
        chatId = messageThreadCubit.viewModel.chatId;
      }

      messageThreadCubit.getMessages(chatId);
    });
  }

  void _updateOnReceiptReceived() {
    final messageThreadCubit = context.read<MessageThreadCubit>();
    context.read<ReceiptBloc>().stream.listen((state) async {
      if (state is ReceiptReceivedSuccess) {
        await messageThreadCubit.viewModel.updateMessageReceipt(state.receipt);
        messageThreadCubit.getMessages(chatId);
        widget.chatsCubit.getChats();
      }
    });
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _subscription?.cancel();
    _stopTypingTimer?.cancel();
    _startTypingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            titleSpacing: 0,
            automaticallyImplyLeading: false,
            title: Row(children: [
              IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded),
                  color: isLightTheme(context) ? Colors.black : Colors.white,
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  }),
              Expanded(
                  child: BlocBuilder<TypingNotificationBloc,
                          TypingNotificationState>(
                      bloc: widget.typingNotificationBloc,
                      builder: (_, state) {
                        bool? typing;
                        if (state is TypingReceivedSuccess &&
                            state.typingEvent.event == Typing.start &&
                            state.typingEvent.from == receiver.id) {
                          typing = true;
                        }

                        return HeaderStatus(receiver.username,
                            receiver.photoUrl, receiver.isActive,
                            lastSeen: receiver.lastSeen, typing: typing);
                      }))
            ])),
        resizeToAvoidBottomInset: true,
        body: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: Column(children: [
              Flexible(
                  flex: 6,
                  child: BlocBuilder<MessageThreadCubit, List<LocalMessage>>(
                      builder: (_, messages) {
                    this.messages = messages;
                    if (this.messages.isEmpty) {
                      return Container(color: Colors.transparent);
                    } else {
                      WidgetsBinding.instance
                          ?.addPostFrameCallback((_) => _scrollToEnd());

                      return _buildListOfMessages();
                    }
                  })),
              Expanded(
                  child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                          boxShadow: const [
                            BoxShadow(
                                offset: Offset(0, -3),
                                blurRadius: 6.0,
                                color: Colors.black12)
                          ],
                          color: isLightTheme(context)
                              ? Colors.white
                              : appBarDark),
                      alignment: Alignment.topCenter,
                      child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(child: _buildMessageInput(context)),
                              Padding(
                                  padding: const EdgeInsets.only(left: 12),
                                  child: SizedBox(
                                    height: 45,
                                    width: 45,
                                    child: RawMaterialButton(
                                        onPressed: () {
                                          _sendMessage();
                                        },
                                        fillColor: appColor,
                                        shape: const CircleBorder(),
                                        elevation: 5,
                                        child: const Icon(Icons.send,
                                            color: Colors.white)),
                                  ))
                            ],
                          ))))
            ])));
  }

  _sendMessage() {
    if (_textEditingController.text.trim().isEmpty) return;

    final message = Message(
        from: widget.activeUser.id,
        to: receiver.id,
        timestamp: DateTime.now(),
        content: _textEditingController.text);

    widget.messageBloc.add(MessageEvent.onMessageSent(message));

    _textEditingController.clear();
    _startTypingTimer?.cancel();
    _stopTypingTimer?.cancel();
    _dispathTyping(Typing.stop);
  }

  void _dispathTyping(Typing typingEvent) {
    final typing = TypingEvent(
        from: widget.activeUser.id, to: receiver.id, event: typingEvent);
    widget.typingNotificationBloc
        .add(TypingNotificationEvent.onTypingNotificationSent(typing));
  }

  void _sendTypingNotification(String text) {
    if (text.trim().isEmpty || messages.isEmpty) return;
    if (_startTypingTimer?.isActive ?? false) return;
    if (_stopTypingTimer?.isActive ?? false) _stopTypingTimer?.cancel();

    _dispathTyping(Typing.start);

    _startTypingTimer =
        Timer(const Duration(seconds: 5), () {}); // send one every 5 seconds

    _stopTypingTimer =
        Timer(const Duration(seconds: 6), () => _dispathTyping(Typing.stop));
  }

  _buildMessageInput(BuildContext context) {
    final _border = OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(50)),
        borderSide: isLightTheme(context)
            ? BorderSide.none
            : BorderSide(color: Colors.grey.withOpacity(0.3)));

    return Focus(
        onFocusChange: (focus) {
          if (_startTypingTimer == null ||
              (_startTypingTimer != null && focus)) {
            return;
          }

          _stopTypingTimer?.cancel();
          _dispathTyping(Typing.stop);
        },
        child: TextFormField(
          controller: _textEditingController,
          textInputAction: TextInputAction.newline,
          keyboardType: TextInputType.multiline,
          maxLines: null,
          style: Theme.of(context).textTheme.caption,
          cursorColor: appColor,
          onChanged: _sendTypingNotification,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
            enabledBorder: _border,
            filled: true,
            fillColor:
                isLightTheme(context) ? appColor.withOpacity(0.1) : bubbleDark,
            focusedBorder: _border,
          ),
        ));
  }

  _buildListOfMessages() => ListView.builder(
      padding: const EdgeInsets.only(top: 16, left: 16, bottom: 20),
      itemBuilder: (_, index) {
        if (messages[index].message.from == receiver.id) {
          _sendReceipt(messages[index]);
          return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ReceiverMessage(messages[index], receiver.photoUrl));
        } else {
          return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SenderMessage(messages[index]));
        }
      },
      itemCount: messages.length,
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      addAutomaticKeepAlives: true);

  _scrollToEnd() {
    _scrollController.animateTo(_scrollController.position.maxScrollExtent,
        duration: const Duration(microseconds: 200), curve: Curves.easeInOut);
  }

  _sendReceipt(LocalMessage message) async {
    if (message.receipt == ReceiptStatus.read) return;

    final receipt = Receipt(
        recipient: message.message.from,
        messageId: message.id,
        status: ReceiptStatus.read,
        timestamp: DateTime.now());

    context.read<ReceiptBloc>().add(ReceiptEvent.onReceiptSent(receipt));

    await context
        .read<MessageThreadCubit>()
        .viewModel
        .updateMessageReceipt(receipt);
  }
}
