import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants.dart';

class ProfileCard extends StatelessWidget {
  final Map<String, dynamic> profile;
  final User? user;
  final String username;
  final String displayName;
  final int? userTag;
  final String bio;
  final List<Map<String, String>> infoFields;
  final int commentCount;
  final VoidCallback onEditProfile;
  final VoidCallback onOpenLikedBy;
  final VoidCallback onOpenLikedProfiles;
  final VoidCallback onOpenRanking;
  final VoidCallback onOpenComments;

  const ProfileCard({
    super.key,
    required this.profile,
    required this.user,
    required this.username,
    required this.displayName,
    required this.userTag,
    required this.bio,
    required this.infoFields,
    required this.commentCount,
    required this.onEditProfile,
    required this.onOpenLikedBy,
    required this.onOpenLikedProfiles,
    required this.onOpenRanking,
    required this.onOpenComments,
  });

  @override
  Widget build(BuildContext context) {
    final photoURL = (profile['photoURL'] as String?) ?? user?.photoURL ?? '';

    return Container(
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
          // 프로필 헤더
          Row(
            children: [
              _buildAvatar(photoURL),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(text: username, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.foreground)),
                                if (userTag != null) TextSpan(text: ' #$userTag', style: TextStyle(fontSize: 14, color: AppColors.pastelPurple)),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: onEditProfile,
                          child: Text('프로필 변경', style: TextStyle(fontSize: 12, color: AppColors.pastelPurple)),
                        ),
                      ],
                    ),
                    Text(displayName, style: TextStyle(fontSize: 14, color: AppColors.muted)),
                    const SizedBox(height: 4),
                    // 스탯 칩
                    Wrap(
                      spacing: 8,
                      children: [
                        _statChip('조회수 ${profile['views'] ?? 0}'),
                        GestureDetector(
                          onTap: onOpenLikedBy,
                          child: _statChip('받은 좋아요 ${profile['likes'] ?? 0}'),
                        ),
                        GestureDetector(
                          onTap: onOpenLikedProfiles,
                          child: _statChip('누른 좋아요'),
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
                Row(
                  children: [
                    Text('자기소개', style: TextStyle(fontSize: 12, color: AppColors.muted, fontWeight: FontWeight.w500)),
                    const Spacer(),
                    GestureDetector(
                      onTap: onEditProfile,
                      child: Text('편집', style: TextStyle(fontSize: 12, color: AppColors.pastelPurple)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
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
                      Text(bio.isEmpty ? '-' : bio, style: TextStyle(fontSize: 14, color: AppColors.foreground.withValues(alpha: 0.7)), textAlign: TextAlign.center),
                    ],
                  ),
                ),
                if (infoFields.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
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
          const SizedBox(height: 12),

          // 순위 보기 / 댓글 보기 버튼
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onOpenRanking,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.pastelPurple.withValues(alpha: 0.3)),
                    ),
                    child: const Center(child: Text('🏆 순위 보기', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: onOpenComments,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.pastelPurple.withValues(alpha: 0.3)),
                    ),
                    child: Center(child: Text('💬 댓글 보기($commentCount)', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String photoURL) {
    if (photoURL.isNotEmpty) {
      return CircleAvatar(
        radius: 32,
        backgroundImage: NetworkImage(photoURL),
        backgroundColor: AppColors.pastelPurple.withValues(alpha: 0.3),
      );
    }
    return Container(
      width: 64, height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [AppColors.pastelPink, AppColors.pastelPurple],
        ),
      ),
    );
  }

  Widget _statChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.foreground.withValues(alpha: 0.15)),
      ),
      child: Text(label, style: TextStyle(fontSize: 10, color: AppColors.muted)),
    );
  }
}
