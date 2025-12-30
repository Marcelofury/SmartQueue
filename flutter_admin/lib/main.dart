import 'package:flutter/material.dart';
import 'config/theme.dart';
import 'screens/dashboard_screen.dart';
import 'services/admin_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  // TODO: Replace with your actual Supabase credentials
  await AdminService.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );

  runApp(const SmartQueueAdminApp());
}

class SmartQueueAdminApp extends StatelessWidget {
  const SmartQueueAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartQueue Admin',
      debugShowCheckedModeBanner: false,
      theme: AdminTheme.lightTheme,
      home: const DashboardScreen(),
    );
  }
}
