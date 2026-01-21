class SecureStorageService {
  static final SecureStorageService _instance = SecureStorageService._internal();
  static SecureStorageService get instance => _instance;

  final Map<String, String> _memory;

  SecureStorageService._internal() : _memory = <String, String>{};

  Future<void> write(String key, String value) async {
    _memory[key] = value;
  }

  Future<String?> read(String key) async {
    return _memory[key];
  }

  Future<void> remove(String key) async {
    _memory.remove(key);
  }

  Future<void> clearAll() async {
    _memory.clear();
  }
}
