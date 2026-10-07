import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/pickup_address.dart';
import '../../services/pickup_address_service.dart';
import '../addresses/add_address_screen.dart';
import 'booking_summary_screen.dart';

class PickupAddressScreen extends StatefulWidget {
  const PickupAddressScreen({
    super.key,
    required this.petName,
    required this.immediate,
    required this.walkDateTime,
  });

  final String petName;
  final bool immediate;
  final DateTime walkDateTime;

  @override
  State<PickupAddressScreen> createState() =>
      _PickupAddressScreenState();
}

class _PickupAddressScreenState
    extends State<PickupAddressScreen> {
  final PickupAddressService _addressService =
      PickupAddressService();

  String? _selectedAddressId;

  Future<void> _addAddress() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const AddAddressScreen(),
      ),
    );

    if (result == true && mounted) {
      setState(() {});
    }
  }

  void _continue(List<PickupAddress> addresses) {
    if (_selectedAddressId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select a pickup address.',
          ),
        ),
      );
      return;
    }

    PickupAddress? selected;

    for (final address in addresses) {
      if (address.id == _selectedAddressId) {
        selected = address;
        break;
      }
    }

    if (selected == null) {
      setState(() {
        _selectedAddressId = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select a valid pickup address.',
          ),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingSummaryScreen(
          petName: widget.petName,
          immediate: widget.immediate,
          walkDateTime: widget.walkDateTime,
          address: selected!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DojoWalkTheme.background,
      appBar: AppBar(
        title: const Text('Pickup Address'),
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
          child: StreamBuilder<List<PickupAddress>>(
            stream: _addressService.watchAddresses(),
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
                return const Center(
                  child: Text(
                    'Unable to load addresses.',
                    style: TextStyle(
                      color: DojoWalkTheme.mutedText,
                      fontSize: 15,
                    ),
                  ),
                );
              }

              final addresses =
                  snapshot.data ?? <PickupAddress>[];

              if (addresses.isEmpty) {
                return Column(
                  children: [
                    Expanded(
                      child: _EmptyAddresses(
                        onAddAddress: _addAddress,
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: OutlinedButton.icon(
                        onPressed: _addAddress,
                        icon: const Icon(
                          Icons.add_location_alt_outlined,
                        ),
                        label: const Text(
                          'Add New Address',
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor:
                              DojoWalkTheme.primary,
                          side: const BorderSide(
                            color:
                                DojoWalkTheme.primary,
                          ),
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }

              final selectedExists = addresses.any(
                (address) =>
                    address.id == _selectedAddressId,
              );

              if (!selectedExists &&
                  _selectedAddressId != null) {
                WidgetsBinding.instance
                    .addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() {
                      _selectedAddressId = null;
                    });
                  }
                });
              }

              return Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Where should we\npick up your dog?',
                    style: TextStyle(
                      color: DojoWalkTheme.text,
                      fontSize: 28,
                      height: 1.15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Choose a saved pickup address for ${widget.petName}.',
                    style: const TextStyle(
                      color:
                          DojoWalkTheme.mutedText,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Saved addresses',
                          style: TextStyle(
                            color:
                                DojoWalkTheme.text,
                            fontSize: 18,
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _addAddress,
                        icon: const Icon(
                          Icons.add_rounded,
                          size: 20,
                        ),
                        label:
                            const Text('Add new'),
                        style: TextButton.styleFrom(
                          foregroundColor:
                              DojoWalkTheme.primary,
                          textStyle:
                              const TextStyle(
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: addresses.length,
                      separatorBuilder:
                          (_, __) =>
                              const SizedBox(
                        height: 12,
                      ),
                      itemBuilder:
                          (context, index) {
                        final address =
                            addresses[index];

                        return _AddressCard(
                          address: address,
                          selected:
                              _selectedAddressId ==
                                  address.id,
                          onTap: () {
                            setState(() {
                              _selectedAddressId =
                                  address.id;
                            });
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
                      onPressed: _addAddress,
                      icon: const Icon(
                        Icons.add_location_alt_outlined,
                      ),
                      label: const Text(
                        'Add New Address',
                      ),
                      style:
                          OutlinedButton.styleFrom(
                        foregroundColor:
                            DojoWalkTheme.primary,
                        side: const BorderSide(
                          color:
                              DojoWalkTheme.primary,
                        ),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            16,
                          ),
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
                          _selectedAddressId == null
                              ? null
                              : () => _continue(
                                    addresses,
                                  ),
                      child: const Text(
                        'Continue',
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.address,
    required this.selected,
    required this.onTap,
  });

  final PickupAddress address;
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
          duration:
              const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(20),
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
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color:
                      DojoWalkTheme.primary.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                      BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: DojoWalkTheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      address.label,
                      style: const TextStyle(
                        color: DojoWalkTheme.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      address.address,
                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        color:
                            DojoWalkTheme.mutedText,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${address.city} • ${address.pincode}',
                      style: const TextStyle(
                        color:
                            DojoWalkTheme.mutedText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                selected
                    ? Icons
                        .radio_button_checked_rounded
                    : Icons
                        .radio_button_off_rounded,
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

class _EmptyAddresses extends StatelessWidget {
  const _EmptyAddresses({
    required this.onAddAddress,
  });

  final VoidCallback onAddAddress;

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
              Icons.location_on_rounded,
              color: DojoWalkTheme.primary,
              size: 40,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'No address saved',
            style: TextStyle(
              color: DojoWalkTheme.text,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Add your pickup address before booking.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: DojoWalkTheme.mutedText,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onAddAddress,
            style: ElevatedButton.styleFrom(
              minimumSize:
                  const Size(160, 48),
            ),
            child: const Text(
              'Add Address',
            ),
          ),
        ],
      ),
    );
  }
}
