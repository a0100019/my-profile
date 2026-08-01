import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants.dart';
import '../l10n/app_localizations.dart';

class NationalitySelectScreen extends StatefulWidget {
  final String uid;
  const NationalitySelectScreen({super.key, required this.uid});

  @override
  State<NationalitySelectScreen> createState() => _NationalitySelectScreenState();
}

class _NationalitySelectScreenState extends State<NationalitySelectScreen> {
  bool _saving = false;
  late final String _highlighted = _detectDefault();

  String _detectDefault() {
    final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
    if (deviceLocale.countryCode == 'JP' || deviceLocale.languageCode == 'ja') return 'JP';
    return 'KR';
  }

  Future<void> _select(String code) async {
    if (_saving) return;
    setState(() => _saving = true);
    await FirebaseFirestore.instance.collection('users').doc(widget.uid).set(
      {'nationality': code},
      SetOptions(merge: true),
    );
    // The StreamBuilder in _AuthedRouter (main.dart) picks up the change and routes onward.
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: _saving
                  ? const CircularProgressIndicator(color: AppColors.pastelPurple)
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.nationalityTitle,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.nationalitySubtitle,
                          style: TextStyle(fontSize: 13, color: AppColors.muted),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        Row(
                          children: [
                            Expanded(child: _countryCard('🇰🇷', l10n.nationalityKorea, 'KR', () => _select('KR'))),
                            const SizedBox(width: 16),
                            Expanded(child: _countryCard('🇯🇵', l10n.nationalityJapan, 'JP', () => _select('JP'))),
                          ],
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _countryCard(String flag, String label, String code, VoidCallback onTap) {
    final selected = _highlighted == code;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: selected ? AppColors.pastelPurple.withValues(alpha: 0.15) : AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppColors.pastelPurple : AppColors.pastelPurple.withValues(alpha: 0.3), width: selected ? 2 : 1),
        ),
        child: Column(
          children: [
            Text(flag, style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
