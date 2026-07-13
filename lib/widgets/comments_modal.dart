import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants.dart';

class CommentsModal extends StatefulWidget {
  final User? user;
  final String username;
  final int? userTag;
  final Function(int) onCountUpdate;

  const CommentsModal({
    super.key,
    required this.user,
    required this.username,
    required this.userTag,
    required this.onCountUpdate,
  });

  @override
  State<CommentsModal> createState() => _CommentsModalState();
}

class _CommentsModalState extends State<CommentsModal> {
  final _controller = TextEditingController();
  bool _sending = false;
  final _db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    if (widget.user == null) return const SizedBox.shrink();

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
                StreamBuilder<QuerySnapshot>(
                  stream: _db.collection('users').doc(widget.user!.uid).collection('comments').snapshots(),
                  builder: (context, snapshot) {
                    final count = snapshot.data?.docs.length ?? 0;
                    WidgetsBinding.instance.addPostFrameCallback((_) => widget.onCountUpdate(count));
                    return Text('댓글 ($count)', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600));
                  },
                ),
                const Spacer(),
                GestureDetector(onTap: () => Navigator.pop(context), child: Text('✕', style: TextStyle(fontSize: 18, color: AppColors.muted))),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _db.collection('users').doc(widget.user!.uid).collection('comments').orderBy('createdAt', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.pastelPurple));
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) return const Center(child: Text('아직 댓글이 없어요', style: TextStyle(color: AppColors.muted)));
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final d = docs[i].data() as Map<String, dynamic>;
                    final ts = d['createdAt'] as Timestamp?;
                    final photoURL = d['senderPhoto'] as String? ?? '';
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundImage: photoURL.isNotEmpty ? NetworkImage(photoURL) : null,
                            backgroundColor: AppColors.pastelPurple.withValues(alpha: 0.3),
                            child: photoURL.isEmpty ? const Icon(Icons.person, size: 14) : null,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(d['senderName'] ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                                    const SizedBox(width: 4),
                                    Text('#${d['senderTag'] ?? ''}', style: TextStyle(fontSize: 10, color: AppColors.muted)),
                                    const Spacer(),
                                    if (ts != null)
                                      Text('${ts.toDate().month}월 ${ts.toDate().day}일', style: TextStyle(fontSize: 10, color: AppColors.muted)),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(d['text'] ?? '', style: TextStyle(fontSize: 13, color: AppColors.foreground.withValues(alpha: 0.8))),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => _confirmDelete(docs[i].id),
                            child: Text('삭제', style: TextStyle(fontSize: 10, color: AppColors.muted)),
                          ),
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
                    onSubmitted: (_) => _send(),
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

  void _confirmDelete(String commentId) {
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
              _db.collection('users').doc(widget.user!.uid).collection('comments').doc(commentId).delete();
            },
            child: Text('삭제', style: TextStyle(color: AppColors.pastelPink)),
          ),
        ],
      ),
    );
  }

  Future<void> _send() async {
    if (_controller.text.trim().isEmpty || _sending) return;
    setState(() => _sending = true);
    await _db.collection('users').doc(widget.user!.uid).collection('comments').add({
      'text': _controller.text.trim(),
      'senderUid': widget.user!.uid,
      'senderName': widget.username,
      'senderTag': '${widget.userTag ?? ''}',
      'senderPhoto': widget.user!.photoURL ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    });
    _controller.clear();
    setState(() => _sending = false);
  }
}
