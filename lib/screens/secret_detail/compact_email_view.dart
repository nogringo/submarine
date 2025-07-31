import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ndk/ndk.dart';

class CompactEmailView extends StatelessWidget {
  final Nip01Event email;
  final VoidCallback? onTap;

  const CompactEmailView({
    super.key,
    required this.email,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Parse email content
    final subject = _extractSubject(email.content);
    final preview = _extractPreview(email.content);
    final timestamp = _formatTimestamp(DateTime.fromMillisecondsSinceEpoch(email.createdAt * 1000));

    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar placeholder
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.mail_outline,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Email content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          subject,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        timestamp,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    preview,
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  String _extractSubject(String content) {
    // Try to extract subject from content
    // Assuming format: "Subject: xxx\n\nBody..."
    final lines = content.split('\n');
    for (final line in lines) {
      if (line.toLowerCase().startsWith('subject:')) {
        return line.substring(8).trim();
      }
    }
    // If no subject found, use first line or part of content
    return lines.isNotEmpty && lines.first.isNotEmpty 
        ? lines.first 
        : 'No subject';
  }

  String _extractPreview(String content) {
    // Remove subject line if present
    var preview = content;
    if (preview.toLowerCase().contains('subject:')) {
      final subjectEnd = preview.indexOf('\n');
      if (subjectEnd != -1) {
        preview = preview.substring(subjectEnd + 1).trim();
      }
    }
    
    // Clean up and limit preview
    preview = preview.replaceAll('\n', ' ').trim();
    return preview.isNotEmpty ? preview : 'No preview available';
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(timestamp);
    }
  }
}