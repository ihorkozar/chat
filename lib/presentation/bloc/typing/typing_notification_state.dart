part of 'typing_notification_bloc.dart';

abstract class TypingNotificationState extends Equatable {
  const TypingNotificationState();

  factory TypingNotificationState.initial() => TypingInitial();
  factory TypingNotificationState.sent() => TypingSentSuccess();

  factory TypingNotificationState.received(TypingEvent typingEvent) =>
      TypingReceivedSuccess(typingEvent);

  @override
  List<Object?> get props => [];
}

class TypingInitial extends TypingNotificationState {}

class TypingSentSuccess extends TypingNotificationState {}

class TypingReceivedSuccess extends TypingNotificationState {
  final TypingEvent typingEvent;

  const TypingReceivedSuccess(this.typingEvent);

  @override
  List<Object?> get props => [typingEvent];
}
