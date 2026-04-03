class Product {
  final int id;
  final String title;
  final double price;
  final String image;
  final String category;
  final String description;
  bool favorite; // estado local, não vem da API

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.image,
    required this.category,
    required this.description,
    this.favorite = false,
  });
}
