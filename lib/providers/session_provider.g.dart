// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$splitSessionNotifierHash() =>
    r'720a5fe115de9d44a354840259381d7c472085ef';

/// Holds the in-progress [SplitSession] being built across the 3-step wizard.
/// On [confirmSession] the session is persisted via [HistoryNotifier] and
/// the local state is reset.
///
/// Copied from [SplitSessionNotifier].
@ProviderFor(SplitSessionNotifier)
final splitSessionNotifierProvider =
    AutoDisposeNotifierProvider<SplitSessionNotifier, SplitSession>.internal(
  SplitSessionNotifier.new,
  name: r'splitSessionNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$splitSessionNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SplitSessionNotifier = AutoDisposeNotifier<SplitSession>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
