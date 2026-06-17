// Property 2: Round-Trip Persistence
//
// For any BillEntry written to and read back from the 'bill_entries' Hive box,
// every field (id, type, amount, name, dateTime) equals the original.
//
// **Validates: Requirements 8.5**
//
// Test approach: manual property-based testing — generate a large sample of
// arbitrary BillEntry values and assert round-trip field equality for each.
// Uses an in-memory Hive configuration (temp directory, adapters registered
// without Flutter bindings) so the test runs as a plain Dart test.

import 'dart:io';
import 'dart:math';

import 'package:hive/hive.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bill_splitter/models/bill_entry.dart';

// ── Generators ────────────────────────────────────────────────────────────────

/// Characters allowed in entry names: printable ASCII plus a few Unicode chars.
const _nameChars =
    'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 '
    '!@#\$%^&*()-_=+[]{}|;:,.<>?/~`'
    'àáâãäåæçèéêëìíîïðñòóôõöùúûüýþÿ';

/// Generate a random string of [length] characters from [_nameChars].
String _randomName(Random rng, int length) {
  if (length == 0) return '';
  return String.fromCharCodes(
    List.generate(
      length,
      (_) => _nameChars.codeUnitAt(rng.nextInt(_nameChars.length)),
    ),
  );
}

/// Generate a random amount in the valid range [0.01, 999_999_999.99].
/// Uses a mix of small, medium, and large values to cover the full range.
double _randomAmount(Random rng) {
  // Pick a random number of dollars (0..999_999_999) and cents (1..99) to keep
  // the value in [0.01, 999_999_999.99].
  final dollars = rng.nextInt(1_000_000_000); // 0..999_999_999
  final cents = rng.nextInt(100); // 0..99

  // Avoid exactly 0.00: if both are 0, set cents to 1.
  final effectiveCents = (dollars == 0 && cents == 0) ? 1 : cents;

  // Round to 2 decimal places to avoid floating-point drift in comparison.
  return double.parse((dollars + effectiveCents / 100.0).toStringAsFixed(2));
}

/// Generate a random DateTime between 2000-01-01 and 2099-12-31.
/// Truncated to seconds to match Hive's DateTime serialisation precision.
DateTime _randomDateTime(Random rng) {
  const epoch2000 = 946684800; // Unix seconds for 2000-01-01T00:00:00Z
  const epoch2100 = 4102444800; // Unix seconds for 2100-01-01T00:00:00Z
  final secondsRange = epoch2100 - epoch2000;
  final offsetSecs = rng.nextInt(secondsRange);
  // Truncate to seconds — Hive stores DateTime with microsecond precision, but
  // we use second-level granularity to keep assertions deterministic.
  final dt = DateTime.fromMillisecondsSinceEpoch(
    (epoch2000 + offsetSecs) * 1000,
    isUtc: false,
  );
  return DateTime(dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second);
}

/// Generate an arbitrary [BillEntry] with the given [type].
BillEntry _randomEntry(Random rng, BillEntryType type) {
  // Name length: 1..100 characters (valid range per spec).
  final nameLen = 1 + rng.nextInt(100); // 1..100
  return BillEntry(
    id: 'test-${rng.nextInt(1 << 30)}-${rng.nextInt(1 << 30)}',
    type: type,
    amount: _randomAmount(rng),
    name: _randomName(rng, nameLen),
    dateTime: _randomDateTime(rng),
  );
}

// ── Hive helpers ──────────────────────────────────────────────────────────────

/// Open an isolated, in-memory-style Hive box inside [dir].
/// Returns the open box; caller is responsible for closing it.
Future<Box<BillEntry>> _openBox(Directory dir, String boxName) async {
  Hive.init(dir.path);
  if (!Hive.isAdapterRegistered(4)) {
    Hive.registerAdapter(BillEntryTypeAdapter());
  }
  if (!Hive.isAdapterRegistered(5)) {
    Hive.registerAdapter(BillEntryAdapter());
  }
  return Hive.openBox<BillEntry>(boxName);
}

// ── Round-trip assertion ──────────────────────────────────────────────────────

/// Assert that every field of the entry read back from [box] equals [original].
void _assertRoundTrip(BillEntry original, BillEntry readBack) {
  expect(
    readBack.id,
    equals(original.id),
    reason: 'id must survive round-trip',
  );
  expect(
    readBack.type,
    equals(original.type),
    reason: 'type must survive round-trip',
  );
  expect(
    readBack.amount,
    equals(original.amount),
    reason: 'amount must survive round-trip',
  );
  expect(
    readBack.name,
    equals(original.name),
    reason: 'name must survive round-trip',
  );
  expect(
    readBack.dateTime,
    equals(original.dateTime),
    reason: 'dateTime must survive round-trip',
  );
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  late Directory tempDir;
  late Box<BillEntry> box;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_persistence_test_');
    box = await _openBox(tempDir, 'bill_entries_test');
  });

  tearDown(() async {
    await box.clear();
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  // ── Property 2: Round-Trip Persistence ─────────────────────────────────────
  //
  // For any BillEntry written to and read back from the Hive box, every field
  // (id, type, amount, name, dateTime) is equal to the original.
  //
  // **Validates: Requirements 8.5**

  group('Property 2 — Round-Trip Persistence', () {
    // Number of random samples per property check.
    const sampleCount = 200;

    test(
      'expense entries: all fields equal after write → read ($sampleCount samples)',
      () async {
        final rng = Random(42); // fixed seed for reproducibility

        for (var i = 0; i < sampleCount; i++) {
          final entry = _randomEntry(rng, BillEntryType.expense);

          // Write to Hive box.
          await box.put(entry.id, entry);

          // Read back from Hive box using the same key.
          final readBack = box.get(entry.id);

          expect(
            readBack,
            isNotNull,
            reason: 'box.get() must return the written entry (sample $i)',
          );
          _assertRoundTrip(entry, readBack!);

          // Clean up for next iteration to avoid interference.
          await box.delete(entry.id);
        }
      },
    );

    test(
      'income entries: all fields equal after write → read ($sampleCount samples)',
      () async {
        final rng = Random(137); // different seed from expense test

        for (var i = 0; i < sampleCount; i++) {
          final entry = _randomEntry(rng, BillEntryType.income);

          await box.put(entry.id, entry);

          final readBack = box.get(entry.id);

          expect(
            readBack,
            isNotNull,
            reason: 'box.get() must return the written entry (sample $i)',
          );
          _assertRoundTrip(entry, readBack!);

          await box.delete(entry.id);
        }
      },
    );

    test(
      'mixed expense and income entries: all fields equal after bulk write → read',
      () async {
        final rng = Random(999);
        const halfCount = sampleCount ~/ 2;

        // Write all entries first, then read them all back.
        final entries = <BillEntry>[];
        for (var i = 0; i < halfCount; i++) {
          entries.add(_randomEntry(rng, BillEntryType.expense));
          entries.add(_randomEntry(rng, BillEntryType.income));
        }

        // Bulk write.
        for (final entry in entries) {
          await box.put(entry.id, entry);
        }

        // Bulk read and assert.
        for (final original in entries) {
          final readBack = box.get(original.id);
          expect(
            readBack,
            isNotNull,
            reason: 'box.get() must return entry id=${original.id}',
          );
          _assertRoundTrip(original, readBack!);
        }
      },
    );

    // ── Edge cases ────────────────────────────────────────────────────────────

    test(
      'entry with minimum valid amount (0.01) round-trips correctly',
      () async {
        final entry = BillEntry(
          id: 'min-amount-test',
          type: BillEntryType.expense,
          amount: 0.01,
          name: 'a',
          dateTime: DateTime(2024, 6, 15, 10, 30, 0),
        );

        await box.put(entry.id, entry);
        final readBack = box.get(entry.id);

        expect(readBack, isNotNull);
        _assertRoundTrip(entry, readBack!);
      },
    );

    test(
      'entry with maximum valid amount (999999999.99) round-trips correctly',
      () async {
        final entry = BillEntry(
          id: 'max-amount-test',
          type: BillEntryType.income,
          amount: 999999999.99,
          name: 'max income',
          dateTime: DateTime(2024, 1, 1, 0, 0, 0),
        );

        await box.put(entry.id, entry);
        final readBack = box.get(entry.id);

        expect(readBack, isNotNull);
        _assertRoundTrip(entry, readBack!);
      },
    );

    test('entry with name of 1 character round-trips correctly', () async {
      final entry = BillEntry(
        id: 'min-name-test',
        type: BillEntryType.expense,
        amount: 1.00,
        name: 'X',
        dateTime: DateTime(2023, 12, 31, 23, 59, 59),
      );

      await box.put(entry.id, entry);
      final readBack = box.get(entry.id);

      expect(readBack, isNotNull);
      _assertRoundTrip(entry, readBack!);
    });

    test('entry with name of 100 characters round-trips correctly', () async {
      final longName = 'A' * 100;
      final entry = BillEntry(
        id: 'max-name-test',
        type: BillEntryType.income,
        amount: 50.00,
        name: longName,
        dateTime: DateTime(2025, 3, 20, 14, 45, 0),
      );

      await box.put(entry.id, entry);
      final readBack = box.get(entry.id);

      expect(readBack, isNotNull);
      _assertRoundTrip(entry, readBack!);
    });

    test(
      'entry with BillEntryType.expense type round-trips correctly',
      () async {
        final entry = BillEntry(
          id: 'type-expense-test',
          type: BillEntryType.expense,
          amount: 42.50,
          name: 'Coffee',
          dateTime: DateTime(2024, 8, 10, 9, 0, 0),
        );

        await box.put(entry.id, entry);
        final readBack = box.get(entry.id);

        expect(readBack, isNotNull);
        expect(readBack!.type, equals(BillEntryType.expense));
        _assertRoundTrip(entry, readBack);
      },
    );

    test(
      'entry with BillEntryType.income type round-trips correctly',
      () async {
        final entry = BillEntry(
          id: 'type-income-test',
          type: BillEntryType.income,
          amount: 5000.00,
          name: 'Salary',
          dateTime: DateTime(2024, 8, 1, 12, 0, 0),
        );

        await box.put(entry.id, entry);
        final readBack = box.get(entry.id);

        expect(readBack, isNotNull);
        expect(readBack!.type, equals(BillEntryType.income));
        _assertRoundTrip(entry, readBack);
      },
    );

    test(
      'overwriting an entry with the same id round-trips the new values',
      () async {
        final original = BillEntry(
          id: 'overwrite-test',
          type: BillEntryType.expense,
          amount: 10.00,
          name: 'Initial',
          dateTime: DateTime(2024, 1, 1, 0, 0, 0),
        );
        final updated = BillEntry(
          id: 'overwrite-test', // same id
          type: BillEntryType.income,
          amount: 99.99,
          name: 'Updated',
          dateTime: DateTime(2024, 6, 15, 12, 30, 0),
        );

        await box.put(original.id, original);
        await box.put(updated.id, updated);

        final readBack = box.get('overwrite-test');
        expect(readBack, isNotNull);
        _assertRoundTrip(updated, readBack!);
      },
    );
  });
}
