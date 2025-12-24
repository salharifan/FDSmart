class MenuItemModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category; // 'food' or 'drink'
  final bool isAvailable;
  final double rating;
  final double calories;

  final bool isSpecial;
  final String tag; // e.g. 'healthy', 'new', etc.

  MenuItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.isAvailable = true,
    this.rating = 4.5,
    this.calories = 200.0,
    this.isSpecial = false,
    this.tag = '',
  });

  factory MenuItemModel.fromMap(Map<String, dynamic> data, String id) {
    return MenuItemModel(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      category: data['category'] ?? 'food',
      isAvailable: data['isAvailable'] ?? true,
      rating: (data['rating'] ?? 4.5).toDouble(),
      calories: (data['calories'] ?? 200.0).toDouble(),
      isSpecial: data['isSpecial'] ?? false,
      tag: data['tag'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'isAvailable': isAvailable,
      'rating': rating,
      'calories': calories,
      'isSpecial': isSpecial,
      'tag': tag,
    };
  }
}
