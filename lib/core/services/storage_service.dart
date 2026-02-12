import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  static StorageService get instance => _instance;

  late SharedPreferences _prefs;
  final FlutterSecureStorage _secure;

  StorageService._internal() : _secure = const FlutterSecureStorage();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // --- LOCAL STORAGE (SharedPreferences) ---

  Future<void> write(String key, String value) async {
    await _prefs.setString(key, value);
  }

  String? read(String key) {
    return _prefs.getString(key);
  }

  Future<void> writeBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  bool readBool(String key) {
    return _prefs.getBool(key) ?? false;
  }

  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  Future<void> clearAll() async {
    await _prefs.clear();
  }

  // --- SECURE STORAGE (FlutterSecureStorage) ---

  Future<void> secureWrite(String key, String value) async {
    await _secure.write(key: key, value: value);
  }

  Future<String?> secureRead(String key) async {
    return _secure.read(key: key);
  }

  Future<void> secureRemove(String key) async {
    await _secure.delete(key: key);
  }

  Future<void> secureClearAll() async {
    await _secure.deleteAll();
  }
}
