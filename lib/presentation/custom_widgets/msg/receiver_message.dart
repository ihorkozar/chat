import 'package:chat/models/local_msg.dart';
import 'package:chat/util/colors.dart';
import 'package:chat/util/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

class ReceiverMessage extends StatelessWidget {
  final String _url;
  final LocalMessage _localMessage;

  const ReceiverMessage(this._localMessage, this._url);

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
        alignment: Alignment.topLeft,
        widthFactor: 0.75,
        child: Stack(children: [
          Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DecoratedBox(
                        decoration: BoxDecoration(
                            color: isLightTheme(context)
                                ? bubbleLight
                                : bubbleDark,
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
                                  .copyWith(height: 1.2)),
                        )),
                    Padding(
                        padding: const EdgeInsets.only(top: 12, left: 12),
                        child: Align(
                            alignment: Alignment.bottomLeft,
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
          CircleAvatar(
              backgroundColor:
                  isLightTheme(context) ? Colors.white : Colors.black,
              radius: 18,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: SvgPicture.network(_url,
                      width: 30, height: 30, fit: BoxFit.fill)))
        ]));
  }
}
