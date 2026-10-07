import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../addresses/add_address_screen.dart';
import '../auth/login_screen.dart';
import '../booking/my_bookings_screen.dart';
import '../pets/my_pets_screen.dart';
import 'change_mobile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please login again.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: DojoWalkTheme.background,
      body: SafeArea(
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

            final age = data?['age'];

            final currentUser =
                FirebaseAuth.instance.currentUser;

            final phone =
                currentUser?.phoneNumber ?? '';

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                20,
                20,
                20,
                30,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Profile',
                    style: TextStyle(
                      color: DojoWalkTheme.text,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // PROFILE HEADER
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: DojoWalkTheme.primary,
                      borderRadius:
                          BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration:
                              const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            color:
                                DojoWalkTheme.primary,
                            size: 34,
                          ),
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                name.trim().isEmpty
                                    ? 'DOJO WALK Customer'
                                    : name.trim(),
                                style:
                                    const TextStyle(
                                  color: Colors.white,
                                  fontSize: 21,
                                  fontWeight:
                                      FontWeight.w800,
                                ),
                              ),

                              const SizedBox(height: 5),

                              Text(
                                phone.isEmpty
                                    ? 'Mobile number not available'
                                    : phone,
                                style:
                                    const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    'Personal Information',
                    style: TextStyle(
                      color: DojoWalkTheme.text,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        _InfoRow(
                          icon:
                              Icons.person_outline_rounded,
                          title: 'Name',
                          value: name.trim().isEmpty
                              ? 'Not added'
                              : name.trim(),
                        ),

                        const Divider(
                          height: 1,
                          indent: 18,
                          endIndent: 18,
                        ),

                        _InfoRow(
                          icon: Icons.cake_outlined,
                          title: 'Age',
                          value: age == null
                              ? 'Not added'
                              : '$age years',
                        ),

                        const Divider(
                          height: 1,
                          indent: 18,
                          endIndent: 18,
                        ),

                        _InfoRow(
                          icon:
                              Icons.phone_outlined,
                          title: 'Mobile',
                          value: phone.isEmpty
                              ? 'Not available'
                              : phone,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const ChangeMobileScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    'Your DOJO',
                    style: TextStyle(
                      color: DojoWalkTheme.text,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 14),

                  _MenuCard(
                    icon: Icons.pets_rounded,
                    title: 'My Pets',
                    subtitle: 'Manage your dogs',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const MyPetsScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 10),

                  _MenuCard(
                    icon:
                        Icons.location_on_outlined,
                    title: 'Saved Addresses',
                    subtitle:
                        'Manage pickup locations',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const AddAddressScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 10),

                  _MenuCard(
                    icon:
                        Icons.receipt_long_outlined,
                    title: 'My Bookings',
                    subtitle:
                        'View your walk history',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const MyBookingsScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    'Support',
                    style: TextStyle(
                      color: DojoWalkTheme.text,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 14),

                  _MenuCard(
                    icon:
                        Icons.help_outline_rounded,
                    title: 'Help & Support',
                    subtitle:
                        'Need help? We are here.',
                    onTap: () {},
                  ),

                  const SizedBox(height: 10),

                  _MenuCard(
                    icon:
                        Icons.description_outlined,
                    title: 'Terms & Privacy',
                    subtitle:
                        'App terms and privacy',
                    onTap: () {},
                  ),

                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _logout(context),
                      icon: const Icon(
                        Icons.logout_rounded,
                      ),
                      label: const Text(
                        'Logout',
                      ),
                      style:
                          OutlinedButton.styleFrom(
                        foregroundColor:
                            DojoWalkTheme.text,
                        minimumSize:
                            const Size(
                          double.infinity,
                          52,
                        ),
                        side: const BorderSide(
                          color: Color(0xFFE0E0E0),
                        ),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _logout(
    BuildContext context,
  ) async {
    final shouldLogout =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Logout?'),
          content: const Text(
            'Are you sure you want to logout?',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.pop(context, true),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) return;

    await FirebaseAuth.instance.signOut();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Icon(
              icon,
              color: DojoWalkTheme.primary,
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
                      color:
                          DojoWalkTheme.mutedText,
                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    value,
                    style: const TextStyle(
                      color: DojoWalkTheme.text,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            if (onTap != null)
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 15,
                color:
                    DojoWalkTheme.mutedText,
              ),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({
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
        borderRadius:
            BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                  color:
                      DojoWalkTheme.primary,
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
                        color:
                            DojoWalkTheme.text,
                        fontSize: 15,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: DojoWalkTheme
                            .mutedText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color:
                    DojoWalkTheme.mutedText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
