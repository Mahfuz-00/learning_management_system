import 'package:equatable/equatable.dart';

class StoreItemEntity extends Equatable {
  final String id;
  final String title;
  final String? description;
  final double price;
  final String? thumbnail;
  final String? author;

  const StoreItemEntity({
    required this.id,
    required this.title,
    this.description,
    required this.price,
    this.thumbnail,
    this.author,
  });

  @override
  List<Object?> get props => [id, title, description, price, thumbnail, author];
}
