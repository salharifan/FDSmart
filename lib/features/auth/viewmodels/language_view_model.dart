import 'package:flutter/material.dart';

enum Language { english, sinhala, tamil }

class LanguageViewModel extends ChangeNotifier {
  Language _currentLanguage = Language.english;

  Language get currentLanguage => _currentLanguage;

  void setLanguage(Language lang) {
    _currentLanguage = lang;
    notifyListeners();
  }

  String translate(String key) {
    if (_currentLanguage == Language.sinhala) {
      return _sinhala[key] ?? key;
    } else if (_currentLanguage == Language.tamil) {
      return _tamil[key] ?? key;
    }
    return _english[key] ?? key;
  }

  static const Map<String, String> _english = {
    'home': 'Home',
    'menu': 'Menu',
    'orders': 'Orders',
    'profile': 'Profile',
    'search_hint': 'Search for food, drinks...',
    'todays_specials': "Today's Specials",
    'healthy_picks': 'Healthy Picks',
    'order_tracker': 'Order Tracker',
    'nutrition_info': 'Nutrition Info',
    'favourites': 'Favourites',
    'settings': 'Settings',
    'language': 'Language',
    'change_password': 'Change Password',
    'confirm_order': 'CONFIRM ORDER',
    'total_amount': 'Total Amount',
    'food': 'Food',
    'drink': 'Drinks',
  };

  static const Map<String, String> _sinhala = {
    'home': 'මුල් පිටුව',
    'menu': 'මෙනුව',
    'orders': 'ඇණවුම්',
    'profile': 'ගිණුම',
    'search_hint': 'ආහාර, බීම සොයන්න...',
    'todays_specials': 'අද විශේෂ',
    'healthy_picks': 'සෞඛ්‍ය සම්පන්න',
    'order_tracker': 'ඇණවුම් පරීක්ෂාව',
    'nutrition_info': 'පෝෂණ තොරතුරු',
    'favourites': 'කැමතිම දේ',
    'settings': 'සැකසුම්',
    'language': 'භාෂාව',
    'change_password': 'මුරපදය වෙනස් කරන්න',
    'confirm_order': 'ඇණවුම තහවුරු කරන්න',
    'total_amount': 'මුළු මුදල',
    'food': 'ආහාර',
    'drink': 'බීම',
  };

  static const Map<String, String> _tamil = {
    'home': 'முகப்பு',
    'menu': 'மெனு',
    'orders': 'ஆர்டர்கள்',
    'profile': 'சுயவிவரம்',
    'search_hint': 'உணவு, பானங்களைத் தேடுங்கள்...',
    'todays_specials': 'இன்றைய சிறப்பு',
    'healthy_picks': 'ஆரோக்கியமான தேர்வு',
    'order_tracker': 'ஆர்டர் டிராக்கர்',
    'nutrition_info': 'ஊட்டச்சத்து தகவல்',
    'favourites': 'பிடித்தவை',
    'settings': 'அமைப்புகள்',
    'language': 'மொழி',
    'change_password': 'கடவுச்சொல்லை மாற்றவும்',
    'confirm_order': 'ஆர்டரை உறுதிப்படுத்தவும்',
    'total_amount': 'மொத்த தொகை',
    'food': 'உணவு',
    'drink': 'பானங்கள்',
  };
}
