import 'package:flutter/material.dart';
import 'sorteo_page.dart';
import 'statistics_page.dart';

void main() {
  runApp(MaterialApp(
    title: 'Sorteo de Lotería',
    theme: ThemeData(
      primarySwatch: Colors.purple,
      scaffoldBackgroundColor: Colors.grey[100],
      textTheme: const TextTheme(
        headlineSmall: TextStyle(fontWeight: FontWeight.bold),
        bodyMedium: TextStyle(color: Colors.black87),
      ),
    ),
    home: const _LotteryApp(),
  ));
}

class _LotteryApp extends StatefulWidget {
  const _LotteryApp();

  @override
  State<_LotteryApp> createState() => _LotteryAppState();
}

class _LotteryAppState extends State<_LotteryApp> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sorteo de Lotería', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.purple[700],
        elevation: 4,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          SorteoPage(),
          StatisticsPage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.shuffle),
            label: 'Genera tu Sorteo',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart),
            label: 'Estadísticas',
          ),
        ],
      ),
    );
  }
}