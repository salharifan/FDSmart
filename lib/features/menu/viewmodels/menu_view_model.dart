import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fdsmart/features/menu/models/menu_item_model.dart';
import 'package:flutter/material.dart';

class MenuViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<MenuItemModel> _items = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<MenuItemModel> get items => _items;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Getters for specific categories
  List<MenuItemModel> get foodItems =>
      _items.where((i) => i.category == 'food').toList();
  List<MenuItemModel> get drinkItems =>
      _items.where((i) => i.category == 'drink').toList();

  MenuViewModel() {
    fetchMenuItems();
  }

  Future<void> fetchMenuItems() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Offline-first approach could be implemented here with Hive
      // For now, simpler Firestore fetch
      final snapshot = await _firestore.collection('menu_items').get();

      if (snapshot.docs.isNotEmpty) {
        _items = snapshot.docs.map((doc) {
          return MenuItemModel.fromMap(doc.data(), doc.id);
        }).toList();
      } else {
        // SEED DB if empty
        final dummy = _getDummyData();
        for (var item in dummy) {
          await addMenuItem(item);
        }
        // _items will be updated by addMenuItem refetch
      }
    } catch (e) {
      _errorMessage = "Could not fetch live menu: $e";
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addMenuItem(MenuItemModel item) async {
    try {
      await _firestore.collection('menu_items').add(item.toMap());
      await fetchMenuItems(); // Refresh
    } catch (e) {
      _errorMessage = "Failed to add item: $e";
      notifyListeners();
    }
  }

  // Delete Item
  Future<void> deleteMenuItem(String id) async {
    try {
      await _firestore.collection('menu_items').doc(id).delete();
      await fetchMenuItems(); // Refresh
    } catch (e) {
      _errorMessage = "Failed to delete item: $e";
      notifyListeners();
    }
  }

  List<MenuItemModel> _getDummyData() {
    return [
      MenuItemModel(
        id: '1',
        name: 'Classic Burger',
        description: 'Juicy beef patty with fresh lettuce, tomato, and cheese.',
        price: 12.0, // Tokens
        imageUrl: '',
        category: 'food',
        rating: 4.8,
      ),
      MenuItemModel(
        id: '2',
        name: 'Veggie Pizza',
        description:
            'Bell peppers, onions, mushrooms, and olives on thin crust.',
        price: 15.0,
        imageUrl: '',
        category: 'food',
        rating: 4.5,
      ),
      MenuItemModel(
        id: '3',
        name: 'Cola',
        description: 'Chilled carbonated soft drink.',
        price: 3.0,
        imageUrl: '',
        category: 'drink',
        rating: 4.2,
      ),
      MenuItemModel(
        id: '4',
        name: 'Fresh Orange Juice',
        description: 'Freshly squeezed oranges, no sugar added.',
        price: 5.0,
        imageUrl: '',
        category: 'drink',
        rating: 4.9,
      ),
    ];
  }
}
