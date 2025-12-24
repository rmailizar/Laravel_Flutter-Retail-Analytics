import 'package:flutter/material.dart';
import '../models/category.dart';

class CategoryFilter extends StatelessWidget {
  final List<Category> categories;
  final int? selectedCategoryId;
  final ValueChanged<int?> onCategorySelected;
  final bool isLoading;

  const CategoryFilter({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: 44,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: 5,
          itemBuilder: (context, index) {
            return Container(
              width: 80,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(22),
              ),
            );
          },
        ),
      );
    }

    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length + 1, // +1 for "All" option
        itemBuilder: (context, index) {
          if (index == 0) {
            // "All" Category
            return _CategoryChip(
              label: 'Semua',
              icon: Icons.grid_view_rounded,
              isSelected: selectedCategoryId == null,
              onTap: () => onCategorySelected(null),
            );
          }
          final category = categories[index - 1];
          return _CategoryChip(
            label: category.name,
            icon: _getCategoryIcon(category.name),
            isSelected: selectedCategoryId == category.id,
            onTap: () => onCategorySelected(category.id),
          );
        },
      ),
    );
  }

  IconData _getCategoryIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('minuman') || lower.contains('drink')) {
      return Icons.local_drink_rounded;
    } else if (lower.contains('makanan') || lower.contains('food')) {
      return Icons.restaurant_rounded;
    } else if (lower.contains('snack')) {
      return Icons.cookie_rounded;
    } else if (lower.contains('elektronik')) {
      return Icons.devices_rounded;
    }
    return Icons.category_rounded;
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [Color(0xFF7C3AED), Color(0xFF2DD4BF)],
                    )
                  : null,
              color: isSelected ? null : Colors.grey.shade100,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFF7C3AED).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
