import 'package:flutter/material.dart';
import 'lottery_service.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  List<int> topThreeNumbers = [];
  bool isLoading = false;
  String error = '';

  @override
  void initState() {
    super.initState();
    _fetchStatistics();
  }

  Future<void> _fetchStatistics() async {
    setState(() {
      isLoading = true;
      error = '';
    });

    try {
      final statsData = await LotteryService.fetchStatistics();
      setState(() {
        topThreeNumbers = statsData;
        isLoading = false;
      });
    } catch (e) {
      if (e.toString().contains('Connection refused')) {
        setState(() {
          error = 'El servidor no está disponible. Asegúrate de que esté ejecutándose en http://192.168.1.x:8080';
          isLoading = false;
        });
      } else if (e.toString().contains('Timeout')) {
        setState(() {
          error = 'La solicitud tardó demasiado. Verifica tu conexión o el servidor.';
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Error: $e';
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Estadísticas',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.purple),
          ),
          const SizedBox(height: 20),
          if (isLoading)
            const Center(child: CircularProgressIndicator(color: Colors.purple)),
          if (error.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Center(
                child: Text(
                  error,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          if (topThreeNumbers.isNotEmpty)
            Center(
              child: Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 20),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Tres Números Más Frecuentes',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.purple),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        topThreeNumbers.join(', '),
                        style: const TextStyle(fontSize: 20, color: Colors.black87),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}