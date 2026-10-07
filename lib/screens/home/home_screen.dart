import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../booking/my_bookings_screen.dart';
import '../booking/walk_service_screen.dart';
import '../pets/my_pets_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      const _HomeContent(),
      const MyBookingsScreen(),
      const ProfileScreen(),
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
          setState(() {
            _currentIndex = index;
          });
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
            label: 'Bookings',
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
  const _HomeContent();

  String _greeting() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return 'Good morning 👋';
    }

    if (hour >= 12 && hour < 17) {
      return 'Good afternoon 👋';
    }

    if (hour >= 17 && hour < 21) {
      return 'Good evening 👋';
    }

    return 'Good night 🌙';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(
        child: Text('Please login again.'),
      );
    }

    return SafeArea(
      child: StreamBuilder<
          DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          final data = snapshot.data?.data();

          final name =
              data?['name'] as String? ?? '';

          final displayName =
              name.trim().isEmpty ? 'there' : name.trim();

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              20,
              18,
              20,
              28,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                // ─────────────────────────────
                // HEADER
                // ─────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            _greeting(),
                            style: const TextStyle(
                              color:
                                  DojoWalkTheme.mutedText,
                              fontSize: 14,
                              fontWeight:
                                  FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            name.trim().isEmpty
                                ? 'Ready for a walk?'
                                : '$displayName, ready for a walk?',
                            style: const TextStyle(
                              color: DojoWalkTheme.text,
                              fontSize: 24,
                              fontWeight:
                                  FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Notification
                    Material(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius:
                            BorderRadius.circular(16),
                        onTap: () {
                          // Notifications screen next.
                        },
                        child: const SizedBox(
                          width: 48,
                          height: 48,
                          child: Icon(
                            Icons
                                .notifications_none_rounded,
                            color:
                                DojoWalkTheme.text,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 26),

                // ─────────────────────────────
                // BOOK A WALK HERO
                // ─────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: DojoWalkTheme.primary,
                    borderRadius:
                        BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.pets_rounded,
                        color: Colors.white,
                        size: 32,
                      ),

                      const SizedBox(height: 16),

                      const Text(
                        'Ready for a walk?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 7),

                      const Text(
                        'Happy walks start here.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const WalkServiceScreen(),
                              ),
                            );
                          },
                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor:
                                DojoWalkTheme.primary,
                            minimumSize: Size.zero,
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 22,
                            ),
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(15),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize:
                                MainAxisSize.min,
                            children: [
                              Text(
                                'Book a Walk',
                                style: TextStyle(
                                  fontWeight:
                                      FontWeight.w800,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons
                                    .arrow_forward_rounded,
                                size: 19,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // ─────────────────────────────
                // YOUR DOJO
                // ─────────────────────────────
                const Text(
                  'Your DOJO',
                  style: TextStyle(
                    color: DojoWalkTheme.text,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 14),

                Material(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(20),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const MyPetsScreen(),
                        ),
                      );
                    },
                    borderRadius:
                        BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: DojoWalkTheme
                                  .primary
                                  .withValues(
                                alpha: 0.10,
                              ),
                              borderRadius:
                                  BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.pets_rounded,
                              color:
                                  DojoWalkTheme.primary,
                              size: 28,
                            ),
                          ),

                          const SizedBox(width: 14),

                          const Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'My Pets',
                                  style: TextStyle(
                                    color:
                                        DojoWalkTheme.text,
                                    fontSize: 16,
                                    fontWeight:
                                        FontWeight.w800,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Manage your dogs',
                                  style: TextStyle(
                                    color: DojoWalkTheme
                                        .mutedText,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const Icon(
                            Icons
                                .arrow_forward_ios_rounded,
                            size: 17,
                            color:
                                DojoWalkTheme.mutedText,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // ─────────────────────────────
                // UPCOMING WALK
                // ─────────────────────────────
                const Text(
                  'Upcoming Walk',
                  style: TextStyle(
                    color: DojoWalkTheme.text,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 14),

                _UpcomingWalkCard(
                  userId: user.uid,
                ),

                const SizedBox(height: 28),

                // ─────────────────────────────
                // WHY DOJO WALK
                // ─────────────────────────────
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
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                  child: const Column(
                    children: [
                      _BenefitRow(
                        icon:
                            Icons.verified_user_outlined,
                        title: 'Trusted walkers',
                        subtitle:
                            'Reliable care for your dog.',
                      ),
                      SizedBox(height: 16),
                      _BenefitRow(
                        icon:
                            Icons.flash_on_rounded,
                        title: 'Easy booking',
                        subtitle:
                            'Book a walk in just a few taps.',
                      ),
                      SizedBox(height: 16),
                      _BenefitRow(
                        icon:
                            Icons.favorite_outline_rounded,
                        title: 'Happy dogs',
                        subtitle:
                            'Every walk made with care.',
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

class _UpcomingWalkCard extends StatelessWidget {
  const _UpcomingWalkCard({
    required this.userId,
  });

  final String userId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<
        QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('bookings')
          .where(
            'customerId',
            isEqualTo: userId,
          )
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
                ConnectionState.waiting &&
            !snapshot.hasData) {
          return _EmptyWalkCard(
            icon: Icons.calendar_today_outlined,
            title: 'No upcoming walk',
            subtitle:
                'Your next booking will appear here.',
          );
        }

        final docs = snapshot.data?.docs ?? [];

        final upcoming = docs.where((doc) {
          final data = doc.data();

          final status =
              data['status'] as String? ?? '';

          final scheduledAt =
              data['scheduledAt'];

          if (scheduledAt is! Timestamp) {
            return false;
          }

          final date =
              scheduledAt.toDate();

          final isFuture =
              date.isAfter(DateTime.now());

          final activeStatus =
              status != 'completed' &&
              status != 'cancelled';

          return isFuture && activeStatus;
        }).toList();

        upcoming.sort((a, b) {
          final aDate =
              (a.data()['scheduledAt'] as Timestamp)
                  .toDate();

          final bDate =
              (b.data()['scheduledAt'] as Timestamp)
                  .toDate();

          return aDate.compareTo(bDate);
        });

        if (upcoming.isEmpty) {
          return _EmptyWalkCard(
            icon: Icons.calendar_today_outlined,
            title: 'No upcoming walk',
            subtitle:
                'Book a walk and it will appear here.',
          );
        }

        final booking = upcoming.first.data();

        final petName =
            booking['petName'] as String? ?? 'Your dog';

        final status =
            booking['status'] as String? ?? 'pending';

        final timestamp =
            booking['scheduledAt'] as Timestamp;

        final date = timestamp.toDate();

        final dateText =
            MaterialLocalizations.of(context)
                .formatMediumDate(date);

        final timeText =
            MaterialLocalizations.of(context)
                .formatTimeOfDay(
          TimeOfDay.fromDateTime(date),
        );

        return Material(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(20),
          child: InkWell(
            onTap: () {
              // Booking details screen next.
            },
            borderRadius:
                BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: DojoWalkTheme.primary
                          .withValues(alpha: 0.10),
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.pets_rounded,
                      color:
                          DojoWalkTheme.primary,
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
                          petName,
                          style: const TextStyle(
                            color:
                                DojoWalkTheme.text,
                            fontSize: 16,
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '$dateText • $timeText',
                          style: const TextStyle(
                            color:
                                DojoWalkTheme.mutedText,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _statusLabel(status),
                          style: const TextStyle(
                            color:
                                DojoWalkTheme.primary,
                            fontSize: 12,
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Icon(
                    Icons
                        .arrow_forward_ios_rounded,
                    size: 17,
                    color:
                        DojoWalkTheme.mutedText,
                  ),
                ],
              ),
            ),
          ),
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

class _EmptyWalkCard extends StatelessWidget {
  const _EmptyWalkCard({
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
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: DojoWalkTheme.primary
                  .withValues(alpha: 0.10),
              borderRadius:
                  BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: DojoWalkTheme.primary,
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
                    color: DojoWalkTheme.text,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color:
                        DojoWalkTheme.mutedText,
                    fontSize: 13,
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
            color: DojoWalkTheme.primary
                .withValues(alpha: 0.10),
            borderRadius:
                BorderRadius.circular(13),
          ),
          child: Icon(
            icon,
            color: DojoWalkTheme.primary,
            size: 22,
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
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
