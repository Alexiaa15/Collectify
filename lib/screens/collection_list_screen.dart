import 'package:flutter/material.dart';
import '../models/collection_item.dart';
import '../services/collection_service.dart';
import '../utils/app_theme.dart';
import '../widgets/item_card.dart';
import '../widgets/add_edit_item_sheet.dart';
import 'item_detail_screen.dart';

class CollectionListScreen extends StatefulWidget {
  final String userId;
  final ItemType type;

  const CollectionListScreen({
    super.key,
    required this.userId,
    required this.type,
  });

  @override
  State<CollectionListScreen> createState() => _CollectionListScreenState();
}

class _CollectionListScreenState extends State<CollectionListScreen> {
  final _service = CollectionService();
  String? _filterStatus;

  bool get isGame => widget.type == ItemType.game;
  Color get accent => isGame ? AppTheme.accentGame : AppTheme.accentComic;
  List<String> get statuses =>
      isGame ? AppConstants.gameStatuses : AppConstants.comicStatuses;

  void _openAdd() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddEditItemSheet(
        userId: widget.userId,
        type: widget.type,
      ),
    );
  }

  void _openEdit(CollectionItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddEditItemSheet(
        userId: widget.userId,
        type: widget.type,
        existing: item,
      ),
    );
  }

  Future<void> _confirmDelete(CollectionItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgSurface,
        title: const Text('Delete item?',
            style: TextStyle(color: AppTheme.textPrimary)),
        content: Text(
          'Remove "${item.title}" from your collection?',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete',
                style: TextStyle(color: Color(0xFFF44336))),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _service.deleteItem(item.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Status filter chips
          _FilterBar(
            statuses: statuses,
            selected: _filterStatus,
            accent: accent,
            onSelect: (s) => setState(
                () => _filterStatus = _filterStatus == s ? null : s),
          ),
          // Grid
          Expanded(
            child: StreamBuilder<List<CollectionItem>>(
              stream: _filterStatus != null
                  ? _service.streamByStatus(
                      widget.userId, widget.type, _filterStatus!)
                  : _service.streamItems(widget.userId, widget.type),
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final items = snap.data ?? [];

                if (items.isEmpty) {
                  return _EmptyState(
                    isGame: isGame,
                    accent: accent,
                    hasFilter: _filterStatus != null,
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.62,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: items.length,
                  itemBuilder: (_, i) => ItemCard(
                    item: items[i],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ItemDetailScreen(
                          item: items[i],
                          onEdit: () => _openEdit(items[i]),
                        ),
                      ),
                    ),
                    onDelete: () => _confirmDelete(items[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAdd,
        backgroundColor: accent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          'Add ${isGame ? 'Game' : 'Comic'}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  final List<String> statuses;
  final String? selected;
  final Color accent;
  final ValueChanged<String> onSelect;

  const _FilterBar({
    required this.statuses,
    required this.selected,
    required this.accent,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: statuses.map((s) {
          final isSelected = selected == s;
          final color = AppConstants.statusColor(s);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onSelect(s),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected ? color.withOpacity(0.15) : AppTheme.bgCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? color : AppTheme.divider,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Text(
                  s,
                  style: TextStyle(
                    color: isSelected ? color : AppTheme.textSecondary,
                    fontSize: 12,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isGame;
  final Color accent;
  final bool hasFilter;

  const _EmptyState({
    required this.isGame,
    required this.accent,
    required this.hasFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isGame
                ? Icons.sports_esports_rounded
                : Icons.menu_book_rounded,
            color: accent.withOpacity(0.3),
            size: 72,
          ),
          const SizedBox(height: 16),
          Text(
            hasFilter
                ? 'Nothing here yet'
                : 'Your collection is empty',
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasFilter
                ? 'No ${isGame ? 'games' : 'comics'} with this status'
                : 'Tap the button below to add your first ${isGame ? 'game' : 'comic'}',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
