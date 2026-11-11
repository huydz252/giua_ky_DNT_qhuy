import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase Storage is used for image bytes; Firestore only stores the URL.
class SupabaseImageStorage {
  SupabaseImageStorage(this._client);

  static const bucketName = 'images';
  static const _defaultUrl = 'https://rkwtaqqjzqtombtuvphw.supabase.co';
  static const _defaultPublishableKey =
      'sb_publishable_5H8tYY49CkuG1dF3lBN78A_px94wNAs';

  final SupabaseClient _client;

  static String get url => const String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: _defaultUrl,
  );
  static String get anonKey =>
      const String.fromEnvironment(
        'SUPABASE_ANON_KEY',
        defaultValue: _defaultPublishableKey,
      );
  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;

  static Future<SupabaseImageStorage?> initialize() async {
    if (!isConfigured) return null;
    await Supabase.initialize(url: url, publishableKey: anonKey);
    return SupabaseImageStorage(Supabase.instance.client);
  }

  Future<String> upload(Uint8List bytes, String fileName) async {
    final safeName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final path = '${DateTime.now().microsecondsSinceEpoch}_$safeName';
    await _client.storage.from(bucketName).uploadBinary(path, bytes);
    return _client.storage.from(bucketName).getPublicUrl(path);
  }
}
