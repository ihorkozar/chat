import 'package:equatable/equatable.dart';
import 'package:flutter_chat/chat.dart';

abstract class OnboardingState extends Equatable {}

class OnboardingInitial extends OnboardingState {
  @override
  List<Object?> get props => [];
}

class Loading extends OnboardingState {
  @override
  List<Object?> get props => [];
}

class OnboardingSuccess extends OnboardingState {
  final User user;

  OnboardingSuccess(this.user);

  @override
  List<Object?> get props => [user];
}