import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  static LocalStorageService get instance => _instance;

  late SharedPreferences _prefs;

  LocalStorageService._internal();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // --- FONCTIONS GENERIQUES ---

  // Pour enregistrer n'importe quel texte
  Future<void> write(String key, String value) async {
    await _prefs.setString(key, value);
  }

  // Pour lire n'importe quel texte
  String? read(String key) {
    return _prefs.getString(key);
  }

  // Pour supprimer une valeur spécifique
  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  // Pour tout effacer (Logout)
  Future<void> clearAll() async {
    await _prefs.clear();
  }
}