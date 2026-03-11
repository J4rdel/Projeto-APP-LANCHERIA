import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  bool _isHandling = false;

  void _popError(String message) {
    if (!mounted) return;
    Navigator.of(context).pop({'error': message});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ler QR Code da Mesa')),
      body: MobileScanner(
        onDetect: (capture) {
          if (_isHandling) return;

          final raw = capture.barcodes.isNotEmpty ? capture.barcodes.first.rawValue : null;
          if (raw == null || raw.isEmpty) return;

          _isHandling = true;
          try {
            final decoded = json.decode(raw);
            if (decoded is! Map<String, dynamic>) {
              _popError('QR inválido (esperado JSON).');
              return;
            }

            final backendUrl = decoded['backendUrl']?.toString() ?? '';
            final mesaId = decoded['mesaId']?.toString() ?? '';
            final mesaNumeroRaw = decoded['mesaNumero'];
            final mesaNumero = int.tryParse(mesaNumeroRaw?.toString() ?? '');

            if (backendUrl.isEmpty || mesaId.isEmpty || mesaNumero == null) {
              _popError('QR inválido (campos faltando).');
              return;
            }

            if (!mounted) return;
            Navigator.of(context).pop({
              'backendUrl': backendUrl,
              'mesaId': mesaId,
              'mesaNumero': mesaNumero,
            });
          } catch (_) {
            _popError('QR inválido (JSON malformado).');
          } finally {
            _isHandling = false;
          }
        },
      ),
    );
  }
}
