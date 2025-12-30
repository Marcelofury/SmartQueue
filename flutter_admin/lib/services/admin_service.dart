import 'package:supabase_flutter/supabase_flutter.dart';

class AdminService {
  static final AdminService _instance = AdminService._internal();
  factory AdminService() => _instance;
  AdminService._internal();

  SupabaseClient get client => Supabase.instance.client;

  // Initialize Supabase
  static Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
  }

  // Get all businesses
  Future<List<Map<String, dynamic>>> getAllBusinesses() async {
    try {
      final response = await client.from('businesses').select().order('created_at');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch businesses: $e');
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
          .order('position', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch waiting queue: $e');
    }
  }

  // Stream waiting queue for real-time updates
  Stream<List<Map<String, dynamic>>> streamWaitingQueue(String businessId) {
    return client
        .from('queues')
        .stream(primaryKey: ['id'])
        .eq('business_id', businessId)
        .eq('status', 'waiting')
        .order('position', ascending: true)
        .map((data) => List<Map<String, dynamic>>.from(data));
  }

  // Get all queue entries (for statistics)
  Future<List<Map<String, dynamic>>> getAllQueueEntries(String businessId) async {
    try {
      final response = await client
          .from('queues')
          .select('*')
          .eq('business_id', businessId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch queue entries: $e');
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
      final allEntries = await getAllQueueEntries(businessId);

      final waiting = allEntries.where((e) => e['status'] == 'waiting').length;
      final serving = allEntries.where((e) => e['status'] == 'serving').length;
      final done = allEntries.where((e) => e['status'] == 'done').length;

      // Get business info
      final business = await client
          .from('businesses')
          .select('avg_service_time')
          .eq('id', businessId)
          .single();

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
      throw Exception('Failed to get statistics: $e');
    }
  }
}
