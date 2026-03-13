class Product {
  final int id;
  final String title;
  final double price;
  final String image;
  final String category;
  bool favorite; // estado local, não vem da API

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.image,
    required this.category,
    this.favorite = false,
  });
}
