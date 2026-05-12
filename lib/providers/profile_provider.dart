import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'profile_provider.g.dart';

// ── Value object ──────────────────────────────────────────────────────────────

class UserProfile {
  final String name;
  final String emoji;

  const UserProfile({required this.name, required this.emoji});

  UserProfile copyWith({String? name, String? emoji}) => UserProfile(
        name: name ?? this.name,
        emoji: emoji ?? this.emoji,
      );

  @override
  String toString() => 'UserProfile(name: $name, emoji: $emoji)';
}

// ── Provider ──────────────────────────────────────────────────────────────────

const _kName  = 'profile_name';
const _kEmoji = 'profile_emoji';

/// Persists the user's display name and avatar emoji to [SharedPreferences].
/// Falls back to sensible defaults on first run.
///
/// **Async provider** — wrap reads with `.when` or `.requireValue`:
/// ```dart
/// final profile = ref.watch(profileProvider).requireValue;
/// ```
@riverpod
class Profile extends _$Profile {
  late SharedPreferences _prefs;

  @override
  Future<UserProfile> build() async {
    _prefs = await SharedPreferences.getInstance();
    return UserProfile(
      name:  _prefs.getString(_kName)  ?? 'You',
      emoji: _prefs.getString(_kEmoji) ?? '🧑',
    );
  }

  // ── Mutations ─────────────────────────────────────────────────────────────

  Future<void> updateName(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    await _prefs.setString(_kName, trimmed);
    state = AsyncData(state.requireValue.copyWith(name: trimmed));
  }

  Future<void> updateEmoji(String emoji) async {
    await _prefs.setString(_kEmoji, emoji);
    state = AsyncData(state.requireValue.copyWith(emoji: emoji));
  }
}
