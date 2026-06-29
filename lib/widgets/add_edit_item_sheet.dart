import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_picker/image_picker.dart';
import '../models/collection_item.dart';
import '../services/collection_service.dart';
import '../utils/app_theme.dart';

class AddEditItemSheet extends StatefulWidget {
  final String userId;
  final ItemType type;
  final CollectionItem? existing;

  const AddEditItemSheet({
    super.key,
    required this.userId,
    required this.type,
    this.existing,
  });

  @override
  State<AddEditItemSheet> createState() => _AddEditItemSheetState();
}

class _AddEditItemSheetState extends State<AddEditItemSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _coverCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _genreCtrl = TextEditingController();
  final _service = CollectionService();
  final _picker = ImagePicker();

  late String _status;
  double _rating = 0;
  bool _loading = false;

  // null = belum pick, string = path file yang dipilih
  String? _pickedImagePath;
  // base64 dari gambar yang dipilih
  String? _pickedImageBase64;

  bool get isEdit => widget.existing != null;
  bool get _hasPickedImage => _pickedImagePath != null;
  bool get _existingIsBase64 =>
      isEdit &&
      widget.existing!.coverUrl.startsWith('data:image');

  @override
  void initState() {
    super.initState();
    final statuses = widget.type == ItemType.game
        ? AppConstants.gameStatuses
        : AppConstants.comicStatuses;

    if (isEdit) {
      _titleCtrl.text = widget.existing!.title;
      // Kalau coverUrl bukan base64, tampilkan di field URL
      if (!_existingIsBase64) {
        _coverCtrl.text = widget.existing!.coverUrl;
      }
      _notesCtrl.text = widget.existing!.notes;
      _genreCtrl.text = widget.existing!.genre ?? '';
      _status = widget.existing!.status;
      _rating = widget.existing!.rating;
    } else {
      _status = statuses.first;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _coverCtrl.dispose();
    _notesCtrl.dispose();
    _genreCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    final base64Str = base64Encode(bytes);
    final mimeType = picked.mimeType ?? 'image/jpeg';

    setState(() {
      _pickedImagePath = picked.path;
      _pickedImageBase64 = 'data:$mimeType;base64,$base64Str';
      // Clear URL field kalau pilih dari device
      _coverCtrl.clear();
    });
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded,
                  color: AppTheme.accentGame),
              title: const Text('Pilih dari Galeri',
                  style: TextStyle(color: AppTheme.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded,
                  color: AppTheme.accentComic),
              title: const Text('Ambil Foto',
                  style: TextStyle(color: AppTheme.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _removePickedImage() {
    setState(() {
      _pickedImagePath = null;
      _pickedImageBase64 = null;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      // Prioritas: gambar dari device > URL > base64 lama
      String coverUrl = '';
      if (_hasPickedImage && _pickedImageBase64 != null) {
        coverUrl = _pickedImageBase64!;
      } else if (_coverCtrl.text.trim().isNotEmpty) {
        coverUrl = _coverCtrl.text.trim();
      } else if (isEdit && _existingIsBase64) {
        coverUrl = widget.existing!.coverUrl;
      }

      final item = CollectionItem(
        id: isEdit ? widget.existing!.id : '',
        userId: widget.userId,
        type: widget.type,
        title: _titleCtrl.text.trim(),
        coverUrl: coverUrl,
        status: _status,
        rating: _rating,
        notes: _notesCtrl.text.trim(),
        genre: _genreCtrl.text.trim().isEmpty ? null : _genreCtrl.text.trim(),
        createdAt: isEdit ? widget.existing!.createdAt : DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (isEdit) {
        await _service.updateItem(item);
      } else {
        await _service.addItem(item);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isGame = widget.type == ItemType.game;
    final accent = isGame ? AppTheme.accentGame : AppTheme.accentComic;
    final statuses =
        isGame ? AppConstants.gameStatuses : AppConstants.comicStatuses;

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.bgSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Header
              Row(
                children: [
                  Icon(
                    isGame
                        ? Icons.sports_esports_rounded
                        : Icons.menu_book_rounded,
                    color: accent,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isEdit
                        ? 'Edit ${isGame ? 'Game' : 'Comic'}'
                        : 'Add ${isGame ? 'Game' : 'Comic'}',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Title
              _label('Title *'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _titleCtrl,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  hintText: isGame ? 'e.g. Elden Ring' : 'e.g. One Piece',
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),

              // Cover Image Section
              _label('Cover Image'),
              const SizedBox(height: 10),
              _buildCoverSection(accent),
              const SizedBox(height: 16),

              // Genre
              _label('Genre'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _genreCtrl,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  hintText:
                      isGame ? 'e.g. RPG, Action' : 'e.g. Shonen, Isekai',
                ),
              ),
              const SizedBox(height: 16),

              // Status
              _label('Status'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: statuses.map((s) {
                  final selected = _status == s;
                  final color = AppConstants.statusColor(s);
                  return GestureDetector(
                    onTap: () => setState(() => _status = s),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected
                            ? color.withOpacity(0.2)
                            : AppTheme.bgCard,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selected ? color : AppTheme.divider,
                          width: selected ? 1.5 : 1,
                        ),
                      ),
                      child: Text(
                        s,
                        style: TextStyle(
                          color:
                              selected ? color : AppTheme.textSecondary,
                          fontSize: 13,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Rating
              _label('Rating'),
              const SizedBox(height: 10),
              RatingBar.builder(
                initialRating: _rating,
                minRating: 0,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: const EdgeInsets.only(right: 4),
                itemBuilder: (_, __) => const Icon(
                  Icons.star_rounded,
                  color: AppTheme.starColor,
                ),
                onRatingUpdate: (r) => setState(() => _rating = r),
                itemSize: 32,
              ),
              const SizedBox(height: 16),

              // Notes
              _label('Notes'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _notesCtrl,
                style: const TextStyle(color: AppTheme.textPrimary),
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Your thoughts, review, or anything...',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _loading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          isEdit ? 'Save Changes' : 'Add to Collection',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoverSection(Color accent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Preview + Pick button
        Row(
          children: [
            // Preview box
            GestureDetector(
              onTap: _showImageSourceDialog,
              child: Container(
                width: 80,
                height: 100,
                decoration: BoxDecoration(
                  color: AppTheme.bgCard,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.divider),
                ),
                clipBehavior: Clip.hardEdge,
                child: _buildPreview(),
              ),
            ),
            const SizedBox(width: 14),
            // Buttons
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _showImageSourceDialog,
                      icon: const Icon(Icons.photo_library_rounded, size: 16),
                      label: Text(_hasPickedImage
                          ? 'Ganti Gambar'
                          : 'Pilih dari Device'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: accent,
                        side: BorderSide(color: accent.withOpacity(0.5)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  if (_hasPickedImage) ...[
                    const SizedBox(height: 6),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton.icon(
                        onPressed: _removePickedImage,
                        icon: const Icon(Icons.close_rounded,
                            size: 14, color: AppTheme.textSecondary),
                        label: const Text('Hapus Gambar',
                            style: TextStyle(
                                color: AppTheme.textSecondary, fontSize: 12)),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Divider dengan "atau"
        if (!_hasPickedImage) ...[
          Row(
            children: [
              const Expanded(child: Divider(color: AppTheme.divider)),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text('atau pakai URL',
                    style: TextStyle(
                        color: AppTheme.textSecondary, fontSize: 11)),
              ),
              const Expanded(child: Divider(color: AppTheme.divider)),
            ],
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _coverCtrl,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: const InputDecoration(
              hintText: 'https://...',
              prefixIcon: Icon(Icons.link_rounded,
                  color: AppTheme.textSecondary, size: 18),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ],
    );
  }

  Widget _buildPreview() {
    // Prioritas: gambar yang baru dipick > base64 lama > URL
    if (_hasPickedImage) {
      return Image.file(
        File(_pickedImagePath!),
        fit: BoxFit.cover,
      );
    }
    if (isEdit && _existingIsBase64) {
      final base64Data =
          widget.existing!.coverUrl.split(',').last;
      return Image.memory(
        base64Decode(base64Data),
        fit: BoxFit.cover,
      );
    }
    if (_coverCtrl.text.trim().isNotEmpty) {
      return Image.network(
        _coverCtrl.text.trim(),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _emptyPreview(),
      );
    }
    return _emptyPreview();
  }

  Widget _emptyPreview() {
    return const Center(
      child: Icon(Icons.add_photo_alternate_rounded,
          color: AppTheme.textSecondary, size: 28),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppTheme.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }
}