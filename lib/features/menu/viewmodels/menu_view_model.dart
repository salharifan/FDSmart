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

      // Force re-seed if the first item isn't one of our new ones
      bool needsReseed = snapshot.docs.isEmpty;
      if (!needsReseed) {
        final firstItemName = snapshot.docs.first.data()['name'] as String?;
        if (firstItemName == null || !firstItemName.contains('AVOCADO')) {
          needsReseed = true;
        }
      }

      if (needsReseed) {
        // Clear existing items if any
        for (var doc in snapshot.docs) {
          await _firestore.collection('menu_items').doc(doc.id).delete();
        }

        // SEED DB with new professional menu
        final dummy = _getDummyData();
        final batch = _firestore.batch();
        for (var item in dummy) {
          final docRef = _firestore.collection('menu_items').doc();
          batch.set(docRef, item.toMap());
        }
        await batch.commit();

        // Recursive call (guarded by isLoading)
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

  // Toggle Availability
  Future<void> toggleAvailability(String id, bool isAvailable) async {
    try {
      await _firestore.collection('menu_items').doc(id).update({
        'isAvailable': isAvailable,
      });
      await fetchMenuItems(); // Refresh
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
            'Fresh organic healthy greens with sliced avocado, cherry tomatoes, and balsamic glaze. Perfect healthy choice.',
        price: 450.0,
        imageUrl: 'local:Green salad.jpg',
        category: 'food',
        rating: 4.8,
        calories: 180,
        tag: 'healthy',
      ),
      MenuItemModel(
        id: '1-1',
        name: 'MIXED FRUIT SALAD',
        description:
            'Seasonal fresh healthy fruits mixed with a touch of honey and mint. Refreshing healthy pick.',
        price: 350.0,
        imageUrl:
            'local:fruit_salad_generated.png', // I'll use the generated high qual ones as well or fallback
        category: 'food',
        rating: 4.7,
        calories: 150,
        tag: 'healthy',
        isSpecial: true,
      ),
      MenuItemModel(
        id: '1-2',
        name: 'QUINOA VEGGIE BOWL',
        description:
            'Nutrient dense quinoa with roasted vegetables and lemon tahini dressing.',
        price: 550.0,
        imageUrl: 'local:protein milkshakes.jpg', // Placeholder
        category: 'food',
        rating: 4.9,
        calories: 210,
        tag: 'healthy',
      ),
      MenuItemModel(
        id: '2',
        name: 'GREEK SALMON BOWL',
        description:
            'Pan-seared salmon with quinoa, cucumber, feta cheese, and olives. A healthy choice.',
        price: 1250.0,
        imageUrl: 'local:greek salmon.jpg',
        category: 'food',
        rating: 4.9,
        calories: 450,
        tag: 'healthy',
        isSpecial: true,
      ),
      MenuItemModel(
        id: '3',
        name: 'HEARTY LENTIL SOUP (VEG)',
        description:
            'Warm and hearty lentil soup with garden healthy vegetables and aromatic spices.',
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
        id: '7',
        name: 'CLASSIC BURGER & FRIES',
        description:
            'Premium beef patty with melted cheese, served with crispy golden fries.',
        price: 950.0,
        imageUrl: 'local:burger with fries.png',
        category: 'food',
        rating: 4.7,
        calories: 850,
        isSpecial: true,
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
        price: 350.0,
        imageUrl: 'local:Strawberry Mojito.jpg',
        category: 'drink',
        rating: 4.8,
        calories: 120,
      ),
      MenuItemModel(
        id: '10',
        name: 'AVOCADO JUICE (HEALTHY)',
        description:
            'Creamy and nutritious healthy avocado blend with a hint of honey. High in healthy fats.',
        price: 400.0,
        imageUrl: 'local:avacado juice.png',
        category: 'drink',
        rating: 4.7,
        calories: 210,
        tag: 'healthy',
      ),
      MenuItemModel(
        id: '10-1',
        name: 'KOLA KANDA (HEALTHY)',
        description:
            'Traditional herbal gruel made with medicinal healthy greens and rice. Ultimate healthy drink.',
        price: 180.0,
        imageUrl: 'local:kola kanda drink.jpg',
        category: 'drink',
        rating: 4.9,
        calories: 120,
        tag: 'healthy',
      ),
      MenuItemModel(
        id: '10-2',
        name: 'PROTEIN MILKSHAKE',
        description:
            'Whey protein blended with milk and banana. Perfect healthy recovery.',
        price: 600.0,
        imageUrl: 'local:protein milkshakes.jpg',
        category: 'drink',
        rating: 4.8,
        calories: 350,
        tag: 'healthy',
        isSpecial: true,
      ),
      MenuItemModel(
        id: '11',
        name: 'MASALA CHAI',
        description:
            'Indian style black tea brewed with aromatic spices and milk.',
        price: 150.0,
        imageUrl: 'local:chai.jpg',
        category: 'drink',
        rating: 4.9,
        calories: 90,
      ),
      MenuItemModel(
        id: '12',
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
        name: 'OATMEAL FRUIT BOWL',
        description:
            'Warm healthy oats topped with fresh fruits, nuts and honey.',
        price: 380.0,
        imageUrl: 'local:fruit_salad_generated.png',
        category: 'food',
        rating: 4.8,
        calories: 310,
        tag: 'healthy',
        isSpecial: true,
      ),
      MenuItemModel(
        id: '16',
        name: 'GREEN SMOOTHIE',
        description:
            'Nutrient-packed healthy smoothie with spinach, apple, and ginger.',
        price: 420.0,
        imageUrl: 'local:avacado juice.png',
        category: 'drink',
        rating: 4.9,
        calories: 140,
        tag: 'healthy',
      ),
      MenuItemModel(
        id: '17',
        name: 'GRILLED CHICKEN SALAD',
        description: 'Tender grilled chicken on a bed of fresh healthy greens.',
        price: 750.0,
        imageUrl: 'local:Green salad.jpg',
        category: 'food',
        rating: 4.8,
        calories: 380,
        tag: 'healthy',
        isSpecial: true,
      ),
      MenuItemModel(
        id: '18',
        name: 'CHICKPEA SALAD BOWL',
        description:
            'Protein-rich chickpeas with cucumber, onions and healthy lemon juice.',
        price: 320.0,
        imageUrl: 'local:Green salad.jpg',
        category: 'food',
        rating: 4.7,
        calories: 280,
        tag: 'healthy',
      ),
      MenuItemModel(
        id: '19',
        name: 'BERRY POWER SMOOTHIE',
        description: 'Antioxidant rich healthy mixed berries with almond milk.',
        price: 450.0,
        imageUrl: 'local:Strawberry Mojito.jpg',
        category: 'drink',
        rating: 4.9,
        calories: 180,
        tag: 'healthy',
        isSpecial: true,
      ),
      MenuItemModel(
        id: '20',
        name: 'TOFU STIR FRY',
        description:
            'Pan-fried tofu with healthy seasonal vegetables and light soy.',
        price: 580.0,
        imageUrl: 'local:Green salad.jpg',
        category: 'food',
        rating: 4.6,
        calories: 290,
        tag: 'healthy',
      ),
    ];
  }
}
