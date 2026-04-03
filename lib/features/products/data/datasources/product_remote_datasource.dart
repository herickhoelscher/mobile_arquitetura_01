import 'dart:convert';
import '../../../../core/network/http_client.dart';
import '../models/product_model.dart';

class ProductRemoteDatasource {
  final AppHttpClient httpClient;
  static const _url = 'https://fakestoreapi.com/products';

  ProductRemoteDatasource({required this.httpClient});

  Future<List<ProductModel>> fetchProducts() async {
    final response = await httpClient.get(_url);
    final List<dynamic> jsonList = json.decode(response.body);
    return jsonList.map((e) => ProductModel.fromJson(e)).toList();
  }

  Future<ProductModel> createProduct(ProductModel product) async {
    final response = await httpClient.post(_url, product.toJson());
    return ProductModel.fromJson(json.decode(response.body) as Map<String, dynamic>);
  }

  Future<ProductModel> updateProduct(ProductModel product) async {
    final response = await httpClient.put('$_url/${product.id}', product.toJson());
    return ProductModel.fromJson(json.decode(response.body) as Map<String, dynamic>);
  }

  Future<void> deleteProduct(int id) async {
    await httpClient.delete('$_url/$id');
  }
}
