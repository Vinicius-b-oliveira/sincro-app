class TransactionCategories {
  static const List<String> income = [
    'Aluguel Recebido',
    'Bônus',
    'Cashback',
    'Dividendos',
    'Freelance',
    'Investimentos',
    'Presente',
    'Reembolso',
    'Salário',
    'Vendas',
    'Outros',
  ];

  static const List<String> expense = [
    'Alimentação',
    'Assinaturas',
    'Beleza',
    'Casa',
    'Compras',
    'Contas',
    'Dívidas',
    'Doações',
    'Educação',
    'Eletrônicos',
    'Impostos',
    'Lazer',
    'Mercado',
    'Moradia',
    'Pets',
    'Saúde',
    'Serviços',
    'Transporte',
    'Vestuário',
    'Viagem',
    'Outros',
  ];

  static List<String> getAll() {
    final all = {...income, ...expense}.toList();
    all.sort();
    return all;
  }
}
