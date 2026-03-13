import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_model.dart';
import '../../../../core/errors/app_exception.dart';

class ProductLocalDatasource {
  static const _cacheKey = 'cached_products';

  Future<void> saveProducts(List<ProductModel> products) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = products.map((p) => p.toJson()).toList();
    await prefs.setString(_cacheKey, json.encode(jsonList));
  }

  Future<List<ProductModel>> getProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_cacheKey);
    if (cached == null) throw CacheException();
    final List<dynamic> jsonList = json.decode(cached);
    return jsonList.map((e) => ProductModel.fromJson(e)).toList();
  }
}
