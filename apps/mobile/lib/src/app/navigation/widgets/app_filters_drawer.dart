import 'package:flutter/material.dart';

import '../app_destination.dart';

Future<Map<String, String>?> showAppFiltersDrawer(
  BuildContext context, {
  required AppDestination destination,
  required Map<String, String> initialFilters,
}) {
  return showModalBottomSheet<Map<String, String>>(
    context: context,
    useSafeArea: true,
    builder:
        (_) => _FiltersDrawer(
          destination: destination,
          initialFilters: initialFilters,
        ),
  );
}

class _FiltersDrawer extends StatefulWidget {
  const _FiltersDrawer({
    required this.destination,
    required this.initialFilters,
  });

  final AppDestination destination;
  final Map<String, String> initialFilters;

  @override
  State<_FiltersDrawer> createState() => _FiltersDrawerState();
}

class _FiltersDrawerState extends State<_FiltersDrawer> {
  late String _status = widget.initialFilters['status'] ?? '';
  late String _gender = widget.initialFilters['gender'] ?? '';
  late String _sortBy =
      widget.initialFilters['sortBy'] ??
      (widget.destination == AppDestination.episodes ? 'episode' : 'name');
  late String _order = widget.initialFilters['order'] ?? 'asc';

  Map<String, String> get _sortOptions => switch (widget.destination) {
    AppDestination.episodes => const {
      'episode': 'Temporada e episódio',
      'name': 'Nome',
      'airDate': 'Data de exibição',
    },
    AppDestination.locations => const {
      'name': 'Nome',
      'type': 'Tipo',
      'dimension': 'Dimensão',
      'residents': 'Número de residentes',
    },
    _ => const {'name': 'Nome', 'status': 'Status', 'species': 'Espécie'},
  };

  String get _defaultSort =>
      widget.destination == AppDestination.episodes ? 'episode' : 'name';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: 'Limpar filtros',
                  onPressed:
                      () => Navigator.of(context).pop(<String, String>{}),
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
            const SizedBox(height: 20),
            if (widget.destination == AppDestination.characters) ...[
              _OptionGroup(
                title: 'Status',
                selected: _status,
                options: const {
                  '': 'Todos',
                  'alive': 'Vivo',
                  'dead': 'Morto',
                  'unknown': 'Desconhecido',
                },
                onSelected: (value) => setState(() => _status = value),
              ),
              const SizedBox(height: 20),
            ],
            _OptionGroup(
              title: 'Ordenar por',
              selected: _sortBy,
              options: _sortOptions,
              onSelected: (value) => setState(() => _sortBy = value),
            ),
            const SizedBox(height: 20),
            _OptionGroup(
              title: 'Ordem',
              selected: _order,
              options: const {'asc': 'Crescente', 'desc': 'Decrescente'},
              onSelected: (value) => setState(() => _order = value),
            ),
            const SizedBox(height: 20),
            if (widget.destination == AppDestination.characters) ...[
              _OptionGroup(
                title: 'Gênero',
                selected: _gender,
                options: const {
                  '': 'Todos',
                  'female': 'Feminino',
                  'male': 'Masculino',
                  'genderless': 'Sem gênero',
                  'unknown': 'Desconhecido',
                },
                onSelected: (value) => setState(() => _gender = value),
              ),
              const SizedBox(height: 24),
            ],
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed:
                    () => Navigator.of(context).pop({
                      if (_status.isNotEmpty) 'status': _status,
                      if (_gender.isNotEmpty) 'gender': _gender,
                      if (_sortBy != _defaultSort) 'sortBy': _sortBy,
                      if (_order != 'asc') 'order': _order,
                    }),
                child: const Text('Aplicar filtros'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionGroup extends StatelessWidget {
  const _OptionGroup({
    required this.title,
    required this.selected,
    required this.options,
    required this.onSelected,
  });

  final String title;
  final String selected;
  final Map<String, String> options;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in options.entries)
              ChoiceChip(
                label: Text(option.value),
                selected: selected == option.key,
                onSelected: (_) => onSelected(option.key),
              ),
          ],
        ),
      ],
    );
  }
}
