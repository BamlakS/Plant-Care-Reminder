import 'package:flutter/material.dart';
import '../models/plant.dart';
import '../services/firestore_service.dart';

// AddPlantScreen is a StatefulWidget for adding new plants to the database
class AddPlantScreen extends StatefulWidget {
  const AddPlantScreen({super.key});

  @override
  State<AddPlantScreen> createState() => _AddPlantScreenState();
}

// _AddPlantScreenState manages the form data and submission logic
class _AddPlantScreenState extends State<AddPlantScreen> {
  // Form key to validate and save form fields
  final _formKey = GlobalKey<FormState>();
  // Create an instance of FirestoreService to save plant to database
  final FirestoreService _firestoreService = FirestoreService();

  // Variables to store form input values
  String _name = '';
  String _species = '';
  int _wateringFrequency = 7;
  String _careInstructions = '';
  String _selectedEmoji = '🌿';

  // List of emoji options for the user to choose from
  final List<String> _emojiOptions = ['🌿', '🍃', '🌵', '🌱', '🪴', '🎋', '🌺', '🌻'];

  // Track loading state while saving to database
  bool _isLoading = false;

  // This function validates the form and saves the plant to Firestore
  Future<void> _savePlant() async {
    // Validate all form fields before proceeding
    if (_formKey.currentState!.validate()) {
      // Save all form field values to variables
      _formKey.currentState!.save();

      // Show loading indicator
      setState(() {
        _isLoading = true;
      });

      try {
        // Create a new Plant object with form data
        final newPlant = Plant(
          id: '',
          name: _name,
          species: _species,
          lastWatered: DateTime.now(),
          wateringFrequencyDays: _wateringFrequency,
          careInstructions: _careInstructions,
          emoji: _selectedEmoji,
        );

        // Save the new plant to Firestore database
        await _firestoreService.addPlant(newPlant);

        // Check if widget is still mounted before updating UI
        if (mounted) {
          // Close this screen and go back to home screen
          Navigator.pop(context);
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Plant added successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        // If there's an error, show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error adding plant: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        // Hide loading indicator after save is complete
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  // build method creates the UI for the add plant form
  @override
  Widget build(BuildContext context) {
    // Scaffold provides the basic structure (app bar and body)
    return Scaffold(
      // App bar at the top with title
      appBar: AppBar(
        title: const Text('Add New Plant'),
      ),
      // Show loading spinner while saving, otherwise show the form
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        // Form widget manages validation and saving of all form fields
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Label for emoji selection
              const Text(
                'Choose an emoji:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              // Emoji selection chips - user can tap to select an emoji
              Wrap(
                spacing: 8,
                children: _emojiOptions.map((emoji) {
                  return ChoiceChip(
                    label: Text(emoji, style: const TextStyle(fontSize: 24)),
                    selected: _selectedEmoji == emoji,
                    onSelected: (selected) {
                      setState(() {
                        _selectedEmoji = emoji;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Plant Name input field
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Plant Name',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., Sunny',
                ),
                // Validator checks if field is empty
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a plant name';
                  }
                  return null;
                },
                // Save the value when form is saved
                onSaved: (value) => _name = value!,
              ),
              const SizedBox(height: 16),

              // Plant Species input field
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Plant Species',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., Snake Plant',
                ),
                // Validator checks if field is empty
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a species';
                  }
                  return null;
                },
                // Save the value when form is saved
                onSaved: (value) => _species = value!,
              ),
              const SizedBox(height: 16),

              // Watering Frequency input field (numbers only)
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Watering Frequency (days)',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., 7',
                ),
                keyboardType: TextInputType.number,
                initialValue: '7',
                // Validator checks if field is empty and is a valid number
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter watering frequency';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                // Convert string to integer and save
                onSaved: (value) => _wateringFrequency = int.parse(value!),
              ),
              const SizedBox(height: 16),

              // Care Instructions input field (multiline)
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Care Instructions',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., Water when soil is dry',
                ),
                maxLines: 3,
                // Validator checks if field is empty
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter care instructions';
                  }
                  return null;
                },
                // Save the value when form is saved
                onSaved: (value) => _careInstructions = value!,
              ),
              const SizedBox(height: 24),

              // Add Plant button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _savePlant,
                  child: const Text(
                    'Add Plant',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
