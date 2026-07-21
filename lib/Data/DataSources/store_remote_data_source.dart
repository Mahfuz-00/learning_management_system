import 'package:dio/dio.dart';
import '../Models/store_item_model.dart';
import 'dart:developer';

abstract class StoreRemoteDataSource {
  Future<List<StoreItemModel>> getStoreItems();
}

class StoreRemoteDataSourceImpl implements StoreRemoteDataSource {
  final Dio dio;

  StoreRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<StoreItemModel>> getStoreItems() async {
    log('API Request: Get store items');
    try {
      final response = await dio.get('/Store/getall'); // Assuming standard naming
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((json) => StoreItemModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load store items');
      }
    } on DioException catch (e) {
      log('API Error: Get store items failed: ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? 'Network error');
    }
  }
}
