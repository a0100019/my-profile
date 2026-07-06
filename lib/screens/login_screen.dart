import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import '../constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _loading = false;
  bool _agreed = true;
  bool _showTerms = false;

  Future<void> _handleGoogleLogin() async {
    if (!_agreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('약관에 동의해주세요.')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        await FirebaseAuth.instance.signInWithPopup(provider);
      } else {
        final googleSignIn = GoogleSignIn.instance;
        await googleSignIn.initialize();
        final account = await googleSignIn.authenticate();
        final idToken = account.authentication.idToken;
        final credential = GoogleAuthProvider.credential(idToken: idToken);
        await FirebaseAuth.instance.signInWithCredential(credential);
      }
    } catch (e) {
      debugPrint('로그인 실패: $e');
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 배경 장식
          Positioned(top: -80, left: -80, child: _blob(AppColors.pastelPink, 280)),
          Positioned(top: 200, right: -60, child: _blob(AppColors.pastelBlue, 240)),
          Positioned(bottom: 80, left: 80, child: _blob(AppColors.pastelMint, 220)),
          Positioned(bottom: -40, right: 100, child: _blob(AppColors.pastelPurple, 180)),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 380),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 로고
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                          children: [
                            TextSpan(text: 'm', style: TextStyle(color: AppColors.pastelPurple)),
                            TextSpan(text: 'y', style: TextStyle(color: AppColors.pastelPink)),
                            TextSpan(text: 'b', style: TextStyle(color: AppColors.pastelBlue)),
                            TextSpan(text: 'i', style: TextStyle(color: AppColors.pastelMint)),
                            TextSpan(text: 'o', style: TextStyle(color: AppColors.pastelPeach)),
                            TextSpan(text: '.', style: TextStyle(color: AppColors.foreground)),
                            TextSpan(text: 'k', style: TextStyle(color: AppColors.pastelPurple)),
                            TextSpan(text: 'r', style: TextStyle(color: AppColors.pastelPink)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '나만의 취향을 담은 프로필을 만들고\n친구에게 공유해보세요',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: AppColors.muted, height: 1.5),
                      ),
                      const SizedBox(height: 32),

                      // 카드 미리보기
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.pastelPink.withValues(alpha: 0.3)),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 48, height: 48,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(colors: [AppColors.pastelPink, AppColors.pastelPurple]),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(width: 96, height: 12, decoration: BoxDecoration(color: AppColors.pastelBlue.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(6))),
                                    const SizedBox(height: 8),
                                    Container(width: 64, height: 8, decoration: BoxDecoration(color: AppColors.pastelMint.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(4))),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8, runSpacing: 8,
                              children: ['🍕 피자', '🎬 영화', '🎵 음악', '📚 독서', '✈️ 여행', '💕 이상형', '🐶 동물', '💼 MBTI', '🎌 애니']
                                  .map((tag) => Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.pastelYellow.withValues(alpha: 0.5),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(tag, style: TextStyle(fontSize: 12, color: AppColors.foreground.withValues(alpha: 0.7))),
                                  ))
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // 구글 로그인 버튼
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _handleGoogleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.card,
                            foregroundColor: AppColors.foreground,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(color: AppColors.pastelPurple.withValues(alpha: 0.2)),
                            ),
                            elevation: 2,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.network(
                                'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                                width: 20, height: 20,
                                errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Text(_loading ? '로그인 중...' : 'Google로 시작하기', style: const TextStyle(fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 약관 동의
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () => setState(() => _agreed = !_agreed),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 18, height: 18,
                                  child: Checkbox(
                                    value: _agreed,
                                    onChanged: (v) => setState(() => _agreed = v ?? false),
                                    activeColor: AppColors.pastelPurple,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text('이용약관에 동의합니다', style: TextStyle(fontSize: 12, color: AppColors.muted)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => setState(() => _showTerms = true),
                            child: Text('자세히보기', style: TextStyle(fontSize: 12, color: AppColors.pastelPurple, decoration: TextDecoration.underline)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 이용약관 모달
          if (_showTerms) _buildTermsModal(),
        ],
      ),
    );
  }

  Widget _blob(Color color, double size) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.4),
      ),
    );
  }

  Widget _buildTermsModal() {
    return GestureDetector(
      onTap: () => setState(() => _showTerms = false),
      child: Container(
        color: Colors.black.withValues(alpha: 0.3),
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              constraints: const BoxConstraints(maxWidth: 380, maxHeight: 600),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('이용약관', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _termSection('제1조 (목적)', '본 약관은 mybio.kr(이하 "서비스")의 이용 조건 및 절차, 이용자와 서비스 제공자의 권리·의무를 규정함을 목적으로 합니다.'),
                          _termSection('제2조 (정의)', '① "서비스"란 사용자가 자신의 취향과 관심사를 프로필로 만들어 공유할 수 있는 애플리케이션을 말합니다.\n② "이용자"란 Google 계정으로 로그인하여 서비스를 이용하는 자를 말합니다.'),
                          _termSection('제3조 (개인정보 수집 및 이용)', '서비스는 Google 로그인을 통해 아래 정보를 수집합니다.\n• 이름 (표시명)\n• 이메일 주소\n• 프로필 사진 URL\n\n수집된 정보는 프로필 표시 및 서비스 운영 목적으로만 사용되며, 제3자에게 제공하지 않습니다.'),
                          _termSection('제4조 (이용자의 의무)', '① 이용자는 타인의 권리를 침해하는 콘텐츠를 게시해서는 안 됩니다.\n② 이용자는 서비스를 부정한 목적으로 사용해서는 안 됩니다.\n③ 이용자가 업로드한 콘텐츠에 대한 책임은 이용자 본인에게 있습니다.'),
                          _termSection('제5조 (서비스 제공 및 변경)', '① 서비스는 무료로 제공되며, 사전 공지 후 내용이 변경될 수 있습니다.\n② 서비스 제공자는 천재지변, 기술적 장애 등 불가피한 사유로 서비스를 일시 중단할 수 있습니다.'),
                          _termSection('제6조 (계정 탈퇴 및 데이터 삭제)', '이용자는 언제든지 설정에서 계정 탈퇴가 가능하며, 탈퇴 시 모든 개인정보와 프로필 데이터가 즉시 삭제됩니다.'),
                          _termSection('제7조 (면책)', '서비스 제공자는 이용자가 서비스 내에 게시한 정보의 신뢰도, 정확성에 대해 책임을 지지 않습니다.'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => setState(() => _showTerms = false),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        backgroundColor: AppColors.pastelPurple,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('확인', style: TextStyle(fontWeight: FontWeight.w500)),
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

  Widget _termSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.foreground)),
          const SizedBox(height: 4),
          Text(content, style: TextStyle(fontSize: 12, color: AppColors.foreground.withValues(alpha: 0.7), height: 1.5)),
        ],
      ),
    );
  }
}
