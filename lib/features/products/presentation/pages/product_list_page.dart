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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtos'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Consumer<ProductViewModel>(
        builder: (context, vm, _) {
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
              return ListView.builder(
                itemCount: vm.products.length,
                itemBuilder: (_, index) =>
                    ProductCard(product: vm.products[index]),
              );
          }
        },
      ),
    );
  }
}
