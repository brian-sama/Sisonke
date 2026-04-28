import 'package:flutter/material.dart';
import '../models/qa_model.dart';
import '../../../core/constants/app_constants.dart';

class QACategoryFilter extends StatefulWidget {
  final List<QuestionCategory> categories;
  final Function(String?) onCategorySelected;

  const QACategoryFilter({
    super.key,
    required this.categories,
    required this.onCategorySelected,
  });

  @override
  State<QACategoryFilter> createState() => _QACategoryFilterState();
}

class _QACategoryFilterState extends State<QACategoryFilter> {
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
                icon: Icons.question_answer,
              ),
              const SizedBox(width: AppConstants.spacingSmall),
              // Category chips
              ...widget.categories.map((category) => _buildCategoryChip(
                id: category.id,
                name: category.name,
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
      case 'relationships':
        return Icons.people;
      case 'general':
        return Icons.help_outline;
      default:
        return Icons.category;
    }
  }
}
