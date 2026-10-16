enum MealSlot { breakfast, lunch, dinner, snack }

String mealSlotLabel(MealSlot slot) {
  switch (slot) {
    case MealSlot.breakfast:
      return 'Breakfast';
    case MealSlot.lunch:
      return 'Lunch';
    case MealSlot.dinner:
      return 'Dinner';
    case MealSlot.snack:
      return 'Snack';
  }
}

class MealTemplate {
  final String id;
  final String name;
  final MealSlot slot;
  final String notes;
  final bool favorite;
  final int timesPlanned;

  const MealTemplate({
    required this.id,
    required this.name,
    required this.slot,
    required this.notes,
    required this.favorite,
    required this.timesPlanned,
  });

  MealTemplate copyWith({
    String? id,
    String? name,
    MealSlot? slot,
    String? notes,
    bool? favorite,
    int? timesPlanned,
  }) {
    return MealTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      slot: slot ?? this.slot,
      notes: notes ?? this.notes,
      favorite: favorite ?? this.favorite,
      timesPlanned: timesPlanned ?? this.timesPlanned,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'slot': slot.name,
        'notes': notes,
        'favorite': favorite,
        'timesPlanned': timesPlanned,
      };

  factory MealTemplate.fromMap(Map<String, dynamic> map) {
    final rawSlot = map['slot'] as String? ?? MealSlot.lunch.name;
    final slot = MealSlot.values.firstWhere(
      (value) => value.name == rawSlot,
      orElse: () => MealSlot.lunch,
    );

    return MealTemplate(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      slot: slot,
      notes: map['notes'] as String? ?? '',
      favorite: map['favorite'] as bool? ?? false,
      timesPlanned: map['timesPlanned'] as int? ?? 0,
    );
  }
}

class MealPlanEntry {
  final String id;
  final String mealId;
  final String mealName;
  final MealSlot slot;
  final DateTime date;
  final String notes;

  const MealPlanEntry({
    required this.id,
    required this.mealId,
    required this.mealName,
    required this.slot,
    required this.date,
    required this.notes,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'mealId': mealId,
        'mealName': mealName,
        'slot': slot.name,
        'date': DateTime(date.year, date.month, date.day).toIso8601String(),
        'notes': notes,
      };

  factory MealPlanEntry.fromMap(Map<String, dynamic> map) {
    final rawSlot = map['slot'] as String? ?? MealSlot.lunch.name;
    final slot = MealSlot.values.firstWhere(
      (value) => value.name == rawSlot,
      orElse: () => MealSlot.lunch,
    );

    return MealPlanEntry(
      id: map['id'] as String? ?? '',
      mealId: map['mealId'] as String? ?? '',
      mealName: map['mealName'] as String? ?? '',
      slot: slot,
      date: DateTime.tryParse(map['date'] as String? ?? '') ?? DateTime.now(),
      notes: map['notes'] as String? ?? '',
    );
  }
}

class ShoppingItem {
  final String id;
  final String text;
  final bool checked;

  const ShoppingItem({
    required this.id,
    required this.text,
    required this.checked,
  });

  ShoppingItem copyWith({
    String? id,
    String? text,
    bool? checked,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      text: text ?? this.text,
      checked: checked ?? this.checked,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'text': text,
        'checked': checked,
      };

  factory ShoppingItem.fromMap(Map<String, dynamic> map) {
    return ShoppingItem(
      id: map['id'] as String? ?? '',
      text: map['text'] as String? ?? '',
      checked: map['checked'] as bool? ?? false,
    );
  }
}
