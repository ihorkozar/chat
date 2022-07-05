import 'package:chat/data/datasources/datasource.dart';
import 'package:chat/data/datasources/db_factories.dart';
import 'package:chat/data/datasources/sqflite_datasource_impl.dart';
import 'package:chat/presentation/bloc/home/chats_cubit.dart';
import 'package:chat/presentation/bloc/home/online_users_cubit.dart';
import 'package:chat/presentation/bloc/message/message_bloc.dart';
import 'package:chat/presentation/bloc/message/message_thread_cubit.dart';
import 'package:chat/presentation/bloc/onboarding/onboarding_cubit.dart';
import 'package:chat/presentation/bloc/receipt/receipt_bloc.dart';
import 'package:chat/presentation/bloc/typing/typing_notification_bloc.dart';
import 'package:chat/presentation/screens/home.dart';
import 'package:chat/presentation/screens/home_router.dart';
import 'package:chat/presentation/screens/messages_list.dart';
import 'package:chat/presentation/screens/onboarding_dart.dart';
import 'package:chat/presentation/screens/onboarding_router.dart';
import 'package:chat/viewmodels/chat_view_model.dart';
import 'package:chat/viewmodels/chats_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat/chat.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'local_cache.dart';

class CompositionRoot {
  static late RethinkDb _rethinkDb;
  static late Connection _connection;
  static late IUserService _userService;
  static late IMessageService _messageService;
  static late Database _database;
  static late IDataSource _dataSource;
  static late ILocalCache _localCache;
  static late MessageBloc _messageBloc;
  static late ITypingNotificationService _typingService;
  static late TypingNotificationBloc _typingNotificationBloc;
  static late ChatsCubit _chatsCubit;

  static configure() async {
    _rethinkDb = RethinkDb();
    _connection = await _rethinkDb.connect(host: '192.168.34.49', port: 28015);
    _userService = UserService(_rethinkDb, _connection);
    _messageService = MessageService(_rethinkDb, _connection);
    _database = await LocalDatabaseFactory().createDatabase();
    _dataSource = SQFLiteDataSource(_database);
    _typingService = TypingService(_rethinkDb, _connection, _userService);
    _typingNotificationBloc = TypingNotificationBloc(_typingService);

    _chatsCubit = ChatsCubit(ChatsViewModel(_dataSource, _userService));

    /* await _rethinkDb.table('messages').delete().run(_connection);
    await _database.delete('messages');
    await _database.delete('chats'); */

    _localCache = LocalCache(await SharedPreferences.getInstance());
    _messageBloc = MessageBloc(_messageService);
  }

  static Widget start() {
    final user = _localCache.fetch('user_cached');

    if (user.isNotEmpty) {
      user['last_seen'] = DateTime.now();
      return composeHomeUI(User.fromJson(user));
    } else {
      return composeOnboardingUI();
    }
  }

  static Widget composeOnboardingUI() {
    OnboardingCubit onboardingCubit =
    OnboardingCubit(_userService, _localCache);

    IOnboardingRouter router = OnboardingRouter(composeHomeUI);

    return MultiBlocProvider(providers: [
      BlocProvider(create: (BuildContext context) => onboardingCubit)
    ], child: Onboarding(router));
  }

  static Widget composeHomeUI(User user) {
    OnlineUsersCubit onlineUsersCubit =
    OnlineUsersCubit(_userService, _localCache);

    IHomeRouter router = HomeRouter(showMessageThread: composeMessageThreadUI);

    return MultiBlocProvider(providers: [
      BlocProvider(create: (BuildContext context) => onlineUsersCubit),
      BlocProvider(create: (BuildContext context) => _messageBloc),
      BlocProvider(create: (BuildContext context) => _chatsCubit),
      BlocProvider(create: (BuildContext context) => _typingNotificationBloc)
    ], child: Home(user, router));
  }

  static Widget composeMessageThreadUI(User receiver, User activeUser,
      {required String chatId}) {
    ChatViewModel chatViewModel = ChatViewModel(_dataSource);
    MessageThreadCubit messageThreadCubit = MessageThreadCubit(chatViewModel);
    IReceiptService receiptService = ReceiptService(_rethinkDb, _connection);
    ReceiptBloc receiptBloc = ReceiptBloc(receiptService);

    return MultiBlocProvider(
        providers: [
          BlocProvider(create: (BuildContext context) => messageThreadCubit),
          BlocProvider(create: (BuildContext context) => receiptBloc)
        ],
        child: MessagesList(receiver, activeUser, _messageBloc, _chatsCubit,
            _typingNotificationBloc,
            chatId: chatId));
  }
}