import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miniott/shared/widgets/back_button.dart';

import '../../../coins/presentation/providers/coin_providers.dart';

class ProfileVouchersScreen extends ConsumerStatefulWidget {
  const ProfileVouchersScreen({super.key});

  @override
  ConsumerState<ProfileVouchersScreen> createState() =>
      _ProfileVouchersScreenState();
}

class _ProfileVouchersScreenState extends ConsumerState<ProfileVouchersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(coinNotifierProvider.notifier).fetchCoinPackages();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(coinNotifierProvider);
    final packages = state.coinPackages;
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Vouchers'),
        leading: CustomIconButton(icon: Icons.arrow_back_ios_rounded),
      ),
      body: packages.isEmpty
          ? const Center(child: Text('No voucher offers available right now.'))
          : ListView.separated(
              itemCount: packages.length,
              separatorBuilder: (_, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = packages[index];
                return ListTile(
                  leading: const Icon(Icons.local_offer_outlined),
                  title: Text(item.title),
                  subtitle: Text('${item.coins} coins'),
                  trailing: Text('NPR ${item.price.toStringAsFixed(2)}'),
                );
              },
            ),
    );
  }
}
