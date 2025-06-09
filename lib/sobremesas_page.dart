import 'package:flutter/material.dart';

class SobremesasPage extends StatelessWidget {
  const SobremesasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nossas Sobremesas'),
        backgroundColor: Colors.deepOrange,
      ),
      body: const Center(
        child: Text(
          'Aguarde por deliciosas sobremesas!',
          style: TextStyle(fontSize: 20, color: Colors.grey),
        ),
      ),
    );
  }
}