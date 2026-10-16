import 'package:flutter/material.dart';

import 'models.dart';

const plativoGreen = Color(0xFF2F6B4F);
const plativoTerracotta = Color(0xFFD97852);
const plativoMustard = Color(0xFFE3B341);
const plativoCream = Color(0xFFF8F3E8);
const plativoInk = Color(0xFF1E2B25);
const plativoMint = Color(0xFFB8D8C5);
const plativoRose = Color(0xFFC96767);
const plativoDarkSurface = Color(0xFF223129);

ThemeData plativoTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: ColorScheme.fromSeed(
      seedColor: plativoGreen,
      brightness: brightness,
      primary: plativoGreen,
      secondary: plativoTerracotta,
    ),
    scaffoldBackgroundColor: dark ? const Color(0xFF142019) : plativoCream,
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: dark ? plativoDarkSurface : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(18)),
      ),
    ),
  );
}

IconData slotIcon(MealSlot slot) {
  switch (slot) {
    case MealSlot.breakfast:
      return Icons.free_breakfast_outlined;
    case MealSlot.lunch:
      return Icons.lunch_dining_outlined;
    case MealSlot.dinner:
      return Icons.dinner_dining_outlined;
    case MealSlot.snack:
      return Icons.cookie_outlined;
  }
}

Color slotColor(MealSlot slot) {
  switch (slot) {
    case MealSlot.breakfast:
      return plativoMustard;
    case MealSlot.lunch:
      return plativoGreen;
    case MealSlot.dinner:
      return plativoTerracotta;
    case MealSlot.snack:
      return const Color(0xFF8C6BB1);
  }
}

String dayShort(DateTime date) {
  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return days[date.weekday - 1];
}

String monthShort(DateTime date) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return months[date.month - 1];
}

String friendlyDate(DateTime date) =>
    '${dayShort(date)}, ${monthShort(date)} ${date.day}';

String weekRangeLabel(DateTime start) {
  final end = start.add(const Duration(days: 6));
  if (start.month == end.month) {
    return '${monthShort(start)} ${start.day}–${end.day}, ${end.year}';
  }
  return '${monthShort(start)} ${start.day} – ${monthShort(end)} ${end.day}, ${end.year}';
}

class PlativoLogo extends StatelessWidget {
  final double size;

  const PlativoLogo({super.key, this.size = 72});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: plativoGreen,
        borderRadius: BorderRadius.circular(size * .28),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size * .52,
            height: size * .52,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: plativoMustard,
                width: size * .055,
              ),
            ),
          ),
          Icon(
            Icons.restaurant_rounded,
            color: plativoGreen,
            size: size * .29,
          ),
          Positioned(
            right: size * .09,
            bottom: size * .09,
            child: Container(
              width: size * .27,
              height: size * .27,
              decoration: const BoxDecoration(
                color: plativoTerracotta,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.calendar_month_rounded,
                color: Colors.white,
                size: size * .16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MetricCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const MetricCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withOpacity(.09),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 23,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: .6,
            ),
          ),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const SectionTitle({
    super.key,
    required this.title,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        if (action != null)
          TextButton(
            onPressed: onAction,
            child: Text(action!),
          ),
      ],
    );
  }
}

class EmptyCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const EmptyCard({
    super.key,
    required this.icon,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            Icon(icon, color: plativoTerracotta, size: 38),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
