import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants.dart';

class EditProfileModal extends StatefulWidget {
  final User? user;
  final Map<String, dynamic> profile;
  final String bio;
  final List<Map<String, String>> infoFields;
  final Function(Map<String, dynamic>) onSave;

  const EditProfileModal({
    super.key,
    required this.user,
    required this.profile,
    required this.bio,
    required this.infoFields,
    required this.onSave,
  });

  @override
  State<EditProfileModal> createState() => _EditProfileModalState();
}

class _EditProfileModalState extends State<EditProfileModal> {
  late TextEditingController _bioController;
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late List<Map<String, String>> _fields;
  final _newLabelController = TextEditingController();
  final _newValueController = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _bioController = TextEditingController(text: widget.bio);
    _nameController = TextEditingController(text: widget.profile['displayName'] ?? '');
    _usernameController = TextEditingController(text: widget.profile['username'] ?? '');
    _fields = List.from(widget.infoFields.map((f) => Map<String, String>.from(f)));
  }

  @override
  void dispose() {
    _bioController.dispose();
    _nameController.dispose();
    _usernameController.dispose();
    _newLabelController.dispose();
    _newValueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
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
                const Text('프로필 편집', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const Spacer(),
                GestureDetector(onTap: () => Navigator.pop(context), child: Text('✕', style: TextStyle(fontSize: 18, color: AppColors.muted))),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('이름'),
                  _input(_nameController, maxLength: 10),
                  const SizedBox(height: 12),
                  _label('유저네임'),
                  _input(_usernameController, maxLength: 15),
                  const SizedBox(height: 12),
                  _label('한줄 소개'),
                  _input(_bioController, maxLength: 200, maxLines: 3),
                  const SizedBox(height: 16),
                  _label('정보 필드'),
                  ..._fields.asMap().entries.map((entry) {
                    final i = entry.key;
                    final f = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 80,
                            child: Text(f['label'] ?? '', style: TextStyle(fontSize: 13, color: AppColors.muted)),
                          ),
                          Expanded(
                            child: Text(f['value'] ?? '', style: const TextStyle(fontSize: 13)),
                          ),
                          GestureDetector(
                            onTap: () => setState(() => _fields.removeAt(i)),
                            child: Icon(Icons.close, size: 16, color: AppColors.pastelPink),
                          ),
                        ],
                      ),
                    );
                  }),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _newLabelController,
                          decoration: InputDecoration(
                            hintText: '항목명',
                            hintStyle: TextStyle(fontSize: 12, color: AppColors.muted),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.pastelPurple.withValues(alpha: 0.3))),
                            isDense: true,
                          ),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: _newValueController,
                          decoration: InputDecoration(
                            hintText: '내용',
                            hintStyle: TextStyle(fontSize: 12, color: AppColors.muted),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.pastelPurple.withValues(alpha: 0.3))),
                            isDense: true,
                          ),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          if (_newLabelController.text.trim().isEmpty) return;
                          setState(() {
                            _fields.add({'label': _newLabelController.text.trim(), 'value': _newValueController.text.trim()});
                            _newLabelController.clear();
                            _newValueController.clear();
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: AppColors.pastelPurple, borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.add, size: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  backgroundColor: AppColors.pastelPurple,
                  foregroundColor: Colors.white,
                ),
                child: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('저장', style: TextStyle(fontWeight: FontWeight.w500)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: TextStyle(fontSize: 12, color: AppColors.muted, fontWeight: FontWeight.w500)),
    );
  }

  Widget _input(TextEditingController controller, {int? maxLength, int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLength: maxLength,
      maxLines: maxLines,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.pastelPurple.withValues(alpha: 0.3))),
      ),
      style: const TextStyle(fontSize: 14),
    );
  }

  Future<void> _save() async {
    final newUsername = _usernameController.text.trim();
    if (newUsername.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('유저네임을 입력해주세요.')),
      );
      return;
    }

    setState(() => _saving = true);

    final currentUsername = widget.profile['username'] as String? ?? '';
    if (newUsername != currentUsername) {
      final dupSnap = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: newUsername)
          .limit(1)
          .get();
      final taken = dupSnap.docs.isNotEmpty && dupSnap.docs.first.id != widget.user?.uid;
      if (taken) {
        if (!mounted) return;
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이미 사용 중인 유저네임이에요.')),
        );
        return;
      }
    }

    widget.onSave({
      'displayName': _nameController.text.trim(),
      'username': newUsername,
      'bio': _bioController.text.trim(),
      'infoFields': _fields.map((f) => {'label': f['label'], 'value': f['value']}).toList(),
    });
    if (!mounted) return;
    Navigator.pop(context);
  }
}
