import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'profile_provider.g.dart';

class UserProfile {
  final String name;
  final String emoji;

  const UserProfile({required this.name, required this.emoji});

  UserProfile copyWith({String? name, String? emoji}) =>
      UserProfile(name: name ?? this.name, emoji: emoji ?? this.emoji);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfile &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          emoji == other.emoji;

  @override
  int get hashCode => name.hashCode ^ emoji.hashCode;
}

@riverpod
class ProfileNotifier extends _$ProfileNotifier {
  static const String _nameKey = 'user_name';
  static const String _emojiKey = 'user_emoji';

  @override
  UserProfile build() {
    _loadProfile();
    return const UserProfile(name: 'You', emoji: '🧑');
  }

  /// Load profile from SharedPreferences
  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_nameKey) ?? 'You';
    final emoji = prefs.getString(_emojiKey) ?? '🧑';

    state = UserProfile(name: name, emoji: emoji);
  }

  /// Update user name and persist to SharedPreferences
  Future<void> updateName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, name);
    state = state.copyWith(name: name);
  }

  /// Update user emoji and persist to SharedPreferences
  Future<void> updateEmoji(String emoji) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_emojiKey, emoji);
    state = state.copyWith(emoji: emoji);
  }

  /// Update both name and emoji
  Future<void> updateProfile(String name, String emoji) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setString(_nameKey, name),
      prefs.setString(_emojiKey, emoji),
    ]);
    state = UserProfile(name: name, emoji: emoji);
  }

  /// Reset profile to defaults
  Future<void> resetProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([prefs.remove(_nameKey), prefs.remove(_emojiKey)]);
    state = const UserProfile(name: 'You', emoji: '🧑');
  }
}
