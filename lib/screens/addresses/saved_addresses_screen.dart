import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/pickup_address.dart';
import '../../services/pickup_address_service.dart';
import 'add_address_screen.dart';

class SavedAddressesScreen extends StatelessWidget {
  const SavedAddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final addressService = PickupAddressService();

    return Scaffold(
      backgroundColor: DojoWalkTheme.background,
      appBar: AppBar(
        title: const Text('Saved Addresses'),
      ),
      body: StreamBuilder<List<PickupAddress>>(
        stream: addressService.watchAddresses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
                  ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                color: DojoWalkTheme.primary,
              ),
            );
          }

          if (snapshot.hasError) {
            return _ErrorState(
              onRetry: () {},
            );
          }

          final addresses =
              snapshot.data ?? [];

          if (addresses.isEmpty) {
            return _EmptyState(
              onAdd: () {
                _openAddAddress(context);
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
            itemCount: addresses.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final address = addresses[index];

              return _AddressCard(
                address: address,
                onDelete: () {
                  _deleteAddress(
                    context,
                    addressService,
                    address,
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _openAddAddress(context);
        },
        backgroundColor: DojoWalkTheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(
          Icons.add_rounded,
        ),
        label: const Text(
          'Add Address',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Future<void> _openAddAddress(
    BuildContext context,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddAddressScreen(),
      ),
    );
  }

  Future<void> _deleteAddress(
    BuildContext context,
    PickupAddressService service,
    PickupAddress address,
  ) async {
    final shouldDelete =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Delete address?',
          ),
          content: Text(
            'Remove "${address.label}" from your saved addresses?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    try {
      await service.deleteAddress(address.id);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Address deleted.',
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not delete address. Please try again.',
          ),
        ),
      );
    }
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.address,
    required this.onDelete,
  });

  final PickupAddress address;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final cityLine = [
      address.city.trim(),
      address.pincode.trim(),
    ].where((value) => value.isNotEmpty).join(' • ');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: DojoWalkTheme.primary
                  .withValues(alpha: 0.10),
              borderRadius:
                  BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.location_on_rounded,
              color: DojoWalkTheme.primary,
              size: 25,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  address.label.isEmpty
                      ? 'Address'
                      : address.label,
                  style: const TextStyle(
                    color: DojoWalkTheme.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  address.address,
                  style: const TextStyle(
                    color: DojoWalkTheme.mutedText,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),

                if (cityLine.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    cityLine,
                    style: const TextStyle(
                      color:
                          DojoWalkTheme.mutedText,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                InkWell(
                  onTap: onDelete,
                  borderRadius:
                      BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 4,
                    ),
                    child: Row(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        Icon(
                          Icons
                              .delete_outline_rounded,
                          size: 18,
                          color: Colors.redAccent,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Delete',
                          style: TextStyle(
                            color:
                                Colors.redAccent,
                            fontSize: 13,
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.onAdd,
  });

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                color: DojoWalkTheme.primary
                    .withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_on_outlined,
                color: DojoWalkTheme.primary,
                size: 38,
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'No saved addresses',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: DojoWalkTheme.text,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Add your dog’s pickup location to make booking faster.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: DojoWalkTheme.mutedText,
                fontSize: 14,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: onAdd,
              style: ElevatedButton.styleFrom(
                minimumSize:
                    const Size(190, 52),
              ),
              child: const Text(
                'Add Address',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.onRetry,
  });

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: DojoWalkTheme.primary,
              size: 42,
            ),
            const SizedBox(height: 16),
            const Text(
              'Could not load addresses.',
              style: TextStyle(
                color: DojoWalkTheme.text,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onRetry,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
