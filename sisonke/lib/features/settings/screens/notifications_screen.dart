import 'package:flutter/material.dart';
import 'package:sisonke/core/services/api_service.dart';
import 'package:sisonke/shared/widgets/index.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _api = ApiService();
  late Future<List<Map<String, dynamic>>> _future = _api.getNotifications();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SisonkeAppBar(title: 'Notifications'),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 48, color: Colors.redAccent),
                    const SizedBox(height: 16),
                    const Text(
                      'Failed to load notifications',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => setState(() => _future = _api.getNotifications()),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final list = snapshot.data!;
          if (list.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications_none_rounded, size: 64, color: Colors.grey.withOpacity(0.5)),
                    const SizedBox(height: 16),
                    const Text(
                      'All quiet here',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'You do not have any notifications right now.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _future = _api.getNotifications();
              });
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = list[index];
                final isRead = item['readAt'] != null;
                return Card(
                  elevation: isRead ? 0 : 2,
                  color: isRead ? Colors.white.withOpacity(0.7) : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: isRead ? BorderSide(color: Colors.grey.withOpacity(0.1)) : BorderSide.none,
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: isRead ? Colors.grey.shade100 : const Color(0xFF2E6F60).withOpacity(0.1),
                      child: Icon(
                        Icons.notifications_rounded,
                        color: isRead ? Colors.grey : const Color(0xFF2E6F60),
                      ),
                    ),
                    title: Text(
                      '${item['title']}',
                      style: TextStyle(
                        fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                        color: isRead ? Colors.grey.shade800 : Colors.black,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          '${item['body']}',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        if (item['createdAt'] != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            _formatTimestamp(item['createdAt']),
                            style: TextStyle(fontSize: 10, color: Colors.grey.shade400, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ],
                    ),
                    onTap: isRead
                        ? null
                        : () async {
                            try {
                              await _api.markNotificationRead(item['id']);
                              setState(() {
                                _future = _api.getNotifications();
                              });
                            } catch (_) {}
                          },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _formatTimestamp(dynamic val) {
    if (val == null) return '';
    try {
      final dt = DateTime.parse('$val').toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 60) {
        return '${diff.inMinutes}m ago';
      } else if (diff.inHours < 24) {
        return '${diff.inHours}h ago';
      } else {
        return '${dt.day}/${dt.month}/${dt.year}';
      }
    } catch (_) {
      return '';
    }
  }
}
