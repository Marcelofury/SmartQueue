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
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    // Check login status asynchronously without blocking
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLoginStatus();
    });
  }

  Future<void> _checkLoginStatus() async {
    try {
      final loggedIn = await _adminService.isLoggedIn();
      if (mounted) {
        setState(() {
          _isLoggedIn = loggedIn;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Auth check error: $e');
      if (mounted) {
        setState(() {
          _isLoggedIn = false;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return _isLoggedIn ? const DashboardScreen() : const LoginScreen();
  }
}
