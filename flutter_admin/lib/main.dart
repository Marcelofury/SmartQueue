import 'package:flutter/material.dart';
import 'config/theme.dart';
import 'screens/dashboard_screen.dart';
import 'services/admin_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await AdminService.initialize(
    url: 'https://ehygofstivdylpkwlcug.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVoeWdvZnN0aXZkeWxwa3dsY3VnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjcwODQ1NDQsImV4cCI6MjA4MjY2MDU0NH0.dUQZr2o14GRRVrQ1FsxlCv0R_nY1N-wCFA7Sb8YGW1k',
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
