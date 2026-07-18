import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dipalza_movil/src/share/cached_list_store.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  String toJsonString(List<String> items) => jsonEncode(items);
  List<String> fromJsonString(String raw) =>
      (jsonDecode(raw) as List).map((e) => e as String).toList();

  CachedListStore<String> buildStore() => CachedListStore<String>(
        key: 'test_key',
        toJsonString: toJsonString,
        fromJsonString: fromJsonString,
      );

  group('CachedListStore', () {
    test('read devuelve null si nunca se escribió nada', () async {
      final store = buildStore();

      expect(await store.read(), isNull);
    });

    test('write seguido de read hace round-trip de los items', () async {
      final store = buildStore();
      await store.write(['a', 'b', 'c']);

      final entry = await store.read();

      expect(entry, isNotNull);
      expect(entry!.items, ['a', 'b', 'c']);
    });

    test('read devuelve null si el JSON guardado está corrupto', () async {
      SharedPreferences.setMockInitialValues({
        'test_key_data': 'esto no es json valido',
        'test_key_savedAt': DateTime.now().toIso8601String(),
      });
      final store = buildStore();

      expect(await store.read(), isNull);
    });

    test('read devuelve null si falta la marca de tiempo', () async {
      SharedPreferences.setMockInitialValues({
        'test_key_data': jsonEncode(['a']),
      });
      final store = buildStore();

      expect(await store.read(), isNull);
    });

    test('clear borra los datos guardados', () async {
      final store = buildStore();
      await store.write(['a']);

      await store.clear();

      expect(await store.read(), isNull);
    });
  });

  group('CachedListEntry.isStale', () {
    test('false cuando savedAt está dentro del TTL', () {
      final entry = CachedListEntry<String>(
        items: ['a'],
        savedAt: DateTime.now().subtract(const Duration(minutes: 10)),
      );

      expect(entry.isStale(const Duration(minutes: 30)), isFalse);
    });

    test('true cuando savedAt superó el TTL', () {
      final entry = CachedListEntry<String>(
        items: ['a'],
        savedAt: DateTime.now().subtract(const Duration(minutes: 31)),
      );

      expect(entry.isStale(const Duration(minutes: 30)), isTrue);
    });
  });
}
