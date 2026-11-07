import 'package:flutter/material.dart';

class IconsHelper {
  static IconData getIconByName(String name) {
    switch (name) {
      case 'calculate':
        return Icons.calculate_rounded;
      case 'shapes':
        return Icons.category_rounded;
      case 'menu_book':
        return Icons.menu_book_rounded;
      case 'bolt':
        return Icons.bolt_rounded;
      case 'science':
        return Icons.science_rounded;
      case 'eco':
        return Icons.eco_rounded;
      case 'history_edu':
        return Icons.history_edu_rounded;
      case 'public':
        return Icons.public_rounded;
      case 'psychology':
        return Icons.psychology_rounded;
      case 'school':
        return Icons.school_rounded;
      case 'star':
        return Icons.star_rounded;
      case 'lightbulb':
        return Icons.lightbulb_rounded;
      default:
        return Icons.auto_stories_rounded;
    }
  }

  static List<String> availableIconNames = [
    'calculate',
    'shapes',
    'menu_book',
    'bolt',
    'science',
    'eco',
    'history_edu',
    'public',
    'psychology',
    'school',
    'star',
    'lightbulb',
  ];
}
