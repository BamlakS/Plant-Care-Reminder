import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/plant.dart';

class FirestoreService {
  final CollectionReference plantsCollection =
  FirebaseFirestore.instance.collection('plants');

  // Get all plants as a stream
  Stream<List<Plant>> getPlants() {
    return plantsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Plant.fromFirestore(doc)).toList();
    });
  }

  // Add a new plant
  Future<void> addPlant(Plant plant) async {
    try {
      await plantsCollection.add(plant.toMap());
    } catch (e) {
      throw Exception('Failed to add plant: $e');
    }
  }

  // Water plant update
  Future<void> waterPlant(String plantId) async {
    try {
      await plantsCollection.doc(plantId).update({
        'lastWatered': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to water plant: $e');
    }
  }

  // Delete plant
  Future<void> deletePlant(String plantId) async {
    try {
      await plantsCollection.doc(plantId).delete();
    } catch (e) {
      throw Exception('Failed to delete plant: $e');
    }
  }

  // Initialize sample data (call this once)
  Future<void> initializeSampleData() async {
    final snapshot = await plantsCollection.get();
    if (snapshot.docs.isEmpty) {
      // Add sample plants
      final samplePlants = [
        Plant(
          id: '',
          name: "Sunny",
          species: "Snake Plant",
          lastWatered: DateTime.now().subtract(const Duration(days: 5)),
          wateringFrequencyDays: 7,
          careInstructions: "Water when soil is completely dry. Tolerates low light.",
          emoji: "🌿",
        ),
        Plant(
          id: '',
          name: "Leafy",
          species: "Pothos",
          lastWatered: DateTime.now().subtract(const Duration(days: 4)),
          wateringFrequencyDays: 5,
          careInstructions: "Water when top inch of soil is dry. Bright indirect light.",
          emoji: "🍃",
        ),
        Plant(
          id: '',
          name: "Spike",
          species: "Cactus",
          lastWatered: DateTime.now().subtract(const Duration(days: 15)),
          wateringFrequencyDays: 14,
          careInstructions: "Water sparingly. Needs full sun and well-draining soil.",
          emoji: "🌵",
        ),
      ];

      for (var plant in samplePlants) {
        await addPlant(plant);
      }
    }
  }
}