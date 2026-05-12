// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$historyHash() => r'a4088d9b738eb10ea17b95f6fe23df4bd4179a17';

/// Reads/writes [SplitSession] objects from the Hive box `'sessions'`.
/// Exposes a [List<SplitSession>] sorted newest-first.
/// Subscribes to box changes via [Box.watch] for reactive updates.
///
/// Copied from [History].
@ProviderFor(History)
final historyProvider =
    AutoDisposeNotifierProvider<History, List<SplitSession>>.internal(
  History.new,
  name: r'historyProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$historyHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$History = AutoDisposeNotifier<List<SplitSession>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
