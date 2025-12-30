import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

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

  // Join queue
  Future<Map<String, dynamic>> joinQueue({
    required String businessId,
    required String customerName,
    required String phoneNumber,
  }) async {
    try {
      final response = await client.from('queues').insert({
        'business_id': businessId,
        'customer_name': customerName,
        'phone_number': phoneNumber,
        'status': 'waiting',
      }).select('''
        *,
        businesses (
          name,
          avg_service_time
        )
      ''').single();

      // Get current position
      final positionResponse = await client
          .from('queues')
          .select('id')
          .eq('business_id', businessId)
          .eq('status', 'waiting')
          .order('created_at', ascending: true);

      final position = positionResponse.indexWhere((q) => q['id'] == response['id']) + 1;

      // Update position
      await client.from('queues').update({'position': position}).eq('id', response['id']);

      final business = response['businesses'] as Map<String, dynamic>;
      final avgServiceTime = business['avg_service_time'] as int;
      final waitTime = (position - 1) * avgServiceTime;

      return {
        'queue_id': response['id'],
        'customer_name': response['customer_name'],
        'phone_number': response['phone_number'],
        'position': position,
        'status': response['status'],
        'business_name': business['name'],
        'estimated_wait_time': waitTime,
        'created_at': response['created_at'],
      };
    } catch (e) {
      throw Exception('Failed to join queue: $e');
    }
  }

  // Get queue status (one-time fetch)
  Future<Map<String, dynamic>> getQueueStatus(String queueId) async {
    try {
      final response = await client
          .from('queues')
          .select('''
            *,
            businesses (
              name,
              avg_service_time
            )
          ''')
          .eq('id', queueId)
          .single();

      final business = response['businesses'] as Map<String, dynamic>;
      final position = response['position'] as int;
      final avgServiceTime = business['avg_service_time'] as int;
      final waitTime = (position - 1) * avgServiceTime;

      return {
        'queue_id': response['id'],
        'customer_name': response['customer_name'],
        'phone_number': response['phone_number'],
        'position': position,
        'status': response['status'],
        'business_name': business['name'],
        'estimated_wait_time': waitTime,
        'created_at': response['created_at'],
      };
    } catch (e) {
      throw Exception('Failed to get queue status: $e');
    }
  }

  // Stream queue status (real-time updates)
  Stream<Map<String, dynamic>> streamQueueStatus(String queueId) {
    return client
        .from('queues')
        .stream(primaryKey: ['id'])
        .eq('id', queueId)
        .asyncMap((data) async {
          if (data.isEmpty) {
            throw Exception('Queue entry not found');
          }

          final queueData = data.first;
          
          // Fetch business details
          final businessResponse = await client
              .from('businesses')
              .select('name, avg_service_time')
              .eq('id', queueData['business_id'])
              .single();

          final position = queueData['position'] as int;
          final avgServiceTime = businessResponse['avg_service_time'] as int;
          final waitTime = (position - 1) * avgServiceTime;

          return {
            'queue_id': queueData['id'],
            'customer_name': queueData['customer_name'],
            'phone_number': queueData['phone_number'],
            'position': position,
            'status': queueData['status'],
            'business_name': businessResponse['name'],
            'estimated_wait_time': waitTime,
            'created_at': queueData['created_at'],
          };
        });
  }

  // Get business by ID
  Future<Map<String, dynamic>> getBusiness(String businessId) async {
    try {
      final response = await client
          .from('businesses')
          .select()
          .eq('id', businessId)
          .single();

      return response;
    } catch (e) {
      throw Exception('Failed to get business: $e');
    }
  }

  // Get all businesses (for QR code generation later)
  Future<List<Map<String, dynamic>>> getAllBusinesses() async {
    try {
      final response = await client.from('businesses').select();
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to get businesses: $e');
    }
  }
}
