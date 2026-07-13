import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants.dart';
import '../screens/public_profile_screen.dart';

class RankingModal extends StatefulWidget {
  const RankingModal({super.key});

  @override
  State<RankingModal> createState() => _RankingModalState();
}

class _RankingModalState extends State<RankingModal> {
  String _tab = 'views';
  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> _rankingList = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRanking();
  }

  Future<void> _loadRanking() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').get();
    _allUsers = snapshot.docs.where((d) => d.data()['isPrivate'] != true).map((d) {
      final data = d.data();
      return {
        'username': data['username'] ?? '',
        'displayName': data['displayName'] ?? '',
        'tag': data['tag'] ?? 0,
        'photoURL': data['photoURL'] ?? '',
        'views': data['views'] ?? 0,
        'likes': data['likes'] ?? 0,
        'friends': (data['friends'] as List?)?.length ?? 0,
        'bio': data['bio'] ?? '',
      };
    }).toList();
    _sortBy('views');
    setState(() => _loading = false);
  }

  void _sortBy(String tab) {
    setState(() {
      _tab = tab;
      _rankingList = [..._allUsers]..sort((a, b) {
        final av = a[tab] as int;
        final bv = b[tab] as int;
        if (bv != av) return bv.compareTo(av);
        return (a['username'] as String).compareTo(b['username'] as String);
      });
    });
  }

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
                const Text('🏆 순위', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const Spacer(),
                GestureDetector(onTap: () => Navigator.pop(context), child: Text('✕', style: TextStyle(fontSize: 18, color: AppColors.muted))),
              ],
            ),
          ),
          // 탭
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _tabButton('조회수', 'views'),
                const SizedBox(width: 8),
                _tabButton('좋아요', 'likes'),
                const SizedBox(width: 8),
                _tabButton('친구', 'friends'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.pastelPurple))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _rankingList.length,
                    itemBuilder: (context, i) {
                      final u = _rankingList[i];
                      final rank = i + 1;
                      return GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => PublicProfileScreen(tag: '${u['tag']}')));
                        },
                        child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: rank <= 3 ? AppColors.pastelYellow.withValues(alpha: 0.2) : AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 28,
                              child: Text(
                                rank <= 3 ? ['🥇', '🥈', '🥉'][rank - 1] : '$rank',
                                style: TextStyle(fontSize: rank <= 3 ? 18 : 14, fontWeight: FontWeight.w600),
                              ),
                            ),
                            const SizedBox(width: 8),
                            CircleAvatar(
                              radius: 16,
                              backgroundImage: (u['photoURL'] ?? '').isNotEmpty ? NetworkImage(u['photoURL']) : null,
                              backgroundColor: AppColors.pastelPurple.withValues(alpha: 0.3),
                              child: (u['photoURL'] ?? '').isEmpty ? const Icon(Icons.person, size: 16) : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    Text(u['username'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                                    const SizedBox(width: 4),
                                    Text('#${u['tag']}', style: TextStyle(fontSize: 10, color: AppColors.muted)),
                                  ]),
                                  if ((u['bio'] ?? '').isNotEmpty)
                                    Text(u['bio'], maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10, color: AppColors.muted)),
                                ],
                              ),
                            ),
                            Text('${u[_tab]}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.pastelPurple)),
                          ],
                        ),
                      ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _tabButton(String label, String tab) {
    final selected = _tab == tab;
    return Expanded(
      child: GestureDetector(
        onTap: () => _sortBy(tab),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.pastelPurple : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.pastelPurple.withValues(alpha: 0.3)),
          ),
          child: Center(child: Text(label, style: TextStyle(fontSize: 12, color: selected ? Colors.white : AppColors.foreground, fontWeight: FontWeight.w500))),
        ),
      ),
    );
  }
}
