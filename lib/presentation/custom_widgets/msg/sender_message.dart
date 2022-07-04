import 'package:chat/models/local_msg.dart';
import 'package:chat/util/colors.dart';
import 'package:chat/util/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/chat.dart';
import 'package:intl/intl.dart';

class SenderMessage extends StatelessWidget {
  final LocalMessage _localMessage;

  const SenderMessage(this._localMessage);

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
        alignment: Alignment.centerRight,
        widthFactor: 0.75,
        child: Stack(children: [
          Padding(
              padding: const EdgeInsets.only(right: 30),
              child:
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                DecoratedBox(
                    decoration: BoxDecoration(
                        color: appColor,
                        borderRadius: BorderRadius.circular(30)),
                    position: DecorationPosition.background,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      child: Text(_localMessage.message.content.trim(),
                          softWrap: true,
                          style: Theme.of(context)
                              .textTheme
                              .caption!
                              .copyWith(height: 1.2, color: Colors.white)),
                    )),
                Padding(
                    padding: const EdgeInsets.only(top: 12, left: 12),
                    child: Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                            DateFormat('h:mm a')
                                .format(_localMessage.message.timestamp),
                            style: Theme.of(context)
                                .textTheme
                                .overline!
                                .copyWith(
                                color: isLightTheme(context)
                                    ? Colors.black54
                                    : Colors.white70))))
              ])),
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              child: Align(
                  alignment: Alignment.centerRight,
                  child: DecoratedBox(
                      decoration: BoxDecoration(
                          color: isLightTheme(context)
                              ? Colors.white
                              : Colors.black,
                          borderRadius: BorderRadius.circular(30)),
                      child: Icon(Icons.check_circle_rounded,
                          color: _localMessage.receipt == ReceiptStatus.read
                              ? Colors.green[700]
                              : Colors.grey,
                          size: 20))))
        ]));
  }
}