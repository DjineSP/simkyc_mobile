import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app/app.dart';

import 'core/services/storage_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
    await StorageService.instance.init();

    debugPrint("Services initialisés avec succès");
  } catch (e) {
    debugPrint("Erreur lors de l'initialisation : $e");
  }

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}