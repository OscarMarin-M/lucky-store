import 'package:flutter/material.dart';

import '../common/coming_soon_page.dart';
import '../history/history_page.dart';
import '../products/products_page.dart';
import '../purchases/purchase_page.dart';
import '../sales/sale_page.dart';

/// Bottom navigation (thumb reach). Tabs keep their state while switching.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 1; // Productos is the first screen that exists.

  static const _pages = <Widget>[
    ComingSoonPage(title: 'Inicio', icon: Icons.insights_outlined),
    ProductsPage(),
    SalePage(),
    PurchasePage(),
    HistoryPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
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
