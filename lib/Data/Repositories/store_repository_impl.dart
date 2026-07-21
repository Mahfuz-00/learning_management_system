import 'package:dartz/dartz.dart';
import '../../Core/Error/failures.dart';
import '../../Domain/Entities/store_item_entity.dart';
import '../../Domain/Repositories/store_repository.dart';
import '../DataSources/store_remote_data_source.dart';
import 'dart:developer';

class StoreRepositoryImpl implements StoreRepository {
  final StoreRemoteDataSource remoteDataSource;

  StoreRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<StoreItemEntity>>> getStoreItems() async {
    log('Repo: Fetching store items');
    try {
      final items = await remoteDataSource.getStoreItems();
      return Right(items);
    } catch (e) {
      log('Repo Error: Store fetch failed: $e');
      return Left(ServerFailure(e.toString()));
    }
  }
}
