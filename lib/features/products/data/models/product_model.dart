import '../../domain/entities/product.dart';

class ProductModel extends Product {
  ProductModel({
    required super.id,
    required super.title,
    required super.price,
    required super.image,
    required super.category,
    required super.description,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // DummyJSON usa 'thumbnail'; suporte legado a 'image' para cache antigo
    final image = (json['thumbnail'] ?? json['image']) as String? ?? '';
    return ProductModel(
      id: json['id'] as int,
      title: json['title'] as String,
      price: (json['price'] as num).toDouble(),
      image: image,
      category: json['category'] as String,
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'thumbnail': image,
      'category': category,
      'description': description,
    };
  }
}
