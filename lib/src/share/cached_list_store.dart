import 'package:shared_preferences/shared_preferences.dart';

class CachedListEntry<M> {
  final List<M> items;
  final DateTime savedAt;

  CachedListEntry({required this.items, required this.savedAt});

  bool isStale(Duration ttl) => DateTime.now().difference(savedAt) > ttl;
}

class CachedListStore<M> {
  final String key;
  final String Function(List<M>) toJsonString;
  final List<M> Function(String) fromJsonString;

  CachedListStore({
    required this.key,
    required this.toJsonString,
    required this.fromJsonString,
  });

  String get _dataKey => '${key}_data';

  String get _savedAtKey => '${key}_savedAt';

  Future<CachedListEntry<M>?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_dataKey);
    final savedAtRaw = prefs.getString(_savedAtKey);
    if (raw == null || savedAtRaw == null) return null;

    final savedAt = DateTime.tryParse(savedAtRaw);
    if (savedAt == null) return null;

    try {
      final items = fromJsonString(raw);
      return CachedListEntry<M>(items: items, savedAt: savedAt);
    } catch (_) {
      return null;
    }
  }

  Future<void> write(List<M> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dataKey, toJsonString(items));
    await prefs.setString(_savedAtKey, DateTime.now().toIso8601String());
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_dataKey);
    await prefs.remove(_savedAtKey);
  }
}
