import 'package:flutter_chat/src/models/receipt.dart';
import 'package:flutter_chat/src/models/user.dart';

abstract class IReceiptService {
  Future<bool> send(Receipt receipt);
  Stream<Receipt> getReceipts(User user);
  void dispose();
}