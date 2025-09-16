import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_service.dart';
import '../../shared/models/meal_models.dart';

class MealService {
  final ApiService _apiService = ApiService.instance;

  // Upload and analyze meal photo
  Future<Meal> analyzeMealPhoto(File imageFile) async {
    try {
      final response = await _apiService.uploadFile(
        '/meals/analyze-photo',
        imageFile.path,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Meal.fromJson(response.data);
      } else {
        throw Exception('Failed to analyze photo: ${response.data['detail'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception(e.response?.data['detail'] ?? 'Invalid image file');
      }
      if (e.response?.statusCode == 413) {
        throw Exception('Image file is too large. Please select a smaller image.');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to analyze photo: $e');
    }
  }

  // Get user's meals for a specific date
  Future<List<Meal>> getMealsForDate(DateTime date) async {
    try {
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final response = await _apiService.get('/meals/', queryParameters: {'date': dateStr});
      
      final List<dynamic> mealsData = response.data;
      return mealsData.map((meal) => Meal.fromJson(meal)).toList();
    } on DioException catch (e) {
      throw Exception('Failed to fetch meals: ${e.message}');
    }
  }

  // Get meals for current user (all meals)
  Future<List<Meal>> getAllMeals({int? skip, int? limit}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (skip != null) queryParams['skip'] = skip;
      if (limit != null) queryParams['limit'] = limit;

      final response = await _apiService.get('/meals/', queryParameters: queryParams);
      
      final List<dynamic> mealsData = response.data;
      return mealsData.map((meal) => Meal.fromJson(meal)).toList();
    } on DioException catch (e) {
      throw Exception('Failed to fetch meals: ${e.message}');
    }
  }

  // Get daily summary for a specific date
  Future<DailySummary> getDailySummary(DateTime date) async {
    try {
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final response = await _apiService.get('/meals/daily-summary/$dateStr');
      
      return DailySummary.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to fetch daily summary: ${e.message}');
    }
  }

  // Update meal details
  Future<Meal> updateMeal(int mealId, {
    String? foodName,
    int? calories,
    String? notes,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (foodName != null) data['food_name'] = foodName;
      if (calories != null) data['calories'] = calories;
      if (notes != null) data['notes'] = notes;

      final response = await _apiService.put('/meals/$mealId', data: data);
      return Meal.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Meal not found');
      }
      throw Exception('Failed to update meal: ${e.response?.data['detail'] ?? e.message}');
    }
  }

  // Delete a meal
  Future<void> deleteMeal(int mealId) async {
    try {
      await _apiService.delete('/meals/$mealId');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Meal not found');
      }
      throw Exception('Failed to delete meal: ${e.response?.data['detail'] ?? e.message}');
    }
  }

  // Get meal by ID
  Future<Meal> getMealById(int mealId) async {
    try {
      final response = await _apiService.get('/meals/$mealId');
      return Meal.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Meal not found');
      }
      throw Exception('Failed to fetch meal: ${e.message}');
    }
  }

  // Get weekly summary
  Future<Map<String, DailySummary>> getWeeklySummary(DateTime startDate) async {
    try {
      final startDateStr = '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
      final response = await _apiService.get('/meals/weekly-summary', queryParameters: {'start_date': startDateStr});
      
      final Map<String, dynamic> weeklyData = response.data;
      final Map<String, DailySummary> weeklySummary = {};
      
      weeklyData.forEach((date, summaryData) {
        weeklySummary[date] = DailySummary.fromJson(summaryData);
      });
      
      return weeklySummary;
    } on DioException catch (e) {
      throw Exception('Failed to fetch weekly summary: ${e.message}');
    }
  }
}

// Riverpod provider for MealService
final mealServiceProvider = Provider<MealService>((ref) {
  return MealService();
});
