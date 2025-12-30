import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/admin_service.dart';
import '../config/theme.dart';

class QueueListCard extends StatelessWidget {
  final String businessId;

  const QueueListCard({
    super.key,
    required this.businessId,
  });

  String _formatTime(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else {
        return DateFormat('MMM d, h:mm a').format(dateTime);
      }
    } catch (e) {
      return timestamp;
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminService = AdminService();

    return Card(
      child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: adminService.streamWaitingQueue(businessId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.all(40),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(40),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red.shade600,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading queue',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          final queue = snapshot.data ?? [];

          if (queue.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(40),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 64,
                      color: AdminTheme.textLight,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No customers in queue',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AdminTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Customers will appear here when they join',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AdminTheme.borderColor),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      '${queue.length} ${queue.length == 1 ? 'Customer' : 'Customers'} Waiting',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AdminTheme.statusWaiting.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.circle,
                            size: 8,
                            color: AdminTheme.statusWaiting,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Live Updates',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AdminTheme.statusWaiting,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Queue List
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: queue.length,
                itemBuilder: (context, index) {
                  final customer = queue[index];
                  final isFirst = index == 0;

                  return Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: AdminTheme.borderColor,
                          width: index == queue.length - 1 ? 0 : 1,
                        ),
                      ),
                      color: isFirst
                          ? AdminTheme.primaryViolet.withOpacity(0.05)
                          : null,
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isFirst
                              ? AdminTheme.primaryViolet
                              : AdminTheme.lightViolet.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '${customer['position']}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isFirst
                                  ? Colors.white
                                  : AdminTheme.primaryViolet,
                            ),
                          ),
                        ),
                      ),
                      title: Row(
                        children: [
                          Text(
                            customer['customer_name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          if (isFirst) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AdminTheme.primaryViolet,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'NEXT',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.phone,
                              size: 14,
                              color: AdminTheme.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              customer['phone_number'],
                              style: TextStyle(
                                color: AdminTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: AdminTheme.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatTime(customer['created_at']),
                              style: TextStyle(
                                color: AdminTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      trailing: isFirst
                          ? Icon(
                              Icons.arrow_forward,
                              color: AdminTheme.primaryViolet,
                            )
                          : null,
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
