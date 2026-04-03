import 'package:flutter/foundation.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../../../../core/errors/app_exception.dart';

enum ProductState { initial, loading, success, error }

class ProductViewModel extends ChangeNotifier {
  final ProductRepository repository;

  ProductViewModel({required this.repository});

  ProductState _state = ProductState.initial;
  List<Product> _products = [];
  String _errorMessage = '';
  bool _showOnlyFavorites = false;
  bool _isSubmitting = false;

  ProductState get state => _state;
  List<Product> get products =>
      _showOnlyFavorites ? _products.where((p) => p.favorite).toList() : List.unmodifiable(_products);
  List<Product> get allProducts => List.unmodifiable(_products);
  String get errorMessage => _errorMessage;
  int get favoriteCount => _products.where((p) => p.favorite).length;
  bool get showOnlyFavorites => _showOnlyFavorites;
  bool get isSubmitting => _isSubmitting;

  void toggleFavorite(Product product) {
    product.favorite = !product.favorite;
    notifyListeners();
  }

  void toggleFilter() {
    _showOnlyFavorites = !_showOnlyFavorites;
    notifyListeners();
  }

  Future<void> loadProducts() async {
    _state = ProductState.loading;
    notifyListeners();

    try {
      _products = await repository.getProducts();
      _state = ProductState.success;
    } on CacheException {
      _errorMessage = 'Sem conexão e nenhum dado em cache disponível.';
      _state = ProductState.error;
    } on NetworkException {
      _errorMessage = 'Sem conexão com a internet. Tente novamente.';
      _state = ProductState.error;
    } on AppException catch (e) {
      _errorMessage = e.message;
      _state = ProductState.error;
    } catch (_) {
      _errorMessage = 'Erro inesperado. Tente novamente.';
      _state = ProductState.error;
    }

    notifyListeners();
  }

  Future<bool> addProduct({
    required String title,
    required double price,
    required String category,
    required String description,
    required String image,
  }) async {
    _isSubmitting = true;
    notifyListeners();
    try {
      final product = Product(
        id: 0,
        title: title,
        price: price,
        category: category,
        description: description,
        image: image,
      );
      final created = await repository.addProduct(product);
      _products.add(created);
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (_) {
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProduct(Product product) async {
    _isSubmitting = true;
    notifyListeners();
    try {
      final updated = await repository.updateProduct(product);
      final index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) _products[index] = updated;
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (_) {
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProduct(int id) async {
    _isSubmitting = true;
    notifyListeners();
    try {
      await repository.deleteProduct(id);
      _products.removeWhere((p) => p.id == id);
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (_) {
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }
}
