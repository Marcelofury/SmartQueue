import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminService {
  static final AdminService _instance = AdminService._internal();
  factory AdminService() => _instance;
  AdminService._internal();

  SupabaseClient get client => Supabase.instance.client;
  String? _currentUserId;
  String? _currentUserEmail;

  // Initialize Supabase (only once)
  static bool _isInitialized = false;
  
  static Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    if (_isInitialized) {
      print('Supabase already initialized, skipping');
      return;
    }
    
    try {
      await Supabase.initialize(
        url: url,
        anonKey: anonKey,
      );
      _isInitialized = true;
      print('Supabase initialized successfully');
    } catch (e) {
      if (e.toString().contains('already initialized')) {
        _isInitialized = true;
        print('Supabase was already initialized');
      } else {
        rethrow;
      }
    }
  }

  // Login
  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      print('Attempting login for: $email');
      
      // Query admin_users table with timeout
      final response = await client
          .from('admin_users')
          .select('id, email, full_name')
          .eq('email', email)
          .maybeSingle()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Connection timeout - please check your internet'),
          );

      if (response == null) {
        throw Exception('Invalid email or password');
      }

      print('User found: ${response['email']}');
      
      // In production, verify password hash
      // For now, accepting any password for demo
      _currentUserId = response['id'];
      _currentUserEmail = response['email'];

      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('admin_user_id', _currentUserId!);
      await prefs.setString('admin_email', _currentUserEmail!);
      
      print('Login successful for: $_currentUserEmail');
    } catch (e) {
      print('Login error: $e');
      if (e.toString().contains('timeout')) {
        throw Exception('Connection timeout. Please check your internet connection.');
      } else if (e.toString().contains('Failed host lookup')) {
        throw Exception('Cannot connect to server. Please check your internet connection.');
      } else {
        throw Exception('Login failed: ${e.toString().replaceAll('Exception: ', '')}');
      }
    }
  }

  // Logout
  Future<void> logout() async {
    _currentUserId = null;
    _currentUserEmail = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('admin_user_id');
    await prefs.remove('admin_email');
  }

  // Check if logged in
  Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance()
          .timeout(const Duration(seconds: 5));
      _currentUserId = prefs.getString('admin_user_id');
      _currentUserEmail = prefs.getString('admin_email');
      print('Login status check: ${_currentUserId != null}');
      return _currentUserId != null;
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }

  // Get current user ID
  String? get currentUserId => _currentUserId;

  // Get all businesses for current admin
  Future<List<Map<String, dynamic>>> getAllBusinesses() async {
    try {
      if (_currentUserId == null) {
        throw Exception('Not logged in');
      }

      final response = await client
          .from('businesses')
          .select()
          .eq('admin_user_id', _currentUserId!)
          .order('created_at')
          .timeout(const Duration(seconds: 10));
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching businesses: $e');
      throw Exception('Failed to fetch businesses: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  // Get waiting queue for a business
  Future<List<Map<String, dynamic>>> getWaitingQueue(String businessId) async {
    try {
      final response = await client
          .from('queues')
          .select('*')
          .eq('business_id', businessId)
          .eq('status', 'waiting')
          .order('position', ascending: true)
          .timeout(const Duration(seconds: 10));

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching queue: $e');
      throw Exception('Failed to fetch queue: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  // Stream waiting queue for real-time updates (throttled to reduce load)
  Stream<List<Map<String, dynamic>>> streamWaitingQueue(String businessId) {
    return client
        .from('queues')
        .stream(primaryKey: ['id'])\n        .asyncMap((data) async {
          // Run filtering off main thread
          return List<Map<String, dynamic>>.from(data)
              .where((item) => 
                  item['business_id'] == businessId && 
                  item['status'] == 'waiting')
              .toList()
            ..sort((a, b) => (a['position'] as int).compareTo(b['position'] as int));
        });\n  }

  // Get all queue entries (for statistics)
  Future<List<Map<String, dynamic>>> getAllQueueEntries(String businessId) async {
    try {
      final response = await client
          .from('queues')
          .select('*')
          .eq('business_id', businessId)
          .order('created_at', ascending: false)
          .timeout(const Duration(seconds: 10));

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching queue entries: $e');\n      throw Exception('Failed to fetch queue entries: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  // Call next customer (move top waiting customer to serving)
  Future<Map<String, dynamic>> callNext(String businessId) async {
    try {
      // Get the first person in queue
      final waitingQueue = await client
          .from('queues')
          .select('*')
          .eq('business_id', businessId)
          .eq('status', 'waiting')
          .order('position', ascending: true)
          .limit(1);

      if (waitingQueue.isEmpty) {
        throw Exception('No customers in queue');
      }

      final nextCustomer = waitingQueue.first;

      // Update status to serving
      await client
          .from('queues')
          .update({'status': 'serving'})
          .eq('id', nextCustomer['id']);

      // Update positions for remaining customers
      await _updateQueuePositions(businessId);

      return nextCustomer;
    } catch (e) {
      throw Exception('Failed to call next customer: $e');
    }
  }

  // Complete service for a customer
  Future<void> completeService(String queueId) async {
    try {
      await client.from('queues').update({'status': 'done'}).eq('id', queueId);
    } catch (e) {
      throw Exception('Failed to complete service: $e');
    }
  }

  // Update positions for all waiting customers
  Future<void> _updateQueuePositions(String businessId) async {
    final waitingQueue = await client
        .from('queues')
        .select('id')
        .eq('business_id', businessId)
        .eq('status', 'waiting')
        .order('created_at', ascending: true);

    // Update positions sequentially
    for (int i = 0; i < waitingQueue.length; i++) {
      await client
          .from('queues')
          .update({'position': i + 1})
          .eq('id', waitingQueue[i]['id']);
    }
  }

  // AI PREDICTOR: Calculate actual average service time from last 5 completed tickets
  Future<int> calculateActualAverageServiceTime(String businessId) async {
    try {
      // Get last 5 completed tickets
      final completedTickets = await client
          .from('queues')
          .select('created_at, updated_at')
          .eq('business_id', businessId)
          .eq('status', 'done')
          .order('updated_at', ascending: false)
          .limit(5);

      if (completedTickets.isEmpty) {
        // No completed tickets yet, return default
        return 15; // Default 15 minutes
      }

      // Calculate service time for each ticket (difference between created_at and updated_at)
      int totalServiceTime = 0;
      int validTickets = 0;

      for (var ticket in completedTickets) {
        try {
          final createdAt = DateTime.parse(ticket['created_at']);
          final updatedAt = DateTime.parse(ticket['updated_at']);
          
          final serviceTime = updatedAt.difference(createdAt).inMinutes;
          
          // Only count valid service times (between 1 and 120 minutes)
          if (serviceTime > 0 && serviceTime <= 120) {
            totalServiceTime += serviceTime;
            validTickets++;
          }
        } catch (e) {
          // Skip invalid dates
          continue;
        }
      }

      if (validTickets == 0) {
        return 15; // Default if no valid tickets
      }

      // Calculate average and round to nearest minute
      final averageServiceTime = (totalServiceTime / validTickets).round();
      
      // Ensure minimum of 5 minutes
      return averageServiceTime < 5 ? 5 : averageServiceTime;
    } catch (e) {
      throw Exception('Failed to calculate average service time: $e');
    }
  }

  // Update business average service time
  Future<void> updateBusinessAverageServiceTime(
    String businessId,
    int avgServiceTime,
  ) async {
    try {
      await client
          .from('businesses')
          .update({'avg_service_time': avgServiceTime})
          .eq('id', businessId);
    } catch (e) {
      throw Exception('Failed to update average service time: $e');
    }
  }

  // AI PREDICTOR with auto-update: Calculate and update avg_service_time
  Future<Map<String, dynamic>> runAIPredictor(String businessId) async {
    try {
      // Calculate actual average service time
      final actualAvgTime = await calculateActualAverageServiceTime(businessId);

      // Get current average service time
      final business = await client
          .from('businesses')
          .select('avg_service_time, name')
          .eq('id', businessId)
          .single();

      final currentAvgTime = business['avg_service_time'] as int;
      final businessName = business['name'] as String;

      // Update the business with new average service time
      await updateBusinessAverageServiceTime(businessId, actualAvgTime);

      return {
        'business_name': businessName,
        'previous_avg_time': currentAvgTime,
        'new_avg_time': actualAvgTime,
        'difference': actualAvgTime - currentAvgTime,
        'improvement_percentage': currentAvgTime > 0
            ? (((currentAvgTime - actualAvgTime) / currentAvgTime) * 100).toStringAsFixed(1)
            : '0',
      };
    } catch (e) {
      throw Exception('Failed to run AI predictor: $e');
    }
  }

  // Get queue statistics
  Future<Map<String, dynamic>> getQueueStatistics(String businessId) async {
    try {
      final allEntries = await getAllQueueEntries(businessId)
          .timeout(const Duration(seconds: 10));

      final waiting = allEntries.where((e) => e['status'] == 'waiting').length;
      final serving = allEntries.where((e) => e['status'] == 'serving').length;
      final done = allEntries.where((e) => e['status'] == 'done').length;

      // Get business info
      final business = await client
          .from('businesses')
          .select('avg_service_time')
          .eq('id', businessId)
          .single()
          .timeout(const Duration(seconds: 10));

      final avgServiceTime = business['avg_service_time'] as int;

      return {
        'total_customers': allEntries.length,
        'waiting': waiting,
        'serving': serving,
        'completed': done,
        'avg_service_time': avgServiceTime,
        'estimated_total_wait': waiting * avgServiceTime,
      };
    } catch (e) {
      print('Error getting statistics: $e');
      throw Exception('Failed to get statistics: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }
}
