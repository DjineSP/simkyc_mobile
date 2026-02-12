import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';

class UserProfile {
  final String name;
  final String age;

  UserProfile({required this.name, required this.age});
}

class UserNotifier extends Notifier<UserProfile> {
  @override
  UserProfile build() {
    // On récupère les données sauvegardées au démarrage
    final name = StorageService.instance.read('user_name') ?? '';
    final age = StorageService.instance.read('user_age') ?? '';
    return UserProfile(name: name, age: age);
  }

  void saveProfile(String name, String age) {
    state = UserProfile(name: name, age: age);
    StorageService.instance.write('user_name', name);
    StorageService.instance.write('user_age', age);
  }
}

final userProvider = NotifierProvider<UserNotifier, UserProfile>(UserNotifier.new);