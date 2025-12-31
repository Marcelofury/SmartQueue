import 'package:flutter/material.dart';
import 'config/theme.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'services/admin_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase only once
  try {
    await AdminService.initialize(
      url: 'https://ehygofstivdylpkwlcug.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVoeWdvZnN0aXZkeWxwa3dsY3VnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjcwODQ1NDQsImV4cCI6MjA4MjY2MDU0NH0.dUQZr2o14GRRVrQ1FsxlCv0R_nY1N-wCFA7Sb8YGW1k',
    );
  } catch (e) {
    print('Supabase already initialized or error: $e');
  }

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
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final _adminService = AdminService();
  late Future<bool> _loginCheckFuture;

  @override
  void initState() {
    super.initState();
    // Start async check immediately without blocking
    _loginCheckFuture = _adminService.isLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _loginCheckFuture,
      builder: (context, snapshot) {
        // Show loading while checking
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Default to login screen on error or if not logged in
        final isLoggedIn = snapshot.data ?? false;
        return isLoggedIn ? const DashboardScreen() : const LoginScreen();
      },
    );
  }
}
