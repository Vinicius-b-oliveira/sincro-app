import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class HistoryView extends HookConsumerWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterMonth = useState(false);
    final filterGroup = useState(
      true,
    );
    final filterFood = useState(false);
    final isFilterExpanded = useState(true);

    final searchController = useTextEditingController();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isFilterExpanded.value
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildFilterPanel(
                      context,
                      filterMonth: filterMonth,
                      filterGroup: filterGroup,
                      filterFood: filterFood,
                      isExpanded: isFilterExpanded,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 5,
                    child: Column(
                      children: [
                        _buildSearchBar(context, searchController),
                        const SizedBox(height: 16),
                        Expanded(
                          child: _buildTransactionList(context),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilterPanel(
                    context,
                    filterMonth: filterMonth,
                    filterGroup: filterGroup,
                    filterFood: filterFood,
                    isExpanded: isFilterExpanded,
                  ),
                  const SizedBox(height: 16),
                  _buildSearchBar(context, searchController),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _buildTransactionList(context),
                  ),
                ],
              ),
      ),
    );
  }

  // Painel de Filtros
  Widget _buildFilterPanel(
    BuildContext context, {
    required ValueNotifier<bool> filterMonth,
    required ValueNotifier<bool> filterGroup,
    required ValueNotifier<bool> filterFood,
    required ValueNotifier<bool> isExpanded,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => isExpanded.value = !isExpanded.value,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      'Filtros',
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: isExpanded.value ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: isExpanded.value ? null : 0,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isExpanded.value ? 1.0 : 0.0,
              child: isExpanded.value
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        _FilterCheckbox(
                          label: 'mês',
                          value: filterMonth.value,
                          onChanged: (val) => filterMonth.value = val ?? false,
                        ),
                        _FilterCheckbox(
                          label: '(nome de grupo)',
                          value: filterGroup.value,
                          onChanged: (val) => filterGroup.value = val ?? false,
                        ),
                        _FilterCheckbox(
                          label: 'comida',
                          value: filterFood.value,
                          onChanged: (val) => filterFood.value = val ?? false,
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
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
        hintText: 'pesquisar',
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

  Widget _buildTransactionList(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView.builder(
      itemCount: 14,
      itemBuilder: (context, index) {
        final color = index.isEven
            ? colorScheme.secondary.withValues(alpha: .7)
            : colorScheme.secondary.withValues(alpha: .4);

        return _TransactionListItem(
          date: 'data e lugar',
          amount: 'R\$ ...',
          color: color,
          textColor: colorScheme.onSecondary,
        );
      },
    );
  }
}

class _FilterCheckbox extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool?> onChanged;

  const _FilterCheckbox({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Checkbox(
              value: value,
              onChanged: onChanged,
              visualDensity: VisualDensity.compact,
            ),
            Expanded(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                softWrap: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionListItem extends StatelessWidget {
  final String date;
  final String amount;
  final Color color;
  final Color textColor;

  const _TransactionListItem({
    required this.date,
    required this.amount,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            date,
            style:
                Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(
                  color: textColor.withValues(alpha: 0.8),
                ),
          ),
          Text(
            amount,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
