import 'package:flutter/material.dart';

import '../../../episodes/domain/character_sort.dart';

class CharacterSortOptions {
  const CharacterSortOptions(this.sortBy, this.order);
  final CharacterSortBy sortBy;
  final CharacterSortOrder order;
}

Future<CharacterSortOptions?> showCharacterSortDrawer(
  BuildContext context, {
  required CharacterSortBy initialSort,
  required CharacterSortOrder initialOrder,
}) {
  return showModalBottomSheet<CharacterSortOptions>(
    context: context,
    useSafeArea: true,
    builder:
        (_) => _CharacterSortDrawer(
          initialSort: initialSort,
          initialOrder: initialOrder,
        ),
  );
}

class _CharacterSortDrawer extends StatefulWidget {
  const _CharacterSortDrawer({
    required this.initialSort,
    required this.initialOrder,
  });
  final CharacterSortBy initialSort;
  final CharacterSortOrder initialOrder;
  @override
  State<_CharacterSortDrawer> createState() => _CharacterSortDrawerState();
}

class _CharacterSortDrawerState extends State<_CharacterSortDrawer> {
  late CharacterSortBy _sortBy = widget.initialSort;
  late CharacterSortOrder _order = widget.initialOrder;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Limpar filtros',
                onPressed:
                    () => Navigator.of(context).pop(
                      const CharacterSortOptions(
                        CharacterSortBy.name,
                        CharacterSortOrder.ascending,
                      ),
                    ),
                icon: const Icon(Icons.delete_outline),
              ),
              const Spacer(),
              Text(
                'Filtros e ordenação',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Fechar',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Ordenar por', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [
              for (final option in CharacterSortBy.values)
                ChoiceChip(
                  label: Text(switch (option) {
                    CharacterSortBy.name => 'Nome',
                    CharacterSortBy.status => 'Status',
                    CharacterSortBy.species => 'Espécie',
                  }),
                  selected: _sortBy == option,
                  onSelected: (_) => setState(() => _sortBy = option),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Ordem', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          SegmentedButton<CharacterSortOrder>(
            segments: const [
              ButtonSegment(
                value: CharacterSortOrder.ascending,
                label: Text('Crescente'),
              ),
              ButtonSegment(
                value: CharacterSortOrder.descending,
                label: Text('Decrescente'),
              ),
            ],
            selected: {_order},
            onSelectionChanged:
                (values) => setState(() => _order = values.first),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed:
                  () => Navigator.of(
                    context,
                  ).pop(CharacterSortOptions(_sortBy, _order)),
              child: const Text('Aplicar'),
            ),
          ),
        ],
      ),
    );
  }
}
