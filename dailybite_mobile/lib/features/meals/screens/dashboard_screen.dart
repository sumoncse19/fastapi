import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/meal_models.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/meals_provider.dart';
import 'camera_screen.dart';
import '../widgets/daily_summary_card.dart';
import '../widgets/meal_list_item.dart';
import '../widgets/empty_meals_widget.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load today's meals when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final today = DateTime.now();
      ref.read(mealsProvider.notifier).loadMealsForDate(today);
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final todayMeals = ref.watch(todayMealsProvider);
    final dailySummary = ref.watch(dailySummaryProvider);
    final isLoading = ref.watch(mealsLoadingProvider);
    final error = ref.watch(mealsErrorProvider);

    // Listen to meal errors
    ref.listen<String?>(mealsErrorProvider, (previous, next) {
      if (next != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        ref.read(mealsProvider.notifier).clearError();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Hi, ${user?.username ?? 'User'}!'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(mealsProvider.notifier).refresh();
        },
        child: CustomScrollView(
          slivers: [
            // Daily summary card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: dailySummary != null
                    ? DailySummaryCard(summary: dailySummary!)
                    : const SizedBox.shrink(),
              ),
            ),

            // Meals section header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Today\'s Meals',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        // Navigate to meal history
                      },
                      icon: const Icon(Icons.history),
                      label: const Text('History'),
                    ),
                  ],
                ),
              ),
            ),

            // Loading indicator
            if (isLoading && todayMeals.isEmpty)
              const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),

            // Empty state
            if (!isLoading && todayMeals.isEmpty)
              const SliverToBoxAdapter(
                child: EmptyMealsWidget(),
              ),

            // Meals list
            if (todayMeals.isNotEmpty)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final meal = todayMeals[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 4.0,
                      ),
                      child: MealListItem(
                        meal: meal,
                        onTap: () {
                          _showMealDetailsDialog(context, meal);
                        },
                        onEdit: () {
                          _showEditMealDialog(context, meal);
                        },
                        onDelete: () {
                          _showDeleteMealDialog(context, meal);
                        },
                      ),
                    );
                  },
                  childCount: todayMeals.length,
                ),
              ),

            // Add some bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const CameraScreen(),
            ),
          );
        },
        icon: const Icon(Icons.camera_alt),
        label: const Text('Add Meal'),
      ),
    );
  }

  void _showMealDetailsDialog(BuildContext context, Meal meal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(meal.foodName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Calories: ${meal.calories}'),
            const SizedBox(height: 8),
            Text('Time: ${_formatTime(meal.createdAt)}'),
            if (meal.notes != null && meal.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Notes: ${meal.notes}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showEditMealDialog(BuildContext context, Meal meal) {
    final foodNameController = TextEditingController(text: meal.foodName);
    final caloriesController = TextEditingController(text: meal.calories.toString());
    final notesController = TextEditingController(text: meal.notes ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Meal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: foodNameController,
              decoration: const InputDecoration(
                labelText: 'Food Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: caloriesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Calories',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final calories = int.tryParse(caloriesController.text);
              if (calories != null && foodNameController.text.isNotEmpty) {
                await ref.read(mealsProvider.notifier).updateMeal(
                  meal.id,
                  foodName: foodNameController.text,
                  calories: calories,
                  notes: notesController.text.isEmpty ? null : notesController.text,
                );
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteMealDialog(BuildContext context, Meal meal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Meal'),
        content: Text('Are you sure you want to delete "${meal.foodName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              await ref.read(mealsProvider.notifier).deleteMeal(meal.id);
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
