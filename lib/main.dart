import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'models/plant.dart';
import 'services/firestore_service.dart';
import 'screens/add_plant_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// _HomeScreenState manages the data and behavior for HomeScreen
class _HomeScreenState extends State<HomeScreen> {
  // Create an instance of FirestoreService to interact with the database
  final FirestoreService _firestoreService = FirestoreService();

  // initState runs once when the screen is first created
  @override
  void initState() {
    super.initState();
    // Initialize sample data in Firestore if the database is empty
    _firestoreService.initializeSampleData();
  }

  // This function updates a plant's last watered date in Firestore
  Future<void> _waterPlant(String plantId, String plantName) async {
    try {
      // Call Firestore service to update the plant's watering date
      await _firestoreService.waterPlant(plantId);
      // Check if the widget is still mounted before showing SnackBar
      if (mounted) {
        // Show a blue success message at the bottom of the screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$plantName watered! 💧'),
            backgroundColor: Colors.blue,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // If there's an error, show a red error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // This function deletes a plant from Firestore after user confirmation
  Future<void> _deletePlant(String plantId, String plantName) async {
    // Show a confirmation dialog before deleting
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Plant'),
        content: Text('Are you sure you want to delete $plantName?'),
        actions: [
          // Cancel button - closes dialog without deleting
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          // Delete button - confirms deletion
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    // Only delete if user confirmed
    if (confirmed == true) {
      try {
        // Call Firestore service to delete the plant
        await _firestoreService.deletePlant(plantId);
        if (mounted) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$plantName deleted'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        // Show error message if deletion fails
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting plant: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // build method creates the UI for the home screen
  @override
  Widget build(BuildContext context) {
    // Scaffold provides the basic structure (app bar, body, floating button)
    return Scaffold(
      // App bar at the top with title
      appBar: AppBar(
        title: const Text('🌿 My Plants'),
      ),
      // Body contains the main content - a list of plants from Firestore
      body: StreamBuilder<List<Plant>>(
        // Listen to real-time updates from Firestore
        stream: _firestoreService.getPlants(),
        builder: (context, snapshot) {
          // Show loading spinner while waiting for data
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Show error message if something went wrong
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  // Retry button to reload data
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Show message if there are no plants yet
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.eco, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No plants yet!',
                    style: TextStyle(fontSize: 20, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap the + button to add your first plant',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // Data loaded successfully - display the list of plants
          final plants = snapshot.data!;

          // Create a scrollable list of plant cards
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: plants.length,
            itemBuilder: (context, index) {
              final plant = plants[index];
              // Build each plant card
              return _buildPlantCard(plant);
            },
          );
        },
      ),
      // Floating action button (+ button) to add new plants
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to Add Plant screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPlantScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // This method builds the UI for each individual plant card
  Widget _buildPlantCard(Plant plant) {
    // Card widget creates a box with shadow and rounded corners
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Top row: emoji, plant info, and status circle
            Row(
              children: [
                // Display plant emoji
                Text(
                  plant.emoji,
                  style: const TextStyle(fontSize: 40),
                ),
                const SizedBox(width: 16),

                // Plant name, species, and watering status
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Plant name in bold
                      Text(
                        plant.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Plant species in smaller gray text
                      Text(
                        plant.species,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Show when plant needs to be watered
                      _buildWateringStatus(plant),
                    ],
                  ),
                ),
                // Colored circle showing plant status (red/orange/yellow/green)
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
            const SizedBox(height: 12),

            // Bottom row: Water and Delete buttons
            Row(
              children: [
                // Water button (blue)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _waterPlant(plant.id, plant.name),
                    icon: const Icon(Icons.water_drop, size: 18),
                    label: const Text('Water'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Delete button (red)
                ElevatedButton.icon(
                  onPressed: () => _deletePlant(plant.id, plant.name),
                  icon: const Icon(Icons.delete, size: 18),
                  label: const Text('Delete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.black,
                  ),
                ),
              ],
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