import 'package:flutter/material.dart';

import 'app.dart';
import 'data/providers/auth_provider.dart';

void main() {
  runApp(CrudTemplateApp(authRepository: AuthProvider.authRepository));
}
