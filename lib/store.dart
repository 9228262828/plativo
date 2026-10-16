import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

class PlativoStore extends ChangeNotifier {
  static const _mealsKey = 'plativo_meals_v1';
  static const _plansKey = 'plativo_plans_v1';
  static const _shoppingKey = 'plativo_shopping_v1';
  static const _darkKey = 'plativo_dark_v1';

  final List<MealTemplate> _meals = [];
  final List<MealPlanEntry> _plans = [];
  final List<ShoppingItem> _shopping = [];

  bool ready = false;
  bool darkMode = false;

  List<MealTemplate> get meals => List.unmodifiable(_meals);
  List<MealPlanEntry> get plans => List.unmodifiable(_plans);
  List<ShoppingItem> get shopping => List.unmodifiable(_shopping);

  int get favoriteCount => _meals.where((meal) => meal.favorite).length;
  int get plannedThisWeek => plansForWeek(weekStart(DateTime.now())).length;
  int get shoppingRemaining => _shopping.where((item) => !item.checked).length;

  List<MealTemplate> get mostRepeatedMeals {
    final result = [..._meals];
    result.sort((a, b) {
      final count = b.timesPlanned.compareTo(a.timesPlanned);
      if (count != 0) return count;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return result;
  }

  List<MealPlanEntry> get history {
    final today = dateOnly(DateTime.now());
    final result = _plans.where((entry) => entry.date.isBefore(today)).toList();
    result.sort((a, b) => b.date.compareTo(a.date));
    return result;
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    darkMode = prefs.getBool(_darkKey) ?? false;

    _meals
      ..clear()
      ..addAll(_decodeList(
        prefs.getString(_mealsKey),
        (map) => MealTemplate.fromMap(map),
      ));

    _plans
      ..clear()
      ..addAll(_decodeList(
        prefs.getString(_plansKey),
        (map) => MealPlanEntry.fromMap(map),
      ));

    _shopping
      ..clear()
      ..addAll(_decodeList(
        prefs.getString(_shoppingKey),
        (map) => ShoppingItem.fromMap(map),
      ));

    ready = true;
    notifyListeners();
  }

  List<T> _decodeList<T>(
    String? raw,
    T Function(Map<String, dynamic>) builder,
  ) {
    if (raw == null || raw.isEmpty) return <T>[];

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((entry) => builder(Map<String, dynamic>.from(entry as Map)))
          .toList();
    } catch (_) {
      return <T>[];
    }
  }

  Future<void> addMeal(MealTemplate meal) async {
    _meals.add(meal);
    await _saveMeals();
    notifyListeners();
  }

  Future<void> updateMeal(MealTemplate meal) async {
    final index = _meals.indexWhere((entry) => entry.id == meal.id);
    if (index == -1) return;

    _meals[index] = meal;

    for (var i = 0; i < _plans.length; i++) {
      final plan = _plans[i];
      if (plan.mealId != meal.id) continue;

      _plans[i] = MealPlanEntry(
        id: plan.id,
        mealId: plan.mealId,
        mealName: meal.name,
        slot: plan.slot,
        date: plan.date,
        notes: plan.notes,
      );
    }

    await Future.wait([_saveMeals(), _savePlans()]);
    notifyListeners();
  }

  Future<void> toggleFavorite(String id) async {
    final index = _meals.indexWhere((meal) => meal.id == id);
    if (index == -1) return;

    final meal = _meals[index];
    _meals[index] = meal.copyWith(favorite: !meal.favorite);
    await _saveMeals();
    notifyListeners();
  }

  Future<void> deleteMeal(String id) async {
    _meals.removeWhere((meal) => meal.id == id);
    await _saveMeals();
    notifyListeners();
  }

  MealPlanEntry? entryFor(DateTime date, MealSlot slot) {
    final day = dateOnly(date);
    for (final entry in _plans) {
      if (sameDay(entry.date, day) && entry.slot == slot) return entry;
    }
    return null;
  }

  List<MealPlanEntry> plansForWeek(DateTime start) {
    final from = dateOnly(start);
    final to = from.add(const Duration(days: 7));
    final result = _plans
        .where((entry) => !entry.date.isBefore(from) && entry.date.isBefore(to))
        .toList();
    result.sort((a, b) {
      final byDate = a.date.compareTo(b.date);
      if (byDate != 0) return byDate;
      return a.slot.index.compareTo(b.slot.index);
    });
    return result;
  }

  Future<void> assignMeal({
    required DateTime date,
    required MealSlot slot,
    required MealTemplate meal,
    String notes = '',
  }) async {
    final cleanDate = dateOnly(date);
    _plans.removeWhere(
      (entry) => sameDay(entry.date, cleanDate) && entry.slot == slot,
    );

    final now = DateTime.now().microsecondsSinceEpoch;
    _plans.add(
      MealPlanEntry(
        id: '$now',
        mealId: meal.id,
        mealName: meal.name,
        slot: slot,
        date: cleanDate,
        notes: notes.trim(),
      ),
    );

    final mealIndex = _meals.indexWhere((entry) => entry.id == meal.id);
    if (mealIndex != -1) {
      final current = _meals[mealIndex];
      _meals[mealIndex] = current.copyWith(
        timesPlanned: current.timesPlanned + 1,
      );
    }

    await Future.wait([_savePlans(), _saveMeals()]);
    notifyListeners();
  }

  Future<void> removePlan(String id) async {
    _plans.removeWhere((entry) => entry.id == id);
    await _savePlans();
    notifyListeners();
  }

  Future<int> copyPreviousWeek(DateTime currentWeekStart) async {
    final currentStart = weekStart(currentWeekStart);
    final previousStart = currentStart.subtract(const Duration(days: 7));
    final previous = plansForWeek(previousStart);
    if (previous.isEmpty) return 0;

    var copied = 0;
    for (final old in previous) {
      final dayOffset = dateOnly(old.date).difference(previousStart).inDays;
      final newDate = currentStart.add(Duration(days: dayOffset));

      if (entryFor(newDate, old.slot) != null) continue;

      final mealIndex = _meals.indexWhere((meal) => meal.id == old.mealId);
      final now = DateTime.now().microsecondsSinceEpoch + copied;
      _plans.add(
        MealPlanEntry(
          id: '$now',
          mealId: old.mealId,
          mealName: old.mealName,
          slot: old.slot,
          date: newDate,
          notes: old.notes,
        ),
      );

      if (mealIndex != -1) {
        final meal = _meals[mealIndex];
        _meals[mealIndex] = meal.copyWith(
          timesPlanned: meal.timesPlanned + 1,
        );
      }
      copied++;
    }

    if (copied > 0) {
      await Future.wait([_savePlans(), _saveMeals()]);
      notifyListeners();
    }

    return copied;
  }

  Future<void> addShoppingItem(String text) async {
    final value = text.trim();
    if (value.isEmpty) return;

    _shopping.add(
      ShoppingItem(
        id: '${DateTime.now().microsecondsSinceEpoch}',
        text: value,
        checked: false,
      ),
    );

    await _saveShopping();
    notifyListeners();
  }

  Future<void> toggleShopping(String id) async {
    final index = _shopping.indexWhere((item) => item.id == id);
    if (index == -1) return;

    final item = _shopping[index];
    _shopping[index] = item.copyWith(checked: !item.checked);
    await _saveShopping();
    notifyListeners();
  }

  Future<void> deleteShopping(String id) async {
    _shopping.removeWhere((item) => item.id == id);
    await _saveShopping();
    notifyListeners();
  }

  Future<void> clearCheckedShopping() async {
    _shopping.removeWhere((item) => item.checked);
    await _saveShopping();
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    darkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkKey, value);
    notifyListeners();
  }

  Future<void> resetAll() async {
    _meals.clear();
    _plans.clear();
    _shopping.clear();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_mealsKey);
    await prefs.remove(_plansKey);
    await prefs.remove(_shoppingKey);
    notifyListeners();
  }

  Future<void> _saveMeals() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _mealsKey,
      jsonEncode(_meals.map((meal) => meal.toMap()).toList()),
    );
  }

  Future<void> _savePlans() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _plansKey,
      jsonEncode(_plans.map((entry) => entry.toMap()).toList()),
    );
  }

  Future<void> _saveShopping() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _shoppingKey,
      jsonEncode(_shopping.map((item) => item.toMap()).toList()),
    );
  }
}

DateTime dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

DateTime weekStart(DateTime date) {
  final clean = dateOnly(date);
  return clean.subtract(Duration(days: clean.weekday - DateTime.monday));
}

bool sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
