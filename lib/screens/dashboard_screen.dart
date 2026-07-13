import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../constants.dart';
import '../widgets/profile_card.dart';
import '../widgets/category_section.dart';
import '../widgets/friends_modal.dart';
import '../widgets/ranking_modal.dart';
import '../widgets/comments_modal.dart';
import '../widgets/settings_modal.dart';
import '../widgets/edit_profile_modal.dart';
import 'public_profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  Map<String, dynamic> profile = {};
  bool _loading = true;
  int? _userTag;
  String _bio = '';
  List<Map<String, String>> _infoFields = [];
  List<String> _categoryOrder = [];
  int _commentCount = 0;
  bool _copied = false;
  final _customCategoryController = TextEditingController();

  User? get _user => _auth.currentUser;
  String get _defaultUsername => (_user?.email?.split('@')[0] ?? '').substring(0, (_user?.email?.split('@')[0] ?? '').length.clamp(0, 15));
  String get username => (profile['username'] as String?) ?? _defaultUsername;
  String get displayName => (profile['displayName'] as String?) ?? _user?.displayName ?? '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _customCategoryController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final user = _user;
    if (user == null) return;

    try {
      final docRef = _db.collection('users').doc(user.uid);
      final docSnap = await docRef.get();

      if (docSnap.exists) {
        final data = docSnap.data()!;
        setState(() {
          profile = data;
          _bio = data['bio'] ?? '';
          _userTag = data['tag'];
          _categoryOrder = List<String>.from(data['categoryOrder'] ?? []);
          _infoFields = (data['infoFields'] as List<dynamic>?)
              ?.map((f) => {'label': f['label'] as String, 'value': f['value'] as String})
              .toList() ?? [];
        });
      } else {
        final counterRef = _db.collection('meta').doc('counter');
        final tag = await _db.runTransaction<int>((transaction) async {
          final counterSnap = await transaction.get(counterRef);
          final current = counterSnap.exists ? (counterSnap.data()?['userCount'] ?? 0) as int : 0;
          final newCount = current + 1;
          transaction.set(counterRef, {'userCount': newCount}, SetOptions(merge: true));
          return newCount;
        });
        setState(() => _userTag = tag);
        await docRef.set({
          'username': _defaultUsername,
          'displayName': user.displayName,
          'photoURL': user.photoURL,
          'email': user.email,
          'createdAt': DateTime.now().toIso8601String(),
          'tag': tag,
        });
      }

      await docRef.update({'lastActiveAt': FieldValue.serverTimestamp()});

      final commentsSnap = await _db.collection('users').doc(user.uid).collection('comments').get();
      setState(() => _commentCount = commentsSnap.size);
    } catch (e) {
      debugPrint('프로필 로드 실패: $e');
    }
    setState(() => _loading = false);
  }

  Future<void> _saveProfile(Map<String, dynamic> updates) async {
    if (_user == null) return;
    await _db.collection('users').doc(_user!.uid).set(updates, SetOptions(merge: true));
    setState(() => profile.addAll(updates));
  }

  Future<void> _handleShare() async {
    if (_userTag == null) return;
    final url = 'https://mybio.kr/u/$_userTag';
    await Clipboard.setData(ClipboardData(text: url));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  List<CategoryInfo> get _addedCategories {
    final addedDefault = allCategories.where((cat) => profile[cat.key] != null).toList();
    final customKeys = profile.keys.where((k) => k.startsWith('custom_') && profile[k] is Map && (profile[k]['items'] as List?)?.isNotEmpty == true).toList();
    final customCats = customKeys.map((k) => CategoryInfo(k, '✨', k.replaceFirst('custom_', ''))).toList();
    final unsorted = [...addedDefault, ...customCats];

    if (_categoryOrder.isEmpty) return unsorted;
    return [...unsorted]..sort((a, b) {
      final ai = _categoryOrder.indexOf(a.key);
      final bi = _categoryOrder.indexOf(b.key);
      if (ai == -1 && bi == -1) return 0;
      if (ai == -1) return 1;
      if (bi == -1) return -1;
      return ai.compareTo(bi);
    });
  }

  List<CategoryInfo> get _availableCategories {
    return allCategories.where((cat) => profile[cat.key] == null).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.pastelPurple)),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  ProfileCard(
                    profile: profile,
                    user: _user,
                    username: username,
                    displayName: displayName,
                    userTag: _userTag,
                    bio: _bio,
                    infoFields: _infoFields,
                    commentCount: _commentCount,
                    onEditProfile: _showEditProfile,
                    onOpenLikedBy: _showLikedBy,
                    onOpenLikedProfiles: _showLikedProfiles,
                    onOpenRanking: _showRanking,
                    onOpenComments: _showComments,
                  ),
                  const SizedBox(height: 16),

                  const SizedBox(height: 16),

                  ReorderableListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    buildDefaultDragHandles: false,
                    proxyDecorator: (child, index, animation) => Material(
                      color: Colors.transparent,
                      child: child,
                    ),
                    onReorderItem: _reorderCategory,
                    children: _addedCategories.asMap().entries.map((entry) {
                      final i = entry.key;
                      final cat = entry.value;
                      final colorIndex = i % rowColors.length;
                      final items = _getCategoryItems(cat.key);
                      return Padding(
                        key: ValueKey(cat.key),
                        padding: const EdgeInsets.only(bottom: 12),
                        child: CategorySection(
                          category: cat,
                          items: items,
                          colorIndex: colorIndex,
                          onSave: (newItems) => _saveCategory(cat.key, newItems),
                          onRemove: () => _removeCategory(cat.key),
                          dragHandle: ReorderableDragStartListener(
                            index: i,
                            child: Icon(Icons.drag_handle, size: 20, color: AppColors.muted),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _actionButton(
                          _copied ? '복사됨!' : '프로필 공유',
                          _copied ? Icons.check : Icons.share,
                          _handleShare,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _actionButton(
                          '사진 변경',
                          Icons.camera_alt,
                          _changePhoto,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildAddCategory(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final reqCount = (profile['friendRequests'] as List?)?.length ?? 0;
    final unreadMap = profile['chatUnread'] as Map<String, dynamic>? ?? {};
    final chatCount = unreadMap.values.fold<int>(0, (a, b) => a + (b as int? ?? 0));
    final total = reqCount + chatCount;

    return Row(
      children: [
        GestureDetector(
          onTap: () => _showSettings(),
          child: const Text('⚙️', style: TextStyle(fontSize: 18)),
        ),
        const Spacer(),
        RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            children: [
              TextSpan(text: 'my', style: TextStyle(color: AppColors.pastelPurple)),
              TextSpan(text: '.', style: TextStyle(color: AppColors.foreground)),
              TextSpan(text: 'bio', style: TextStyle(color: AppColors.pastelBlue)),
            ],
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () => _showFriends(),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('👫 친구', style: TextStyle(
                fontSize: 14,
                color: total > 0 ? AppColors.foreground : AppColors.muted,
                fontWeight: total > 0 ? FontWeight.w600 : FontWeight.normal,
              )),
              if (total > 0) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [BoxShadow(color: Colors.red.withValues(alpha: 0.4), blurRadius: 6)],
                  ),
                  child: Text('$total', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _actionButton(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.pastelPurple.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: AppColors.pastelPurple),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontSize: 13, color: AppColors.foreground, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildAddCategory() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.pastelPurple.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('카테고리 추가하기', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: _availableCategories.map((cat) {
              return GestureDetector(
                onTap: () => _addCategory(cat.key),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.pastelPurple.withValues(alpha: 0.3)),
                  ),
                  child: Text('${cat.emoji} ${cat.label}', style: const TextStyle(fontSize: 12)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          _buildCustomCategoryInput(),
        ],
      ),
    );
  }

  Widget _buildCustomCategoryInput() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _customCategoryController,
            maxLength: 12,
            buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
            decoration: InputDecoration(
              hintText: '원하는 카테고리를 만들어봐요',
              hintStyle: TextStyle(fontSize: 12, color: AppColors.muted),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppColors.pastelPurple.withValues(alpha: 0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppColors.pastelPurple.withValues(alpha: 0.3)),
              ),
            ),
            style: const TextStyle(fontSize: 13),
            onSubmitted: (_) => _submitCustomCategory(),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: _submitCustomCategory,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.pastelPurple, AppColors.pastelPink]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text('추가', style: TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w500)),
          ),
        ),
      ],
    );
  }

  void _submitCustomCategory() {
    final raw = _customCategoryController.text.trim();
    if (raw.isEmpty) return;
    // Firestore 필드 경로에 쓸 수 없는 문자 제거 (., /, [, ], *, ~)
    final text = raw.replaceAll(RegExp(r'[./\[\]*~]'), '');
    if (text.isEmpty) return;

    final match = allCategories.where((c) => c.label == text).firstOrNull;
    final key = match?.key ?? 'custom_$text';

    if (profile[key] != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이미 추가된 카테고리예요.')),
      );
      return;
    }

    _addCategory(key);
    _customCategoryController.clear();
  }

  List<Map<String, dynamic>> _getCategoryItems(String key) {
    final data = profile[key];
    if (data is Map && data['items'] is List) {
      return (data['items'] as List).map((item) {
        if (item is String) return {'text': item, 'link': '', 'image': ''};
        if (item is Map) return Map<String, dynamic>.from(item);
        return {'text': '', 'link': '', 'image': ''};
      }).toList();
    }
    return [];
  }

  Future<void> _addCategory(String key) async {
    await _saveProfile({key: {'items': []}});
    final order = [..._categoryOrder, key];
    setState(() => _categoryOrder = order);
    await _saveProfile({'categoryOrder': order});
  }

  Future<void> _saveCategory(String key, List<Map<String, dynamic>> items) async {
    await _saveProfile({key: {'items': items}});
  }

  Future<void> _removeCategory(String key) async {
    if (_user == null) return;
    await _db.collection('users').doc(_user!.uid).update({key: FieldValue.delete()});
    setState(() {
      profile.remove(key);
      _categoryOrder.remove(key);
    });
  }

  Future<void> _changePhoto() async {
    if (_user == null) return;
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 512, maxHeight: 512, imageQuality: 80);
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      final ref = FirebaseStorage.instance.ref('profilePhotos/${_user!.uid}.jpg');
      await ref.putData(Uint8List.fromList(bytes), SettableMetadata(contentType: 'image/jpeg'));
      final url = await ref.getDownloadURL();
      await _saveProfile({'photoURL': url});
      await _user!.updatePhotoURL(url);
      setState(() {});
    } catch (e) {
      debugPrint('사진 변경 실패: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('사진 변경에 실패했어요. 다시 시도해주세요.')),
      );
    }
  }

  void _reorderCategory(int oldIndex, int newIndex) {
    final order = _addedCategories.map((c) => c.key).toList();
    final item = order.removeAt(oldIndex);
    order.insert(newIndex, item);
    setState(() => _categoryOrder = order);
    _saveProfile({'categoryOrder': order});
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SettingsModal(
        onLogout: () async {
          await _auth.signOut();
        },
        onOpenBamboo: () {
          Navigator.pop(context);
          _showBamboo();
        },
        onDeleteAccount: _deleteAccount,
      ),
    );
  }

  Future<void> _deleteAccount() async {
    final user = _user;
    if (user == null) return;
    try {
      final commentsSnap = await _db.collection('users').doc(user.uid).collection('comments').get();
      for (final doc in commentsSnap.docs) {
        await doc.reference.delete();
      }
      await _db.collection('users').doc(user.uid).delete();
      try {
        await user.delete();
      } on FirebaseAuthException catch (e) {
        if (e.code == 'requires-recent-login') {
          await _auth.signOut();
        } else {
          rethrow;
        }
      }
    } catch (e) {
      debugPrint('회원 탈퇴 실패: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('탈퇴 처리에 실패했어요. 다시 시도해주세요.')),
      );
    }
  }

  void _showFriends() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FriendsModal(
        user: _user,
        profile: profile,
        username: username,
        userTag: _userTag,
        onProfileUpdate: (updates) {
          setState(() => profile.addAll(updates));
        },
      ),
    );
  }

  void _showRanking() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const RankingModal(),
    );
  }

  void _showComments() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommentsModal(
        user: _user,
        username: username,
        userTag: _userTag,
        onCountUpdate: (c) => setState(() => _commentCount = c),
      ),
    );
  }

  void _showEditProfile() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditProfileModal(
        user: _user,
        profile: profile,
        bio: _bio,
        infoFields: _infoFields,
        onSave: (updates) async {
          await _saveProfile(updates);
          if (updates.containsKey('bio')) setState(() => _bio = updates['bio']);
          if (updates.containsKey('infoFields')) {
            setState(() => _infoFields = (updates['infoFields'] as List)
                .map((f) => {'label': f['label'] as String, 'value': f['value'] as String})
                .toList());
          }
        },
      ),
    );
  }

  void _showLikedBy() {
    _showUserList(
      title: '좋아요 눌러준 사람',
      uids: List<String>.from(profile['likedBy'] ?? []),
    );
  }

  void _showLikedProfiles() {
    _showUserList(
      title: '내가 좋아요 누른 프로필',
      uids: List<String>.from(profile['likedProfiles'] ?? []),
    );
  }

  void _showUserList({required String title, required List<String> uids}) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _UserListSheet(title: title, uids: uids, db: _db),
    );
  }

  void _showBamboo() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BambooModal(user: _user, userTag: _userTag),
    );
  }
}

class _UserListSheet extends StatelessWidget {
  final String title;
  final List<String> uids;
  final FirebaseFirestore db;

  const _UserListSheet({required this.title, required this.uids, required this.db});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Text('✕', style: TextStyle(fontSize: 18, color: AppColors.muted)),
                ),
              ],
            ),
          ),
          Flexible(
            child: uids.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('아직 없어요', style: TextStyle(color: AppColors.muted)),
                  )
                : FutureBuilder<List<Map<String, dynamic>>>(
                    future: _fetchUsers(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.pastelPurple));
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, i) {
                          final u = snapshot.data![i];
                          return GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(context, MaterialPageRoute(builder: (_) => PublicProfileScreen(tag: '${u['tag']}')));
                            },
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColors.pastelPurple.withValues(alpha: 0.3),
                                child: const Icon(Icons.person, size: 20),
                              ),
                              title: Text(u['username'] ?? '', style: const TextStyle(fontSize: 14)),
                              subtitle: u['bio'] != null && u['bio'] != ''
                                  ? Text(u['bio'], maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10, color: AppColors.muted))
                                  : null,
                              trailing: Text('#${u['tag']}', style: TextStyle(fontSize: 12, color: AppColors.muted)),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchUsers() async {
    final results = <Map<String, dynamic>>[];
    for (final uid in uids) {
      final snap = await db.collection('users').doc(uid).get();
      if (snap.exists) {
        final d = snap.data()!;
        results.add({'username': d['username'], 'displayName': d['displayName'], 'tag': d['tag'], 'bio': d['bio'] ?? ''});
      }
    }
    return results;
  }
}

class _BambooModal extends StatefulWidget {
  final User? user;
  final int? userTag;
  const _BambooModal({this.user, this.userTag});

  @override
  State<_BambooModal> createState() => _BambooModalState();
}

class _BambooModalState extends State<_BambooModal> {
  final _controller = TextEditingController();
  bool _sending = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text('🎋 대나무숲', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const Spacer(),
                GestureDetector(onTap: () => Navigator.pop(context), child: Text('✕', style: TextStyle(fontSize: 18, color: AppColors.muted))),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.pastelMint.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '대나무숲은 사이트에 관한 의견을 자유롭게 작성하는 곳입니다. 익명이니 안심하고 바라는 점을 적어주세요!',
                style: TextStyle(fontSize: 12, color: AppColors.foreground.withValues(alpha: 0.7)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('bamboo').orderBy('createdAt', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.pastelPurple));
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) return const Center(child: Text('아직 글이 없어요', style: TextStyle(color: AppColors.muted)));
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final d = docs[i].data() as Map<String, dynamic>;
                    final ts = d['createdAt'] as Timestamp?;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(d['text'] ?? '', style: const TextStyle(fontSize: 13)),
                          if (ts != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              _formatDate(ts.toDate()),
                              style: TextStyle(fontSize: 10, color: AppColors.muted),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.pastelPurple.withValues(alpha: 0.15))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    maxLength: 500,
                    buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                    decoration: InputDecoration(
                      hintText: '익명으로 작성하기...',
                      hintStyle: TextStyle(fontSize: 13, color: AppColors.muted),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: AppColors.pastelPurple.withValues(alpha: 0.3))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: AppColors.pastelPurple.withValues(alpha: 0.3))),
                    ),
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _sending ? null : _send,
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
          ),
        ],
      ),
    );
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => _sending = true);
    await FirebaseFirestore.instance.collection('bamboo').add({
      'text': text,
      'uid': widget.user?.uid ?? '',
      'tag': '${widget.userTag ?? ''}',
      'createdAt': FieldValue.serverTimestamp(),
    });
    _controller.clear();
    setState(() => _sending = false);
  }

  String _formatDate(DateTime dt) {
    return '${dt.month}월 ${dt.day}일';
  }
}
