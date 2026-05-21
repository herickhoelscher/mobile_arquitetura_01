import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) context.read<AuthViewModel>().loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Consumer<AuthViewModel>(
        builder: (context, vm, _) {
          if (vm.state == AuthState.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = vm.profileUser ?? vm.currentUser;
          if (user == null) {
            return const Center(child: Text('Usuário não encontrado.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 16),
                CircleAvatar(
                  radius: 56,
                  backgroundColor: Colors.deepPurple.shade100,
                  backgroundImage: user.image.isNotEmpty
                      ? NetworkImage(user.image)
                      : null,
                  child: user.image.isEmpty
                      ? Icon(Icons.person,
                          size: 56, color: Colors.deepPurple.shade400)
                      : null,
                ),
                const SizedBox(height: 20),
                Text(
                  user.fullName,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  '@${user.username}',
                  style: TextStyle(
                      fontSize: 14, color: Colors.deepPurple.shade400),
                ),
                const SizedBox(height: 32),
                _buildInfoCard([
                  _InfoRow(
                    icon: Icons.email_outlined,
                    label: 'E-mail',
                    value: user.email,
                  ),
                  _InfoRow(
                    icon: Icons.badge_outlined,
                    label: 'Nome completo',
                    value: user.fullName,
                  ),
                  _InfoRow(
                    icon: Icons.person_outline,
                    label: 'Usuário',
                    value: user.username,
                  ),
                ]),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await context.read<AuthViewModel>().logout();
                      if (!context.mounted) return;
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                        (_) => false,
                      );
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Sair da conta'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade600,
                      side: BorderSide(color: Colors.red.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(List<_InfoRow> rows) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        children: rows
            .map(
              (row) => ListTile(
                leading: Icon(row.icon, color: Colors.deepPurple.shade400),
                title: Text(row.label,
                    style: const TextStyle(
                        fontSize: 12, color: Colors.grey)),
                subtitle: Text(row.value,
                    style: const TextStyle(
                        fontSize: 15, color: Colors.black87)),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _InfoRow {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});
}
