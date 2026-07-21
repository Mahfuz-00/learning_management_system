import 'package:dartz/dartz.dart';
import '../../Core/Error/failures.dart';
import '../Entities/store_item_entity.dart';

abstract class StoreRepository {
  Future<Either<Failure, List<StoreItemEntity>>> getStoreItems();
}
