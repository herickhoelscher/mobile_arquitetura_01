import 'dart:convert';
import '../../../../core/network/http_client.dart';
import '../models/product_model.dart';

class ProductRemoteDatasource {
  final AppHttpClient httpClient;
  static const _baseUrl = 'https://dummyjson.com';

  ProductRemoteDatasource({required this.httpClient});

  Future<List<ProductModel>> fetchProducts() async {
    final response = await httpClient.get('$_baseUrl/products?limit=30');
    final decoded = json.decode(response.body) as Map<String, dynamic>;
    final List<dynamic> jsonList = decoded['products'] as List<dynamic>;
    return jsonList.map((e) => ProductModel.fromJson(e)).toList();
  }

  Future<ProductModel> fetchProductById(int id) async {
    final response = await httpClient.get('$_baseUrl/products/$id');
    return ProductModel.fromJson(
        json.decode(response.body) as Map<String, dynamic>);
  }

  Future<ProductModel> createProduct(ProductModel product) async {
    final response =
        await httpClient.post('$_baseUrl/products/add', product.toJson());
    return ProductModel.fromJson(
        json.decode(response.body) as Map<String, dynamic>);
  }

  Future<ProductModel> updateProduct(ProductModel product) async {
    final response = await httpClient.put(
        '$_baseUrl/products/${product.id}', product.toJson());
    return ProductModel.fromJson(
        json.decode(response.body) as Map<String, dynamic>);
  }

  Future<void> deleteProduct(int id) async {
    await httpClient.delete('$_baseUrl/products/$id');
  }
}
