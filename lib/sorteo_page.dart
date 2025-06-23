import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_selector/file_selector.dart';
import 'dart:math';
import 'lottery_service.dart';

class SorteoPage extends StatefulWidget {
  const SorteoPage({super.key});

  @override
  State<SorteoPage> createState() => _SorteoPageState();
}

class _SorteoPageState extends State<SorteoPage> {
  List<int> numbers = [];
  bool isLoading = false;
  String error = '';
  bool isFileUploaded = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> uploadExcelFile() async {
    setState(() {
      isLoading = true;
      error = '';
    });

    const XTypeGroup typeGroup = XTypeGroup(
      label: 'Excel files',
      extensions: ['xlsx'],
    );

    final XFile? file = await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
    if (file != null) {
      print('Selected file: ${file.path}'); // Debug
      var request = http.MultipartRequest('POST', Uri.parse('http://192.168.1.9:8080/api/upload')); // Replace with your IP
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        file.path,
        filename: file.name,
      ));

      try {
        var response = await request.send().timeout(const Duration(seconds: 30));
        var responseBody = await response.stream.bytesToString();
        print('Response status: ${response.statusCode}, Body: $responseBody'); // Debug
        if (response.statusCode == 200) {
          setState(() {
            isFileUploaded = true;
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Archivo subido exitosamente')),
          );
          await LotteryService.fetchStatistics();
        } else {
          throw Exception('Error al subir el archivo: ${response.reasonPhrase} - $responseBody');
        }
      } catch (e) {
        print('Error during upload: $e'); // Debug
        if (e.toString().contains('Connection refused')) {
          setState(() {
            error = 'El servidor no está disponible. Asegúrate de que esté ejecutándose en http://192.168.1.9:8080';
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
    } else {
      setState(() {
        error = 'No se seleccionó ningún archivo';
        isLoading = false;
      });
    }
  }

  Future<void> generateSorteo() async {
    if (!isFileUploaded) {
      setState(() {
        error = 'Por favor sube un archivo Excel primero';
      });
      return;
    }

    setState(() {
      isLoading = true;
      error = '';
    });

    try {
      final sorteoData = await LotteryService.fetchSorteo();
      setState(() {
        numbers = sorteoData;
        List<int> fiveBalotas = numbers.sublist(0, 5)..sort();
        int sixthBalota = numbers[5];
        if (sixthBalota < 1 || sixthBalota > 16) {
          sixthBalota = Random().nextInt(16) + 1;
        }
        numbers = [...fiveBalotas, sixthBalota];
        isLoading = false;
      });
    } catch (e) {
      if (e.toString().contains('Connection refused')) {
        setState(() {
          error = 'El servidor no está disponible. Asegúrate de que esté ejecutándose en http://192.168.1.9:8080';
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
            'Genera tu Sorteo',
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
          if (numbers.isNotEmpty)
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
                        'Resultado del Sorteo',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.purple),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Números: ${numbers.sublist(0, 5).join(', ')} | Extra: ${numbers[5]}',
                        style: const TextStyle(fontSize: 20, color: Colors.black87),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: uploadExcelFile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text(
                'Subir Archivo Excel',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: ElevatedButton(
              onPressed: isFileUploaded ? generateSorteo : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isFileUploaded ? Colors.purple : Colors.grey,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text(
                'Generar Sorteo',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}