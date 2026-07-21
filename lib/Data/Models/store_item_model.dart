import '../../Domain/Entities/store_item_entity.dart';

class StoreItemModel extends StoreItemEntity {
  const StoreItemModel({
    required super.id,
    required super.title,
    super.description,
    required super.price,
    super.thumbnail,
    super.author,
  });

  factory StoreItemModel.fromJson(Map<String, dynamic> json) {
    return StoreItemModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      price: (json['price'] ?? 0).toDouble(),
      thumbnail: json['thumbnail'] ?? json['image'],
      author: json['author'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'thumbnail': thumbnail,
      'author': author,
    };
  }
}
