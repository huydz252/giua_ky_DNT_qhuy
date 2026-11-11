import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'data/providers/app_provider.dart';
import 'data/providers/supabase_image_storage.dart';
import 'app.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final imageStorage = await SupabaseImageStorage.initialize();
  runApp(
    ProductAdminApp(
      authRepository: AppProvider.authRepository,
      productRepository: AppProvider.productRepository,
      storage: imageStorage,
    ),
  );
}
