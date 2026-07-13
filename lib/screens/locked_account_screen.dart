import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants.dart';

class LockedAccountScreen extends StatefulWidget {
  final String uid;
  const LockedAccountScreen({super.key, required this.uid});

  @override
  State<LockedAccountScreen> createState() => _LockedAccountScreenState();
}

class _LockedAccountScreenState extends State<LockedAccountScreen> {
  final _db = FirebaseFirestore.instance;
  final _appealController = TextEditingController();
  bool _sending = false;
  bool _sent = false;

  @override
  void dispose() {
    _appealController.dispose();
    super.dispose();
  }

  Future<void> _sendAppeal() async {
    final text = _appealController.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      await _db.collection('appeals').add({
        'uid': widget.uid,
        'text': text,
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      setState(() {
        _sending = false;
        _sent = true;
      });
    } catch (e) {
      debugPrint('문의 접수 실패: $e');
      if (!mounted) return;
      setState(() => _sending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('전송에 실패했어요. 다시 시도해주세요.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 32),
                  const Center(child: Text('🔒', style: TextStyle(fontSize: 48))),
                  const SizedBox(height: 16),
                  const Text('계정이 잠겼어요', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text(
                    '다수의 사용자로부터 신고가 접수되어 계정 이용이 제한됐어요.',
                    style: TextStyle(fontSize: 13, color: AppColors.muted),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  const Text('신고 사유', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  StreamBuilder<QuerySnapshot>(
                    stream: _db.collection('reports').where('reportedUid', isEqualTo: widget.uid).snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator(color: AppColors.pastelPurple));
                      }
                      final docs = snapshot.data!.docs;
                      if (docs.isEmpty) {
                        return Text('등록된 사유가 없어요', style: TextStyle(color: AppColors.muted, fontSize: 13));
                      }
                      return Column(
                        children: docs.map((d) {
                          final data = d.data() as Map<String, dynamic>;
                          final reason = (data['reason'] as String?)?.trim() ?? '';
                          return Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              reason.isEmpty ? '(사유 미작성)' : reason,
                              style: const TextStyle(fontSize: 13),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 28),
                  const Text('문의하기', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('오류가 있다면 알려주세요', style: TextStyle(fontSize: 12, color: AppColors.muted)),
                  const SizedBox(height: 8),
                  if (_sent)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.pastelMint.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('문의가 접수됐어요. 검토 후 반영해드릴게요.', style: TextStyle(fontSize: 13)),
                    )
                  else ...[
                    TextField(
                      controller: _appealController,
                      maxLength: 500,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: '내용을 입력해주세요',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.pastelPurple.withValues(alpha: 0.3))),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _sending ? null : _sendAppeal,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.pastelPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: _sending
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('제출'),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Center(
                    child: TextButton(
                      onPressed: () => FirebaseAuth.instance.signOut(),
                      child: Text('로그아웃', style: TextStyle(color: AppColors.muted)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
