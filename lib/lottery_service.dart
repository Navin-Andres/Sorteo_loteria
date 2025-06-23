import 'package:http/http.dart' as http;
import 'dart:convert';

class LotteryService {
  static const String baseUrl = 'http://192.168.1.9:8080'; // Replace with your IP

  static Future<List<int>> fetchSorteo() async {
    final sorteoResponse = await http.get(Uri.parse('$baseUrl/api/sorteo'));
    if (sorteoResponse.statusCode == 200) {
      final data = json.decode(sorteoResponse.body);
      return List<int>.from(data['balotas']);
    } else {
      throw Exception('Error al obtener el sorteo: ${sorteoResponse.statusCode} - ${sorteoResponse.body}');
    }
  }

  static Future<List<int>> fetchStatistics() async {
    final statsResponse = await http.get(Uri.parse('$baseUrl/api/statistics'));
    if (statsResponse.statusCode == 200) {
      final data = json.decode(statsResponse.body);
      return List<int>.from(data['top_three_numbers']);
    } else {
      throw Exception('Error al obtener estadísticas: ${statsResponse.statusCode} - ${statsResponse.body}');
    }
  }
}