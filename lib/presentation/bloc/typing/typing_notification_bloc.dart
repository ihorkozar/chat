import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_chat/chat.dart';

part 'typing_notification_event.dart';

part 'typing_notification_state.dart';

class TypingNotificationBloc
    extends Bloc<TypingNotificationEvent, TypingNotificationState> {
  final ITypingNotificationService _typingService;
  StreamSubscription? _subscription;

  TypingNotificationBloc(this._typingService)
      : super(TypingNotificationState.initial()) {
    on<Subscribed>(_onSubscribedEvent);
    on<TypingNotificationSent>(_onTypingNotificationSentEvent);
    on<_TypingNotificationReceived>(_onTypingNotificationReceivedEvent);
    on<NotSubscribed>(_notSubscribedEvent);
  }

  void _onSubscribedEvent(
      Subscribed event, Emitter<TypingNotificationState> emit) async {
    List<String>? usersToSubscribe = event.usersWithChat;
    if (usersToSubscribe == null) {
      add(NotSubscribed());
      return;
    } else {
      await _subscription?.cancel();
      _subscription = _typingService
          .subscribe(event.user, usersToSubscribe)
          .listen(
              (typingEvent) => add(_TypingNotificationReceived(typingEvent)));
    }
  }

  void _onTypingNotificationReceivedEvent(_TypingNotificationReceived event,
      Emitter<TypingNotificationState> emit) {
    emit(TypingNotificationState.received(event.typingEvent));
  }

  void _onTypingNotificationSentEvent(TypingNotificationSent event,
      Emitter<TypingNotificationState> emit) async {
    await _typingService.send(typingEvent: event.typingEvent);
    emit(TypingNotificationState.sent());
  }

  void _notSubscribedEvent(
      NotSubscribed event, Emitter<TypingNotificationState> emit) {
    emit(TypingNotificationState.initial());
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    _typingService.dispose();
    return super.close();
  }
}
