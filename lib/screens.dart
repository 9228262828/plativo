import 'package:flutter/material.dart';

import 'models.dart';
import 'store.dart';
import 'ui.dart';

class SplashScreen extends StatefulWidget {
  final PlativoStore store;

  const SplashScreen({super.key, required this.store});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _open();
  }

  Future<void> _open() async {
    while (!widget.store.ready) {
      await Future.delayed(const Duration(milliseconds: 40));
    }

    await Future.delayed(const Duration(milliseconds: 520));

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomeScreen(store: widget.store),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PlativoLogo(size: 100),
            SizedBox(height: 22),
            Text(
              'PLATIVO',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'PLAN MEALS. SIMPLIFY YOUR WEEK.',
              style: TextStyle(
                color: plativoTerracotta,
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final PlativoStore store;

  const HomeScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final today = dateOnly(DateTime.now());
        final todayEntries = MealSlot.values
            .map((slot) => store.entryFor(today, slot))
            .whereType<MealPlanEntry>()
            .toList();
        final favorites = store.meals.where((meal) => meal.favorite).take(3);

        return Scaffold(
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MealEditorScreen(store: store),
              ),
            ),
            icon: const Icon(Icons.add_rounded),
            label: const Text('ADD MEAL'),
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 100),
              children: [
                Row(
                  children: [
                    const PlativoLogo(size: 54),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PLATIVO',
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 3,
                            ),
                          ),
                          Text(
                            'WEEKLY MEAL ROTATION',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SettingsScreen(store: store),
                        ),
                      ),
                      icon: const Icon(Icons.settings_outlined),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                const Text(
                  'Plan less.\nEnjoy meals more.',
                  style: TextStyle(
                    fontSize: 31,
                    height: 1.08,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Build a simple weekly rotation without diet rules or calorie tracking.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: MetricCard(
                        value: '${store.plannedThisWeek}',
                        label: 'PLANNED THIS WEEK',
                        icon: Icons.calendar_month_outlined,
                        color: plativoGreen,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: MetricCard(
                        value: '${store.favoriteCount}',
                        label: 'FAVORITES',
                        icon: Icons.favorite_outline_rounded,
                        color: plativoTerracotta,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                MetricCard(
                  value: '${store.shoppingRemaining}',
                  label: 'SHOPPING NOTES LEFT',
                  icon: Icons.shopping_basket_outlined,
                  color: plativoMustard,
                ),
                const SizedBox(height: 24),
                _HomeMenu(store: store),
                const SizedBox(height: 26),
                SectionTitle(
                  title: 'Today',
                  action: 'OPEN WEEK',
                  onAction: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WeeklyPlannerScreen(store: store),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                if (todayEntries.isEmpty)
                  const EmptyCard(
                    icon: Icons.restaurant_menu_rounded,
                    title: 'Nothing planned today',
                    text: 'Open the weekly planner and add breakfast, lunch, dinner, or a snack.',
                  )
                else
                  ...todayEntries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _PlanTile(
                        entry: entry,
                        onDelete: () => store.removePlan(entry.id),
                      ),
                    ),
                  ),
                if (favorites.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const SectionTitle(title: 'Favorite meals'),
                  const SizedBox(height: 10),
                  ...favorites.map(
                    (meal) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: MealCard(
                        meal: meal,
                        store: store,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MealEditorScreen(
                              store: store,
                              meal: meal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HomeMenu extends StatelessWidget {
  final PlativoStore store;

  const _HomeMenu({required this.store});

  @override
  Widget build(BuildContext context) {
    final actions = [
      (
        'Weekly Planner',
        Icons.calendar_view_week_rounded,
        () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => WeeklyPlannerScreen(store: store),
              ),
            ),
      ),
      (
        'Meal Library',
        Icons.restaurant_menu_rounded,
        () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MealLibraryScreen(store: store),
              ),
            ),
      ),
      (
        'Shopping Notes',
        Icons.shopping_basket_outlined,
        () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ShoppingNotesScreen(store: store),
              ),
            ),
      ),
      (
        'Statistics',
        Icons.bar_chart_rounded,
        () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StatisticsScreen(store: store),
              ),
            ),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.75,
      ),
      itemBuilder: (context, index) {
        final action = actions[index];
        return Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: action.$3,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Icon(action.$2, color: plativoGreen),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      action.$1,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class WeeklyPlannerScreen extends StatefulWidget {
  final PlativoStore store;

  const WeeklyPlannerScreen({super.key, required this.store});

  @override
  State<WeeklyPlannerScreen> createState() => _WeeklyPlannerScreenState();
}

class _WeeklyPlannerScreenState extends State<WeeklyPlannerScreen> {
  late DateTime currentWeek;

  @override
  void initState() {
    super.initState();
    currentWeek = weekStart(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.store,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('WEEKLY PLANNER'),
            actions: [
              IconButton(
                tooltip: 'Copy previous week',
                onPressed: _copyPreviousWeek,
                icon: const Icon(Icons.copy_all_outlined),
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 2, 14, 10),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => setState(() {
                        currentWeek = currentWeek.subtract(
                          const Duration(days: 7),
                        );
                      }),
                      icon: const Icon(Icons.chevron_left_rounded),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            weekRangeLabel(currentWeek),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          TextButton(
                            onPressed: () => setState(() {
                              currentWeek = weekStart(DateTime.now());
                            }),
                            child: const Text('THIS WEEK'),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(() {
                        currentWeek = currentWeek.add(
                          const Duration(days: 7),
                        );
                      }),
                      icon: const Icon(Icons.chevron_right_rounded),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 28),
                  itemCount: 7,
                  itemBuilder: (context, index) {
                    final date = currentWeek.add(Duration(days: index));
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _DayPlannerCard(
                        store: widget.store,
                        date: date,
                        onSlotTap: (slot) => _chooseMeal(date, slot),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _copyPreviousWeek() async {
    final copied = await widget.store.copyPreviousWeek(currentWeek);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          copied == 0
              ? 'Nothing new to copy from the previous week.'
              : '$copied meal${copied == 1 ? '' : 's'} copied into this week.',
        ),
      ),
    );
  }

  Future<void> _chooseMeal(DateTime date, MealSlot slot) async {
    if (widget.store.meals.isEmpty) {
      final create = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Create a meal first'),
          content: const Text(
            'Your meal library is empty. Add a meal, then return to the planner.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('CANCEL'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('ADD MEAL'),
            ),
          ],
        ),
      );

      if (create == true && mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MealEditorScreen(
              store: widget.store,
              initialSlot: slot,
            ),
          ),
        );
      }
      return;
    }

    final current = widget.store.entryFor(date, slot);
    final result = await showModalBottomSheet<_MealChoiceResult>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => _MealPickerSheet(
        meals: widget.store.meals,
        slot: slot,
        current: current,
      ),
    );

    if (result == null) return;

    if (result.removeCurrent && current != null) {
      await widget.store.removePlan(current.id);
      return;
    }

    if (result.meal != null) {
      await widget.store.assignMeal(
        date: date,
        slot: slot,
        meal: result.meal!,
        notes: result.notes,
      );
    }
  }
}

class _DayPlannerCard extends StatelessWidget {
  final PlativoStore store;
  final DateTime date;
  final ValueChanged<MealSlot> onSlotTap;

  const _DayPlannerCard({
    required this.store,
    required this.date,
    required this.onSlotTap,
  });

  @override
  Widget build(BuildContext context) {
    final today = sameDay(date, DateTime.now());

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: today
                        ? plativoGreen
                        : plativoGreen.withOpacity(.09),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                    child: Text(
                      '${date.day}',
                      style: TextStyle(
                        color: today ? Colors.white : plativoGreen,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dayShort(date),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        '${monthShort(date)} ${date.day}',
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (today)
                  const Text(
                    'TODAY',
                    style: TextStyle(
                      color: plativoTerracotta,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .8,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            ...MealSlot.values.map((slot) {
              final entry = store.entryFor(date, slot);
              final color = slotColor(slot);

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => onSlotTap(slot),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(.07),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: color.withOpacity(.14)),
                    ),
                    child: Row(
                      children: [
                        Icon(slotIcon(slot), color: color, size: 21),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 76,
                          child: Text(
                            mealSlotLabel(slot),
                            style: TextStyle(
                              color: color,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            entry?.mealName ?? 'Tap to plan',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: entry == null
                                  ? FontWeight.w600
                                  : FontWeight.w900,
                              color: entry == null
                                  ? Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant
                                  : null,
                            ),
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, size: 20),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _MealChoiceResult {
  final MealTemplate? meal;
  final String notes;
  final bool removeCurrent;

  const _MealChoiceResult({
    this.meal,
    this.notes = '',
    this.removeCurrent = false,
  });
}

class _MealPickerSheet extends StatefulWidget {
  final List<MealTemplate> meals;
  final MealSlot slot;
  final MealPlanEntry? current;

  const _MealPickerSheet({
    required this.meals,
    required this.slot,
    required this.current,
  });

  @override
  State<_MealPickerSheet> createState() => _MealPickerSheetState();
}

class _MealPickerSheetState extends State<_MealPickerSheet> {
  String query = '';
  bool sameSlotOnly = true;

  @override
  Widget build(BuildContext context) {
    final filtered = widget.meals.where((meal) {
      final matchQuery = meal.name.toLowerCase().contains(query.toLowerCase());
      final matchSlot = !sameSlotOnly || meal.slot == widget.slot;
      return matchQuery && matchSlot;
    }).toList()
      ..sort((a, b) {
        if (a.favorite != b.favorite) return a.favorite ? -1 : 1;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 18,
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * .72,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose ${mealSlotLabel(widget.slot)}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                onChanged: (value) => setState(() => query = value),
                decoration: const InputDecoration(
                  hintText: 'Search meal library',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: sameSlotOnly,
                onChanged: (value) => setState(() => sameSlotOnly = value),
                title: Text('Only show ${mealSlotLabel(widget.slot)} meals'),
              ),
              if (widget.current != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => Navigator.pop(
                      context,
                      const _MealChoiceResult(removeCurrent: true),
                    ),
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: const Text('REMOVE CURRENT PLAN'),
                  ),
                ),
              const SizedBox(height: 4),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(
                        child: Text('No meals match this filter.'),
                      )
                    : ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final meal = filtered[index];
                          final color = slotColor(meal.slot);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Card(
                              child: ListTile(
                                leading: Icon(slotIcon(meal.slot), color: color),
                                title: Text(
                                  meal.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                subtitle: Text(
                                  '${mealSlotLabel(meal.slot)} • Planned ${meal.timesPlanned} times',
                                ),
                                trailing: meal.favorite
                                    ? const Icon(
                                        Icons.favorite_rounded,
                                        color: plativoTerracotta,
                                      )
                                    : const Icon(Icons.chevron_right_rounded),
                                onTap: () => Navigator.pop(
                                  context,
                                  _MealChoiceResult(meal: meal),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MealLibraryScreen extends StatefulWidget {
  final PlativoStore store;

  const MealLibraryScreen({super.key, required this.store});

  @override
  State<MealLibraryScreen> createState() => _MealLibraryScreenState();
}

class _MealLibraryScreenState extends State<MealLibraryScreen> {
  String query = '';
  MealSlot? filterSlot;
  bool favoritesOnly = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.store,
      builder: (context, _) {
        final meals = widget.store.meals.where((meal) {
          final matchQuery = meal.name.toLowerCase().contains(
                query.trim().toLowerCase(),
              );
          final matchSlot = filterSlot == null || meal.slot == filterSlot;
          final matchFavorite = !favoritesOnly || meal.favorite;
          return matchQuery && matchSlot && matchFavorite;
        }).toList()
          ..sort((a, b) {
            if (a.favorite != b.favorite) return a.favorite ? -1 : 1;
            return a.name.toLowerCase().compareTo(b.name.toLowerCase());
          });

        return Scaffold(
          appBar: AppBar(title: const Text('MEAL LIBRARY')),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MealEditorScreen(store: widget.store),
              ),
            ),
            icon: const Icon(Icons.add_rounded),
            label: const Text('ADD MEAL'),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
            children: [
              TextField(
                onChanged: (value) => setState(() => query = value),
                decoration: const InputDecoration(
                  hintText: 'Search meals',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 42,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: const Text('All'),
                        selected: filterSlot == null,
                        onSelected: (_) => setState(() => filterSlot = null),
                      ),
                    ),
                    for (final slot in MealSlot.values)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(mealSlotLabel(slot)),
                          selected: filterSlot == slot,
                          onSelected: (_) => setState(() => filterSlot = slot),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: const Text('Favorites'),
                        selected: favoritesOnly,
                        onSelected: (value) => setState(() {
                          favoritesOnly = value;
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                '${meals.length} meals',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              if (meals.isEmpty)
                const EmptyCard(
                  icon: Icons.restaurant_menu_rounded,
                  title: 'No meals found',
                  text: 'Add your regular meals or change the current filters.',
                )
              else
                ...meals.map(
                  (meal) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: MealCard(
                      meal: meal,
                      store: widget.store,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MealEditorScreen(
                            store: widget.store,
                            meal: meal,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class MealCard extends StatelessWidget {
  final MealTemplate meal;
  final PlativoStore store;
  final VoidCallback onTap;

  const MealCard({
    super.key,
    required this.meal,
    required this.store,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = slotColor(meal.slot);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withOpacity(.09),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Icon(slotIcon(meal.slot), color: color),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${mealSlotLabel(meal.slot)} • Planned ${meal.timesPlanned} times',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (meal.notes.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        meal.notes,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                tooltip: meal.favorite ? 'Remove favorite' : 'Add favorite',
                onPressed: () => store.toggleFavorite(meal.id),
                icon: Icon(
                  meal.favorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: meal.favorite ? plativoTerracotta : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MealEditorScreen extends StatefulWidget {
  final PlativoStore store;
  final MealTemplate? meal;
  final MealSlot? initialSlot;

  const MealEditorScreen({
    super.key,
    required this.store,
    this.meal,
    this.initialSlot,
  });

  @override
  State<MealEditorScreen> createState() => _MealEditorScreenState();
}

class _MealEditorScreenState extends State<MealEditorScreen> {
  final formKey = GlobalKey<FormState>();

  late String name;
  late MealSlot slot;
  late String notes;
  late bool favorite;

  bool get editing => widget.meal != null;

  @override
  void initState() {
    super.initState();
    final meal = widget.meal;
    name = meal?.name ?? '';
    slot = meal?.slot ?? widget.initialSlot ?? MealSlot.lunch;
    notes = meal?.notes ?? '';
    favorite = meal?.favorite ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(editing ? 'EDIT MEAL' : 'ADD MEAL'),
        actions: [
          if (editing)
            IconButton(
              tooltip: 'Delete meal',
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline_rounded),
            ),
        ],
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 30),
          children: [
            TextFormField(
              initialValue: name,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Meal name',
                prefixIcon: Icon(Icons.restaurant_menu_rounded),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter a meal name';
                }
                return null;
              },
              onChanged: (value) => name = value,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<MealSlot>(
              initialValue: slot,
              decoration: const InputDecoration(
                labelText: 'Typical meal time',
                prefixIcon: Icon(Icons.schedule_rounded),
              ),
              items: [
                for (final value in MealSlot.values)
                  DropdownMenuItem(
                    value: value,
                    child: Text(mealSlotLabel(value)),
                  ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => slot = value);
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: notes,
              minLines: 3,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Notes',
                hintText: 'Example: Serve with salad or make extra for tomorrow',
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.notes_rounded),
              ),
              onChanged: (value) => notes = value,
            ),
            const SizedBox(height: 12),
            Card(
              child: SwitchListTile(
                value: favorite,
                onChanged: (value) => setState(() => favorite = value),
                secondary: const Icon(
                  Icons.favorite_border_rounded,
                  color: plativoTerracotta,
                ),
                title: const Text(
                  'Favorite meal',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: const Text('Keep it easy to find in your rotation.'),
              ),
            ),
            if (editing) ...[
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.repeat_rounded,
                    color: plativoGreen,
                  ),
                  title: const Text('Times planned'),
                  trailing: Text(
                    '${widget.meal!.timesPlanned}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check_rounded),
              label: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(editing ? 'SAVE CHANGES' : 'ADD MEAL'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    final meal = MealTemplate(
      id: widget.meal?.id ?? '${DateTime.now().microsecondsSinceEpoch}',
      name: name.trim(),
      slot: slot,
      notes: notes.trim(),
      favorite: favorite,
      timesPlanned: widget.meal?.timesPlanned ?? 0,
    );

    if (editing) {
      await widget.store.updateMeal(meal);
    } else {
      await widget.store.addMeal(meal);
    }

    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    final meal = widget.meal;
    if (meal == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete meal?'),
        content: Text(
          'Remove "${meal.name}" from your meal library? Existing planner history will stay visible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await widget.store.deleteMeal(meal.id);
      if (mounted) Navigator.pop(context);
    }
  }
}

class ShoppingNotesScreen extends StatefulWidget {
  final PlativoStore store;

  const ShoppingNotesScreen({super.key, required this.store});

  @override
  State<ShoppingNotesScreen> createState() => _ShoppingNotesScreenState();
}

class _ShoppingNotesScreenState extends State<ShoppingNotesScreen> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.store,
      builder: (context, _) {
        final items = [...widget.store.shopping]
          ..sort((a, b) {
            if (a.checked != b.checked) return a.checked ? 1 : -1;
            return a.text.toLowerCase().compareTo(b.text.toLowerCase());
          });

        return Scaffold(
          appBar: AppBar(
            title: const Text('SHOPPING NOTES'),
            actions: [
              if (items.any((item) => item.checked))
                TextButton(
                  onPressed: widget.store.clearCheckedShopping,
                  child: const Text('CLEAR DONE'),
                ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 30),
            children: [
              Text(
                'Keep a lightweight list of ingredients or groceries you want to remember.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => _add(),
                      decoration: const InputDecoration(
                        hintText: 'Add a shopping note',
                        prefixIcon: Icon(Icons.add_shopping_cart_rounded),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _add,
                    icon: const Icon(Icons.add_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              if (items.isEmpty)
                const EmptyCard(
                  icon: Icons.shopping_basket_outlined,
                  title: 'Shopping notes are empty',
                  text: 'Add groceries, ingredients, or anything you want to remember for the week.',
                )
              else
                ...items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 9),
                    child: Card(
                      child: CheckboxListTile(
                        value: item.checked,
                        onChanged: (_) => widget.store.toggleShopping(item.id),
                        title: Text(
                          item.text,
                          style: TextStyle(
                            decoration: item.checked
                                ? TextDecoration.lineThrough
                                : null,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        secondary: IconButton(
                          tooltip: 'Delete note',
                          onPressed: () => widget.store.deleteShopping(item.id),
                          icon: const Icon(Icons.delete_outline_rounded),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _add() async {
    final value = controller.text.trim();
    if (value.isEmpty) return;
    await widget.store.addShoppingItem(value);
    controller.clear();
  }
}

class HistoryScreen extends StatelessWidget {
  final PlativoStore store;

  const HistoryScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final history = store.history;

        return Scaffold(
          appBar: AppBar(title: const Text('MEAL HISTORY')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 30),
            children: [
              Text(
                'Past planned meals stay here so you can see your rotation over time.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              if (history.isEmpty)
                const EmptyCard(
                  icon: Icons.history_rounded,
                  title: 'No meal history yet',
                  text: 'Past planner entries will appear here automatically.',
                )
              else
                ...history.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 9),
                    child: _PlanTile(
                      entry: entry,
                      onDelete: () => store.removePlan(entry.id),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class StatisticsScreen extends StatelessWidget {
  final PlativoStore store;

  const StatisticsScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final repeated = store.mostRepeatedMeals
            .where((meal) => meal.timesPlanned > 0)
            .take(5)
            .toList();

        final slotCounts = <MealSlot, int>{
          for (final slot in MealSlot.values)
            slot: store.plans.where((entry) => entry.slot == slot).length,
        };

        return Scaffold(
          appBar: AppBar(title: const Text('STATISTICS')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 30),
            children: [
              const Text(
                'Your meal rotation',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: MetricCard(
                      value: '${store.meals.length}',
                      label: 'MEALS SAVED',
                      icon: Icons.restaurant_menu_rounded,
                      color: plativoGreen,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: MetricCard(
                      value: '${store.plans.length}',
                      label: 'TOTAL PLANS',
                      icon: Icons.calendar_month_outlined,
                      color: plativoTerracotta,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: MetricCard(
                      value: '${store.favoriteCount}',
                      label: 'FAVORITES',
                      icon: Icons.favorite_outline_rounded,
                      color: plativoRose,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: MetricCard(
                      value: '${store.history.length}',
                      label: 'PAST MEALS',
                      icon: Icons.history_rounded,
                      color: plativoMustard,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 26),
              const SectionTitle(title: 'Meal time totals'),
              const SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      for (final slot in MealSlot.values)
                        ListTile(
                          leading: Icon(
                            slotIcon(slot),
                            color: slotColor(slot),
                          ),
                          title: Text(
                            mealSlotLabel(slot),
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          trailing: Text(
                            '${slotCounts[slot] ?? 0}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const SectionTitle(title: 'Most repeated meals'),
              const SizedBox(height: 10),
              if (repeated.isEmpty)
                const EmptyCard(
                  icon: Icons.repeat_rounded,
                  title: 'No rotation data yet',
                  text: 'Plan meals during the week to see your most repeated choices.',
                )
              else
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        for (var i = 0; i < repeated.length; i++)
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: slotColor(repeated[i].slot)
                                  .withOpacity(.12),
                              child: Text(
                                '${i + 1}',
                                style: TextStyle(
                                  color: slotColor(repeated[i].slot),
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            title: Text(
                              repeated[i].name,
                              style: const TextStyle(fontWeight: FontWeight.w900),
                            ),
                            subtitle: Text(mealSlotLabel(repeated[i].slot)),
                            trailing: Text(
                              '${repeated[i].timesPlanned}×',
                              style: const TextStyle(
                                color: plativoGreen,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HistoryScreen(store: store),
                  ),
                ),
                icon: const Icon(Icons.history_rounded),
                label: const Padding(
                  padding: EdgeInsets.all(13),
                  child: Text('VIEW MEAL HISTORY'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PlanTile extends StatelessWidget {
  final MealPlanEntry entry;
  final VoidCallback onDelete;

  const _PlanTile({
    required this.entry,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = slotColor(entry.slot);

    return Card(
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(.09),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(slotIcon(entry.slot), color: color),
        ),
        title: Text(
          entry.mealName,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Text(
          '${mealSlotLabel(entry.slot)} • ${friendlyDate(entry.date)}',
        ),
        trailing: IconButton(
          tooltip: 'Remove plan',
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline_rounded),
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  final PlativoStore store;

  const SettingsScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('SETTINGS')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: SwitchListTile(
                  value: store.darkMode,
                  onChanged: store.setDarkMode,
                  secondary: const Icon(Icons.dark_mode_outlined),
                  title: const Text(
                    'Dark mode',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.history_rounded),
                      title: const Text('Meal History'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HistoryScreen(store: store),
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.privacy_tip_outlined),
                      title: const Text('Privacy Policy'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LegalScreen(
                            title: 'Privacy Policy',
                            body: privacyText,
                          ),
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.description_outlined),
                      title: const Text('Terms & Conditions'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LegalScreen(
                            title: 'Terms & Conditions',
                            body: termsText,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  textColor: plativoRose,
                  iconColor: plativoRose,
                  leading: const Icon(Icons.delete_sweep_outlined),
                  title: const Text('Reset all data'),
                  subtitle: const Text(
                    'Delete meal library, planner entries, and shopping notes.',
                  ),
                  onTap: () => _reset(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _reset(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset PLATIVO?'),
        content: const Text(
          'All saved meals, weekly plans, history, and shopping notes will be removed from local app storage.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('RESET'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await store.resetAll();
    }
  }
}

class LegalScreen extends StatelessWidget {
  final String title;
  final String body;

  const LegalScreen({
    super.key,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SelectableText(
            body,
            style: const TextStyle(height: 1.7),
          ),
        ],
      ),
    );
  }
}

const privacyText = '''PLATIVO PRIVACY POLICY

PLATIVO is an offline-first weekly meal rotation planner intended for personal organization.

The current core version does not require an account, login, Firebase, backend services, advertising, analytics, cloud synchronization, or a personal profile.

Information you enter, including meal names, typical meal times, meal notes, favorite status, weekly planner entries, shopping notes, and locally calculated rotation statistics, is stored locally on your device.

PLATIVO does not require health information, calorie data, nutrition data, weight, medical information, dietary diagnosis, or fitness information for normal use.

The current core version does not require access to your precise location, camera, microphone, contacts, phone, SMS, calendar, photos, media library, or payment information.

PLATIVO does not intentionally sell or rent your locally stored information and does not use it for personalized advertising.

You can delete individual meals and planner entries, clear completed shopping notes, or reset all app data from Settings. Clearing application storage or uninstalling the app may also remove locally stored information, subject to operating-system backup and restore behavior.

If future versions add online services, accounts, cloud sync, analytics, crash reporting, advertising, purchases, nutrition services, health integrations, or additional permissions, this policy should be reviewed and updated before release.''';

const termsText = '''PLATIVO TERMS & CONDITIONS

PLATIVO is a weekly meal planning and personal organization tool.

The app helps you organize meal names, weekly meal slots, favorites, shopping notes, history, and simple meal-rotation statistics.

PLATIVO does not provide medical, nutritional, dietary, allergy, food-safety, or other professional advice. It does not determine whether a meal is healthy, suitable, safe, or appropriate for a particular person.

You are responsible for food choices, ingredients, allergies, storage, preparation, dietary requirements, and food safety.

The current core version stores app data locally on your device. We do not guarantee recovery after uninstalling the app, clearing app data, device loss, storage failure, or operating-system changes.

PLATIVO is provided on an "as available" basis to the extent permitted by applicable law. Features may be changed, improved, added, or removed in future versions.''';
