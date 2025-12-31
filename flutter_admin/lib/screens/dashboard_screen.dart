import 'package:flutter/material.dart';
import '../services/admin_service.dart';
import '../config/theme.dart';
import '../widgets/stat_card.dart';
import '../widgets/queue_list_card.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _adminService = AdminService();
  String? _selectedBusinessId;
  Map<String, dynamic>? _selectedBusiness;
  bool _isCallingNext = false;
  bool _isRunningAI = false;
  Map<String, dynamic>? _statistics;
  String? _aiPredictorResult;

  @override
  void initState() {
    super.initState();
    _loadBusinesses();
  }

  Future<void> _loadBusinesses() async {
    try {
      final businesses = await _adminService.getAllBusinesses();
      if (businesses.isNotEmpty && mounted) {
        setState(() {
          _selectedBusiness = businesses[0];
          _selectedBusinessId = businesses[0]['id'];
        });
        _loadStatistics();
      }
    } catch (e) {
      _showError('Failed to load businesses: $e');
    }
  }

  Future<void> _loadStatistics() async {
    if (_selectedBusinessId == null) return;

    try {
      final stats = await _adminService.getQueueStatistics(_selectedBusinessId!);
      if (mounted) {
        setState(() {
          _statistics = stats;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {});
      }
      _showError('Failed to load statistics: $e');
    }
  }

  Future<void> _handleCallNext() async {
    if (_selectedBusinessId == null) return;

    setState(() {
      _isCallingNext = true;
    });

    try {
      final customer = await _adminService.callNext(_selectedBusinessId!);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Called: ${customer['customer_name']} (${customer['phone_number']})',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        _loadStatistics();
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() {
        _isCallingNext = false;
      });
    }
  }

  Future<void> _handleRunAIPredictor() async {
    if (_selectedBusinessId == null) return;

    setState(() {
      _isRunningAI = true;
      _aiPredictorResult = null;
    });

    try {
      final result = await _adminService.runAIPredictor(_selectedBusinessId!);
      
      if (mounted) {
        setState(() {
          _aiPredictorResult = 
              'AI Analysis Complete!\n\n'
              'Previous Avg: ${result['previous_avg_time']} min\n'
              'New Avg: ${result['new_avg_time']} min\n'
              'Difference: ${result['difference']} min\n'
              'Improvement: ${result['improvement_percentage']}%';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'AI Predictor updated avg service time to ${result['new_avg_time']} minutes',
            ),
            backgroundColor: AdminTheme.primaryViolet,
            duration: const Duration(seconds: 4),
          ),
        );
        
        _loadStatistics();
      }
    } catch (e) {
      _showError('AI Predictor failed: $e');
    } finally {
      setState(() {
        _isRunningAI = false;
      });
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.dashboard, color: AdminTheme.primaryViolet),
            const SizedBox(width: 12),
            const Text('SmartQueue Admin Dashboard'),
          ],
        ),
        actions: [
          if (_selectedBusiness != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Chip(
                avatar: Icon(
                  Icons.business,
                  size: 18,
                  color: AdminTheme.primaryViolet,
                ),
                label: Text(
                  _selectedBusiness!['name'],
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                backgroundColor: AdminTheme.paleViolet,
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStatistics,
            tooltip: 'Refresh Statistics',
          ),
        ],
      ),
      body: _selectedBusinessId == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Statistics Cards
                  if (_statistics != null) ...[
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            title: 'Waiting',
                            value: '${_statistics!['waiting']}',
                            icon: Icons.hourglass_empty,
                            color: AdminTheme.statusWaiting,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: StatCard(
                            title: 'Serving',
                            value: '${_statistics!['serving']}',
                            icon: Icons.person,
                            color: AdminTheme.statusServing,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: StatCard(
                            title: 'Completed',
                            value: '${_statistics!['completed']}',
                            icon: Icons.check_circle,
                            color: AdminTheme.statusDone,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: StatCard(
                            title: 'Avg Service Time',
                            value: '${_statistics!['avg_service_time']} min',
                            icon: Icons.access_time,
                            color: AdminTheme.primaryViolet,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Action Buttons Row
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isCallingNext ? null : _handleCallNext,
                          icon: _isCallingNext
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Icon(Icons.notifications_active),
                          label: Text(_isCallingNext ? 'Calling...' : 'Call Next Customer'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            backgroundColor: AdminTheme.primaryViolet,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isRunningAI ? null : _handleRunAIPredictor,
                          icon: _isRunningAI
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(AdminTheme.primaryViolet),
                                  ),
                                )
                              : const Icon(Icons.psychology),
                          label: Text(_isRunningAI ? 'Analyzing...' : 'Run AI Predictor'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // AI Predictor Result
                  if (_aiPredictorResult != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AdminTheme.paleViolet,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AdminTheme.primaryViolet),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lightbulb,
                            color: AdminTheme.primaryViolet,
                            size: 32,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              _aiPredictorResult!,
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              setState(() {
                                _aiPredictorResult = null;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Queue List
                  Text(
                    'Waiting Queue',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 16),
                  QueueListCard(businessId: _selectedBusinessId!),
                ],
              ),
            ),
    );
  }
}
