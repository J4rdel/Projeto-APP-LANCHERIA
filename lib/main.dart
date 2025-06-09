import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_page.dart';
import 'carrinho.dart';
import 'gerenciador_pedidos.dart'; // Adicionado
import 'package:firebase_core/firebase_core.dart'; // Importar Firebase Core
import 'firebase_options.dart'; // Importar as opções de configuração do Firebase

void main() async { // 1. Transforme main em async
  WidgetsFlutterBinding.ensureInitialized(); // 2. Garanta que os bindings do Flutter estão inicializados
  await Firebase.initializeApp( // 3. Inicialize o Firebase
    options: DefaultFirebaseOptions.currentPlatform, // Use as opções geradas pelo FlutterFire CLI
  );
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