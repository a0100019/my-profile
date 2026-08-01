import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants.dart';
import '../l10n/app_localizations.dart';

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
        SnackBar(content: Text(AppLocalizations.of(context).lockedContactFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
                  Text(l10n.lockedTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text(
                    l10n.lockedSubtitle,
                    style: TextStyle(fontSize: 13, color: AppColors.muted),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  Text(l10n.lockedReasonTitle, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  StreamBuilder<QuerySnapshot>(
                    stream: _db.collection('reports').where('reportedUid', isEqualTo: widget.uid).snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator(color: AppColors.pastelPurple));
                      }
                      final docs = snapshot.data!.docs;
                      if (docs.isEmpty) {
                        return Text(l10n.lockedReasonEmpty, style: TextStyle(color: AppColors.muted, fontSize: 13));
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
                              reason.isEmpty ? l10n.lockedReasonUnwritten : reason,
                              style: const TextStyle(fontSize: 13),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 28),
                  Text(l10n.lockedContactTitle, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(l10n.lockedContactSubtitle, style: TextStyle(fontSize: 12, color: AppColors.muted)),
                  const SizedBox(height: 8),
                  if (_sent)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.pastelMint.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(l10n.lockedContactSent, style: const TextStyle(fontSize: 13)),
                    )
                  else ...[
                    TextField(
                      controller: _appealController,
                      maxLength: 500,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: l10n.lockedContactHint,
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
                            : Text(l10n.lockedContactSubmit),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Center(
                    child: TextButton(
                      onPressed: () => FirebaseAuth.instance.signOut(),
                      child: Text(l10n.lockedLogout, style: TextStyle(color: AppColors.muted)),
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
