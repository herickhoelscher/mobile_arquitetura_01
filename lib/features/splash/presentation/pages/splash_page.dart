import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/session/session_manager.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../products/presentation/pages/product_list_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    final session = context.read<SessionManager>();
    final hasSession = await session.loadSession();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            hasSession ? const ProductListPage() : const LoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 80,
              color: Colors.deepPurple.shade400,
            ),
            const SizedBox(height: 20),
            Text(
              'DummyStore',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple.shade700,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 40),
            CircularProgressIndicator(
              color: Colors.deepPurple.shade400,
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}
