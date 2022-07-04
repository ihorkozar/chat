import 'package:chat/util/colors.dart';
import 'package:chat/util/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ProfileAvatar extends StatelessWidget {
  final VoidCallback onUpdateAvatar;
  final String imageUrl;

  const ProfileAvatar({required this.onUpdateAvatar, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 126,
        width: 126,
        child: Material(
            color: isLightTheme(context) ? Colors.white : Colors.black,
            borderRadius: BorderRadius.circular(126),
            child: InkWell(
                borderRadius: BorderRadius.circular(126),
                onTap: () => onUpdateAvatar(),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipOval(
                        child: SvgPicture.network(
                      imageUrl,
                      height: 100,
                    )),
                    Align(
                        alignment: Alignment.topRight,
                        child: CircleAvatar(
                            backgroundColor: isLightTheme(context)
                                ? Colors.white
                                : Colors.black,
                            child: const Icon(Icons.refresh_rounded,
                                color: appColor, size: 38)))
                  ],
                ))));
  }
}
