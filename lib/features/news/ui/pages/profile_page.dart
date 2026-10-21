import 'package:flutter/material.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/service/secure_storage_service.dart';
import '../../../auth/ui/pages/login_page.dart';
import 'animations_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: const Text(
          'Вы уверены?',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Нет', style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Да',
              style: TextStyle(
                  color: Colors.black, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );

    if (yes != true) return;

    await sl<SecureStorageService>().deleteAll();

    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9E9E9),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 56),
                const Text(
                  'Preferences',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 32),
                const _PrefRow(title: 'ACCOUNT'),
                const _PrefRow(title: 'SETTINGS'),
                _PrefRow(
                  title: 'ANIMATIONS',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AnimationsPage()),
                    );
                  },
                ),
                const _PrefRow(title: 'ORDERS PREFERENCES'),
                _PrefRow(
                  title: 'LOGOUT',
                  showArrow: false,
                  onTap: () => _confirmLogout(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PrefRow extends StatelessWidget {
  final String title;
  final bool showArrow;
  final VoidCallback? onTap;

  const _PrefRow({required this.title, this.showArrow = true, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? () {},
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.grey.shade300, width: 0.8),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            if (showArrow)
              Icon(Icons.chevron_right, size: 18, color: Colors.grey.shade600),
          ],
        ),
      ),
    );
  }
}