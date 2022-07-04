import 'dart:math';

enum AvatarCategory {
  human,
  avataaars,
}

extension AvatarCategoryRandomize on AvatarCategory {
  static String getRandomAvatarCategory() {
    return AvatarCategory.values[Random().nextInt(AvatarCategory.values.length)]
        .toString()
        .split('.')
        .last;
  }
}

class AvatarService {
  static const String _baseUrl = 'https://avatars.dicebear.com/api/';

  String getRandomAvatarUrl() {
    return _baseUrl +
        AvatarCategoryRandomize.getRandomAvatarCategory() +
        '/' +
        DateTime.now().toString() +
        '.svg';
  }
}