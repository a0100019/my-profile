import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants.dart';

class CategorySection extends StatefulWidget {
  final CategoryInfo category;
  final List<Map<String, dynamic>> items;
  final int colorIndex;
  final Function(List<Map<String, dynamic>>) onSave;
  final VoidCallback onRemove;
  final Widget? dragHandle;
  final Future<String?> Function() onPickImage;

  const CategorySection({
    super.key,
    required this.category,
    required this.items,
    required this.colorIndex,
    required this.onSave,
    required this.onRemove,
    required this.onPickImage,
    this.dragHandle,
  });

  @override
  State<CategorySection> createState() => _CategorySectionState();
}

class _CategorySectionState extends State<CategorySection> {
  bool _expanded = false;
  final _inputController = TextEditingController();
  final _linkController = TextEditingController();
  bool _showLinkInput = false;
  String? _pendingImageUrl;
  bool _uploadingImage = false;

  @override
  void dispose() {
    if (_pendingImageUrl != null) _deleteUploadedImage(_pendingImageUrl!);
    _inputController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  void _deleteUploadedImage(String url) {
    FirebaseStorage.instance.refFromURL(url).delete().catchError((_) {});
  }

  @override
  Widget build(BuildContext context) {
    final color = rowColors[widget.colorIndex].color;

    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          // 헤더
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Text('${widget.category.emoji} ${widget.category.label}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 8),
                  Text('${widget.items.length}', style: TextStyle(fontSize: 12, color: AppColors.muted)),
                  const Spacer(),
                  if (widget.dragHandle != null) ...[
                    widget.dragHandle!,
                    const SizedBox(width: 8),
                  ],
                  Icon(_expanded ? Icons.expand_less : Icons.expand_more, size: 20, color: AppColors.muted),
                ],
              ),
            ),
          ),

          if (_expanded) ...[
            // 아이템 목록
            if (widget.items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('아직 항목이 없어요', style: TextStyle(fontSize: 13, color: AppColors.muted)),
                ),
              )
            else
              ReorderableListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                buildDefaultDragHandles: false,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                proxyDecorator: (child, index, animation) => Material(
                  color: Colors.transparent,
                  child: child,
                ),
                onReorderItem: _reorderItem,
                children: widget.items.asMap().entries.map((entry) {
                  final i = entry.key;
                  final item = entry.value;
                  final link = (item['link'] as String?) ?? '';
                  final image = (item['image'] as String?) ?? '';
                  return Padding(
                    key: ValueKey('categoryItem_$i'),
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.card.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 16,
                            child: Text('${i + 1}', style: TextStyle(fontSize: 11, color: AppColors.muted, fontWeight: FontWeight.w600)),
                          ),
                          const SizedBox(width: 6),
                          ReorderableDragStartListener(
                            index: i,
                            child: Icon(Icons.drag_handle, size: 16, color: AppColors.muted),
                          ),
                          const SizedBox(width: 8),
                          if (image.isNotEmpty) ...[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(image, width: 28, height: 28, fit: BoxFit.cover),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(item['text'] ?? '', style: const TextStyle(fontSize: 13)),
                                if (link.isNotEmpty)
                                  GestureDetector(
                                    onTap: () => _openLink(link),
                                    child: Text(
                                      link,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 11, color: AppColors.pastelPurple, decoration: TextDecoration.underline),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => _removeItem(i),
                            child: Icon(Icons.close, size: 16, color: AppColors.pastelPink),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

            const SizedBox(height: 8),

            // 항목 추가 (항상 표시)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_pendingImageUrl != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(_pendingImageUrl!, width: 36, height: 36, fit: BoxFit.cover),
                          ),
                          const SizedBox(width: 8),
                          Text('사진 첨부됨', style: TextStyle(fontSize: 12, color: AppColors.muted)),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              final url = _pendingImageUrl!;
                              setState(() => _pendingImageUrl = null);
                              _deleteUploadedImage(url);
                            },
                            child: Icon(Icons.close, size: 14, color: AppColors.pastelPink),
                          ),
                        ],
                      ),
                    ),
                  if (_showLinkInput)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: TextField(
                        controller: _linkController,
                        decoration: InputDecoration(
                          hintText: '링크(URL) 입력',
                          hintStyle: TextStyle(fontSize: 12, color: AppColors.muted),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.pastelPurple.withValues(alpha: 0.3))),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.pastelPurple.withValues(alpha: 0.3))),
                          isDense: true,
                        ),
                        style: const TextStyle(fontSize: 12),
                        keyboardType: TextInputType.url,
                      ),
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _inputController,
                          maxLength: 50,
                          buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                          decoration: InputDecoration(
                            hintText: '새 항목 추가',
                            hintStyle: TextStyle(fontSize: 13, color: AppColors.muted),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.pastelPurple.withValues(alpha: 0.3))),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.pastelPurple.withValues(alpha: 0.3))),
                            isDense: true,
                          ),
                          style: const TextStyle(fontSize: 13),
                          onSubmitted: (_) => _addItem(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => setState(() => _showLinkInput = !_showLinkInput),
                        child: Icon(Icons.link, size: 20, color: _showLinkInput ? AppColors.pastelPurple : AppColors.muted),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _uploadingImage ? null : _pickImage,
                        child: _uploadingImage
                            ? SizedBox(
                                width: 20, height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.pastelPurple),
                              )
                            : Icon(Icons.image_outlined, size: 20, color: _pendingImageUrl != null ? AppColors.pastelPurple : AppColors.muted),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _addItem,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.pastelPurple,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.add, size: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 카테고리 삭제
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () => _confirmRemove(context),
                    child: Text('카테고리 삭제', style: TextStyle(fontSize: 12, color: AppColors.pastelPink)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _reorderItem(int oldIndex, int newIndex) {
    final items = List<Map<String, dynamic>>.from(widget.items.map((e) => Map<String, dynamic>.from(e)));
    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);
    widget.onSave(items);
  }

  void _removeItem(int index) {
    final items = List<Map<String, dynamic>>.from(widget.items.map((e) => Map<String, dynamic>.from(e)));
    items.removeAt(index);
    widget.onSave(items);
  }

  Future<void> _pickImage() async {
    setState(() => _uploadingImage = true);
    final url = await widget.onPickImage();
    if (!mounted) return;
    final previous = _pendingImageUrl;
    setState(() {
      _uploadingImage = false;
      if (url != null) _pendingImageUrl = url;
    });
    if (url != null && previous != null) _deleteUploadedImage(previous);
  }

  Future<void> _openLink(String link) async {
    var url = link.trim();
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _addItem() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    final items = List<Map<String, dynamic>>.from(widget.items.map((e) => Map<String, dynamic>.from(e)));
    items.add({
      'text': text,
      'link': _linkController.text.trim(),
      'image': _pendingImageUrl ?? '',
    });
    widget.onSave(items);
    _inputController.clear();
    _linkController.clear();
    setState(() {
      _pendingImageUrl = null;
      _showLinkInput = false;
    });
  }

  void _confirmRemove(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('카테고리 삭제'),
        content: Text('"${widget.category.label}" 카테고리를 삭제할까요?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              widget.onRemove();
            },
            child: Text('삭제', style: TextStyle(color: AppColors.pastelPink)),
          ),
        ],
      ),
    );
  }
}
