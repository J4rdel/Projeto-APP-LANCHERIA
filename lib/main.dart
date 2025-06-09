import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_page.dart';
import 'carrinho.dart';
import 'gerenciador_pedidos.dart'; // Adicionado

void main() {
  runApp(const LancheriaApp());
}

class LancheriaApp extends StatelessWidget {
  const LancheriaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider( // Usamos MultiProvider para ter múltiplos Providers
      providers: [
        ChangeNotifierProvider(create: (context) => Carrinho()),
        ChangeNotifierProvider(create: (context) => GerenciadorPedidos()), // Adicionado
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Lancheria',
        theme: ThemeData(
          primarySwatch: Colors.deepOrange,
          appBarTheme: const AppBarTheme(
            foregroundColor: Colors.white,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
            ),
          ),
        ),
        home: const HomePage(),
      ),
    );
  }
}