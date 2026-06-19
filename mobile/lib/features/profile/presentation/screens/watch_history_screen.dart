import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miniott/shared/widgets/back_button.dart';

import '../../../coins/presentation/providers/coin_providers.dart';

class WatchHistoryScreen extends ConsumerStatefulWidget {
  const WatchHistoryScreen({super.key});

  @override
  ConsumerState<WatchHistoryScreen> createState() => _WatchHistoryScreenState();
}

class _WatchHistoryScreenState extends ConsumerState<WatchHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(coinNotifierProvider.notifier).fetchTransactionHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(coinNotifierProvider);
    final txns = state.transactions;
    return Scaffold(
      appBar: AppBar(title: const Text('Watch History'),
      leading: CustomIconButton(icon: Icons.arrow_back_ios_rounded),
      ),
      body: txns.isEmpty
          ? const Center(
              child: Text('No watch history available yet.'),
            )
          : ListView.separated(
              itemCount: txns.length,
              separatorBuilder: (_, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = txns[index];
                return ListTile(
                  leading: const Icon(Icons.history_rounded),
                  title: Text(item.description ?? 'Activity'),
                  subtitle: Text(item.type),
                  trailing: Text(item.createdAt.toLocal().toString()),
                );
              },
            ),
    );
  }
}
