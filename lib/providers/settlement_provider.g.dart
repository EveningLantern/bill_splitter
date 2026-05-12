// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settlement_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$settlementsHash() => r'da0db0ed05732949245b00239706bbb7c40e9291';

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

/// Computes settlements for a specific session
///
/// Copied from [settlements].
@ProviderFor(settlements)
const settlementsProvider = SettlementsFamily();

/// Computes settlements for a specific session
///
/// Copied from [settlements].
class SettlementsFamily extends Family<List<Settlement>> {
  /// Computes settlements for a specific session
  ///
  /// Copied from [settlements].
  const SettlementsFamily();

  /// Computes settlements for a specific session
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

/// Computes settlements for a specific session
///
/// Copied from [settlements].
class SettlementsProvider extends AutoDisposeProvider<List<Settlement>> {
  /// Computes settlements for a specific session
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

String _$allActiveSettlementsHash() =>
    r'adfae604e3330c731496c9a0abb83c2b94da4d24';

/// Computes settlements for all active (unsettled) sessions
///
/// Copied from [allActiveSettlements].
@ProviderFor(allActiveSettlements)
final allActiveSettlementsProvider =
    AutoDisposeProvider<Map<String, List<Settlement>>>.internal(
  allActiveSettlements,
  name: r'allActiveSettlementsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$allActiveSettlementsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AllActiveSettlementsRef
    = AutoDisposeProviderRef<Map<String, List<Settlement>>>;
String _$totalOwedByPersonHash() => r'4e1b366a391a600a32573493bbeab5a45c5022a4';

/// Computes total amount owed by a person across all active sessions
///
/// Copied from [totalOwedByPerson].
@ProviderFor(totalOwedByPerson)
const totalOwedByPersonProvider = TotalOwedByPersonFamily();

/// Computes total amount owed by a person across all active sessions
///
/// Copied from [totalOwedByPerson].
class TotalOwedByPersonFamily extends Family<double> {
  /// Computes total amount owed by a person across all active sessions
  ///
  /// Copied from [totalOwedByPerson].
  const TotalOwedByPersonFamily();

  /// Computes total amount owed by a person across all active sessions
  ///
  /// Copied from [totalOwedByPerson].
  TotalOwedByPersonProvider call(
    String personName,
  ) {
    return TotalOwedByPersonProvider(
      personName,
    );
  }

  @override
  TotalOwedByPersonProvider getProviderOverride(
    covariant TotalOwedByPersonProvider provider,
  ) {
    return call(
      provider.personName,
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
  String? get name => r'totalOwedByPersonProvider';
}

/// Computes total amount owed by a person across all active sessions
///
/// Copied from [totalOwedByPerson].
class TotalOwedByPersonProvider extends AutoDisposeProvider<double> {
  /// Computes total amount owed by a person across all active sessions
  ///
  /// Copied from [totalOwedByPerson].
  TotalOwedByPersonProvider(
    String personName,
  ) : this._internal(
          (ref) => totalOwedByPerson(
            ref as TotalOwedByPersonRef,
            personName,
          ),
          from: totalOwedByPersonProvider,
          name: r'totalOwedByPersonProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$totalOwedByPersonHash,
          dependencies: TotalOwedByPersonFamily._dependencies,
          allTransitiveDependencies:
              TotalOwedByPersonFamily._allTransitiveDependencies,
          personName: personName,
        );

  TotalOwedByPersonProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.personName,
  }) : super.internal();

  final String personName;

  @override
  Override overrideWith(
    double Function(TotalOwedByPersonRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TotalOwedByPersonProvider._internal(
        (ref) => create(ref as TotalOwedByPersonRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        personName: personName,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<double> createElement() {
    return _TotalOwedByPersonProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TotalOwedByPersonProvider && other.personName == personName;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, personName.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin TotalOwedByPersonRef on AutoDisposeProviderRef<double> {
  /// The parameter `personName` of this provider.
  String get personName;
}

class _TotalOwedByPersonProviderElement
    extends AutoDisposeProviderElement<double> with TotalOwedByPersonRef {
  _TotalOwedByPersonProviderElement(super.provider);

  @override
  String get personName => (origin as TotalOwedByPersonProvider).personName;
}

String _$totalToReceiveByPersonHash() =>
    r'a1e29226da52e95e0fd7cdee1d93f900b672c0b3';

/// Computes total amount to be received by a person across all active sessions
///
/// Copied from [totalToReceiveByPerson].
@ProviderFor(totalToReceiveByPerson)
const totalToReceiveByPersonProvider = TotalToReceiveByPersonFamily();

/// Computes total amount to be received by a person across all active sessions
///
/// Copied from [totalToReceiveByPerson].
class TotalToReceiveByPersonFamily extends Family<double> {
  /// Computes total amount to be received by a person across all active sessions
  ///
  /// Copied from [totalToReceiveByPerson].
  const TotalToReceiveByPersonFamily();

  /// Computes total amount to be received by a person across all active sessions
  ///
  /// Copied from [totalToReceiveByPerson].
  TotalToReceiveByPersonProvider call(
    String personName,
  ) {
    return TotalToReceiveByPersonProvider(
      personName,
    );
  }

  @override
  TotalToReceiveByPersonProvider getProviderOverride(
    covariant TotalToReceiveByPersonProvider provider,
  ) {
    return call(
      provider.personName,
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
  String? get name => r'totalToReceiveByPersonProvider';
}

/// Computes total amount to be received by a person across all active sessions
///
/// Copied from [totalToReceiveByPerson].
class TotalToReceiveByPersonProvider extends AutoDisposeProvider<double> {
  /// Computes total amount to be received by a person across all active sessions
  ///
  /// Copied from [totalToReceiveByPerson].
  TotalToReceiveByPersonProvider(
    String personName,
  ) : this._internal(
          (ref) => totalToReceiveByPerson(
            ref as TotalToReceiveByPersonRef,
            personName,
          ),
          from: totalToReceiveByPersonProvider,
          name: r'totalToReceiveByPersonProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$totalToReceiveByPersonHash,
          dependencies: TotalToReceiveByPersonFamily._dependencies,
          allTransitiveDependencies:
              TotalToReceiveByPersonFamily._allTransitiveDependencies,
          personName: personName,
        );

  TotalToReceiveByPersonProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.personName,
  }) : super.internal();

  final String personName;

  @override
  Override overrideWith(
    double Function(TotalToReceiveByPersonRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TotalToReceiveByPersonProvider._internal(
        (ref) => create(ref as TotalToReceiveByPersonRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        personName: personName,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<double> createElement() {
    return _TotalToReceiveByPersonProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TotalToReceiveByPersonProvider &&
        other.personName == personName;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, personName.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin TotalToReceiveByPersonRef on AutoDisposeProviderRef<double> {
  /// The parameter `personName` of this provider.
  String get personName;
}

class _TotalToReceiveByPersonProviderElement
    extends AutoDisposeProviderElement<double> with TotalToReceiveByPersonRef {
  _TotalToReceiveByPersonProviderElement(super.provider);

  @override
  String get personName =>
      (origin as TotalToReceiveByPersonProvider).personName;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
