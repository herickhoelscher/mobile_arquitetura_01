import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';
import '../datasources/product_local_datasource.dart';
import '../models/product_model.dart';
import '../../../../core/errors/app_exception.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDatasource remoteDatasource;
  final ProductLocalDatasource localDatasource;

  // Mirror da lista local para calcular IDs e manter cache sincronizado
  List<ProductModel> _localProducts = [];

  ProductRepositoryImpl({
    required this.remoteDatasource,
    required this.localDatasource,
  });

  @override
  Future<List<Product>> getProducts() async {
    try {
      final products = await remoteDatasource.fetchProducts();
      _localProducts = List.of(products);
      await localDatasource.saveProducts(products);
      return products;
    } on AppException {
      try {
        final cached = await localDatasource.getProducts();
        _localProducts = List.of(cached);
        return cached;
      } on CacheException {
        rethrow;
      }
    }
  }

  @override
  Future<Product> addProduct(Product product) async {
    final model = ProductModel(
      id: product.id,
      title: product.title,
      price: product.price,
      image: product.image,
      category: product.category,
      description: product.description,
    );

    // FakeStore API sempre retorna id=21; geramos um ID local válido
    await remoteDatasource.createProduct(model);

    final newId = _localProducts.isEmpty
        ? 1
        : _localProducts.map((p) => p.id).reduce((a, b) => a > b ? a : b) + 1;

    final newProduct = ProductModel(
      id: newId,
      title: product.title,
      price: product.price,
      image: product.image,
      category: product.category,
      description: product.description,
    );

    _localProducts.add(newProduct);
    await localDatasource.saveProducts(_localProducts);
    return newProduct;
  }

  @override
  Future<Product> updateProduct(Product product) async {
    final model = ProductModel(
      id: product.id,
      title: product.title,
      price: product.price,
      image: product.image,
      category: product.category,
      description: product.description,
    );

    await remoteDatasource.updateProduct(model);

    final index = _localProducts.indexWhere((p) => p.id == product.id);
    if (index != -1) _localProducts[index] = model;
    await localDatasource.saveProducts(_localProducts);
    return product;
  }

  @override
  Future<void> deleteProduct(int id) async {
    await remoteDatasource.deleteProduct(id);
    _localProducts.removeWhere((p) => p.id == id);
    await localDatasource.saveProducts(_localProducts);
  }
}
