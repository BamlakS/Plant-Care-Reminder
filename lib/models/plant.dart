import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  // Convert Plant to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'species': species,
      'lastWatered': Timestamp.fromDate(lastWatered),
      'wateringFrequencyDays': wateringFrequencyDays,
      'careInstructions': careInstructions,
      'emoji': emoji,
    };
  }

  // Create Plant from Firestore document
  factory Plant.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Plant(
      id: doc.id,
      name: data['name'] ?? '',
      species: data['species'] ?? '',
      lastWatered: (data['lastWatered'] as Timestamp).toDate(),
      wateringFrequencyDays: data['wateringFrequencyDays'] ?? 7,
      careInstructions: data['careInstructions'] ?? '',
      emoji: data['emoji'] ?? '🌿',
    );
  }
}