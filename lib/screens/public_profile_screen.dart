import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants.dart';

class PublicProfileScreen extends StatefulWidget {
  final String tag;
  const PublicProfileScreen({super.key, required this.tag});

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  final _db = FirebaseFirestore.instance;
  Map<String, dynamic>? _profile;
  String _profileUserId = '';
  bool _loading = true;
  bool _notFound = false;
  int _views = 0;
  int _likes = 0;
  bool _liked = false;
  String _friendStatus = 'none';
  User? get _currentUser => FirebaseAuth.instance.currentUser;
  final _commentController = TextEditingController();
  bool _submitting = false;
  final Set<String> _expanded = {};

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    final isTag = RegExp(r'^\d+$').hasMatch(widget.tag);
    final q = isTag
        ? _db.collection('users').where('tag', isEqualTo: int.parse(widget.tag))
        : _db.collection('users').where('username', isEqualTo: widget.tag);
    final snapshot = await q.get();

    if (snapshot.docs.isEmpty) {
      setState(() { _notFound = true; _loading = false; });
      return;
    }

    final doc = snapshot.docs[0];
    final data = doc.data();
    _profileUserId = doc.id;

    if (_currentUser != null) {
      final likedBy = List<String>.from(data['likedBy'] ?? []);
      _liked = likedBy.contains(_currentUser!.uid);

      final mySnap = await _db.collection('users').doc(_currentUser!.uid).get();
      if (mySnap.exists) {
        final myData = mySnap.data()!;
        final friends = List<String>.from(myData['friends'] ?? []);
        final sent = List<String>.from(myData['sentRequests'] ?? []);
        if (friends.contains(_profileUserId)) {
          _friendStatus = 'friend';
        } else if (sent.contains(_profileUserId)) {
          _friendStatus = 'pending';
        }
      }
    }

    // 조회수 증가 (본인 프로필 열람은 제외)
    final isOwner = _currentUser != null && _currentUser!.uid == _profileUserId;
    int views = data['views'] ?? 0;
    if (!isOwner) {
      await _db.collection('users').doc(_profileUserId).update({'views': FieldValue.increment(1)});
      views += 1;
    }

    setState(() {
      _profile = data;
      _views = views;
      _likes = data['likes'] ?? 0;
      _loading = false;
    });
  }

  Future<void> _handleLike() async {
    if (_currentUser == null || _profileUserId.isEmpty) return;
    final targetRef = _db.collection('users').doc(_profileUserId);
    final myRef = _db.collection('users').doc(_currentUser!.uid);

    if (_liked) {
      await targetRef.update({'likes': FieldValue.increment(-1), 'likedBy': FieldValue.arrayRemove([_currentUser!.uid])});
      await myRef.update({'likedProfiles': FieldValue.arrayRemove([_profileUserId])});
      setState(() { _likes--; _liked = false; });
    } else {
      await targetRef.update({'likes': FieldValue.increment(1), 'likedBy': FieldValue.arrayUnion([_currentUser!.uid])});
      await myRef.update({'likedProfiles': FieldValue.arrayUnion([_profileUserId])});
      setState(() { _likes++; _liked = true; });
    }
  }

  Future<void> _handleFriend() async {
    if (_currentUser == null || _profileUserId.isEmpty || _currentUser!.uid == _profileUserId) return;
    final myRef = _db.collection('users').doc(_currentUser!.uid);
    final targetRef = _db.collection('users').doc(_profileUserId);

    if (_friendStatus == 'friend') {
      await myRef.update({'friends': FieldValue.arrayRemove([_profileUserId])});
      await targetRef.update({'friends': FieldValue.arrayRemove([_currentUser!.uid])});
      setState(() => _friendStatus = 'none');
    } else if (_friendStatus == 'pending') {
      await myRef.update({'sentRequests': FieldValue.arrayRemove([_profileUserId])});
      await targetRef.update({'friendRequests': FieldValue.arrayRemove([_currentUser!.uid])});
      setState(() => _friendStatus = 'none');
    } else {
      await myRef.update({'sentRequests': FieldValue.arrayUnion([_profileUserId])});
      await targetRef.update({'friendRequests': FieldValue.arrayUnion([_currentUser!.uid])});
      setState(() => _friendStatus = 'pending');
    }
  }

  void _confirmDeleteComment(String commentId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('댓글 삭제'),
        content: const Text('이 댓글을 삭제할까요?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _db.collection('users').doc(_profileUserId).collection('comments').doc(commentId).delete();
            },
            child: Text('삭제', style: TextStyle(color: AppColors.pastelPink)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleComment() async {
    if (_currentUser == null || _profileUserId.isEmpty || _commentController.text.trim().isEmpty) return;
    setState(() => _submitting = true);
    try {
      final authorSnap = await _db.collection('users').doc(_currentUser!.uid).get();
      final authorData = authorSnap.data() ?? {};
      await _db.collection('users').doc(_profileUserId).collection('comments').add({
        'text': _commentController.text.trim(),
        'authorName': authorData['displayName'] ?? _currentUser!.displayName ?? '익명',
        'authorUsername': authorData['username'] ?? '',
        'authorTag': authorData['tag'] ?? 0,
        'authorPhoto': authorData['photoURL'] ?? _currentUser!.photoURL ?? '',
        'authorUid': _currentUser!.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
      _commentController.clear();
    } catch (e) {
      debugPrint('댓글 등록 실패: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('댓글 등록에 실패했어요. 다시 시도해주세요.')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  List<CategoryInfo> get _activeCategories {
    if (_profile == null) return [];
    final defaults = allCategories.where((cat) {
      final data = _profile![cat.key];
      return data != null && data is Map && (data['items'] as List?)?.isNotEmpty == true;
    }).toList();
    final customKeys = _profile!.keys.where((k) => k.startsWith('custom_') && _profile![k] is Map && (_profile![k]['items'] as List?)?.isNotEmpty == true).toList();
    final customs = customKeys.map((k) => CategoryInfo(k, '✨', k.replaceFirst('custom_', ''))).toList();

    final order = List<String>.from(_profile!['categoryOrder'] ?? []);
    final all = [...defaults, ...customs];
    if (order.isEmpty) return all;
    return [...all]..sort((a, b) {
      final ai = order.indexOf(a.key);
      final bi = order.indexOf(b.key);
      if (ai == -1 && bi == -1) return 0;
      if (ai == -1) return 1;
      if (bi == -1) return -1;
      return ai.compareTo(bi);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.pastelPurple)));
    }
    if (_notFound) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('😢', style: TextStyle(fontSize: 60)),
              const SizedBox(height: 16),
              const Text('프로필을 찾을 수 없어요', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );
    }

    final p = _profile!;
    final photoURL = p['photoURL'] as String? ?? '';
    final username = p['username'] as String? ?? '';
    final displayName = p['displayName'] as String? ?? '';
    final tag = p['tag'];
    final bio = p['bio'] as String? ?? '';
    final infoFields = (p['infoFields'] as List<dynamic>?) ?? [];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                children: [
                  // 뒤로가기
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.arrow_back, color: AppColors.muted),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 프로필 카드
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.pastelPink.withValues(alpha: 0.3)),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            photoURL.isNotEmpty
                                ? CircleAvatar(radius: 32, backgroundImage: NetworkImage(photoURL))
                                : Container(
                                    width: 64, height: 64,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(colors: [AppColors.pastelPink, AppColors.pastelPurple]),
                                    ),
                                  ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    text: TextSpan(children: [
                                      TextSpan(text: username, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.foreground)),
                                      if (tag != null) TextSpan(text: ' #$tag', style: TextStyle(fontSize: 14, color: AppColors.pastelPurple)),
                                    ]),
                                  ),
                                  Text(displayName, style: TextStyle(fontSize: 14, color: AppColors.muted)),
                                  const SizedBox(height: 4),
                                  Wrap(
                                    spacing: 8,
                                    children: [
                                      _statChip('조회수 $_views'),
                                      GestureDetector(
                                        onTap: _handleLike,
                                        child: _statChip('${_liked ? "❤️" : "🤍"} $_likes', highlight: _liked),
                                      ),
                                      if (_currentUser != null && _currentUser!.uid != _profileUserId && _friendStatus != 'friend')
                                        GestureDetector(
                                          onTap: _handleFriend,
                                          child: _statChip(
                                            _friendStatus == 'pending' ? '요청됨' : '친구 추가',
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // 자기소개
                        if (bio.isNotEmpty || infoFields.isNotEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.pastelPurple.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.pastelPurple.withValues(alpha: 0.2)),
                            ),
                            child: Column(
                              children: [
                                if (bio.isNotEmpty)
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: AppColors.card.withValues(alpha: 0.6),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: AppColors.pastelPurple.withValues(alpha: 0.15)),
                                    ),
                                    child: Column(
                                      children: [
                                        Text('한줄 소개', style: TextStyle(fontSize: 10, color: AppColors.muted)),
                                        const SizedBox(height: 2),
                                        Text(bio, style: TextStyle(fontSize: 14, color: AppColors.foreground.withValues(alpha: 0.7)), textAlign: TextAlign.center),
                                      ],
                                    ),
                                  ),
                                if (infoFields.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  GridView.count(
                                    crossAxisCount: 2,
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    crossAxisSpacing: 8, mainAxisSpacing: 8,
                                    childAspectRatio: 2.5,
                                    children: infoFields.map((f) => Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: AppColors.card.withValues(alpha: 0.6),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: AppColors.pastelPurple.withValues(alpha: 0.15)),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(f['label'] ?? '', style: TextStyle(fontSize: 10, color: AppColors.muted)),
                                          Text(f['value'] ?? '', style: TextStyle(fontSize: 14, color: AppColors.foreground.withValues(alpha: 0.7))),
                                        ],
                                      ),
                                    )).toList(),
                                  ),
                                ],
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 카테고리
                  ..._activeCategories.asMap().entries.map((entry) {
                    final i = entry.key;
                    final cat = entry.value;
                    final colorIndex = i % rowColors.length;
                    final items = _getItems(cat.key);
                    final expanded = _expanded.contains(cat.key);
                    final color = rowColors[colorIndex].color;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: color.withValues(alpha: 0.4)),
                        ),
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () => setState(() {
                                if (expanded) {
                                  _expanded.remove(cat.key);
                                } else {
                                  _expanded.add(cat.key);
                                }
                              }),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                child: Row(
                                  children: [
                                    Text('${cat.emoji} ${cat.label}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                    const SizedBox(width: 8),
                                    Text('${items.length}', style: TextStyle(fontSize: 12, color: AppColors.muted)),
                                    const Spacer(),
                                    Icon(expanded ? Icons.expand_less : Icons.expand_more, size: 20, color: AppColors.muted),
                                  ],
                                ),
                              ),
                            ),
                            if (expanded)
                              ...items.map((item) => Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.card.withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(item['text'] ?? '', style: const TextStyle(fontSize: 13)),
                                ),
                              )),
                            if (expanded) const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 16),

                  // 댓글
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.pastelPurple.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('💬 댓글', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 12),
                        StreamBuilder<QuerySnapshot>(
                          stream: _profileUserId.isNotEmpty
                              ? _db.collection('users').doc(_profileUserId).collection('comments').orderBy('createdAt').snapshots()
                              : null,
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) return const SizedBox.shrink();
                            final docs = snapshot.data!.docs;
                            if (docs.isEmpty) return Text('아직 댓글이 없어요', style: TextStyle(fontSize: 13, color: AppColors.muted));
                            return Column(
                              children: docs.map((d) {
                                final data = d.data() as Map<String, dynamic>;
                                final ts = data['createdAt'] as Timestamp?;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        radius: 14,
                                        backgroundImage: (data['authorPhoto'] ?? '').isNotEmpty ? NetworkImage(data['authorPhoto']) : null,
                                        backgroundColor: AppColors.pastelPurple.withValues(alpha: 0.3),
                                        child: (data['authorPhoto'] ?? '').isEmpty ? const Icon(Icons.person, size: 14) : null,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(data['authorName'] ?? '', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                                                const SizedBox(width: 4),
                                                Text('#${data['authorTag'] ?? ''}', style: TextStyle(fontSize: 10, color: AppColors.muted)),
                                                const Spacer(),
                                                if (ts != null) Text('${ts.toDate().month}월 ${ts.toDate().day}일', style: TextStyle(fontSize: 10, color: AppColors.muted)),
                                              ],
                                            ),
                                            Text(data['text'] ?? '', style: TextStyle(fontSize: 13, color: AppColors.foreground.withValues(alpha: 0.8))),
                                          ],
                                        ),
                                      ),
                                      if (_currentUser != null && (data['authorUid'] == _currentUser!.uid || _currentUser!.uid == _profileUserId))
                                        GestureDetector(
                                          onTap: () => _confirmDeleteComment(d.id),
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 8),
                                            child: Text('삭제', style: TextStyle(fontSize: 10, color: AppColors.muted)),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                        if (_currentUser != null) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _commentController,
                                  maxLength: 300,
                                  buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                                  decoration: InputDecoration(
                                    hintText: '댓글 작성...',
                                    hintStyle: TextStyle(fontSize: 13, color: AppColors.muted),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: AppColors.pastelPurple.withValues(alpha: 0.3))),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: AppColors.pastelPurple.withValues(alpha: 0.3))),
                                  ),
                                  style: const TextStyle(fontSize: 13),
                                  onSubmitted: (_) => _handleComment(),
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: _submitting ? null : _handleComment,
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(colors: [AppColors.pastelPurple, AppColors.pastelPink]),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.send, size: 16, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getItems(String key) {
    final data = _profile?[key];
    if (data is Map && data['items'] is List) {
      return (data['items'] as List).map((item) {
        if (item is String) return {'text': item};
        if (item is Map) return Map<String, dynamic>.from(item);
        return <String, dynamic>{'text': ''};
      }).toList();
    }
    return [];
  }

  Widget _statChip(String label, {bool highlight = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: highlight ? AppColors.pastelPink : AppColors.foreground.withValues(alpha: 0.15)),
      ),
      child: Text(label, style: TextStyle(fontSize: 10, color: highlight ? AppColors.pastelPink : AppColors.muted)),
    );
  }
}
