import 'package:chat/src/models/receipt.dart';
import 'package:chat/src/models/user.dart';
import 'package:chat/src/services/receipt/reseipt_service_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';

import '../helpers.dart';

void main() {
  RethinkDb rethinkdb = RethinkDb();
  late Connection connection;
  late ReceiptService receiptService;

  setUp(() async {
    connection = await rethinkdb.connect(host: "127.0.0.1", port: 28015);
    await createDb(rethinkdb, connection);
    receiptService = ReceiptService(rethinkdb, connection);
  });

  tearDown(() async {
    receiptService.dispose();
    await cleanDb(rethinkdb, connection);
  });

  test('send receipt successfully', () async {
    Receipt receipt = Receipt(
        recipient: '123',
        messageId: '1234',
        status: ReceiptStatus.delivered,
        timestamp: DateTime.now());

    final result = await receiptService.send(receipt);
    expect(result, true);
  });

  test('successfully subscribe and receive receipts', () async {
    User user = User.fromJson({
      'id': '1',
      'username': 'user1',
      'photo_url':
      'https://s.dou.ua/CACHE/images/img/static/companies/dou/e7a0a2cb03acd45577dcc09a5fc8d565.png',
      'is_active': true,
      'last_seen': DateTime.now()
    });

    Receipt receipt1 = Receipt(
        recipient: user.id,
        messageId: '1234',
        status: ReceiptStatus.delivered,
        timestamp: DateTime.now());

    Receipt receipt2 = Receipt(
        recipient: user.id,
        messageId: '1234',
        status: ReceiptStatus.read,
        timestamp: DateTime.now());

    await receiptService.send(receipt1);
    await receiptService.send(receipt2);

    receiptService.getReceipts(user).listen(expectAsync1((receipt) {
      expect(receipt.recipient, user.id);
    }, count: 2));
  });
}