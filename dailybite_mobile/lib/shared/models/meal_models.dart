class Meal {
  final int id;
  final String foodName;
  final int calories;
  final String? photoUrl;
  final String? notes;
  final DateTime createdAt;
  final String status;

  Meal({
    required this.id,
    required this.foodName,
    required this.calories,
    this.photoUrl,
    this.notes,
    required this.createdAt,
    required this.status,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'],
      foodName: json['food_name'],
      calories: json['calories'],
      photoUrl: json['photo_url'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'food_name': foodName,
      'calories': calories,
      'photo_url': photoUrl,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'status': status,
    };
  }

  Meal copyWith({
    int? id,
    String? foodName,
    int? calories,
    String? photoUrl,
    String? notes,
    DateTime? createdAt,
    String? status,
  }) {
    return Meal(
      id: id ?? this.id,
      foodName: foodName ?? this.foodName,
      calories: calories ?? this.calories,
      photoUrl: photoUrl ?? this.photoUrl,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }
}

class DailySummary {
  final DateTime date;
  final int totalCalories;
  final int mealCount;
  final double dailyCalorieGoal;
  final double progress;

  DailySummary({
    required this.date,
    required this.totalCalories,
    required this.mealCount,
    required this.dailyCalorieGoal,
    required this.progress,
  });

  factory DailySummary.fromJson(Map<String, dynamic> json) {
    return DailySummary(
      date: DateTime.parse(json['date']),
      totalCalories: json['total_calories'],
      mealCount: json['meal_count'],
      dailyCalorieGoal: json['daily_calorie_goal'].toDouble(),
      progress: json['progress'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String().split('T')[0],
      'total_calories': totalCalories,
      'meal_count': mealCount,
      'daily_calorie_goal': dailyCalorieGoal,
      'progress': progress,
    };
  }

  bool get isGoalReached => progress >= 1.0;
  int get remainingCalories => (dailyCalorieGoal - totalCalories).round();
}

class MealAnalysisResult {
  final String foodName;
  final int estimatedCalories;
  final double confidence;
  final List<String> detectedIngredients;

  MealAnalysisResult({
    required this.foodName,
    required this.estimatedCalories,
    required this.confidence,
    required this.detectedIngredients,
  });

  factory MealAnalysisResult.fromJson(Map<String, dynamic> json) {
    return MealAnalysisResult(
      foodName: json['food_name'],
      estimatedCalories: json['estimated_calories'],
      confidence: json['confidence'].toDouble(),
      detectedIngredients: List<String>.from(json['detected_ingredients'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'food_name': foodName,
      'estimated_calories': estimatedCalories,
      'confidence': confidence,
      'detected_ingredients': detectedIngredients,
    };
  }
}
