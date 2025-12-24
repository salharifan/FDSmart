import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fdsmart/features/menu/models/menu_item_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MenuViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<MenuItemModel> _items = [];
  String _searchQuery = "";
  bool _isLoading = false;
  String? _errorMessage;

  List<MenuItemModel> get items => itemsWithFavorites([]);

  List<MenuItemModel> itemsWithFavorites(List<String> favorites) {
    List<MenuItemModel> results = _items;
    if (_searchQuery == "fav:only") {
      results = _items.where((i) => favorites.contains(i.id)).toList();
    } else if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      results = _items
          .where(
            (i) =>
                i.name.toLowerCase().contains(q) ||
                i.category.toLowerCase().contains(q) ||
                i.description.toLowerCase().contains(q) ||
                i.tag.toLowerCase().contains(q),
          )
          .toList();
    }
    return results;
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<String> _userFavorites = [];

  void setUserFavorites(List<String> favorites) {
    _userFavorites = favorites;
    notifyListeners();
  }

  List<MenuItemModel> get foodItems => itemsWithFavorites(
    _userFavorites,
  ).where((i) => i.category == 'food').toList();
  List<MenuItemModel> get drinkItems => itemsWithFavorites(
    _userFavorites,
  ).where((i) => i.category == 'drink').toList();

  List<MenuItemModel> get specialItems =>
      _items.where((i) => i.isSpecial).toList();

  MenuViewModel() {
    fetchMenuItems();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> fetchMenuItems() async {
    if (_isLoading) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final snapshot = await _firestore.collection('menu_items').get();

      // Re-seed only if empty or missing new deals
      bool needsReseed =
          snapshot.docs.isEmpty ||
          !snapshot.docs.any((doc) => doc.data().toString().contains('DEAL'));

      if (needsReseed) {
        // Clear existing items if any
        for (var doc in snapshot.docs) {
          await _firestore.collection('menu_items').doc(doc.id).delete();
        }

        // SEED DB with professional menu and DEALS
        final dummy = _getDummyData();
        final batch = _firestore.batch();
        for (var item in dummy) {
          final docRef = _firestore.collection('menu_items').doc();
          batch.set(docRef, item.toMap());
        }
        await batch.commit();

        // Recursive call
        _isLoading = false;
        return await fetchMenuItems();
      } else {
        _items = snapshot.docs.map((doc) {
          return MenuItemModel.fromMap(doc.data(), doc.id);
        }).toList();
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
      await fetchMenuItems();
    } catch (e) {
      _errorMessage = "Failed to add item: $e";
      notifyListeners();
    }
  }

  Future<void> deleteMenuItem(String id) async {
    try {
      await _firestore.collection('menu_items').doc(id).delete();
      await fetchMenuItems();
    } catch (e) {
      _errorMessage = "Failed to delete item: $e";
      notifyListeners();
    }
  }

  Future<void> toggleAvailability(String id, bool isAvailable) async {
    try {
      await _firestore.collection('menu_items').doc(id).update({
        'isAvailable': isAvailable,
      });
      await fetchMenuItems();
    } catch (e) {
      _errorMessage = "Failed to update availability: $e";
      notifyListeners();
    }
  }

  List<MenuItemModel> _getDummyData() {
    return [
      MenuItemModel(
        id: '1',
        name: 'AVOCADO GREEN SALAD (VEG)',
        description:
            'TODAY\'S DEAL: Fresh organic healthy greens with sliced avocado. Best seller.',
        price: 399.0,
        imageUrl: 'local:Green salad.jpg',
        category: 'food',
        rating: 4.8,
        calories: 180,
        tag: 'healthy',
        isSpecial: true,
      ),
      MenuItemModel(
        id: '2',
        name: 'GREEK SALMON BOWL',
        description:
            'LIMITED TIME DEAL: Pan-seared salmon with quinoa and feta. Pure healthy energy.',
        price: 899.0,
        imageUrl: 'local:greek salmon.jpg',
        category: 'food',
        rating: 4.9,
        calories: 450,
        tag: 'healthy',
        isSpecial: true,
      ),
      MenuItemModel(
        id: '7',
        name: 'CLASSIC BURGER & FRIES',
        description:
            'COMBO DEAL: Premium beef patty with melted cheese and crispy golden fries.',
        price: 750.0,
        imageUrl: 'local:burger with fries.png',
        category: 'food',
        rating: 4.7,
        calories: 850,
        isSpecial: true,
      ),
      MenuItemModel(
        id: '12',
        name: 'PROTEIN MILKSHAKE',
        description:
            'POST-WORKOUT DEAL: High-quality whey protein blend. Perfect healthy recovery.',
        price: 450.0,
        imageUrl: 'local:protein milkshakes.jpg',
        category: 'drink',
        rating: 4.8,
        calories: 350,
        tag: 'healthy',
        isSpecial: true,
      ),
      MenuItemModel(
        id: '3',
        name: 'HEARTY LENTIL SOUP (VEG)',
        description:
            'Warm and hearty lentil soup with garden healthy vegetables.',
        price: 300.0,
        imageUrl: 'local:lentil soup.jpg',
        category: 'food',
        rating: 4.6,
        calories: 220,
        tag: 'healthy',
      ),
      MenuItemModel(
        id: '4',
        name: 'MAC AND CHEESE',
        description:
            'Classic comfort food with a blend of four artisanal cheeses.',
        price: 650.0,
        imageUrl: 'local:mac and cheese.jpg',
        category: 'food',
        rating: 4.7,
        calories: 550,
      ),
      MenuItemModel(
        id: '5',
        name: 'MASALA DOSA (VEG)',
        description:
            'Crispy rice crepe filled with spiced potato mash, served with chutney.',
        price: 250.0,
        imageUrl: 'local:masala dosa.jpg',
        category: 'food',
        rating: 4.8,
        calories: 320,
      ),
      MenuItemModel(
        id: '6',
        name: 'CHICKEN BIRIYANI',
        description:
            'Fragrant basmati rice cooked with tender chicken and authentic spices.',
        price: 850.0,
        imageUrl: 'local:biriyani.png',
        category: 'food',
        rating: 4.9,
        calories: 680,
      ),
      MenuItemModel(
        id: '8',
        name: 'CHOCOLATE WAFFLE',
        description:
            'Crispy waffle drizzled with premium dark chocolate sauce.',
        price: 550.0,
        imageUrl: 'local:choclate waffle.jpg',
        category: 'food',
        rating: 4.8,
        calories: 480,
      ),
      MenuItemModel(
        id: '9',
        name: 'STRAWBERRY MOJITO',
        description:
            'Refreshing blend of fresh strawberries, mint, lime, and soda.',
        price: 380.0,
        imageUrl: 'local:Strawberry Mojito.jpg',
        category: 'drink',
        rating: 4.8,
        calories: 120,
      ),
      MenuItemModel(
        id: '10',
        name: 'AVOCADO JUICE (HEALTHY)',
        description:
            'Creamy and nutritious healthy avocado blend. High in healthy fats.',
        price: 400.0,
        imageUrl: 'local:avacado juice.png',
        category: 'drink',
        rating: 4.7,
        calories: 210,
        tag: 'healthy',
      ),
      MenuItemModel(
        id: '11',
        name: 'KOLA KANDA (HEALTHY)',
        description:
            'Traditional herbal healthy greens and rice. Ultimate healthy drink.',
        price: 180.0,
        imageUrl: 'local:kola kanda drink.jpg',
        category: 'drink',
        rating: 4.9,
        calories: 120,
        tag: 'healthy',
      ),
      MenuItemModel(
        id: '13',
        name: 'MASALA CHAI',
        description: 'Indian style black tea brewed with aromatic spices.',
        price: 150.0,
        imageUrl: 'local:chai.jpg',
        category: 'drink',
        rating: 4.9,
        calories: 90,
      ),
      MenuItemModel(
        id: '14',
        name: 'LEMON MOJITO COCKTAIL',
        description: 'Sparkling cocktail with zesty lemon and cool mint.',
        price: 450.0,
        imageUrl: 'local:lemon mojito cocktail.jpg',
        category: 'drink',
        rating: 4.5,
        calories: 150,
      ),
      MenuItemModel(
        id: '15',
        name: 'CHILLED PEPSI',
        description: 'Refresh yourself with a classic chilled Pepsi.',
        price: 120.0,
        imageUrl: 'local:pepsi.png',
        category: 'drink',
        rating: 4.3,
        calories: 140,
      ),
    ];
  }
}
