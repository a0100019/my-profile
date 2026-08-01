import 'package:flutter/material.dart';
import '../constants.dart';
import '../l10n/app_localizations.dart';

// 나중에 실제 굿즈 판매 기능(상품 목록, 상세, 장바구니, 결제 등)이 들어갈 자리.
// 지금은 진입 지점과 "준비 중" 화면만 마련해둠.
class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Text(l10n.dashboardStore, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🛍️', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 16),
                      Text(
                        l10n.storeComingSoonTitle,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.storeComingSoonSubtitle,
                        style: TextStyle(fontSize: 13, color: AppColors.muted),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
