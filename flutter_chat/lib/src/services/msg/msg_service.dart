import 'package:flutter_chat/src/models/message.dart';
import 'package:flutter_chat/src/models/user.dart';

abstract class IMessageService {
  Future<Message> send(Message message);
  Stream<Message> getMessages({required User activeUser});
  dispose();
}