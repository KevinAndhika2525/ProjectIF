import 'package:flutter/material.dart';
import '../helper/colors.dart';
import 'newCategory.dart';
import '../helper/local_storage.dart';

class ManageCategoriesPage extends StatefulWidget {
  const ManageCategoriesPage({super.key});

  @override
  State<ManageCategoriesPage> createState() => _ManageCategoriesPageState();
}

class _ManageCategoriesPageState extends State<ManageCategoriesPage> {
  List<Map<String, dynamic>> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categories = await LocalStorage.getCategories();
    if (mounted) {
      setState(() {
        _categories = categories;
      });
    }
  }

  // Future<void> _saveCategories() async {
  //   await LocalStorage.saveCategories(_categories);
  // }

  void _navigateToNewCategory({Map<String, dynamic>? categoryToEdit}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewCategoryPage(
          categoryToEdit: categoryToEdit,
          onCategoryAdded: (newCategory) async {
            if (categoryToEdit != null) {
              // Update existing category
              await LocalStorage.updateCategory(
                categoryToEdit['id'],
                newCategory,
              );
            } else {
              // Add new category
              await LocalStorage.addCategory(newCategory);
            }
            
            // Reload categories
            await _loadCategories();
          },
        ),
      ),
    );
  }

  Future<void> _deleteCategory(int index) async {
    final category = _categories[index];
    final categoryName = category['name'];
    final categoryId = category['id'];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Delete Category',
          style: TextStyle(fontFamily: 'RobotoSlab', fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to delete "$categoryName"?',
          style: const TextStyle(fontFamily: 'RobotoSlab'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(fontFamily: 'RobotoSlab'),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              // Delete from storage
              await LocalStorage.deleteCategory(categoryId);
              
              // Update local state
              setState(() {
                _categories.removeAt(index);
              });
            },
            child: const Text(
              'Delete',
              style: TextStyle(
                fontFamily: 'RobotoSlab',
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manage Categories',
          style: TextStyle(
            fontFamily: 'RobotoSlab',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: appColors.appBarColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Judul Categories
            const Text(
              'Categories',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'RobotoSlab',
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 10),
            
            // Daftar Kategori
            Expanded(
              child: _categories.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.category,
                            size: 60,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No categories yet',
                            style: TextStyle(
                              fontFamily: 'RobotoSlab',
                              fontSize: 18,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Add your first category',
                            style: TextStyle(
                              fontFamily: 'RobotoSlab',
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          elevation: 1,
                          child: ListTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                // ignore: deprecated_member_use
                                color: _getSafeColor(category).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _getSafeIcon(category),
                                color: _getSafeColor(category),
                                size: 22,
                              ),
                            ),
                            title: Text(
                              category['name'],
                              style: const TextStyle(
                                fontFamily: 'RobotoSlab',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
                                  onPressed: () {
                                    _navigateToNewCategory(categoryToEdit: category);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                  onPressed: () => _deleteCategory(index),
                                ),
                              ],
                            ),
                            onTap: () {
                              _navigateToNewCategory(categoryToEdit: category);
                            },
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToNewCategory(),
        backgroundColor: appColors.appBarColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.add, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  IconData _getSafeIcon(Map<String, dynamic> category) {
    try {
      if (category['icon'] is IconData) {
        return category['icon'];
      } else {
        // Try to reconstruct IconData from stored properties
        final codePoint = category['iconCodePoint'] as int?;
        if (codePoint != null) {
          return IconData(
            codePoint,
            fontFamily: category['iconFontFamily'] as String?,
            fontPackage: category['iconFontPackage'] as String?,
          );
        }
      }
    } catch (e) {
      print('Error getting icon for category ${category['name']}: $e');
    }
    return Icons.category; // Fallback icon
  }
  Color _getSafeColor(Map<String, dynamic> category) {
    try {
      if (category['color'] is Color) {
        return category['color'];
      } else if (category['color'] is int) {
        return Color(category['color']);
      }
    } catch (e) {
      print('Error getting color for category ${category['name']}: $e');
    }
    return Colors.blue; // Fallback color
  }
}