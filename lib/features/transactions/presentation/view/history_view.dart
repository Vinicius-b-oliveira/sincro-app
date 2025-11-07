import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

enum TransactionType { all, income, expense }

class HistoryView extends HookConsumerWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategories = useState<Set<String>>({});
    final selectedLocations = useState<Set<String>>({});
    final selectedGroups = useState<Set<String>>({});
    final selectedTransactionType = useState(TransactionType.all);
    final isFilterExpanded = useState(false);

    final searchController = useTextEditingController();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSearchBar(context, searchController),
            const SizedBox(height: 16),

            _buildFilterHeader(
              context,
              isFilterExpanded,
              selectedCategories,
              selectedLocations,
              selectedGroups,
              selectedTransactionType,
            ),

            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: isFilterExpanded.value ? null : 0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isFilterExpanded.value ? 1.0 : 0.0,
                child: isFilterExpanded.value
                    ? _buildFilterPanel(
                        context,
                        selectedCategories,
                        selectedLocations,
                        selectedGroups,
                        selectedTransactionType,
                      )
                    : const SizedBox.shrink(),
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: _buildTransactionList(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(
    BuildContext context,
    TextEditingController controller,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: 'Pesquisar por nome da transação...',
        fillColor: colorScheme.surfaceContainerHighest,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
        prefixIcon: Icon(
          Icons.search,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildFilterHeader(
    BuildContext context,
    ValueNotifier<bool> isFilterExpanded,
    ValueNotifier<Set<String>> selectedCategories,
    ValueNotifier<Set<String>> selectedLocations,
    ValueNotifier<Set<String>> selectedGroups,
    ValueNotifier<TransactionType> selectedTransactionType,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    final hasActiveFilters =
        selectedCategories.value.isNotEmpty ||
        selectedLocations.value.isNotEmpty ||
        selectedGroups.value.isNotEmpty ||
        selectedTransactionType.value != TransactionType.all;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () => isFilterExpanded.value = !isFilterExpanded.value,
              icon: Icon(
                isFilterExpanded.value
                    ? Icons.filter_list_off
                    : Icons.filter_list,
              ),
              label: Text(
                isFilterExpanded.value ? 'Ocultar Filtros' : 'Filtros',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: hasActiveFilters
                    ? colorScheme.primary
                    : colorScheme.surfaceContainerHighest,
                foregroundColor: hasActiveFilters
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 8),
            if (hasActiveFilters)
              TextButton(
                onPressed: () => _clearAllFilters(
                  selectedCategories,
                  selectedLocations,
                  selectedGroups,
                  selectedTransactionType,
                ),
                child: const Text('Limpar todos'),
              ),
          ],
        ),

        if (hasActiveFilters) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              ...selectedCategories.value.map(
                (category) => _buildFilterChip(
                  context,
                  category,
                  () => selectedCategories.value = selectedCategories.value
                      .difference({category}),
                ),
              ),
              ...selectedLocations.value.map(
                (location) => _buildFilterChip(
                  context,
                  location,
                  () => selectedLocations.value = selectedLocations.value
                      .difference({location}),
                ),
              ),
              ...selectedGroups.value.map(
                (group) => _buildFilterChip(
                  context,
                  group,
                  () => selectedGroups.value = selectedGroups.value.difference({
                    group,
                  }),
                ),
              ),
              if (selectedTransactionType.value != TransactionType.all)
                _buildFilterChip(
                  context,
                  selectedTransactionType.value == TransactionType.income
                      ? 'Entradas'
                      : 'Saídas',
                  () => selectedTransactionType.value = TransactionType.all,
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    VoidCallback onRemove,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Chip(
      label: Text(label),
      onDeleted: onRemove,
      deleteIcon: const Icon(Icons.close, size: 16),
      backgroundColor: colorScheme.primaryContainer,
      labelStyle: TextStyle(color: colorScheme.onPrimaryContainer),
      deleteIconColor: colorScheme.onPrimaryContainer,
    );
  }

  Widget _buildFilterPanel(
    BuildContext context,
    ValueNotifier<Set<String>> selectedCategories,
    ValueNotifier<Set<String>> selectedLocations,
    ValueNotifier<Set<String>> selectedGroups,
    ValueNotifier<TransactionType> selectedTransactionType,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final categories = [
      'Alimentação',
      'Transporte',
      'Lazer',
      'Contas',
      'Investimento',
      'Outros',
    ];
    final locations = [
      'Restaurante',
      'Uber',
      'Cinema',
      'Mercado',
      'Padaria',
      'Posto',
    ];
    final groups = ['Família', 'Trabalho', 'Amigos', 'Faculdade'];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tipo de Transação',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildTransactionTypeChip(
                'Todas',
                selectedTransactionType.value == TransactionType.all,
                () => selectedTransactionType.value = TransactionType.all,
                colorScheme,
              ),
              const SizedBox(width: 8),
              _buildTransactionTypeChip(
                'Entradas',
                selectedTransactionType.value == TransactionType.income,
                () => selectedTransactionType.value = TransactionType.income,
                colorScheme,
              ),
              const SizedBox(width: 8),
              _buildTransactionTypeChip(
                'Saídas',
                selectedTransactionType.value == TransactionType.expense,
                () => selectedTransactionType.value = TransactionType.expense,
                colorScheme,
              ),
            ],
          ),

          const SizedBox(height: 24),

          _buildFilterSection(
            context,
            'Categorias',
            categories,
            selectedCategories.value,
            (category, isSelected) {
              if (isSelected) {
                selectedCategories.value = selectedCategories.value.union({
                  category,
                });
              } else {
                selectedCategories.value = selectedCategories.value.difference({
                  category,
                });
              }
            },
          ),

          const SizedBox(height: 24),

          _buildFilterSection(
            context,
            'Locais',
            locations,
            selectedLocations.value,
            (location, isSelected) {
              if (isSelected) {
                selectedLocations.value = selectedLocations.value.union({
                  location,
                });
              } else {
                selectedLocations.value = selectedLocations.value.difference({
                  location,
                });
              }
            },
          ),

          const SizedBox(height: 24),

          _buildFilterSection(
            context,
            'Grupos',
            groups,
            selectedGroups.value,
            (group, isSelected) {
              if (isSelected) {
                selectedGroups.value = selectedGroups.value.union({group});
              } else {
                selectedGroups.value = selectedGroups.value.difference({group});
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTypeChip(
    String label,
    bool isSelected,
    VoidCallback onTap,
    ColorScheme colorScheme,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outline.withValues(alpha: 0.5),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection(
    BuildContext context,
    String title,
    List<String> items,
    Set<String> selectedItems,
    void Function(String item, bool isSelected) onItemToggle,
  ) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: items.map((item) {
            final isSelected = selectedItems.contains(item);
            return _buildSelectableChip(
              context,
              item,
              isSelected,
              () => onItemToggle(item, !isSelected),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSelectableChip(
    BuildContext context,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outline.withValues(alpha: 0.5),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurface,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  void _clearAllFilters(
    ValueNotifier<Set<String>> selectedCategories,
    ValueNotifier<Set<String>> selectedLocations,
    ValueNotifier<Set<String>> selectedGroups,
    ValueNotifier<TransactionType> selectedTransactionType,
  ) {
    selectedCategories.value = {};
    selectedLocations.value = {};
    selectedGroups.value = {};
    selectedTransactionType.value = TransactionType.all;
  }

  Widget _buildTransactionList(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final transactions = [
      (
        id: 1,
        name: 'Almoço no Restaurante Central',
        category: 'Alimentação',
        location: 'Restaurante Central',
        date: '07 nov, 12:30',
        amount: 'R\$ 45,80',
        type: 'expense',
        group: 'Trabalho',
      ),
      (
        id: 2,
        name: 'Transferência PIX - João',
        category: 'Transferência',
        location: 'PIX',
        date: '06 nov, 18:20',
        amount: 'R\$ 200,00',
        type: 'income',
        group: 'Família',
      ),
      (
        id: 3,
        name: 'Uber para casa',
        category: 'Transporte',
        location: 'Uber',
        date: '06 nov, 22:15',
        amount: 'R\$ 24,50',
        type: 'expense',
        group: 'Pessoal',
      ),
      (
        id: 4,
        name: 'Compras no Mercado',
        category: 'Alimentação',
        location: 'Supermercado Extra',
        date: '05 nov, 15:00',
        amount: 'R\$ 312,90',
        type: 'expense',
        group: 'Família',
      ),
      (
        id: 5,
        name: 'Cinema - Ingresso',
        category: 'Lazer',
        location: 'Shopping Center',
        date: '04 nov, 20:00',
        amount: 'R\$ 28,00',
        type: 'expense',
        group: 'Amigos',
      ),
      (
        id: 6,
        name: 'Freelance - Desenvolvimento',
        category: 'Trabalho',
        location: 'Online',
        date: '03 nov, 14:30',
        amount: 'R\$ 1.500,00',
        type: 'income',
        group: 'Trabalho',
      ),
      (
        id: 7,
        name: 'Conta de Energia',
        category: 'Contas',
        location: 'CEMIG',
        date: '02 nov, 10:00',
        amount: 'R\$ 180,45',
        type: 'expense',
        group: 'Família',
      ),
    ];

    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        final isIncome = transaction.type == 'income';

        final color = index.isEven
            ? colorScheme.secondary.withValues(alpha: 0.7)
            : colorScheme.secondary.withValues(alpha: 0.4);

        return _TransactionListItem(
          id: transaction.id,
          name: transaction.name,
          category: transaction.category,
          location: transaction.location,
          date: transaction.date,
          amount: transaction.amount,
          isIncome: isIncome,
          group: transaction.group,
          color: color,
          textColor: colorScheme.onSecondary,
        );
      },
    );
  }
}

class _TransactionListItem extends StatelessWidget {
  final int id;
  final String name;
  final String category;
  final String location;
  final String date;
  final String amount;
  final bool isIncome;
  final String group;
  final Color color;
  final Color textColor;

  const _TransactionListItem({
    required this.id,
    required this.name,
    required this.category,
    required this.location,
    required this.date,
    required this.amount,
    required this.isIncome,
    required this.group,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.push('/transaction/$id');
      },
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: textColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getCategoryIcon(category),
                    size: 20,
                    color: textColor,
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        location,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: textColor.withValues(alpha: 0.8),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      amount,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isIncome ? Colors.green[700] : Colors.red[700],
                      ),
                    ),
                    Icon(
                      isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                      size: 16,
                      color: isIncome ? Colors.green[700] : Colors.red[700],
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: textColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        category,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: textColor,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: textColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        group,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: textColor,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  date,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: textColor.withValues(alpha: 0.7),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'alimentação':
        return Icons.restaurant;
      case 'transporte':
        return Icons.directions_car;
      case 'lazer':
        return Icons.movie;
      case 'contas':
        return Icons.receipt_long;
      case 'trabalho':
        return Icons.work;
      case 'transferência':
        return Icons.compare_arrows;
      default:
        return Icons.shopping_cart;
    }
  }
}
