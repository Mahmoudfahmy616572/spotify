import 'package:hive/hive.dart';

class SyncOffsetCache {
  static const _boxName = 'sync_offsets';

  Future<Box> _getBox() => Hive.openBox(_boxName);

  Future<Duration?> getOffset(String songId) async {
    final box = await _getBox();
    final ms = box.get(songId) as int?;
    if (ms == null) return null;
    return Duration(milliseconds: ms);
  }

  Future<void> setOffset(String songId, Duration offset) async {
    final box = await _getBox();
    await box.put(songId, offset.inMilliseconds);
  }

  Future<bool> hasOffset(String songId) async {
    final box = await _getBox();
    return box.containsKey(songId);
  }
}
