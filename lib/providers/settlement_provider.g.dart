// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settlement_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$settlementsHash() => r'88888a5dfeaa94ac3d7960cdaf389046c3fd0e60';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Watches [HistoryNotifier] and computes the minimal settlement list for
/// the session identified by [sessionId].
///
/// Returns an empty list when the session cannot be found.
///
/// This is a *family* provider — create it with:
///   ```dart
///   ref.watch(settlementsProvider(sessionId))
///   ```
///
/// Copied from [settlements].
@ProviderFor(settlements)
const settlementsProvider = SettlementsFamily();

/// Watches [HistoryNotifier] and computes the minimal settlement list for
/// the session identified by [sessionId].
///
/// Returns an empty list when the session cannot be found.
///
/// This is a *family* provider — create it with:
///   ```dart
///   ref.watch(settlementsProvider(sessionId))
///   ```
///
/// Copied from [settlements].
class SettlementsFamily extends Family<List<Settlement>> {
  /// Watches [HistoryNotifier] and computes the minimal settlement list for
  /// the session identified by [sessionId].
  ///
  /// Returns an empty list when the session cannot be found.
  ///
  /// This is a *family* provider — create it with:
  ///   ```dart
  ///   ref.watch(settlementsProvider(sessionId))
  ///   ```
  ///
  /// Copied from [settlements].
  const SettlementsFamily();

  /// Watches [HistoryNotifier] and computes the minimal settlement list for
  /// the session identified by [sessionId].
  ///
  /// Returns an empty list when the session cannot be found.
  ///
  /// This is a *family* provider — create it with:
  ///   ```dart
  ///   ref.watch(settlementsProvider(sessionId))
  ///   ```
  ///
  /// Copied from [settlements].
  SettlementsProvider call(
    String sessionId,
  ) {
    return SettlementsProvider(
      sessionId,
    );
  }

  @override
  SettlementsProvider getProviderOverride(
    covariant SettlementsProvider provider,
  ) {
    return call(
      provider.sessionId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'settlementsProvider';
}

/// Watches [HistoryNotifier] and computes the minimal settlement list for
/// the session identified by [sessionId].
///
/// Returns an empty list when the session cannot be found.
///
/// This is a *family* provider — create it with:
///   ```dart
///   ref.watch(settlementsProvider(sessionId))
///   ```
///
/// Copied from [settlements].
class SettlementsProvider extends AutoDisposeProvider<List<Settlement>> {
  /// Watches [HistoryNotifier] and computes the minimal settlement list for
  /// the session identified by [sessionId].
  ///
  /// Returns an empty list when the session cannot be found.
  ///
  /// This is a *family* provider — create it with:
  ///   ```dart
  ///   ref.watch(settlementsProvider(sessionId))
  ///   ```
  ///
  /// Copied from [settlements].
  SettlementsProvider(
    String sessionId,
  ) : this._internal(
          (ref) => settlements(
            ref as SettlementsRef,
            sessionId,
          ),
          from: settlementsProvider,
          name: r'settlementsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$settlementsHash,
          dependencies: SettlementsFamily._dependencies,
          allTransitiveDependencies:
              SettlementsFamily._allTransitiveDependencies,
          sessionId: sessionId,
        );

  SettlementsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.sessionId,
  }) : super.internal();

  final String sessionId;

  @override
  Override overrideWith(
    List<Settlement> Function(SettlementsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SettlementsProvider._internal(
        (ref) => create(ref as SettlementsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        sessionId: sessionId,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<List<Settlement>> createElement() {
    return _SettlementsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SettlementsProvider && other.sessionId == sessionId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, sessionId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin SettlementsRef on AutoDisposeProviderRef<List<Settlement>> {
  /// The parameter `sessionId` of this provider.
  String get sessionId;
}

class _SettlementsProviderElement
    extends AutoDisposeProviderElement<List<Settlement>> with SettlementsRef {
  _SettlementsProviderElement(super.provider);

  @override
  String get sessionId => (origin as SettlementsProvider).sessionId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
