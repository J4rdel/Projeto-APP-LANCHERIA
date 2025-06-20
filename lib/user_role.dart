enum UserRole {
  suporte, // Acesso total
  gerente, // Acesso a pedidos, configuração de mesa, notificações
  cliente, // Associado a uma mesa específica
  none, // Nenhum usuário logado ou mesa configurada
}
