import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_strings.dart';
import '../core/providers/language_provider.dart';
import 'word_learning/screens/api_today_learning_screen.dart';
import 'vocabulary/screens/vocabulary_screen.dart';
import 'card_game/screens/card_matching_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(languageProvider);
    final uiLang = settings.uiLanguage;

    final screens = [
      const ApiTodayLearningScreen(),
      const VocabularyScreen(),
      const CardMatchingScreen(),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.book_outlined),
            activeIcon: const Icon(Icons.book),
            label: AppStrings.get('nav_today_learning', uiLang),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.folder_outlined),
            activeIcon: const Icon(Icons.folder),
            label: AppStrings.get('nav_vocabulary', uiLang),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.games_outlined),
            activeIcon: const Icon(Icons.games),
            label: AppStrings.get('nav_card_matching', uiLang),
          ),
        ],
      ),
    );
  }
}
