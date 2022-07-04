import 'package:chat/models/local_msg.dart';
import 'package:chat/viewmodels/chat_view_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MessageThreadCubit extends Cubit<List<LocalMessage>> {
  final ChatViewModel viewModel;

  MessageThreadCubit(this.viewModel) : super([]);

  Future<void> getMessages(String chatId) async {
    final messages = await viewModel.getMessages(chatId);
    emit(messages);
  }
}