import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/pet.dart';
import '../../services/pet_service.dart';
import '../pets/add_pet_screen.dart';

class SelectPetScreen extends StatefulWidget {
  const SelectPetScreen({super.key});

  @override
  State<SelectPetScreen> createState() => _SelectPetScreenState();
}

class _SelectPetScreenState extends State<SelectPetScreen> {
  final PetService _petService = PetService();

  String? _selectedPetId;

  Future<void> _addPet() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddPetScreen(),
      ),
    );

    if (result == true && mounted) {
      setState(() {});
    }
  }

  void _continue() {
    if (_selectedPetId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a pet.'),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pet selected.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DojoWalkTheme.background,
      appBar: AppBar(
        title: const Text('Select Pet'),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            20,
            20,
            20,
            24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Who is going\nfor a walk?',
                style: TextStyle(
                  color: DojoWalkTheme.text,
                  fontSize: 28,
                  height: 1.15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Select the dog you want to book a walk for.',
                style: TextStyle(
                  color: DojoWalkTheme.mutedText,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 26),
              Expanded(
                child: StreamBuilder<List<Pet>>(
                  stream: _petService.watchPets(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: DojoWalkTheme.primary,
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Unable to load pets.',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      );
                    }

                    final pets = snapshot.data ?? [];

                    if (pets.isEmpty) {
                      return _EmptyPets(
                        onAddPet: _addPet,
                      );
                    }

                    return ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: pets.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final pet = pets[index];

                        return _PetCard(
                          pet: pet,
                          selected:
                              _selectedPetId == pet.id,
                          onTap: () {
                            setState(() {
                              _selectedPetId = pet.id;
                            });
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton.icon(
                  onPressed: _addPet,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add New Pet'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor:
                        DojoWalkTheme.primary,
                    side: const BorderSide(
                      color: DojoWalkTheme.primary,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed:
                      _selectedPetId == null
                          ? null
                          : _continue,
                  child: const Text('Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PetCard extends StatelessWidget {
  const _PetCard({
    required this.pet,
    required this.selected,
    required this.onTap,
  });

  final Pet pet;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? DojoWalkTheme.primary
                  : const Color(0xFFE7E7E7),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color:
                      DojoWalkTheme.primary.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                      BorderRadius.circular(17),
                ),
                child: const Icon(
                  Icons.pets_rounded,
                  color: DojoWalkTheme.primary,
                  size: 30,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      pet.name,
                      style: const TextStyle(
                        color: DojoWalkTheme.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${pet.breed} • ${pet.age} years • ${pet.gender}',
                      style: const TextStyle(
                        color: DojoWalkTheme.mutedText,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: selected
                    ? DojoWalkTheme.primary
                    : const Color(0xFFBDBDBD),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyPets extends StatelessWidget {
  const _EmptyPets({
    required this.onAddPet,
  });

  final VoidCallback onAddPet;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              color:
                  DojoWalkTheme.primary.withValues(
                alpha: 0.10,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.pets_rounded,
              color: DojoWalkTheme.primary,
              size: 40,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'No pets added yet',
            style: TextStyle(
              color: DojoWalkTheme.text,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Add your dog before booking a walk.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: DojoWalkTheme.mutedText,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onAddPet,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(150, 48),
            ),
            child: const Text('Add Pet'),
          ),
        ],
      ),
    );
  }
}
