import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

import '../widgets/animated_widgets.dart';
import '../widgets/link_handler.dart';
import '../theme/app_theme.dart';
import 'comment_sheet.dart';

class ProfileScreen extends StatefulWidget {
  final String userEmail;
  final bool isCurrentUser;

  const ProfileScreen({
    super.key,
    required this.userEmail,
    this.isCurrentUser = false,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _totalPosts = 0;
  int _totalRatingsReceived = 0;
  double _averageRating = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      // Get user's posts
      final postsSnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .where('email', isEqualTo: widget.userEmail)
          .get();

      int totalRatings = 0;
      double sumRatings = 0;

      for (var post in postsSnapshot.docs) {
        final ratingsSnapshot = await FirebaseFirestore.instance
            .collection('posts')
            .doc(post.id)
            .collection('ratings')
            .get();
        
        for (var rating in ratingsSnapshot.docs) {
          totalRatings++;
          sumRatings += (rating.data()['rating'] as int?) ?? 0;
        }
      }

      if (mounted) {
        setState(() {
          _totalPosts = postsSnapshot.docs.length;
          _totalRatingsReceived = totalRatings;
          _averageRating = totalRatings > 0 ? sumRatings / totalRatings : 0;
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout', style: TextStyle(color: AppTheme.textPrimary)),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.secondaryColor,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  }

  Future<void> _deletePost(String postId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Post', style: TextStyle(color: AppTheme.textPrimary)),
        content: const Text(
          'Are you sure you want to delete this post? This action cannot be undone.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance.collection('posts').doc(postId).delete();
      _loadStats();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Post deleted'),
            backgroundColor: AppTheme.primaryColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Stack(
        children: [
          Container(decoration: AppTheme.gradientBackground),
          const Positioned.fill(child: FloatingParticles()),
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // App Bar
                SliverAppBar(
                  floating: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  actions: widget.isCurrentUser
                      ? [
                          IconButton(
                            icon: const Icon(Icons.logout_rounded, color: AppTheme.secondaryColor),
                            onPressed: _handleLogout,
                            tooltip: 'Logout',
                          ),
                        ]
                      : null,
                ),

                // Profile Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 24),
                    child: Column(
                      children: [
                        // Avatar
                        Container(
                          width: isSmallScreen ? 100 : 120,
                          height: isSmallScreen ? 100 : 120,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppTheme.gradientStart, AppTheme.gradientEnd],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryColor.withValues(alpha: 0.4),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              widget.userEmail.isNotEmpty 
                                ? widget.userEmail[0].toUpperCase()
                                : '?',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: isSmallScreen ? 40 : 50,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Username
                        Text(
                          widget.userEmail.split('@')[0],
                          style: TextStyle(
                            fontSize: isSmallScreen ? 24 : 28,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.userEmail,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Stats Row - Responsive
                        Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                icon: Icons.article_rounded,
                                value: _totalPosts.toString(),
                                label: 'Posts',
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _StatCard(
                                icon: Icons.star_rounded,
                                value: _averageRating.toStringAsFixed(1),
                                label: 'Rating',
                                color: Colors.amber,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _StatCard(
                                icon: Icons.reviews_rounded,
                                value: _totalRatingsReceived.toString(),
                                label: 'Reviews',
                                color: AppTheme.accentColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Section Title
                        Align(
                          alignment: Alignment.centerLeft,
                          child: ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [AppTheme.gradientStart, AppTheme.gradientEnd],
                            ).createShader(bounds),
                            child: Text(
                              widget.isCurrentUser ? 'My Posts' : 'Posts',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

                // Posts List
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('posts')
                      .where('email', isEqualTo: widget.userEmail)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SliverFillRemaining(
                        child: Center(
                          child: CircularProgressIndicator(color: AppTheme.primaryColor),
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.post_add_rounded,
                                size: 60,
                                color: AppTheme.textSecondary.withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                widget.isCurrentUser ? 'You haven\'t posted yet' : 'No posts yet',
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 8 : 16,
                        vertical: 8,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final doc = snapshot.data!.docs[index];
                            return _ProfilePostCard(
                              doc: doc,
                              isOwner: widget.isCurrentUser,
                              onDelete: () => _deletePost(doc.id),
                              onComment: () => _showComments(doc.id),
                              isSmallScreen: isSmallScreen,
                            );
                          },
                          childCount: snapshot.data!.docs.length,
                        ),
                      ),
                    );
                  },
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showComments(String postId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommentSheet(postId: postId),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardColor.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppTheme.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ProfilePostCard extends StatelessWidget {
  final QueryDocumentSnapshot doc;
  final bool isOwner;
  final VoidCallback onDelete;
  final VoidCallback onComment;
  final bool isSmallScreen;

  const _ProfilePostCard({
    required this.doc,
    required this.isOwner,
    required this.onDelete,
    required this.onComment,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: GlassCard(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.all(isSmallScreen ? 14 : 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post text
            GestureDetector(
              onLongPress: () {
                Clipboard.setData(ClipboardData(text: doc['text']));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Copied to clipboard'),
                    backgroundColor: AppTheme.primaryColor,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
              child: EnhancedLinkifyText(
                text: doc['text'],
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 15,
                  color: AppTheme.textPrimary,
                  height: 1.5,
                ),
                showOptions: true,
              ),
            ),
            const SizedBox(height: 12),

            // Action Row
            Row(
              children: [
                // Comments Button
                Expanded(
                  child: InkWell(
                    onTap: onComment,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.comment_rounded, size: 16, color: AppTheme.textSecondary),
                          const SizedBox(width: 6),
                          Text(
                            'Comments',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: isSmallScreen ? 12 : 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (isOwner) ...[
                  Container(
                    width: 1,
                    height: 20,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                  // Delete Button
                  Expanded(
                    child: InkWell(
                      onTap: onDelete,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.delete_outline_rounded, size: 16, color: Colors.red.shade400),
                            const SizedBox(width: 6),
                            Text(
                              'Delete',
                              style: TextStyle(
                                color: Colors.red.shade400,
                                fontSize: isSmallScreen ? 12 : 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
