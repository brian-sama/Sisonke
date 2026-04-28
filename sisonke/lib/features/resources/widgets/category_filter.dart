import 'package:flutter/material.dart';
import '../../../shared/models/resource.dart';
import '../../../core/constants/app_constants.dart';

class CategoryFilter extends StatefulWidget {
  final List<ResourceCategory> categories;
  final Function(String?) onCategorySelected;

  const CategoryFilter({
    super.key,
    required this.categories,
    required this.onCategorySelected,
  });

  @override
  State<CategoryFilter> createState() => _CategoryFilterState();
}

class _CategoryFilterState extends State<CategoryFilter> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // "All" option and categories
        SizedBox(
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // "All" option
              _buildCategoryChip(
                id: null,
                name: 'All',
                icon: Icons.apps,
              ),
              const SizedBox(width: AppConstants.spacingSmall),
              // Category chips
              ...widget.categories.map((category) => _buildCategoryChip(
                id: category.id,
                name: category.label,
                icon: _getCategoryIcon(category.id),
              )).toList(),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.spacingMedium),
      ],
    );
  }

  Widget _buildCategoryChip({
    required String? id,
    required String name,
    required IconData icon,
  }) {
    final isSelected = _selectedCategory == id;
    
    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected 
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          const SizedBox(width: AppConstants.spacingXSmall),
          Text(name),
        ],
      ),
      onSelected: (selected) {
        setState(() {
          _selectedCategory = selected ? id : null;
        });
        widget.onCategorySelected(_selectedCategory);
      },
      backgroundColor: Theme.of(context).colorScheme.surface,
      selectedColor: Theme.of(context).colorScheme.primary,
      checkmarkColor: Theme.of(context).colorScheme.onPrimary,
      labelStyle: TextStyle(
        color: isSelected 
            ? Theme.of(context).colorScheme.onPrimary
            : Theme.of(context).colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected 
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.outline.withOpacity(0.3),
      ),
    );
  }

  IconData _getCategoryIcon(String categoryId) {
    switch (categoryId) {
      case 'mental-health':
        return Icons.psychology;
      case 'srhr':
        return Icons.health_and_safety;
      case 'emergency':
        return Icons.emergency;
      case 'substance-use':
        return Icons.medication;
      case 'wellness':
        return Icons.favorite;
      case 'guide':
        return Icons.menu_book;
      default:
        return Icons.category;
    }
  }
}
