import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/pet.dart';
import '../../services/pet_service.dart';
import 'add_pet_screen.dart';

class MyPetsScreen extends StatelessWidget {
  const MyPetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final petService = PetService();

    return Scaffold(
      backgroundColor: DojoWalkTheme.background,
      appBar: AppBar(
        title: const Text('My Pets'),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: DojoWalkTheme.primary,
        foregroundColor: Colors.white,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddPetScreen(),
            ),
          );
        },
        child: const Icon(Icons.add_rounded),
      ),
      body: StreamBuilder<List<Pet>>(
        stream: petService.watchPets(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Unable to load your pets.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: DojoWalkTheme.primary,
              ),
            );
          }

          final pets = snapshot.data ?? [];

          if (pets.isEmpty) {
            return _EmptyPets(
              onAdd: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddPetScreen(),
                  ),
                );
              },
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              20,
              20,
              20,
              100,
            ),
            itemCount: pets.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final pet = pets[index];

              return _PetCard(
                pet: pet,
                onDelete: () =>
                    _deletePet(context, petService, pet),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _deletePet(
    BuildContext context,
    PetService service,
    Pet pet,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Delete pet?',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            'Remove ${pet.name} from your pets?',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, true),
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await service.deletePet(pet.id);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${pet.name} removed.'),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not delete pet. Please try again.',
          ),
        ),
      );
    }
  }
}

class _PetCard extends StatelessWidget {
  const _PetCard({
    required this.pet,
    required this.onDelete,
  });

  final Pet pet;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE8E8E8),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: DojoWalkTheme.primary
                  .withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Icon(
              Icons.pets_rounded,
              color: DojoWalkTheme.primary,
              size: 30,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  pet.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  pet.breed.isEmpty
                      ? 'Breed not added'
                      : pet.breed,
                  style: const TextStyle(
                    color: DojoWalkTheme.mutedText,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${pet.age} ${pet.age == 1 ? 'year' : 'years'} • ${pet.gender}',
                  style: const TextStyle(
                    color: DojoWalkTheme.mutedText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: onDelete,
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyPets extends StatelessWidget {
  const _EmptyPets({
    required this.onAdd,
  });

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: DojoWalkTheme.primary
                    .withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.pets_rounded,
                color: DojoWalkTheme.primary,
                size: 50,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'No pets yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Add your dog to make booking a walk faster.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: DojoWalkTheme.mutedText,
                fontSize: 14,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: 180,
              child: ElevatedButton(
                onPressed: onAdd,
                child: const Text('Add Pet'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
