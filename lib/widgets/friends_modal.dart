import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants.dart';
import '../screens/public_profile_screen.dart';

class FriendsModal extends StatefulWidget {
  final User? user;
  final Map<String, dynamic> profile;
  final String username;
  final int? userTag;
  final Function(Map<String, dynamic>) onProfileUpdate;

  const FriendsModal({
    super.key,
    required this.user,
    required this.profile,
    required this.username,
    required this.userTag,
    required this.onProfileUpdate,
  });

  @override
  State<FriendsModal> createState() => _FriendsModalState();
}

class _FriendsModalState extends State<FriendsModal> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _db = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _friends = [];
  List<Map<String, dynamic>> _friendRequests = [];
  List<Map<String, dynamic>> _randomProfiles = [];
  List<Map<String, dynamic>> _allRandomProfiles = [];
  int _randomShowCount = 10;
  bool _loading = true;

  // 유저 검색
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _searching = false;
  Timer? _searchDebounce;

  // 채팅
  Map<String, dynamic>? _chatTarget;
  final _chatController = TextEditingController();
  bool _sendingChat = false;

  // 전체 채팅
  final _globalChatController = TextEditingController();
  bool _sendingGlobal = false;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadFriends();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _chatController.dispose();
    _globalChatController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {});
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () => _searchUsers(value));
  }

  Future<void> _searchUsers(String query) async {
    final q = query.trim();
    if (q.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _searching = true);
    final snapshot = await _db.collection('users')
        .where('username', isGreaterThanOrEqualTo: q)
        .where('username', isLessThan: '$q')
        .limit(20)
        .get();
    final results = snapshot.docs
        .where((d) => d.id != widget.user?.uid && d.data()['isPrivate'] != true && d.data()['isLocked'] != true)
        .map((d) {
          final data = d.data();
          return {'uid': d.id, 'username': data['username'], 'displayName': data['displayName'], 'tag': data['tag'], 'photoURL': data['photoURL'] ?? '', 'bio': data['bio'] ?? ''};
        })
        .toList();
    if (!mounted) return;
    setState(() {
      _searchResults = results;
      _searching = false;
    });
  }

  Future<void> _loadFriends() async {
    final friendUids = List<String>.from(widget.profile['friends'] ?? []);
    final requestUids = List<String>.from(widget.profile['friendRequests'] ?? []);

    final friends = <Map<String, dynamic>>[];
    for (final uid in friendUids) {
      final snap = await _db.collection('users').doc(uid).get();
      if (snap.exists) {
        final d = snap.data()!;
        friends.add({'username': d['username'], 'displayName': d['displayName'], 'tag': d['tag'], 'photoURL': d['photoURL'] ?? '', 'uid': uid, 'bio': d['bio'] ?? ''});
      }
    }

    final requests = <Map<String, dynamic>>[];
    for (final uid in requestUids) {
      final snap = await _db.collection('users').doc(uid).get();
      if (snap.exists) {
        final d = snap.data()!;
        requests.add({'username': d['username'], 'displayName': d['displayName'], 'tag': d['tag'], 'photoURL': d['photoURL'] ?? '', 'uid': uid, 'bio': d['bio'] ?? ''});
      }
    }

    setState(() {
      _friends = friends;
      _friendRequests = requests;
      _loading = false;
    });
  }

  Future<void> _loadRandomProfiles() async {
    if (_allRandomProfiles.isNotEmpty) return;
    final snapshot = await _db.collection('users').orderBy('lastActiveAt', descending: true).limit(100).get();
    final profiles = snapshot.docs
        .where((d) => d.id != widget.user?.uid && d.data()['isPrivate'] != true && d.data()['isLocked'] != true)
        .map((d) {
          final data = d.data();
          return {'uid': d.id, 'username': data['username'], 'displayName': data['displayName'], 'tag': data['tag'], 'photoURL': data['photoURL'] ?? '', 'bio': data['bio'] ?? ''};
        })
        .toList();
    setState(() {
      _allRandomProfiles = profiles;
      _randomProfiles = profiles.take(10).toList();
      _randomShowCount = 10;
    });
  }

  Future<void> _acceptFriend(String targetUid) async {
    if (widget.user == null) return;
    final myRef = _db.collection('users').doc(widget.user!.uid);
    final targetRef = _db.collection('users').doc(targetUid);
    await myRef.update({'friends': FieldValue.arrayUnion([targetUid]), 'friendRequests': FieldValue.arrayRemove([targetUid])});
    await targetRef.update({'friends': FieldValue.arrayUnion([widget.user!.uid]), 'sentRequests': FieldValue.arrayRemove([widget.user!.uid])});
    final accepted = _friendRequests.firstWhere((r) => r['uid'] == targetUid);
    if (!mounted) return;
    setState(() {
      _friendRequests.removeWhere((r) => r['uid'] == targetUid);
      _friends.add(accepted);
    });
    widget.onProfileUpdate({
      'friends': [...(widget.profile['friends'] ?? []), targetUid],
      'friendRequests': (widget.profile['friendRequests'] as List?)?.where((id) => id != targetUid).toList() ?? [],
    });
  }

  Future<void> _rejectFriend(String targetUid) async {
    if (widget.user == null) return;
    await _db.collection('users').doc(widget.user!.uid).update({'friendRequests': FieldValue.arrayRemove([targetUid])});
    await _db.collection('users').doc(targetUid).update({'sentRequests': FieldValue.arrayRemove([widget.user!.uid])});
    if (!mounted) return;
    setState(() => _friendRequests.removeWhere((r) => r['uid'] == targetUid));
    widget.onProfileUpdate({
      'friendRequests': (widget.profile['friendRequests'] as List?)?.where((id) => id != targetUid).toList() ?? [],
    });
  }

  void _confirmRemoveFriend(String targetUid, String username) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('친구 삭제'),
        content: Text('"$username"님을 친구에서 삭제할까요?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _removeFriend(targetUid);
            },
            child: Text('삭제', style: TextStyle(color: AppColors.pastelPink)),
          ),
        ],
      ),
    );
  }

  Future<void> _removeFriend(String targetUid) async {
    if (widget.user == null) return;
    await _db.collection('users').doc(widget.user!.uid).update({'friends': FieldValue.arrayRemove([targetUid])});
    await _db.collection('users').doc(targetUid).update({'friends': FieldValue.arrayRemove([widget.user!.uid])});
    if (!mounted) return;
    setState(() => _friends.removeWhere((f) => f['uid'] == targetUid));
    widget.onProfileUpdate({
      'friends': (widget.profile['friends'] as List?)?.where((id) => id != targetUid).toList() ?? [],
    });
  }

  String _getChatId(String uid1, String uid2) {
    final sorted = [uid1, uid2]..sort();
    return sorted.join('_');
  }

  void _openChat(Map<String, dynamic> target) {
    setState(() => _chatTarget = target);
    if (widget.user != null) {
      _db.collection('users').doc(widget.user!.uid).update({'chatUnread.${target['uid']}': 0});
    }
  }

  Future<void> _sendChat() async {
    if (widget.user == null || _chatTarget == null || _chatController.text.trim().isEmpty || _sendingChat) return;
    setState(() => _sendingChat = true);
    final chatId = _getChatId(widget.user!.uid, _chatTarget!['uid']);
    await _db.collection('chats').doc(chatId).collection('messages').add({
      'text': _chatController.text.trim(),
      'senderUid': widget.user!.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await _db.collection('users').doc(_chatTarget!['uid']).update({
      'chatUnread.${widget.user!.uid}': FieldValue.increment(1),
    });
    _chatController.clear();
    if (!mounted) return;
    setState(() => _sendingChat = false);
  }

  Future<void> _sendGlobalChat() async {
    if (widget.user == null || _globalChatController.text.trim().isEmpty || _sendingGlobal) return;
    setState(() => _sendingGlobal = true);
    await _db.collection('globalChat').add({
      'text': _globalChatController.text.trim(),
      'senderUid': widget.user!.uid,
      'senderName': widget.username,
      'senderPhoto': widget.user!.photoURL ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    });
    _globalChatController.clear();
    if (!mounted) return;
    setState(() => _sendingGlobal = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_chatTarget != null) return _buildChatView();

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // 헤더
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                const Text('친구', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const Spacer(),
                GestureDetector(onTap: () => Navigator.pop(context), child: Text('✕', style: TextStyle(fontSize: 18, color: AppColors.muted))),
              ],
            ),
          ),
          TabBar(
            controller: _tabController,
            onTap: (i) {
              if (i == 2) _loadRandomProfiles();
            },
            labelColor: AppColors.foreground,
            unselectedLabelColor: AppColors.muted,
            indicatorColor: AppColors.pastelPurple,
            tabs: const [
              Tab(text: '👫 친구'),
              Tab(text: '💬 전체 채팅'),
              Tab(text: '🎲 랜덤 프로필'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFriendsTab(),
                _buildGlobalChatTab(),
                _buildRandomTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendsTab() {
    if (_loading) return const Center(child: CircularProgressIndicator(color: AppColors.pastelPurple));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_friendRequests.isNotEmpty) ...[
          Text('친구 요청', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.pastelPink)),
          const SizedBox(height: 8),
          ..._friendRequests.map((r) => _friendTile(r, isRequest: true)),
          const SizedBox(height: 16),
        ],
        if (_friends.isEmpty && _friendRequests.isEmpty)
          const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('아직 친구가 없어요', style: TextStyle(color: AppColors.muted))))
        else
          ..._friends.map((f) => _friendTile(f, isRequest: false)),
      ],
    );
  }

  Widget _friendTile(Map<String, dynamic> user, {required bool isRequest}) {
    final photoURL = user['photoURL'] as String? ?? '';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: photoURL.isNotEmpty ? NetworkImage(photoURL) : null,
            backgroundColor: AppColors.pastelPurple.withValues(alpha: 0.3),
            child: photoURL.isEmpty ? const Icon(Icons.person, size: 18) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(user['username'] ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                    const SizedBox(width: 4),
                    Text('#${user['tag']}', style: TextStyle(fontSize: 10, color: AppColors.muted)),
                  ],
                ),
                if ((user['bio'] ?? '').isNotEmpty)
                  Text(user['bio'], maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10, color: AppColors.muted)),
              ],
            ),
          ),
          if (isRequest) ...[
            GestureDetector(
              onTap: () => _acceptFriend(user['uid']),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [AppColors.pastelPurple, AppColors.pastelPink]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('수락', style: TextStyle(fontSize: 11, color: Colors.white)),
              ),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () => _rejectFriend(user['uid']),
              child: Text('거절', style: TextStyle(fontSize: 11, color: AppColors.muted)),
            ),
          ] else ...[
            GestureDetector(
              onTap: () => _openChat(user),
              child: const Text('💬', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _confirmRemoveFriend(user['uid'], user['username'] ?? ''),
              child: Icon(Icons.person_remove, size: 16, color: AppColors.muted),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGlobalChatTab() {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _db.collection('globalChat').orderBy('createdAt').limitToLast(100).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.pastelPurple));
              final docs = snapshot.data!.docs;
              if (docs.isEmpty) return const Center(child: Text('아직 메시지가 없어요', style: TextStyle(color: AppColors.muted)));
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_scrollController.hasClients) _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
              });
              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: docs.length,
                itemBuilder: (context, i) {
                  final d = docs[i].data() as Map<String, dynamic>;
                  final isMe = d['senderUid'] == widget.user?.uid;
                  return _chatBubble(d['senderName'] ?? '', d['text'] ?? '', isMe, docs[i].id, isGlobal: true);
                },
              );
            },
          ),
        ),
        _chatInputBar(_globalChatController, _sendGlobalChat, _sendingGlobal),
      ],
    );
  }

  Widget _buildRandomTab() {
    final isSearching = _searchController.text.trim().isNotEmpty;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: '유저네임으로 검색',
              hintStyle: TextStyle(fontSize: 13, color: AppColors.muted),
              prefixIcon: Icon(Icons.search, size: 20, color: AppColors.muted),
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.pastelPurple.withValues(alpha: 0.3))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.pastelPurple.withValues(alpha: 0.3))),
            ),
            style: const TextStyle(fontSize: 13),
          ),
        ),
        Expanded(child: isSearching ? _buildSearchResults() : _buildRandomList()),
      ],
    );
  }

  Widget _buildSearchResults() {
    if (_searching) return const Center(child: CircularProgressIndicator(color: AppColors.pastelPurple));
    if (_searchResults.isEmpty) return const Center(child: Text('검색 결과가 없어요', style: TextStyle(color: AppColors.muted)));
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      children: _searchResults.map(_profileTile).toList(),
    );
  }

  Widget _buildRandomList() {
    if (_allRandomProfiles.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppColors.pastelPurple));
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      children: [
        ..._randomProfiles.map(_profileTile),
        if (_randomShowCount < _allRandomProfiles.length)
          GestureDetector(
            onTap: () {
              setState(() {
                _randomShowCount += 10;
                _randomProfiles = _allRandomProfiles.take(_randomShowCount).toList();
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.pastelPurple.withValues(alpha: 0.3)),
              ),
              child: const Center(child: Text('더보기', style: TextStyle(fontSize: 13, color: AppColors.pastelPurple))),
            ),
          ),
      ],
    );
  }

  Widget _profileTile(Map<String, dynamic> p) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (_) => PublicProfileScreen(tag: '${p['tag']}')));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: (p['photoURL'] ?? '').isNotEmpty ? NetworkImage(p['photoURL']) : null,
              backgroundColor: AppColors.pastelPurple.withValues(alpha: 0.3),
              child: (p['photoURL'] ?? '').isEmpty ? const Icon(Icons.person, size: 18) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(p['username'] ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                    const SizedBox(width: 4),
                    Text('#${p['tag']}', style: TextStyle(fontSize: 10, color: AppColors.muted)),
                  ]),
                  if ((p['bio'] ?? '').isNotEmpty)
                    Text(p['bio'], maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10, color: AppColors.muted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatView() {
    final chatId = _getChatId(widget.user!.uid, _chatTarget!['uid']);
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
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
                GestureDetector(
                  onTap: () => setState(() => _chatTarget = null),
                  child: const Icon(Icons.arrow_back, size: 20),
                ),
                const SizedBox(width: 12),
                Text(_chatTarget!['username'] ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const Spacer(),
                GestureDetector(onTap: () => Navigator.pop(context), child: Text('✕', style: TextStyle(fontSize: 18, color: AppColors.muted))),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _db.collection('chats').doc(chatId).collection('messages').orderBy('createdAt').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.pastelPurple));
                final docs = snapshot.data!.docs;
                return ListView.builder(
                  reverse: false,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final d = docs[i].data() as Map<String, dynamic>;
                    final isMe = d['senderUid'] == widget.user?.uid;
                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
                        decoration: BoxDecoration(
                          color: isMe ? AppColors.pastelPurple.withValues(alpha: 0.2) : AppColors.background,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(d['text'] ?? '', style: const TextStyle(fontSize: 13)),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          _chatInputBar(_chatController, _sendChat, _sendingChat),
        ],
      ),
    );
  }

  void _confirmDeleteChatMessage(String docId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('메시지 삭제'),
        content: const Text('이 메시지를 삭제할까요?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _db.collection('globalChat').doc(docId).delete();
            },
            child: Text('삭제', style: TextStyle(color: AppColors.pastelPink)),
          ),
        ],
      ),
    );
  }

  Widget _chatBubble(String sender, String text, bool isMe, String docId, {bool isGlobal = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(radius: 14, backgroundColor: AppColors.pastelPurple.withValues(alpha: 0.3), child: const Icon(Icons.person, size: 14)),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isMe) Text(sender, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.muted)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isMe ? AppColors.pastelPurple.withValues(alpha: 0.2) : AppColors.background,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(text, style: const TextStyle(fontSize: 13)),
                ),
                if (isMe && isGlobal)
                  GestureDetector(
                    onTap: () => _confirmDeleteChatMessage(docId),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text('삭제', style: TextStyle(fontSize: 10, color: AppColors.muted)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chatInputBar(TextEditingController controller, VoidCallback onSend, bool sending) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.pastelPurple.withValues(alpha: 0.15))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              maxLength: 300,
              buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
              decoration: InputDecoration(
                hintText: '메시지 입력...',
                hintStyle: TextStyle(fontSize: 13, color: AppColors.muted),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: AppColors.pastelPurple.withValues(alpha: 0.3))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: AppColors.pastelPurple.withValues(alpha: 0.3))),
              ),
              style: const TextStyle(fontSize: 13),
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: sending ? null : onSend,
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
    );
  }
}
