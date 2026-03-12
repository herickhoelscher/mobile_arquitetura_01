import 'package:flutter/foundation.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';

enum ProductState { initial, loading, success, error }

class ProductViewModel extends ChangeNotifier {
  final ProductRepository repository;

  ProductViewModel({required this.repository});

  ProductState _state = ProductState.initial;
  List<Product> _products = [];
  String _errorMessage = '';

  ProductState get state => _state;
  List<Product> get products => _products;
  String get errorMessage => _errorMessage;

  Future<void> loadProducts() async {
    _state = ProductState.loading;
    notifyListeners();

    try {
      _products = await repository.getProducts();
      _state = ProductState.success;
    } catch (e) {
      _errorMessage = 'Não foi possível carregar os produtos.';
      _state = ProductState.error;
    }

    notifyListeners();
  }
}
