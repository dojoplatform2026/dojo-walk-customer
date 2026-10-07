import 'package:flutter/material.dart';

import '../../app/theme.dart';
import 'select_pet_screen.dart';

class WalkServiceScreen extends StatefulWidget {
  const WalkServiceScreen({super.key});

  @override
  State<WalkServiceScreen> createState() =>
      _WalkServiceScreenState();
}

class _WalkServiceScreenState
    extends State<WalkServiceScreen> {
  bool _immediate = true;

  void _continue() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SelectPetScreen(
          immediate: _immediate,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DojoWalkTheme.background,
      appBar: AppBar(
        title: const Text('Book a Walk'),
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
                'When does your dog\nneed a walk?',
                style: TextStyle(
                  color: DojoWalkTheme.text,
                  fontSize: 28,
                  height: 1.15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Choose a walk time that works best for you.',
                style: TextStyle(
                  color: DojoWalkTheme.mutedText,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 30),
              _WalkOption(
                selected: _immediate,
                icon: Icons.flash_on_rounded,
                title: 'Immediate Walk',
                description:
                    'Find an available walker as soon as possible.',
                badge: 'NOW',
                onTap: () {
                  setState(() {
                    _immediate = true;
                  });
                },
              ),
              const SizedBox(height: 14),
              _WalkOption(
                selected: !_immediate,
                icon: Icons.calendar_month_rounded,
                title: 'Schedule a Walk',
                description:
                    'Choose a date and time for your dog’s walk.',
                badge: 'SCHEDULE',
                onTap: () {
                  setState(() {
                    _immediate = false;
                  });
                },
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _continue,
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

class _WalkOption extends StatelessWidget {
  const _WalkOption({
    required this.selected,
    required this.icon,
    required this.title,
    required this.description,
    required this.badge,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String title;
  final String description;
  final String badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected
                  ? DojoWalkTheme.primary
                  : const Color(0xFFE8E8E8),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: selected
                      ? DojoWalkTheme.primary
                      : DojoWalkTheme.primary.withValues(
                          alpha: 0.10,
                        ),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Icon(
                  icon,
                  color: selected
                      ? Colors.white
                      : DojoWalkTheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              color: DojoWalkTheme.text,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? DojoWalkTheme.primary
                                    .withValues(alpha: 0.10)
                                : const Color(0xFFF3F3F3),
                            borderRadius:
                                BorderRadius.circular(8),
                          ),
                          child: Text(
                            badge,
                            style: TextStyle(
                              color: selected
                                  ? DojoWalkTheme.primary
                                  : DojoWalkTheme.mutedText,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: const TextStyle(
                        color: DojoWalkTheme.mutedText,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
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
