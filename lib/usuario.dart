import 'package:lancheria/user_role.dart';

class Usuario {
  final String
  id; // UID do Firebase Auth para Suporte/Gerente, ou ID da Mesa para Cliente
  final String? email; // Para Suporte/Gerente
  final String nome; // Nome do Suporte/Gerente, ou "Mesa X" para Cliente
  final UserRole role;
  final String?
  assignedTableIdForDevice; // Se um gerente logou e configurou esta mesa

  Usuario({
    required this.id,
    this.email,
    required this.nome,
    required this.role,
    this.assignedTableIdForDevice,
  });

  // Construtor de fábrica para facilitar a criação de um usuário "Cliente de Mesa"
  factory Usuario.mesaCliente(String mesaId) {
    return Usuario(
      id: mesaId, // Usamos o ID da mesa como ID do "usuário" cliente
      nome: 'Mesa $mesaId',
      role: UserRole.cliente,
      assignedTableIdForDevice: mesaId,
    );
  }
}
