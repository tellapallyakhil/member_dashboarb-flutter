import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../theme/app_theme.dart';

class LinkHandler {
  /// Shows a bottom sheet with link options
  static void showLinkOptions(BuildContext context, String url) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _LinkOptionsSheet(url: url),
    );
  }

  /// Opens URL normally in external browser
  static Future<void> openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// Opens URL in Chrome incognito mode (Android) or shows alternative for web
  static Future<void> openInIncognito(BuildContext context, String url) async {
    if (kIsWeb) {
      // On web, we can't force incognito, but we open in new tab
      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Link opened! Use Ctrl+Shift+N for incognito',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.primaryColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } else {
      // On mobile, try to open in Chrome incognito
      final chromeIncognitoUrl = 'googlechrome://navigate?url=$url&incognito=true';
      final chromeUri = Uri.parse(chromeIncognitoUrl);
      
      try {
        final canLaunchChrome = await canLaunchUrl(chromeUri);
        if (canLaunchChrome) {
          await launchUrl(chromeUri);
        } else {
          // Fallback: Try Chrome with intent
          final intentUrl = 'intent://${url.replaceFirst(RegExp(r'https?://'), '')}#Intent;scheme=https;package=com.android.chrome;S.browser_fallback_url=$url;end';
          final intentUri = Uri.parse(intentUrl);
          
          if (await canLaunchUrl(intentUri)) {
            await launchUrl(intentUri);
          } else {
            // Final fallback: Open normally
            await openUrl(url);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Opened in browser (incognito not available)'),
                  backgroundColor: AppTheme.primaryColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            }
          }
        }
      } catch (e) {
        await openUrl(url);
      }
    }
  }

  /// Copy URL to clipboard
  static void copyUrl(BuildContext context, String url) {
    Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Link copied to clipboard'),
          ],
        ),
        backgroundColor: AppTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _LinkOptionsSheet extends StatelessWidget {
  final String url;

  const _LinkOptionsSheet({required this.url});

  String _getDisplayUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host + (uri.path.length > 30 ? '${uri.path.substring(0, 30)}...' : uri.path);
    } catch (e) {
      return url.length > 40 ? '${url.substring(0, 40)}...' : url;
    }
  }

  IconData _getFaviconIcon(String url) {
    final lowerUrl = url.toLowerCase();
    if (lowerUrl.contains('youtube') || lowerUrl.contains('youtu.be')) {
      return Icons.play_circle_fill;
    } else if (lowerUrl.contains('github')) {
      return Icons.code;
    } else if (lowerUrl.contains('twitter') || lowerUrl.contains('x.com')) {
      return Icons.chat_bubble;
    } else if (lowerUrl.contains('instagram')) {
      return Icons.camera_alt;
    } else if (lowerUrl.contains('linkedin')) {
      return Icons.business;
    } else if (lowerUrl.contains('facebook')) {
      return Icons.people;
    } else if (lowerUrl.contains('google')) {
      return Icons.search;
    } else if (lowerUrl.contains('stackoverflow')) {
      return Icons.question_answer;
    } else {
      return Icons.link;
    }
  }

  Color _getFaviconColor(String url) {
    final lowerUrl = url.toLowerCase();
    if (lowerUrl.contains('youtube')) return Colors.red;
    if (lowerUrl.contains('github')) return Colors.grey.shade800;
    if (lowerUrl.contains('twitter') || lowerUrl.contains('x.com')) return Colors.blue;
    if (lowerUrl.contains('instagram')) return Colors.purple;
    if (lowerUrl.contains('linkedin')) return Colors.blue.shade700;
    if (lowerUrl.contains('facebook')) return Colors.blue.shade600;
    if (lowerUrl.contains('google')) return Colors.blue;
    return AppTheme.accentColor;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.textSecondary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // URL Preview
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getFaviconColor(url).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getFaviconIcon(url),
                      color: _getFaviconColor(url),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Open Link',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _getDisplayUrl(url),
                          style: const TextStyle(
                            color: AppTheme.accentColor,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Options
          _OptionTile(
            icon: Icons.open_in_browser,
            iconColor: AppTheme.primaryColor,
            title: 'Open in Browser',
            subtitle: 'Open link in default browser',
            onTap: () {
              Navigator.pop(context);
              LinkHandler.openUrl(url);
            },
          ),
          
          _OptionTile(
            icon: Icons.security,
            iconColor: AppTheme.accentColor,
            title: 'Open in Incognito',
            subtitle: 'Private browsing mode',
            onTap: () {
              Navigator.pop(context);
              LinkHandler.openInIncognito(context, url);
            },
          ),
          
          _OptionTile(
            icon: Icons.copy,
            iconColor: AppTheme.secondaryColor,
            title: 'Copy Link',
            subtitle: 'Copy URL to clipboard',
            onTap: () {
              Navigator.pop(context);
              LinkHandler.copyUrl(context, url);
            },
          ),
          
          _OptionTile(
            icon: Icons.share,
            iconColor: Colors.green,
            title: 'Share Link',
            subtitle: 'Share with others',
            onTap: () {
              Navigator.pop(context);
              LinkHandler.copyUrl(context, url);
            },
          ),
          
          const SizedBox(height: 20),
          
          // Cancel Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ),
            ),
          ),
          
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 10,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppTheme.textSecondary,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom Linkify text widget with enhanced styling and tap handling
class EnhancedLinkifyText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final bool showOptions;

  const EnhancedLinkifyText({
    super.key,
    required this.text,
    this.style,
    this.showOptions = true,
  });

  @override
  Widget build(BuildContext context) {
    // Simple URL regex
    final urlRegex = RegExp(
      r'https?://[^\s<>\[\]{}|\\^`"]+',
      caseSensitive: false,
    );

    final matches = urlRegex.allMatches(text);
    if (matches.isEmpty) {
      return Text(text, style: style);
    }

    final spans = <InlineSpan>[];
    int lastEnd = 0;

    for (final match in matches) {
      // Add text before the URL
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: style,
        ));
      }

      // Add the URL as a tappable span
      final url = match.group(0)!;
      spans.add(WidgetSpan(
        alignment: PlaceholderAlignment.baseline,
        baseline: TextBaseline.alphabetic,
        child: GestureDetector(
          onTap: () {
            if (showOptions) {
              LinkHandler.showLinkOptions(context, url);
            } else {
              LinkHandler.openUrl(url);
            }
          },
          onLongPress: () => LinkHandler.showLinkOptions(context, url),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 250),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            margin: const EdgeInsets.symmetric(vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: AppTheme.accentColor.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.link,
                  size: 12,
                  color: AppTheme.accentColor,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    _shortenUrl(url),
                    style: TextStyle(
                      color: AppTheme.accentColor,
                      fontSize: (style?.fontSize ?? 14) - 2,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      decorationColor: AppTheme.accentColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ));

      lastEnd = match.end;
    }

    // Add remaining text
    if (lastEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastEnd),
        style: style,
      ));
    }

    return Text.rich(
      TextSpan(children: spans),
      style: style,
    );
  }

  String _shortenUrl(String url) {
    try {
      final uri = Uri.parse(url);
      String display = uri.host.replaceFirst('www.', '');
      if (uri.path.isNotEmpty && uri.path != '/') {
        final path = uri.path.length > 20 
          ? '${uri.path.substring(0, 20)}...' 
          : uri.path;
        display += path;
      }
      return display;
    } catch (e) {
      return url.length > 30 ? '${url.substring(0, 30)}...' : url;
    }
  }
}
