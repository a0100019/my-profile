import 'package:flutter/material.dart';
import '../constants.dart';

class SettingsModal extends StatefulWidget {
  final VoidCallback onLogout;
  final VoidCallback onOpenBamboo;
  final VoidCallback onDeleteAccount;
  final bool isPrivate;
  final Function(bool) onChangePrivacy;
  final VoidCallback onShowReportedList;

  const SettingsModal({
    super.key,
    required this.onLogout,
    required this.onOpenBamboo,
    required this.onDeleteAccount,
    required this.isPrivate,
    required this.onChangePrivacy,
    required this.onShowReportedList,
  });

  @override
  State<SettingsModal> createState() => _SettingsModalState();
}

class _SettingsModalState extends State<SettingsModal> {
  late bool _isPrivate = widget.isPrivate;

  @override
  Widget build(BuildContext context) {
    return Container(
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
                const Text('⚙️ 설정', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const Spacer(),
                GestureDetector(onTap: () => Navigator.pop(context), child: Text('✕', style: TextStyle(fontSize: 18, color: AppColors.muted))),
              ],
            ),
          ),
          _privacyItem(),
          _settingItem('🚨 내가 신고한 사용자', widget.onShowReportedList),
          _settingItem('🎋 대나무숲', widget.onOpenBamboo),
          _settingItem('📋 이용약관', () {
            Navigator.pop(context);
            _showTerms(context);
          }),
          _settingItem('🚪 로그아웃', () => _confirmLogout(context), isDestructive: true),
          _settingItem('❌ 회원 탈퇴', () => _confirmDeleteAccount(context), isDestructive: true),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _privacyItem() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🔒 프로필 비공개', style: TextStyle(fontSize: 14)),
                const SizedBox(height: 2),
                Text(
                  '비공개하면 검색 및 랜덤 프로필 보기에서 제외돼요',
                  style: TextStyle(fontSize: 11, color: AppColors.muted),
                ),
              ],
            ),
          ),
          Switch(
            value: _isPrivate,
            activeTrackColor: AppColors.pastelPurple,
            onChanged: (v) {
              setState(() => _isPrivate = v);
              widget.onChangePrivacy(v);
            },
          ),
        ],
      ),
    );
  }

  Widget _settingItem(String label, VoidCallback onTap, {bool isDestructive = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Text(label, style: TextStyle(fontSize: 14, color: isDestructive ? AppColors.pastelPink : AppColors.foreground)),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('로그아웃 하시겠어요?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
              widget.onLogout();
            },
            child: Text('로그아웃', style: TextStyle(color: AppColors.pastelPink)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('회원 탈퇴'),
        content: const Text('탈퇴 시 프로필, 카테고리, 댓글 등 모든 데이터가 즉시 삭제되며 되돌릴 수 없어요. 정말 탈퇴하시겠어요?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
              widget.onDeleteAccount();
            },
            child: Text('탈퇴', style: TextStyle(color: AppColors.pastelPink)),
          ),
        ],
      ),
    );
  }

  void _showTerms(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('이용약관', textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _term('제1조 (목적)', '본 약관은 mybio.kr(이하 "서비스")의 이용 조건 및 절차, 이용자와 서비스 제공자의 권리·의무를 규정함을 목적으로 합니다.'),
              _term('제2조 (정의)', '① "서비스"란 사용자가 자신의 취향과 관심사를 프로필로 만들어 공유할 수 있는 애플리케이션을 말합니다.\n② "이용자"란 Google 계정으로 로그인하여 서비스를 이용하는 자를 말합니다.'),
              _term('제3조 (개인정보)', '서비스는 Google 로그인을 통해 이름, 이메일, 프로필 사진 URL을 수집합니다. 수집된 정보는 프로필 표시 및 서비스 운영 목적으로만 사용됩니다.'),
              _term('제4조 (이용자의 의무)', '① 타인의 권리를 침해하는 콘텐츠를 게시해서는 안 됩니다.\n② 서비스를 부정한 목적으로 사용해서는 안 됩니다.'),
              _term('제5조 (서비스 변경)', '서비스는 무료로 제공되며, 사전 공지 후 내용이 변경될 수 있습니다.'),
              _term('제6조 (탈퇴)', '이용자는 언제든지 계정 탈퇴가 가능하며, 모든 데이터가 즉시 삭제됩니다.'),
              _term('제7조 (면책)', '서비스 제공자는 게시된 정보의 정확성에 대해 책임지지 않습니다.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('확인', style: TextStyle(color: AppColors.pastelPurple)),
          ),
        ],
      ),
    );
  }

  Widget _term(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(content, style: TextStyle(fontSize: 12, color: AppColors.foreground.withValues(alpha: 0.7), height: 1.5)),
        ],
      ),
    );
  }
}
