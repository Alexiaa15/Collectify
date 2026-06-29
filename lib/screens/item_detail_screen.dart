import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import '../models/collection_item.dart';
import '../utils/app_theme.dart';

class ItemDetailScreen extends StatelessWidget {
  final CollectionItem item;
  final VoidCallback onEdit;

  const ItemDetailScreen({
    super.key,
    required this.item,
    required this.onEdit,
  });

  bool get _isBase64 => item.coverUrl.startsWith('data:image');

  @override
  Widget build(BuildContext context) {
    final isGame = item.type == ItemType.game;
    final accent = isGame ? AppTheme.accentGame : AppTheme.accentComic;
    final statusColor = AppConstants.statusColor(item.status);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppTheme.bgDeep,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_rounded),
                onPressed: () {
                  Navigator.pop(context);
                  onEdit();
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (item.coverUrl.isNotEmpty)
                    _buildCoverImage(isGame, accent)
                  else
                    _placeholder(isGame, accent),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, AppTheme.bgDeep],
                        stops: [0.5, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isGame
                                  ? Icons.sports_esports_rounded
                                  : Icons.menu_book_rounded,
                              color: accent,
                              size: 14,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              isGame ? 'Game' : 'Comic',
                              style: TextStyle(
                                color: accent,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.status,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.title,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  if (item.genre != null && item.genre!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      item.genre!,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 15,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  if (item.rating > 0) ...[
                    Row(
                      children: [
                        RatingBarIndicator(
                          rating: item.rating,
                          itemBuilder: (_, __) => const Icon(
                            Icons.star_rounded,
                            color: AppTheme.starColor,
                          ),
                          itemCount: 5,
                          itemSize: 22,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          item.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            color: AppTheme.starColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                  if (item.notes.isNotEmpty) ...[
                    const Divider(color: AppTheme.divider),
                    const SizedBox(height: 16),
                    const Text(
                      'NOTES',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      item.notes,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 15,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  const Divider(color: AppTheme.divider),
                  const SizedBox(height: 16),
                  _InfoRow(
                    label: 'Added',
                    value: DateFormat('d MMM yyyy').format(item.createdAt),
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    label: 'Updated',
                    value: DateFormat('d MMM yyyy, HH:mm').format(item.updatedAt),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverImage(bool isGame, Color accent) {
    if (_isBase64) {
      try {
        final base64Data = item.coverUrl.split(',').last;
        return Image.memory(
          base64Decode(base64Data),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholder(isGame, accent),
        );
      } catch (_) {
        return _placeholder(isGame, accent);
      }
    }
    return CachedNetworkImage(
      imageUrl: item.coverUrl,
      fit: BoxFit.cover,
      errorWidget: (_, __, ___) => _placeholder(isGame, accent),
    );
  }

  Widget _placeholder(bool isGame, Color accent) {
    return Container(
      color: AppTheme.bgSurface,
      child: Center(
        child: Icon(
          isGame ? Icons.sports_esports_rounded : Icons.menu_book_rounded,
          color: accent.withOpacity(0.3),
          size: 80,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}