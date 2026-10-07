import 'package:flutter/material.dart';

import '../../app/theme.dart';

class SelectPetScreen extends StatefulWidget {
  const SelectPetScreen({
    super.key,
  });

  @override
  State<SelectPetScreen> createState() =>
      _SelectPetScreenState();
}

class _SelectPetScreenState extends State<SelectPetScreen> {
  int? _selectedPet;

  final List<_PetOption> _pets = const [
    _PetOption(
      name: 'My Dog',
      breed: 'Add your pet details',
      icon: Icons.pets_rounded,
    ),
  ];

  void _continue() {
    if (_selectedPet == null) {
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

              const SizedBox(height: 28),

              ...List.generate(
                _pets.length,
                (index) {
                  final pet = _pets[index];
                  final selected = _selectedPet == index;

                  return Padding(
                    padding: const EdgeInsets.only(
                      bottom: 12,
                    ),
                    child: _PetCard(
                      pet: pet,
                      selected: selected,
                      onTap: () {
                        setState(() {
                          _selectedPet = index;
                        });
                      },
                    ),
                  );
                },
              ),

              const SizedBox(height: 4),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.add_rounded,
                  ),
                  label: const Text(
                    'Add New Pet',
                  ),
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

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _continue,
                  child: const Text(
                    'Continue',
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

class _PetCard extends StatelessWidget {
  const _PetCard({
    required this.pet,
    required this.selected,
    required this.onTap,
  });

  final _PetOption pet;
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
                  color: DojoWalkTheme.primary.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius: BorderRadius.circular(17),
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
                      pet.breed,
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

class _PetOption {
  const _PetOption({
    required this.name,
    required this.breed,
    required this.icon,
  });

  final String name;
  final String breed;
  final IconData icon;
}
