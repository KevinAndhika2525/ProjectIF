import 'package:flutter/material.dart';

import '../helper/colors.dart';

class NewCategoryPage extends StatefulWidget {
  final Map<String, dynamic>? categoryToEdit;
  final Function(Map<String, dynamic>)? onCategoryAdded;

  const NewCategoryPage({super.key, this.categoryToEdit, this.onCategoryAdded});

  @override
  State<NewCategoryPage> createState() => _NewCategoryPageState();
}

class _NewCategoryPageState extends State<NewCategoryPage> {
  final TextEditingController _categoryNameController = TextEditingController();
  IconData _selectedIcon = Icons.category;
  Color _selectedColor = Colors.blue;

  // Daftar icon yang tersedia
  final List<Map<String, dynamic>> _availableIcons = [
    {'icon': Icons.shopping_cart, 'label': 'Shopping', 'color': Colors.green},
    {'icon': Icons.directions_bus, 'label': 'Transport', 'color': Colors.blue},
    {'icon': Icons.receipt_long, 'label': 'Bill', 'color': Colors.orange},
    {'icon': Icons.restaurant, 'label': 'Food', 'color': Colors.red},
    {'icon': Icons.work, 'label': 'Salary', 'color': Colors.green},
    {'icon': Icons.movie, 'label': 'Movie', 'color': Colors.purple},
    {'icon': Icons.fitness_center, 'label': 'Gym', 'color': Colors.orange},
    {'icon': Icons.home, 'label': 'Home', 'color': Colors.brown},
    {'icon': Icons.local_hospital, 'label': 'Health', 'color': Colors.red},
    {'icon': Icons.school, 'label': 'Study', 'color': Colors.blue},
    {'icon': Icons.flight, 'label': 'Travel', 'color': Colors.teal},
    {'icon': Icons.card_giftcard, 'label': 'Gift', 'color': Colors.pink},
    {'icon': Icons.more_horiz, 'label': 'Other', 'color': Colors.grey},
  ];

  // Daftar warna yang tersedia
  final List<Color> _availableColors = [
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.brown,
    Colors.indigo,
    Colors.cyan,
    Colors.amber,
    Colors.grey,
  ];

  @override
  void initState() {
    super.initState();
    
    // Jika dalam mode edit, load data kategori
    if (widget.categoryToEdit != null) {
      _categoryNameController.text = widget.categoryToEdit!['name'];
      _selectedIcon = widget.categoryToEdit!['icon'];
      _selectedColor = widget.categoryToEdit!['color'];
    }
  }

  void _saveCategory() {
    final categoryName = _categoryNameController.text.trim();
    
    if (categoryName.isEmpty) {
      _showError('Please enter category name');
      return;
    }
    
    final newCategory = {
      'name': categoryName,
      'icon': _selectedIcon,
      'color': _selectedColor,
    };
    
    widget.onCategoryAdded?.call(newCategory);
    Navigator.pop(context);
  }

  void _cancel() {
    Navigator.pop(context);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'RobotoSlab'),
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  void dispose() {
    _categoryNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    final isEditMode = widget.categoryToEdit != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditMode ? 'Edit Category' : 'New Category',
          style: const TextStyle(
            fontFamily: 'RobotoSlab',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: appColors.appBarColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Name
            const Text(
              'Category Name',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'RobotoSlab',
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _categoryNameController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.all(12),
                hintText: 'Enter category name (e.g., "Entertainment")',
                hintStyle: const TextStyle(
                  fontFamily: 'RobotoSlab',
                  color: Colors.grey,
                ),
              ),
              style: const TextStyle(
                fontFamily: 'RobotoSlab',
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 30),

            // Icon Selector
            const Text(
              'Select Icon',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'RobotoSlab',
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Choose an icon that represents this category',
              style: TextStyle(
                fontFamily: 'RobotoSlab',
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 15),
            
            // Grid Icons
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              itemCount: _availableIcons.length,
              itemBuilder: (context, index) {
                final iconData = _availableIcons[index];
                final isSelected = _selectedIcon == iconData['icon'];
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIcon = iconData['icon'];
                      _selectedColor = iconData['color'];
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected 
                          // ignore: deprecated_member_use
                          ? _selectedColor.withOpacity(0.1)
                          : appColors.lightGreyCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? _selectedColor : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          iconData['icon'],
                          color: isSelected ? _selectedColor : appColors.textSecondary,
                          size: 28,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          iconData['label'],
                          style: TextStyle(
                            fontFamily: 'RobotoSlab',
                            fontSize: 11,
                            color: isSelected ? _selectedColor : appColors.textSecondary,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 30),

            // Color Selector
            const Text(
              'Select Color',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'RobotoSlab',
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Choose a color for this category',
              style: TextStyle(
                fontFamily: 'RobotoSlab',
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 15),
            
            // Grid Colors
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemCount: _availableColors.length,
              itemBuilder: (context, index) {
                final color = _availableColors[index];
                final isSelected = _selectedColor == color;
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.transparent,
                        width: isSelected ? 3 : 0,
                      ),
                    ),
                    child: isSelected
                        ? const Center(
                            child: Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 20,
                            ),
                          )
                        : null,
                  ),
                );
              },
            ),
            const SizedBox(height: 40),

            // Selected Preview
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: appColors.lightGreyCard,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      // ignore: deprecated_member_use
                      color: _selectedColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _selectedIcon,
                      color: _selectedColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _categoryNameController.text.isEmpty 
                              ? 'Category Preview'
                              : _categoryNameController.text,
                          style: const TextStyle(
                            fontFamily: 'RobotoSlab',
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'This is how your category will look',
                          style: TextStyle(
                            fontFamily: 'RobotoSlab',
                            color: appColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Action Buttons
            Row(
              children: [
                // Cancel Button
                Expanded(
                  child: OutlinedButton(
                    onPressed: _cancel,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'RobotoSlab',
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Save Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveCategory,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      isEditMode ? 'Update' : 'Save',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'RobotoSlab',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}