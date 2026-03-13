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

  ProductState get state => _state;
  List<Product> get products => _products;
  String get errorMessage => _errorMessage;

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
}
