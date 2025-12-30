import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'config/theme.dart';
import 'screens/home_screen.dart';
import 'screens/queue_screen.dart';
import 'screens/ussd_screen.dart';
import 'services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  // TODO: Replace with your actual Supabase credentials
  await SupabaseService.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );

  runApp(const SmartQueueApp());
}

class SmartQueueApp extends StatelessWidget {
  const SmartQueueApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SmartQueue',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: _router,
    );
  }
}

// Router configuration
final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/queue/:queueId',
      builder: (context, state) {
        final queueId = state.pathParameters['queueId']!;
        return QueueScreen(queueId: queueId);
      },
    ),
    GoRoute(
      path: '/ussd',
      builder: (context, state) => const USSDScreen(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Page not found',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/'),
            child: const Text('Go Home'),
          ),
        ],
      ),
    ),
  ),
);
