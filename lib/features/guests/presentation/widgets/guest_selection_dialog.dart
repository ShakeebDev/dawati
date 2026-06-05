import 'package:flutter/material.dart';
import 'package:dawati/features/guests/data/models/guest_model.dart';
import 'package:dawati/core/theme/app_theme.dart';

class GuestSelectionDialog extends StatefulWidget {
  final List<GuestModel> guests;

  const GuestSelectionDialog({super.key, required this.guests});

  @override
  State<GuestSelectionDialog> createState() => _GuestSelectionDialogState();
}

class _GuestSelectionDialogState extends State<GuestSelectionDialog> {
  late Set<String> _selectedIds;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedIds = widget.guests.map((g) => g.phone).toSet();
  }

  void _toggleSelectAll(List<GuestModel> filteredGuests) {
    setState(() {
      final filteredIds = filteredGuests.map((g) => g.phone).toSet();
      if (_selectedIds.containsAll(filteredIds)) {
        _selectedIds.removeAll(filteredIds);
      } else {
        _selectedIds.addAll(filteredIds);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredGuests = widget.guests
        .where((g) =>
            g.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            g.phone.contains(_searchQuery))
        .toList();

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.dividerColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'استيراد جهات الاتصال',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => _toggleSelectAll(filteredGuests),
                  child: Text(
                    _selectedIds.length == widget.guests.length
                        ? 'إلغاء الكل'
                        : 'تحديد الكل',
                    style: const TextStyle(color: AppTheme.goldDark),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'بحث في جهات الاتصال...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: theme.cardTheme.color,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                'تم تحديد ${_selectedIds.length} ضيف',
                style: TextStyle(color: theme.hintColor, fontSize: 12),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: filteredGuests.length,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemBuilder: (context, index) {
                final guest = filteredGuests[index];
                final isSelected = _selectedIds.contains(guest.phone);
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.goldPrimary.withOpacity(0.05)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: CheckboxListTile(
                    value: isSelected,
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          _selectedIds.add(guest.phone);
                        } else {
                          _selectedIds.remove(guest.phone);
                        }
                      });
                    },
                    title: Text(
                      guest.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      guest.phone,
                      style: TextStyle(color: theme.hintColor, fontSize: 13),
                    ),
                    secondary: CircleAvatar(
                      backgroundColor: isSelected
                          ? AppTheme.goldPrimary
                          : AppTheme.goldPrimary.withOpacity(0.1),
                      child: Text(
                        guest.name.substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppTheme.goldDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    activeColor: AppTheme.goldPrimary,
                    checkColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _selectedIds.isEmpty
                    ? null
                    : () {
                        final selected = widget.guests
                            .where((g) => _selectedIds.contains(g.phone))
                            .toList();
                        Navigator.pop(context, selected);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.goldDark,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'استيراد ${_selectedIds.length} ضيف',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
