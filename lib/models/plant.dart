import 'package:flutter/material.dart';

class Plant {
  final String id;
  final String name;
  final String species;
  final DateTime lastWatered;
  final int wateringFrequencyDays;
  final String careInstructions;
  final String emoji;

  Plant({
    required this.id,
    required this.name,
    required this.species,
    required this.lastWatered,
    required this.wateringFrequencyDays,
    required this.careInstructions,
    required this.emoji,
  });

  // Calculate days until next watering
  int get daysUntilWatering {
    DateTime nextWatering = lastWatered.add(Duration(days: wateringFrequencyDays));
    return nextWatering.difference(DateTime.now()).inDays;
  }

  // Get status color
  Color get statusColor {
    if (daysUntilWatering < 0) return Colors.red;
    if (daysUntilWatering <= 1) return Colors.orange;
    if (daysUntilWatering <= 2) return Colors.yellow.shade700;
    return Colors.green;
  }
}