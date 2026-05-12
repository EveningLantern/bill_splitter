// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$profileHash() => r'21db40e78158bde297cb52f80d92e57648c0de67';

/// Persists the user's display name and avatar emoji to [SharedPreferences].
/// Falls back to sensible defaults on first run.
///
/// **Async provider** — wrap reads with `.when` or `.requireValue`:
/// ```dart
/// final profile = ref.watch(profileProvider).requireValue;
/// ```
///
/// Copied from [Profile].
@ProviderFor(Profile)
final profileProvider =
    AutoDisposeAsyncNotifierProvider<Profile, UserProfile>.internal(
  Profile.new,
  name: r'profileProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$profileHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Profile = AutoDisposeAsyncNotifier<UserProfile>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
