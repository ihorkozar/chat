import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_chat/chat.dart';
import 'package:meta/meta.dart';

part 'receipt_event.dart';
part 'receipt_state.dart';

class ReceiptBloc extends Bloc<ReceiptEvent, ReceiptState> {
  final IReceiptService _receiptService;
  StreamSubscription? _subscription;

  ReceiptBloc(this._receiptService) : super(ReceiptState.initial()) {
    on<Subscribed>(_onSubscribedEvent);
    on<ReceiptSent>(_onReceiptSentEvent);
    on<_ReceiptReceived>(_onReceiptReceivedEvent);
  }

  void _onSubscribedEvent(Subscribed event, Emitter<ReceiptState> emit) async {
    await _subscription?.cancel();
    _subscription = _receiptService
        .getReceipts(event.user)
        .listen((receipt) => add(_ReceiptReceived(receipt)));
  }

  void _onReceiptReceivedEvent(
      _ReceiptReceived event, Emitter<ReceiptState> emit) {
    emit(ReceiptState.received(event.receipt));
  }

  void _onReceiptSentEvent(
      ReceiptSent event, Emitter<ReceiptState> emit) async {
    await _receiptService.send(event.receipt);
    emit(ReceiptState.sent(event.receipt));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    _receiptService.dispose();
    return super.close();
  }
}
