
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../screens/auth/login_screen.dart';
import '../../../screens/booking/my_bookings_screen.dart';
import '../../../screens/booking/walk_service_screen.dart';
import '../../../screens/pets/my_pets_screen.dart';
import '../../../screens/profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  void _requireLogin(String action) {
    if (FirebaseAuth.instance.currentUser != null) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const LoginScreen(),
      ),
    ).then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    final screens = [
      _HomeContent(
        user: user,
        onLoginRequired: _requireLogin,
      ),
      user == null
          ? _GuestPage(
              title: 'My Bookings',
              subtitle:
                  'Login to view and manage your bookings.',
              icon: Icons.calendar_month_rounded,
              onLogin: () => _requireLogin('bookings'),
            )
          : const MyBookingsScreen(),
      user == null
          ? _GuestPage(
              title: 'Your DOJO Account',
              subtitle:
                  'Login when you want to save your details or manage your account.',
              icon: Icons.person_outline_rounded,
              onLogin: () => _requireLogin('profile'),
            )
          : const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: DojoWalkTheme.background,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        backgroundColor: Colors.white,
        elevation: 8,
        indicatorColor:
            DojoWalkTheme.primary.withValues(alpha: 0.12),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(
              Icons.home_rounded,
              color: DojoWalkTheme.primary,
            ),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(
              Icons.receipt_long_rounded,
              color: DojoWalkTheme.primary,
            ),
            label: 'My Bookings',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(
              Icons.person_rounded,
              color: DojoWalkTheme.primary,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({
    required this.user,
    required this.onLoginRequired,
  });

  final User? user;
  final void Function(String action) onLoginRequired;

  String get _greeting {
    final hour = DateTime.now().hour;

    if (hour < 12) return 'Good morning 👋';
    if (hour < 17) return 'Good afternoon 👋';
    if (hour < 21) return 'Good evening 👋';
    return 'Good night 🌙';
  }

  void _openWalkServices(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const WalkServiceScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: user == null
            ? null
            : FirebaseFirestore.instance
                .collection('users')
                .doc(user!.uid)
                .snapshots(),
        builder: (context, snapshot) {
          final name =
              snapshot.data?.data()?['name'] as String? ?? '';

          final greetingName = name.trim();

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header and notifications
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _greeting,
                            style: const TextStyle(
                              color: DojoWalkTheme.mutedText,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            greetingName.isEmpty
                                ? 'Ready for a walk?'
                                : 'Hi, $greetingName!',
                            style: const TextStyle(
                              color: DojoWalkTheme.text,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Notifications screen will be connected next.',
                              ),
                            ),
                          );
                        },
                        child: const SizedBox(
                          width: 48,
                          height: 48,
                          child: Icon(
                            Icons.notifications_none_rounded,
                            color: DojoWalkTheme.text,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                // Address selector
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      if (user == null) {
                        onLoginRequired('address');
                        return;
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Address selection will be connected next.',
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            color: DojoWalkTheme.primary,
                            size: 27,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'YOUR LOCATION',
                                  style: TextStyle(
                                    color: DojoWalkTheme.mutedText,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user == null
                                      ? 'Choose your pickup address'
                                      : 'Select your saved address',
                                  style: const TextStyle(
                                    color: DojoWalkTheme.text,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: DojoWalkTheme.mutedText,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                // Hero
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: DojoWalkTheme.primary,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.pets_rounded,
                        color: Colors.white,
                        size: 34,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Happy dogs.\nHappier days.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 27,
                          height: 1.15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Trusted walks, right around the corner.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => _openWalkServices(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: DojoWalkTheme.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Book a Walk',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded, size: 19),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                const Text(
                  'Choose your walk',
                  style: TextStyle(
                    color: DojoWalkTheme.text,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: _WalkOptionCard(
                        icon: Icons.directions_walk_rounded,
                        title: 'One-Time Walk',
                        subtitle: 'Book when you need',
                        onTap: () => _openWalkServices(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _WalkOptionCard(
                        icon: Icons.calendar_month_rounded,
                        title: 'Regular Walk',
                        subtitle: 'Build a routine',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Regular Walk scheduling will be added next.',
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Your furry friends',
                        style: TextStyle(
                          color: DojoWalkTheme.text,
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        if (user == null) {
                          onLoginRequired('pets');
                          return;
                        }

                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const MyPetsScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'View all',
                        style: TextStyle(
                          color: DojoWalkTheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () {
                      if (user == null) {
                        onLoginRequired('pets');
                        return;
                      }

                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const MyPetsScreen(),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(17),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: DojoWalkTheme.primary
                                  .withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Icon(
                              Icons.pets_rounded,
                              color: DojoWalkTheme.primary,
                              size: 27,
                            ),
                          ),
                          const SizedBox(width: 13),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user == null
                                      ? 'Add your first dog'
                                      : 'My Dogs',
                                  style: const TextStyle(
                                    color: DojoWalkTheme.text,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user == null
                                      ? 'Login when you want to save pet details.'
                                      : 'Manage your saved pet details',
                                  style: const TextStyle(
                                    color: DojoWalkTheme.mutedText,
                                    fontSize: 12,
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
                ),

                if (user != null) ...[
                  const SizedBox(height: 28),
                  const Text(
                    'Upcoming Walk',
                    style: TextStyle(
                      color: DojoWalkTheme.text,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _UpcomingWalkCard(userId: user!.uid),
                ],

                const SizedBox(height: 28),

                const Text(
                  'Why DOJO WALK?',
                  style: TextStyle(
                    color: DojoWalkTheme.text,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Column(
                    children: [
                      _BenefitRow(
                        icon: Icons.verified_user_outlined,
                        title: 'Trusted walkers',
                        subtitle: 'Reliable care for your dog.',
                      ),
                      SizedBox(height: 18),
                      _BenefitRow(
                        icon: Icons.flash_on_rounded,
                        title: 'Easy booking',
                        subtitle: 'Book in just a few taps.',
                      ),
                      SizedBox(height: 18),
                      _BenefitRow(
                        icon: Icons.favorite_outline_rounded,
                        title: 'Happy dogs',
                        subtitle: 'Every walk made with care.',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _WalkOptionCard extends StatelessWidget {
  const _WalkOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: DojoWalkTheme.primary, size: 30),
              const SizedBox(height: 13),
              Text(
                title,
                style: const TextStyle(
                  color: DojoWalkTheme.text,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: const TextStyle(
                  color: DojoWalkTheme.mutedText,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UpcomingWalkCard extends StatelessWidget {
  const _UpcomingWalkCard({required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('bookings')
          .where('customerId', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _InfoCard(
            icon: Icons.cloud_off_outlined,
            title: 'Could not load bookings',
            subtitle: 'Please check your connection and try again.',
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(
              child: CircularProgressIndicator(
                color: DojoWalkTheme.primary,
              ),
            ),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        final upcoming = docs.where((doc) {
          final data = doc.data();
          final status = data['status'] as String? ?? '';
          final scheduledAt = data['scheduledAt'];

          if (scheduledAt is! Timestamp) return false;

          final date = scheduledAt.toDate();
          final active = ![
            'completed',
            'cancelled',
          ].contains(status);

          return active && date.isAfter(DateTime.now());
        }).toList();

        upcoming.sort((a, b) {
          final aDate =
              (a.data()['scheduledAt'] as Timestamp).toDate();
          final bDate =
              (b.data()['scheduledAt'] as Timestamp).toDate();
          return aDate.compareTo(bDate);
        });

        if (upcoming.isEmpty) {
          return const _InfoCard(
            icon: Icons.calendar_today_outlined,
            title: 'No upcoming walk',
            subtitle: 'Your next booking will appear here.',
          );
        }

        final booking = upcoming.first.data();
        final petName = booking['petName'] as String? ?? 'Your dog';
        final status = booking['status'] as String? ?? 'pending';
        final date = (booking['scheduledAt'] as Timestamp).toDate();

        final dateText =
            MaterialLocalizations.of(context).formatMediumDate(date);
        final timeText = MaterialLocalizations.of(context)
            .formatTimeOfDay(TimeOfDay.fromDateTime(date));

        return _InfoCard(
          icon: Icons.pets_rounded,
          title: petName,
          subtitle: '$dateText · $timeText\n${_statusLabel(status)}',
        );
      },
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'finding_walker':
        return 'Finding walker';
      case 'walker_assigned':
        return 'Walker assigned';
      case 'walker_arriving':
        return 'Walker arriving';
      case 'walk_started':
        return 'Walk in progress';
      case 'pending':
        return 'Scheduled';
      default:
        return 'Upcoming';
    }
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: DojoWalkTheme.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: DojoWalkTheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: DojoWalkTheme.text,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: DojoWalkTheme.mutedText,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: DojoWalkTheme.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: DojoWalkTheme.primary, size: 22),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: DojoWalkTheme.text,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color: DojoWalkTheme.mutedText,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GuestPage extends StatelessWidget {
  const _GuestPage({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onLogin,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 58,
                color: DojoWalkTheme.primary,
              ),
              const SizedBox(height: 18),
              Text(
                title,
                style: const TextStyle(
                  color: DojoWalkTheme.text,
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: DojoWalkTheme.mutedText,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 22),
              ElevatedButton(
                onPressed: onLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: DojoWalkTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 14,
                  ),
                ),
                child: const Text('Login / Sign up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
