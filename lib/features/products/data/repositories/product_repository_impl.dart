import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';
import '../datasources/product_local_datasource.dart';
import '../../../../core/errors/app_exception.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDatasource remoteDatasource;
  final ProductLocalDatasource localDatasource;

  ProductRepositoryImpl({
    required this.remoteDatasource,
    required this.localDatasource,
  });

  @override
  Future<List<Product>> getProducts() async {
    try {
      // Tenta buscar da API primeiro
      final products = await remoteDatasource.fetchProducts();
      // Se deu certo, salva no cache para uso offline
      await localDatasource.saveProducts(products);
      return products;
    } on AppException {
      // Se a API falhou, tenta retornar o cache
      try {
        return await localDatasource.getProducts();
      } on CacheException {
        // Se não tem cache, relança o erro original
        rethrow;
      }
    }
  }
}
