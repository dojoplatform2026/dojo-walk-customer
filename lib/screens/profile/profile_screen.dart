import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../auth/login_screen.dart';
import 'change_mobile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Logout?',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
          content: const Text(
            'Are you sure you want to logout?',
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
                'Logout',
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

    if (confirm != true) return;

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

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final phoneNumber =
        user?.phoneNumber ?? 'No mobile number';

    return Scaffold(
      backgroundColor: DojoWalkTheme.background,
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            10,
            20,
            30,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
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
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color:
                            DojoWalkTheme.primary,
                        size: 34,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DOJO WALK',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Your Profile',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight:
                                  FontWeight.w800,
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
                'Account',
                style: TextStyle(
                  color: DojoWalkTheme.text,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 12),

              _ProfileTile(
                icon: Icons.phone_rounded,
                title: 'Mobile Number',
                subtitle: phoneNumber,
                trailing:
                    Icons.chevron_right_rounded,
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

              const SizedBox(height: 10),

              _ProfileTile(
                icon: Icons.person_outline_rounded,
                title: 'Account',
                subtitle: 'DOJO WALK Customer',
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

              const SizedBox(height: 12),

              _ProfileTile(
                icon: Icons.pets_rounded,
                title: 'My Pets',
                subtitle: 'Manage your dogs',
              ),

              const SizedBox(height: 10),

              _ProfileTile(
                icon: Icons.location_on_outlined,
                title: 'Saved Addresses',
                subtitle: 'Manage pickup locations',
              ),

              const SizedBox(height: 10),

              _ProfileTile(
                icon: Icons.receipt_long_outlined,
                title: 'My Bookings',
                subtitle: 'View your walk history',
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

              const SizedBox(height: 12),

              _ProfileTile(
                icon: Icons.help_outline_rounded,
                title: 'Help & Support',
                subtitle: 'We are here to help',
              ),

              const SizedBox(height: 10),

              _ProfileTile(
                icon: Icons.lock_outline_rounded,
                title: 'Privacy Policy',
                subtitle: 'Your privacy matters',
              ),

              const SizedBox(height: 10),

              _ProfileTile(
                icon: Icons.description_outlined,
                title: 'Terms & Conditions',
                subtitle: 'DOJO WALK terms',
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _logout(context),
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: Colors.red,
                  ),
                  label: const Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize:
                        const Size(double.infinity, 54),
                    side: const BorderSide(
                      color: Color(0xFFFFD4D4),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const Center(
                child: Column(
                  children: [
                    Text(
                      'DOJO WALK',
                      style: TextStyle(
                        color: DojoWalkTheme.text,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Happy walks. Happy dogs.',
                      style: TextStyle(
                        color:
                            DojoWalkTheme.mutedText,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        color:
                            DojoWalkTheme.mutedText,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final IconData? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: DojoWalkTheme.primary
                      .withValues(alpha: 0.09),
                  borderRadius:
                      BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: DojoWalkTheme.primary,
                  size: 24,
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
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color:
                            DojoWalkTheme.mutedText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null)
                Icon(
                  trailing,
                  color: DojoWalkTheme.mutedText,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
