class TransactionCategories {
  static const List<String> income = [
    'Salário',
    'Freelance',
    'Investimentos',
    'Presente',
    'Outros',
  ];

  static const List<String> expense = [
    'Alimentação',
    'Transporte',
    'Lazer',
    'Moradia',
    'Saúde',
    'Outros',
  ];

  static List<String> getAll() {
    final all = {...income, ...expense}.toList();
    all.sort();
    return all;
  }
}
