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
}
