import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/product_viewmodel.dart';
import '../widgets/product_card.dart';
import 'product_detail_page.dart';
import 'product_form_page.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../auth/presentation/pages/profile_page.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) context.read<ProductViewModel>().loadProducts();
    });
  }

  Future<void> _logout(BuildContext context) async {
    await context.read<AuthViewModel>().logout();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ProductViewModel, AuthViewModel>(
      builder: (context, vm, authVm, _) {
        final favoriteCount = vm.favoriteCount;
        final showOnlyFavorites = vm.showOnlyFavorites;
        final user = authVm.currentUser;

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Produtos'),
                if (user != null)
                  Text(
                    'Olá, ${user.firstName}',
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w400),
                  ),
              ],
            ),
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Atualizar lista',
                onPressed: vm.loadProducts,
              ),
              if (vm.state == ProductState.success)
                Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: Icon(
                        showOnlyFavorites ? Icons.star : Icons.star_border,
                        color: Colors.white,
                      ),
                      tooltip: showOnlyFavorites
                          ? 'Mostrar todos'
                          : 'Mostrar favoritos',
                      onPressed: vm.toggleFilter,
                    ),
                    if (favoriteCount > 0)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.amber,
                            shape: BoxShape.circle,
                          ),
                          constraints:
                              const BoxConstraints(minWidth: 16, minHeight: 16),
                          child: Text(
                            '$favoriteCount',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              if (user != null)
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfilePage()),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.deepPurple.shade200,
                      backgroundImage: user.image.isNotEmpty
                          ? NetworkImage(user.image)
                          : null,
                      child: user.image.isEmpty
                          ? const Icon(Icons.person,
                              size: 18, color: Colors.white)
                          : null,
                    ),
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Sair',
                onPressed: () => _logout(context),
              ),
            ],
          ),
          body: _buildBody(vm, showOnlyFavorites),
          floatingActionButton: vm.state == ProductState.success
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (favoriteCount > 0) ...[
                      FloatingActionButton.extended(
                        heroTag: 'fab_favorites',
                        onPressed: () {
                          if (!showOnlyFavorites) vm.toggleFilter();
                        },
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                        icon: const Icon(Icons.star),
                        label: Text(
                          '$favoriteCount ${favoriteCount == 1 ? 'favorito' : 'favoritos'}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    FloatingActionButton(
                      heroTag: 'fab_add',
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ProductFormPage()),
                      ),
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      tooltip: 'Adicionar produto',
                      child: const Icon(Icons.add),
                    ),
                  ],
                )
              : null,
        );
      },
    );
  }

  Widget _buildBody(ProductViewModel vm, bool showOnlyFavorites) {
    switch (vm.state) {
      case ProductState.loading:
      case ProductState.initial:
        return const Center(child: CircularProgressIndicator());

      case ProductState.error:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text(vm.errorMessage),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: vm.loadProducts,
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        );

      case ProductState.success:
        final products = vm.products;
        if (products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 12),
                const Text('Nenhum favorito ainda', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: vm.toggleFilter,
                  child: const Text('Ver todos os produtos'),
                ),
              ],
            ),
          );
        }
        return Column(
          children: [
            if (showOnlyFavorites)
              Container(
                width: double.infinity,
                color: Colors.amber.shade50,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.filter_list, size: 16, color: Colors.deepPurple),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text('Exibindo apenas favoritos',
                          style: TextStyle(fontSize: 13, color: Colors.deepPurple)),
                    ),
                    GestureDetector(
                      onTap: vm.toggleFilter,
                      child: const Text('Ver todos',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.bold,
                          )),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: products.length,
                itemBuilder: (_, index) => ProductCard(
                  product: products[index],
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ProductDetailPage(productId: products[index].id),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
    }
  }
}
