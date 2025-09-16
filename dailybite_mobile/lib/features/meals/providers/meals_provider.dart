import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/meal_service.dart';
import '../../../shared/models/meal_models.dart';

// Meals state
class MealsState {
  final List<Meal> meals;
  final bool isLoading;
  final String? error;
  final DailySummary? dailySummary;

  const MealsState({
    this.meals = const [],
    this.isLoading = false,
    this.error,
    this.dailySummary,
  });

  MealsState copyWith({
    List<Meal>? meals,
    bool? isLoading,
    String? error,
    DailySummary? dailySummary,
  }) {
    return MealsState(
      meals: meals ?? this.meals,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      dailySummary: dailySummary ?? this.dailySummary,
    );
  }
}

// Meals provider
class MealsNotifier extends StateNotifier<MealsState> {
  final MealService _mealService;

  MealsNotifier(this._mealService) : super(const MealsState());

  // Load meals for a specific date
  Future<void> loadMealsForDate(DateTime date) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final meals = await _mealService.getMealsForDate(date);
      final dailySummary = await _mealService.getDailySummary(date);

      state = state.copyWith(
        meals: meals,
        dailySummary: dailySummary,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  // Analyze meal photo
  Future<Meal?> analyzeMealPhoto(File imageFile) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final meal = await _mealService.analyzeMealPhoto(imageFile);
      
      // Add the new meal to the current list
      final updatedMeals = [meal, ...state.meals];
      
      // Recalculate daily summary for today
      final today = DateTime.now();
      final todaysMeals = updatedMeals.where((m) => 
        m.createdAt.year == today.year &&
        m.createdAt.month == today.month &&
        m.createdAt.day == today.day
      ).toList();
      
      final totalCalories = todaysMeals.fold<int>(0, (sum, meal) => sum + meal.calories);
      
      // Update state with new meal and recalculated summary
      state = state.copyWith(
        meals: updatedMeals,
        isLoading: false,
      );

      // Refresh daily summary
      await loadDailySummary(today);

      return meal;
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      return null;
    }
  }

  // Load daily summary only
  Future<void> loadDailySummary(DateTime date) async {
    try {
      final dailySummary = await _mealService.getDailySummary(date);
      state = state.copyWith(dailySummary: dailySummary);
    } catch (e) {
      // Don't update error state for summary-only failures
    }
  }

  // Update meal
  Future<void> updateMeal(int mealId, {
    String? foodName,
    int? calories,
    String? notes,
  }) async {
    try {
      final updatedMeal = await _mealService.updateMeal(
        mealId,
        foodName: foodName,
        calories: calories,
        notes: notes,
      );

      // Update the meal in the current list
      final updatedMeals = state.meals.map((meal) {
        if (meal.id == mealId) {
          return updatedMeal;
        }
        return meal;
      }).toList();

      state = state.copyWith(meals: updatedMeals);

      // Refresh daily summary
      final today = DateTime.now();
      await loadDailySummary(today);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Delete meal
  Future<void> deleteMeal(int mealId) async {
    try {
      await _mealService.deleteMeal(mealId);

      // Remove the meal from the current list
      final updatedMeals = state.meals.where((meal) => meal.id != mealId).toList();
      state = state.copyWith(meals: updatedMeals);

      // Refresh daily summary
      final today = DateTime.now();
      await loadDailySummary(today);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Load all meals (for history view)
  Future<void> loadAllMeals({int? skip, int? limit}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final meals = await _mealService.getAllMeals(skip: skip, limit: limit);
      state = state.copyWith(
        meals: meals,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Refresh data
  Future<void> refresh() async {
    final today = DateTime.now();
    await loadMealsForDate(today);
  }
}

// Photo analysis state for upload flow
class PhotoAnalysisState {
  final bool isAnalyzing;
  final MealAnalysisResult? result;
  final String? error;
  final File? selectedImage;

  const PhotoAnalysisState({
    this.isAnalyzing = false,
    this.result,
    this.error,
    this.selectedImage,
  });

  PhotoAnalysisState copyWith({
    bool? isAnalyzing,
    MealAnalysisResult? result,
    String? error,
    File? selectedImage,
  }) {
    return PhotoAnalysisState(
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      result: result,
      error: error,
      selectedImage: selectedImage ?? this.selectedImage,
    );
  }
}

// Photo analysis provider
class PhotoAnalysisNotifier extends StateNotifier<PhotoAnalysisState> {
  PhotoAnalysisNotifier() : super(const PhotoAnalysisState());

  void setSelectedImage(File image) {
    state = state.copyWith(selectedImage: image);
  }

  void clearSelection() {
    state = const PhotoAnalysisState();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Providers
final mealsProvider = StateNotifierProvider<MealsNotifier, MealsState>((ref) {
  final mealService = ref.read(mealServiceProvider);
  return MealsNotifier(mealService);
});

final photoAnalysisProvider = StateNotifierProvider<PhotoAnalysisNotifier, PhotoAnalysisState>((ref) {
  return PhotoAnalysisNotifier();
});

// Convenience providers
final todayMealsProvider = Provider<List<Meal>>((ref) {
  final meals = ref.watch(mealsProvider).meals;
  final today = DateTime.now();
  
  return meals.where((meal) => 
    meal.createdAt.year == today.year &&
    meal.createdAt.month == today.month &&
    meal.createdAt.day == today.day
  ).toList();
});

final dailySummaryProvider = Provider<DailySummary?>((ref) {
  return ref.watch(mealsProvider).dailySummary;
});

final mealsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(mealsProvider).isLoading;
});

final mealsErrorProvider = Provider<String?>((ref) {
  return ref.watch(mealsProvider).error;
});
