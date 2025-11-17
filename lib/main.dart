import 'package:flutter/material.dart';
import 'models/plant.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plant Care Reminder',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Hardcoded plant data for Sprint 1
  static final List<Plant> myPlants = [
    Plant(
      id: "1",
      name: "Sunny",
      species: "Snake Plant",
      lastWatered: DateTime(2025, 11, 12),
      wateringFrequencyDays: 7,
      careInstructions: "Water when soil is completely dry. Tolerates low light.",
      emoji: "🌿",
    ),
    Plant(
      id: "2",
      name: "Leafy",
      species: "Pothos",
      lastWatered: DateTime(2025, 11, 13),
      wateringFrequencyDays: 5,
      careInstructions: "Water when top inch of soil is dry. Bright indirect light.",
      emoji: "🍃",
    ),
    Plant(
      id: "3",
      name: "Spike",
      species: "Cactus",
      lastWatered: DateTime(2025, 11, 2),
      wateringFrequencyDays: 14,
      careInstructions: "Water sparingly. Needs full sun and well-draining soil.",
      emoji: "🌵",
    ),
    Plant(
      id: "4",
      name: "Greenie",
      species: "Spider Plant",
      lastWatered: DateTime(2025, 11, 14),
      wateringFrequencyDays: 5,
      careInstructions: "Keep soil lightly moist. Prefers bright indirect light.",
      emoji: "🌱",
    ),
    Plant(
      id: "5",
      name: "Rosie",
      species: "Succulent",
      lastWatered: DateTime(2025, 11, 7),
      wateringFrequencyDays: 10,
      careInstructions: "Water deeply but infrequently. Needs bright light.",
      emoji: "🪴",
    ),
    Plant(
      id: "6",
      name: "Fern",
      species: "Boston Fern",
      lastWatered: DateTime(2025, 11, 15),
      wateringFrequencyDays: 3,
      careInstructions: "Keep soil consistently moist. High humidity needed.",
      emoji: "🌿",
    ),
    Plant(
      id: "7",
      name: "Lucky",
      species: "Bamboo",
      lastWatered: DateTime(2025, 11, 10),
      wateringFrequencyDays: 7,
      careInstructions: "Change water weekly. Indirect light preferred.",
      emoji: "🎋",
    ),
    Plant(
      id: "8",
      name: "Minty",
      species: "Mint Plant",
      lastWatered: DateTime(2025, 11, 16),
      wateringFrequencyDays: 2,
      careInstructions: "Water frequently. Loves full sun. Pinch for bushiness.",
      emoji: "🌿",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🌿 My Plants'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: myPlants.length,
        itemBuilder: (context, index) {
          final plant = myPlants[index];
          return _buildPlantCard(plant);
        },
      ),
    );
  }

  Widget _buildPlantCard(Plant plant) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Plant emoji
            Text(
              plant.emoji,
              style: const TextStyle(fontSize: 40),
            ),
            const SizedBox(width: 16),

            // Plant info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plant.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    plant.species,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildWateringStatus(plant),
                ],
              ),
            ),

            // Status indicator circle
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: plant.statusColor,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWateringStatus(Plant plant) {
    String statusText;

    if (plant.daysUntilWatering < 0) {
      statusText = "Overdue by ${-plant.daysUntilWatering} days!";
    } else if (plant.daysUntilWatering == 0) {
      statusText = "Water today";
    } else if (plant.daysUntilWatering == 1) {
      statusText = "Water tomorrow";
    } else {
      statusText = "Water in ${plant.daysUntilWatering} days";
    }

    return Text(
      statusText,
      style: TextStyle(
        fontSize: 14,
        color: plant.statusColor,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}