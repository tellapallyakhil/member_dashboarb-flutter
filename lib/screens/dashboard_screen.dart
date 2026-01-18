import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/firestore_service.dart';
import '../widgets/animated_widgets.dart';
import '../widgets/link_handler.dart';
import '../theme/app_theme.dart';
import 'upload_screen.dart';
import 'comment_sheet.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  final FirestoreService firestore = FirestoreService();
  late AnimationController _fabController;
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabController.forward();
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  void _openProfile(String email, {bool isCurrentUser = false}) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => ProfileScreen(
          userEmail: email,
          isCurrentUser: isCurrentUser,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Stack(
        children: [
          Container(
            decoration: AppTheme.gradientBackground,
          ),
          const Positioned.fill(child: FloatingParticles()),
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  floating: true,
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  expandedHeight: isSmallScreen ? 100 : 120,
                  automaticallyImplyLeading: false,
                  leading: Padding(
                    padding: const EdgeInsets.all(8),
                    child: GestureDetector(
                      onTap: () => _openProfile(user?.email ?? '', isCurrentUser: true),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.gradientStart, AppTheme.gradientEnd],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor.withValues(alpha: 0.3),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            user?.email?.isNotEmpty == true 
                              ? user!.email![0].toUpperCase()
                              : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  actions: [
                    // My Profile Button
                    IconButton(
                      icon: const Icon(Icons.person_outline_rounded, color: Colors.white),
                      onPressed: () => _openProfile(user?.email ?? '', isCurrentUser: true),
                      tooltip: 'My Profile',
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    title: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [AppTheme.gradientStart, AppTheme.gradientEnd],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [AppTheme.gradientStart, AppTheme.gradientEnd],
                          ).createShader(bounds),
                          child: Text(
                            'Dashboard',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 18 : 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.backgroundColor,
                            AppTheme.surfaceColor.withValues(alpha: 0.5),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: firestore.getPosts(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SliverFillRemaining(
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      );
                    }
                    
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return SliverFillRemaining(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(30),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppTheme.primaryColor.withValues(alpha: 0.2),
                                        AppTheme.secondaryColor.withValues(alpha: 0.2),
                                      ],
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.post_add_rounded,
                                    size: 60,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                const Text(
                                  'No posts yet',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Tap the + button to create your first post',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    return SliverPadding(
                      padding: EdgeInsets.only(
                        top: 16, 
                        bottom: 100,
                        left: isSmallScreen ? 4 : 16,
                        right: isSmallScreen ? 4 : 16,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final doc = snapshot.data!.docs[index];
                            return _PostCard(
                              doc: doc,
                              currentUserEmail: user?.email ?? '',
                              onCopy: () => _copyToClipboard(doc['text']),
                              onComment: () => _showComments(doc.id),
                              onProfileTap: () => _openProfile(doc['email']),
                              firestoreService: firestore,
                              isSmallScreen: isSmallScreen,
                            );
                          },
                          childCount: snapshot.data!.docs.length,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: _fabController, curve: Curves.elasticOut),
        ),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => const UploadScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
              ),
            );
          },
          icon: const Icon(Icons.add_rounded),
          label: Text(isSmallScreen ? 'Post' : 'New Post'),
          backgroundColor: AppTheme.primaryColor,
        ),
      ),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Copied to clipboard'),
        backgroundColor: AppTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
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

class _PostCard extends StatefulWidget {
  final QueryDocumentSnapshot doc;
  final String currentUserEmail;
  final VoidCallback onCopy;
  final VoidCallback onComment;
  final VoidCallback onProfileTap;
  final FirestoreService firestoreService;
  final bool isSmallScreen;

  const _PostCard({
    required this.doc,
    required this.currentUserEmail,
    required this.onCopy,
    required this.onComment,
    required this.onProfileTap,
    required this.firestoreService,
    required this.isSmallScreen,
  });

  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard> {
  int _userRating = 0;
  double _averageRating = 0;
  int _totalRatings = 0;
  int _commentCount = 0;
  bool _isBookmarked = false;
  bool _isLoadingRating = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadRating(),
      _loadCommentCount(),
      _loadBookmark(),
    ]);
  }

  Future<void> _loadRating() async {
    try {
      final userRatingDoc = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.doc.id)
          .collection('ratings')
          .doc(widget.currentUserEmail)
          .get();
      
      if (userRatingDoc.exists) {
        _userRating = userRatingDoc.data()?['rating'] ?? 0;
      }

      final ratingsSnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.doc.id)
          .collection('ratings')
          .get();
      
      if (ratingsSnapshot.docs.isNotEmpty) {
        int total = 0;
        for (var doc in ratingsSnapshot.docs) {
          total += (doc.data()['rating'] as int?) ?? 0;
        }
        _averageRating = total / ratingsSnapshot.docs.length;
        _totalRatings = ratingsSnapshot.docs.length;
      }
    } catch (e) {
      // Handle silently
    }

    if (mounted) setState(() => _isLoadingRating = false);
  }

  Future<void> _loadCommentCount() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.doc.id)
          .collection('comments')
          .get();
      
      if (mounted) setState(() => _commentCount = snapshot.docs.length);
    } catch (e) {
      // Handle silently
    }
  }

  Future<void> _loadBookmark() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentUserEmail)
          .collection('bookmarks')
          .doc(widget.doc.id)
          .get();
      
      if (mounted) setState(() => _isBookmarked = doc.exists);
    } catch (e) {
      // Handle silently
    }
  }

  Future<void> _toggleBookmark() async {
    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.currentUserEmail)
        .collection('bookmarks')
        .doc(widget.doc.id);

    if (_isBookmarked) {
      await ref.delete();
    } else {
      await ref.set({
        'postId': widget.doc.id,
        'savedAt': FieldValue.serverTimestamp(),
      });
    }

    setState(() => _isBookmarked = !_isBookmarked);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isBookmarked ? 'Bookmarked!' : 'Removed from bookmarks'),
          backgroundColor: AppTheme.primaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _submitRating(int rating) async {
    setState(() => _userRating = rating);

    try {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.doc.id)
          .collection('ratings')
          .doc(widget.currentUserEmail)
          .set({
        'rating': rating,
        'ratedAt': FieldValue.serverTimestamp(),
        'email': widget.currentUserEmail,
      });

      await _loadRating();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Rated $rating star${rating > 1 ? 's' : ''}!'),
            backgroundColor: AppTheme.primaryColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOwner = widget.doc['email'] == widget.currentUserEmail;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: widget.isSmallScreen ? 8 : 16, 
        vertical: 8,
      ),
      child: GlassCard(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.all(widget.isSmallScreen ? 14 : 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info Row - Tappable for profile
            GestureDetector(
              onTap: widget.onProfileTap,
              child: Row(
                children: [
                  Container(
                    width: widget.isSmallScreen ? 36 : 42,
                    height: widget.isSmallScreen ? 36 : 42,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.gradientStart, AppTheme.gradientEnd],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withValues(alpha: 0.3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        widget.doc['email'].toString().isNotEmpty 
                          ? widget.doc['email'].toString()[0].toUpperCase()
                          : '?',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: widget.isSmallScreen ? 14 : 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                widget.doc['email'].toString().split('@')[0],
                                style: TextStyle(
                                  fontSize: widget.isSmallScreen ? 14 : 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isOwner) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [AppTheme.gradientStart, AppTheme.gradientEnd],
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'You',
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
                        const SizedBox(height: 2),
                        Text(
                          'Tap to view profile',
                          style: TextStyle(
                            fontSize: widget.isSmallScreen ? 10 : 11,
                            color: AppTheme.accentColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Action buttons
                  IconButton(
                    icon: Icon(
                      _isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded, 
                      size: widget.isSmallScreen ? 20 : 22,
                    ),
                    color: _isBookmarked ? AppTheme.accentColor : AppTheme.textSecondary,
                    onPressed: _toggleBookmark,
                    tooltip: 'Bookmark',
                  ),
                  IconButton(
                    icon: Icon(Icons.copy_rounded, size: widget.isSmallScreen ? 18 : 20),
                    color: AppTheme.textSecondary,
                    onPressed: widget.onCopy,
                    tooltip: 'Copy',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            
            // Post Content - Enhanced with link options
            GestureDetector(
              onLongPress: widget.onCopy,
              child: EnhancedLinkifyText(
                text: widget.doc['text'],
                style: TextStyle(
                  fontSize: widget.isSmallScreen ? 14 : 15,
                  color: AppTheme.textPrimary,
                  height: 1.5,
                ),
                showOptions: true,
              ),
            ),
            const SizedBox(height: 14),
            
            // Star Rating Section
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Column(
                children: [
                  // Average Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isLoadingRating)
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accentColor),
                        )
                      else ...[
                        Icon(
                          Icons.star_rounded,
                          color: _averageRating > 0 ? Colors.amber : AppTheme.textSecondary,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _averageRating > 0 ? _averageRating.toStringAsFixed(1) : '-',
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          ' ($_totalRatings)',
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Star Input
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starNumber = index + 1;
                      return GestureDetector(
                        onTap: () => _submitRating(starNumber),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: widget.isSmallScreen ? 3 : 5),
                          child: Icon(
                            _userRating >= starNumber ? Icons.star_rounded : Icons.star_border_rounded,
                            color: _userRating >= starNumber ? Colors.amber : AppTheme.textSecondary,
                            size: widget.isSmallScreen ? 26 : 30,
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            
            // Actions Row
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: Icons.comment_rounded,
                    label: 'Comments${_commentCount > 0 ? ' ($_commentCount)' : ''}',
                    onTap: widget.onComment,
                    isSmallScreen: widget.isSmallScreen,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.share_rounded,
                    label: 'Share',
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: widget.doc['text']));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Text copied for sharing!'),
                          backgroundColor: AppTheme.primaryColor,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    },
                    isSmallScreen: widget.isSmallScreen,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isSmallScreen;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withValues(alpha: 0.15),
            AppTheme.secondaryColor.withValues(alpha: 0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 8 : 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: isSmallScreen ? 14 : 16, color: AppTheme.textPrimary),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: isSmallScreen ? 11 : 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
