import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pet_provider.dart';
import '../models/pet.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green.shade600,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Consumer<PetProvider>(
        builder: (context, petProvider, child) {
          final pet = petProvider.pet;
          
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Profile Header
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.green.shade100,
                        child: Icon(
                          Icons.pets,
                          size: 50,
                          color: Colors.green.shade600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        pet.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Level ${pet.level} ${_getEvolutionStageText(pet.evolutionStage)}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.green.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Stats Section
              _buildStatsSection(pet),
              const SizedBox(height: 20),
              
              // Achievement Section
              _buildAchievementSection(pet),
              const SizedBox(height: 20),
              
              // Actions Section
              _buildActionsSection(context, petProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatsSection(Pet pet) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatRow('Experience Points', '${pet.xp} XP'),
            _buildStatRow('Happiness', '${pet.happiness}%'),
            _buildStatRow('Level', '${pet.level}'),
            _buildStatRow('Evolution Stage', _getEvolutionStageText(pet.evolutionStage)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementSection(Pet pet) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Achievements',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Achievement system coming soon!',
              style: TextStyle(
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsSection(BuildContext context, PetProvider petProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Change Pet Name'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showNameChangeDialog(context, petProvider),
            ),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Reset Pet'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showResetDialog(context, petProvider),
            ),
          ],
        ),
      ),
    );
  }

  String _getEvolutionStageText(PetEvolutionStage evolutionStage) {
    switch (evolutionStage.toString()) {
      case 'PetEvolutionStage.baby':
        return 'Baby';
      case 'PetEvolutionStage.child':
        return 'Child';
      case 'PetEvolutionStage.adult':
        return 'Adult';
      default:
        return 'Unknown';
    }
  }

  void _showNameChangeDialog(BuildContext context, PetProvider petProvider) {
    final controller = TextEditingController(text: petProvider.pet.name);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Pet Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Pet Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                petProvider.updatePetName(controller.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, PetProvider petProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Pet'),
        content: const Text(
          'Are you sure you want to reset your pet? This will delete all progress and cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement pet reset functionality
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}