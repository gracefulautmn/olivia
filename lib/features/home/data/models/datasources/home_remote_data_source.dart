import 'package:olivia/core/errors/exceptions.dart';
import 'package:olivia/core/utils/constants.dart';
import 'package:olivia/features/home/data/models/category_model.dart';
import 'package:olivia/features/home/data/models/item_preview_model.dart';
import 'package:olivia/features/home/data/models/location_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class HomeRemoteDataSource {
  Future<List<CategoryModel>> getCategories();
  Future<List<LocationModel>> getLocations();
  Future<List<ItemPreviewModel>> getRecentFoundItems(int limit);
  Future<List<ItemPreviewModel>> getRecentLostItems(int limit);
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final SupabaseClient supabaseClient;

  HomeRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await supabaseClient
          .from('categories')
          .select()
          .order('name', ascending: true); // Urutkan berdasarkan nama

      return response
          .map((categoryJson) => CategoryModel.fromJson(categoryJson))
          .toList();
    } catch (e) {
      print('Error fetching categories: $e');
      throw ServerException(
        message: "Failed to fetch categories: ${e.toString()}",
      );
    }
  }

  @override
  Future<List<LocationModel>> getLocations() async {
    try {
      final response = await supabaseClient
          .from('locations')
          .select()
          .order('name', ascending: true);

      return response
          .map((locationJson) => LocationModel.fromJson(locationJson))
          .toList();
    } catch (e) {
      print('Error fetching locations: $e');
      throw ServerException(
        message: "Failed to fetch locations: ${e.toString()}",
      );
    }
  }

  @override
  Future<List<ItemPreviewModel>> getRecentFoundItems(int limit) async {
    try {
      final response = await supabaseClient
          .from('items')
          .select(
            'id, item_name, image_url, report_type, categories ( name ), locations ( name )',
          ) // Join
          .eq('report_type', AppConstants.reportTypeFound)
          .eq(
            'status',
            AppConstants.itemStatusFoundAvailable,
          ) // Hanya yang masih tersedia
          .order('reported_at', ascending: false)
          .limit(limit);

      return response
          .map((itemJson) => ItemPreviewModel.fromJson(itemJson))
          .toList();
    } catch (e) {
      print('Error fetching recent found items: $e');
      throw ServerException(
        message: "Failed to fetch recent found items: ${e.toString()}",
      );
    }
  }

  @override
  Future<List<ItemPreviewModel>> getRecentLostItems(int limit) async {
    try {
      final response = await supabaseClient
          .from('items')
          .select(
            'id, item_name, image_url, report_type, categories ( name ), locations ( name )',
          ) // Join
          .eq('report_type', AppConstants.reportTypeLoss)
          .eq('status', AppConstants.itemStatusLost) // Hanya yang masih hilang
          .order('reported_at', ascending: false)
          .limit(limit);

      return response
          .map((itemJson) => ItemPreviewModel.fromJson(itemJson))
          .toList();
    } catch (e) {
      print('Error fetching recent lost items: $e');
      throw ServerException(
        message: "Failed to fetch recent lost items: ${e.toString()}",
      );
    }
  }
}
