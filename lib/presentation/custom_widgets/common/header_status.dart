import 'package:chat/presentation/custom_widgets/home/avatar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HeaderStatus extends StatelessWidget {
  final String username;
  final String photoUrl;
  final bool isActive;

  final DateTime? lastSeen;
  final bool? typing;

  const HeaderStatus(this.username, this.photoUrl, this.isActive,
      {this.lastSeen, this.typing});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.maxFinite,
        child: Row(
          children: [
            Avatar(
              imageUrl: photoUrl,
              isOnline: isActive,
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Text(username,
                      style: Theme.of(context).textTheme.caption?.copyWith(
                          fontSize: 14, fontWeight: FontWeight.bold))),
              Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: typing == null
                      ? Text(
                          isActive
                              ? 'online'
                              : 'last seen ${DateFormat.yMd().add_jm().format(lastSeen!)}',
                          style: Theme.of(context)
                              .textTheme
                              .caption
                              ?.copyWith(fontSize: 14))
                      : Text('typing...',
                          style: Theme.of(context)
                              .textTheme
                              .caption
                              ?.copyWith(fontStyle: FontStyle.italic)))
            ])
          ],
        ));
  }
}
