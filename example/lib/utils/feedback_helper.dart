import 'package:flutter/material.dart';

/// Utility class for showing user feedback messages
/// Follows the Strategy pattern for different types of user notifications
class FeedbackHelper {
  /// Show a success message
  static void showSuccess(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.green));
  }

  /// Show an error message
  static void showError(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  /// Show a warning message
  static void showWarning(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.orange));
  }

  /// Show a dialog with scheduled announcements
  static Future<void> showScheduledAnnouncementsDialog(BuildContext context, List<dynamic> announcements) async {
    if (!context.mounted) return;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Scheduled Announcements'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: announcements.isEmpty
              ? const Text('No announcements scheduled.')
              : ListView.builder(
                  itemCount: announcements.length,
                  itemBuilder: (context, index) {
                    final announcement = announcements[index];
                    return Card(
                      child: ListTile(
                        title: Text(announcement.content, maxLines: 2, overflow: TextOverflow.ellipsis),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('ID: ${announcement.id}'),
                            Text('Time: ${announcement.scheduledTime}'),
                            if (announcement.isRecurring) Text('Recurs: ${announcement.recurrence}'),
                          ],
                        ),
                        trailing: announcement.isActive ? const Icon(Icons.schedule, color: Colors.green) : const Icon(Icons.schedule_send, color: Colors.grey),
                      ),
                    );
                  },
                ),
        ),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))],
      ),
    );
  }
}
