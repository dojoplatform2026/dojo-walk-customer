import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/pet.dart';

class WalkDateTimeScreen extends StatefulWidget {
  const WalkDateTimeScreen({
    super.key,
    required this.pet,
    required this.immediate,
  });

  final Pet pet;
  final bool immediate;

  @override
  State<WalkDateTimeScreen> createState() =>
      _WalkDateTimeScreenState();
}

class _WalkDateTimeScreenState
    extends State<WalkDateTimeScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  Future<void> _pickDate() async {
    final now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(
        const Duration(days: 30),
      ),
      initialDate: _selectedDate ?? now,
    );

    if (date != null && mounted) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime:
          _selectedTime ?? TimeOfDay.now(),
    );

    if (time != null && mounted) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  void _continue() {
    if (!widget.immediate) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a date.'),
          ),
        );
        return;
      }

      if (_selectedTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a time.'),
          ),
        );
        return;
      }
    }

    final dateTime = widget.immediate
        ? DateTime.now()
        : DateTime(
            _selectedDate!.year,
            _selectedDate!.month,
            _selectedDate!.day,
            _selectedTime!.hour,
            _selectedTime!.minute,
          );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.immediate
              ? '${widget.pet.name} walk requested now.'
              : '${widget.pet.name} walk scheduled.',
        ),
      ),
    );

    // Next step:
    // Pickup Address screen yahan open hoga.
    debugPrint('Pet: ${widget.pet.id}');
    debugPrint('Immediate: ${widget.immediate}');
    debugPrint('Walk time: $dateTime');
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    return time.format(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DojoWalkTheme.background,
      appBar: AppBar(
        title: const Text('Walk Time'),
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
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                widget.immediate
                    ? 'When should ${widget.pet.name}\nstart walking?'
                    : 'Choose ${widget.pet.name}’s\nwalk time',
                style: const TextStyle(
                  color: DojoWalkTheme.text,
                  fontSize: 28,
                  height: 1.15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                widget.immediate
                    ? 'We will look for an available walker right now.'
                    : 'Select a date and time that works for you.',
                style: const TextStyle(
                  color: DojoWalkTheme.mutedText,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 28),
              if (widget.immediate)
                _ImmediateCard(
                  petName: widget.pet.name,
                )
              else ...[
                _SelectionCard(
                  icon: Icons.calendar_month_rounded,
                  title: 'Date',
                  value: _selectedDate == null
                      ? 'Choose date'
                      : _formatDate(
                          _selectedDate!,
                        ),
                  onTap: _pickDate,
                ),
                const SizedBox(height: 14),
                _SelectionCard(
                  icon: Icons.access_time_rounded,
                  title: 'Time',
                  value: _selectedTime == null
                      ? 'Choose time'
                      : _formatTime(
                          _selectedTime!,
                        ),
                  onTap: _pickTime,
                ),
              ],
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: DojoWalkTheme.primary.withValues(
                    alpha: 0.07,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.pets_rounded,
                      color: DojoWalkTheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Walking with ${widget.pet.name}',
                        style: const TextStyle(
                          color: DojoWalkTheme.text,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
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

class _ImmediateCard extends StatelessWidget {
  const _ImmediateCard({
    required this.petName,
  });

  final String petName;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: DojoWalkTheme.primary,
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: DojoWalkTheme.primary.withValues(
                alpha: 0.10,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.flash_on_rounded,
              color: DojoWalkTheme.primary,
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Walk Now',
            style: TextStyle(
              color: DojoWalkTheme.text,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'Find an available walker for $petName as soon as possible.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: DojoWalkTheme.mutedText,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectionCard extends StatelessWidget {
  const _SelectionCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFE7E7E7),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: DojoWalkTheme.primary.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: DojoWalkTheme.primary,
                  size: 27,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: DojoWalkTheme.mutedText,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      value,
                      style: const TextStyle(
                        color: DojoWalkTheme.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: DojoWalkTheme.mutedText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
