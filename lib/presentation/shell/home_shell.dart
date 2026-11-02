import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/sync_providers.dart';
import '../home/home_page.dart';
import '../history/history_page.dart';
import '../products/products_page.dart';
import '../purchases/purchase_page.dart';
import '../sales/sale_page.dart';

/// Bottom navigation (thumb reach). Tabs keep their state while switching.
/// Pulling down any list of any tab syncs with the cloud.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = 0;

  static const _pages = <Widget>[
    HomePage(),
    ProductsPage(),
    SalePage(),
    PurchasePage(),
    HistoryPage(),
  ];

  @override
  Widget build(BuildContext context) {
    // Watching the controller here keeps the automatic sync running on
    // every tab.
    final sync = ref.watch(syncControllerProvider);
    final pages = IndexedStack(index: _index, children: _pages);
    return Scaffold(
      body: !sync.enabled
          ? pages
          : RefreshIndicator(
              // Below the tabs' own app bars.
              edgeOffset: MediaQuery.paddingOf(context).top + kToolbarHeight,
              // Lists live inside each tab's Scaffold, so accept vertical
              // scrolls at any depth (horizontal chips must not trigger it).
              notificationPredicate: (n) => n.metrics.axis == Axis.vertical,
              onRefresh: ref.read(syncControllerProvider.notifier).syncNow,
              child: pages,
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Productos',
          ),
          NavigationDestination(
            icon: Icon(Icons.point_of_sale_outlined),
            selectedIcon: Icon(Icons.point_of_sale),
            label: 'Vender',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_basket_outlined),
            selectedIcon: Icon(Icons.shopping_basket),
            label: 'Comprar',
          ),
          NavigationDestination(icon: Icon(Icons.history), label: 'Historial'),
        ],
      ),
    );
  }
}
