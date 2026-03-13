import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/product_viewmodel.dart';
import '../widgets/product_card.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        context.read<ProductViewModel>().loadProducts());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductViewModel>(
      builder: (context, vm, _) {
        final favoriteCount = vm.favoriteCount;
        final showOnlyFavorites = vm.showOnlyFavorites;

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Produtos'),
                if (favoriteCount > 0 && vm.state == ProductState.success)
                  Text(
                    '$favoriteCount ${favoriteCount == 1 ? 'favorito' : 'favoritos'}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                  ),
              ],
            ),
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            actions: [
              if (vm.state == ProductState.success)
                Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: Icon(
                        showOnlyFavorites ? Icons.star : Icons.star_border,
                        color: Colors.white,
                      ),
                      tooltip: showOnlyFavorites ? 'Mostrar todos' : 'Mostrar favoritos',
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
                          constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
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
            ],
          ),
          body: _buildBody(vm, showOnlyFavorites),
          floatingActionButton: (vm.state == ProductState.success && favoriteCount > 0)
              ? FloatingActionButton.extended(
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
                itemBuilder: (_, index) => ProductCard(product: products[index]),
              ),
            ),
          ],
        );
    }
  }
}
