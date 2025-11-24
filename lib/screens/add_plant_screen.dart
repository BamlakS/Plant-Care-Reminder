import 'package:flutter/material.dart';
import '../models/plant.dart';
import '../services/firestore_service.dart';

class AddPlantScreen extends StatefulWidget {
  const AddPlantScreen({super.key});

  @override
  State<AddPlantScreen> createState() => _AddPlantScreenState();
}

class _AddPlantScreenState extends State<AddPlantScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();

  String _name = '';
  String _species = '';
  int _wateringFrequency = 7;
  String _careInstructions = '';
  String _selectedEmoji = '🌿';

  final List<String> _emojiOptions = ['🌿', '🍃', '🌵', '🌱', '🪴', '🎋', '🌺', '🌻'];

  bool _isLoading = false;

  Future<void> _savePlant() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _isLoading = true;
      });

      try {
        final newPlant = Plant(
          id: '',
          name: _name,
          species: _species,
          lastWatered: DateTime.now(),
          wateringFrequencyDays: _wateringFrequency,
          careInstructions: _careInstructions,
          emoji: _selectedEmoji,
        );

        await _firestoreService.addPlant(newPlant);

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Plant added successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error adding plant: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Plant'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Choose an emoji:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
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

              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Plant Name',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., Sunny',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a plant name';
                  }
                  return null;
                },
                onSaved: (value) => _name = value!,
              ),
              const SizedBox(height: 16),

              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Plant Species',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., Snake Plant',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a species';
                  }
                  return null;
                },
                onSaved: (value) => _species = value!,
              ),
              const SizedBox(height: 16),

              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Watering Frequency (days)',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., 7',
                ),
                keyboardType: TextInputType.number,
                initialValue: '7',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter watering frequency';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                onSaved: (value) => _wateringFrequency = int.parse(value!),
              ),
              const SizedBox(height: 16),

              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Care Instructions',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., Water when soil is dry',
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter care instructions';
                  }
                  return null;
                },
                onSaved: (value) => _careInstructions = value!,
              ),
              const SizedBox(height: 24),

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