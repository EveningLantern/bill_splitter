import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_provider.g.dart';

class UserProfile {
  final String name;
  final String emoji;

  const UserProfile({required this.name, required this.emoji});

  UserProfile copyWith({String? name, String? emoji}) => UserProfile(
        name: name ?? this.name,
        emoji: emoji ?? this.emoji,
      );
}

@riverpod
class Profile extends _$Profile {
  @override
  UserProfile build() => const UserProfile(name: 'You', emoji: '🧑');

  void updateName(String name) => state = state.copyWith(name: name);
  void updateEmoji(String emoji) => state = state.copyWith(emoji: emoji);
}
