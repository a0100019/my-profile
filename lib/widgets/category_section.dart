import 'package:flutter/material.dart';
import '../constants.dart';

class CategorySection extends StatefulWidget {
  final CategoryInfo category;
  final List<Map<String, dynamic>> items;
  final int colorIndex;
  final Function(List<Map<String, dynamic>>) onSave;
  final VoidCallback onRemove;

  const CategorySection({
    super.key,
    required this.category,
    required this.items,
    required this.colorIndex,
    required this.onSave,
    required this.onRemove,
  });

  @override
  State<CategorySection> createState() => _CategorySectionState();
}

class _CategorySectionState extends State<CategorySection> {
  bool _expanded = false;
  bool _editing = false;
  final _inputController = TextEditingController();
  List<Map<String, dynamic>> _editItems = [];

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
                  Icon(_expanded ? Icons.expand_less : Icons.expand_more, size: 20, color: AppColors.muted),
                ],
              ),
            ),
          ),

          if (_expanded) ...[
            // 아이템 목록
            if (widget.items.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text('아직 항목이 없어요', style: TextStyle(fontSize: 13, color: AppColors.muted)),
              )
            else
              ...widget.items.asMap().entries.map((entry) {
                final item = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.card.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(item['text'] ?? '', style: const TextStyle(fontSize: 13)),
                  ),
                );
              }),

            // 편집/삭제 버튼
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: _startEditing,
                    child: Text('편집', style: TextStyle(fontSize: 12, color: AppColors.pastelPurple)),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () => _confirmRemove(context),
                    child: Text('삭제', style: TextStyle(fontSize: 12, color: AppColors.pastelPink)),
                  ),
                ],
              ),
            ),

            // 편집 모드
            if (_editing) _buildEditMode(),
          ],
        ],
      ),
    );
  }

  void _startEditing() {
    setState(() {
      _editing = true;
      _editItems = List.from(widget.items.map((e) => Map<String, dynamic>.from(e)));
    });
  }

  Widget _buildEditMode() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.pastelPurple.withValues(alpha: 0.15))),
      ),
      child: Column(
        children: [
          ..._editItems.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(child: Text(item['text'] ?? '', style: const TextStyle(fontSize: 13))),
                  GestureDetector(
                    onTap: () => setState(() => _editItems.removeAt(i)),
                    child: Icon(Icons.close, size: 16, color: AppColors.pastelPink),
                  ),
                ],
              ),
            );
          }),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _inputController,
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
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => setState(() => _editing = false),
                child: Text('취소', style: TextStyle(fontSize: 13, color: AppColors.muted)),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () {
                  widget.onSave(_editItems);
                  setState(() => _editing = false);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [AppColors.pastelPurple, AppColors.pastelPink]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('저장', style: TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w500)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _addItem() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _editItems.add({'text': text, 'link': '', 'image': ''});
      _inputController.clear();
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
