/// 앱에서 사용하는 다국어 문자열을 정의합니다.
class AppStrings {
  // Private constructor
  AppStrings._();

  // 한국어 문자열
  static const Map<String, String> ko = {
    // App
    'app_name': 'Vocatch',
    
    // Bottom Navigation
    'nav_today_learning': '오늘의 학습',
    'nav_vocabulary': '단어장',
    'nav_card_matching': '카드 매칭',
    
    // Language Selection
    'select_learning_language': '학습할 언어를 선택하세요',
    'select_ui_language': 'UI 언어를 선택하세요',
    'korean': '한국어',
    'english': '영어',
    'start': '시작하기',
    
    // Today's Learning
    'today_learning_title': '오늘의 학습',
    'level_beginner': '초급',
    'level_intermediate': '중급',
    'level_advanced': '고급',
    'no_words_today': '오늘 학습할 단어가 없습니다',
    'add_to_vocabulary': '단어장에 추가',
    'remove_from_vocabulary': '단어장에서 제거',
    'word': '단어',
    'expression': '표현',
    'meaning': '의미',
    'example': '예문',
    'pronunciation': '발음',
    
    // Vocabulary
    'vocabulary_title': '단어장',
    'create_group': '그룹 생성',
    'group_name': '그룹 이름',
    'create': '생성',
    'cancel': '취소',
    'no_vocabulary': '저장된 단어가 없습니다',
    'all_words': '모든 단어',
    'delete_group': '그룹 삭제',
    'edit_group': '그룹 수정',
    
    // Card Matching
    'card_matching_title': '카드 매칭',
    'select_group': '그룹을 선택하세요',
    'start_game': '게임 시작',
    'score': '점수',
    'time': '시간',
    'complete': '완료',
    'retry': '다시 하기',
    'no_groups': '그룹이 없습니다',
    
    // Common
    'save': '저장',
    'delete': '삭제',
    'edit': '수정',
    'confirm': '확인',
    'back': '뒤로',
    'next': '다음',
    'done': '완료',
    'loading': '로딩중...',
    'error': '오류',
    'success': '성공',
  };

  // 영어 문자열
  static const Map<String, String> en = {
    // App
    'app_name': 'Vocatch',
    
    // Bottom Navigation
    'nav_today_learning': 'Today\'s Learning',
    'nav_vocabulary': 'Vocabulary',
    'nav_card_matching': 'Card Matching',
    
    // Language Selection
    'select_learning_language': 'Select learning language',
    'select_ui_language': 'Select UI language',
    'korean': 'Korean',
    'english': 'English',
    'start': 'Start',
    
    // Today's Learning
    'today_learning_title': 'Today\'s Learning',
    'level_beginner': 'Beginner',
    'level_intermediate': 'Intermediate',
    'level_advanced': 'Advanced',
    'no_words_today': 'No words to learn today',
    'add_to_vocabulary': 'Add to Vocabulary',
    'remove_from_vocabulary': 'Remove from Vocabulary',
    'word': 'Word',
    'expression': 'Expression',
    'meaning': 'Meaning',
    'example': 'Example',
    'pronunciation': 'Pronunciation',
    
    // Vocabulary
    'vocabulary_title': 'My Vocabulary',
    'create_group': 'Create Group',
    'group_name': 'Group Name',
    'create': 'Create',
    'cancel': 'Cancel',
    'no_vocabulary': 'No saved words',
    'all_words': 'All Words',
    'delete_group': 'Delete Group',
    'edit_group': 'Edit Group',
    
    // Card Matching
    'card_matching_title': 'Card Matching',
    'select_group': 'Select a group',
    'start_game': 'Start Game',
    'score': 'Score',
    'time': 'Time',
    'complete': 'Complete',
    'retry': 'Retry',
    'no_groups': 'No groups available',
    
    // Common
    'save': 'Save',
    'delete': 'Delete',
    'edit': 'Edit',
    'confirm': 'Confirm',
    'back': 'Back',
    'next': 'Next',
    'done': 'Done',
    'loading': 'Loading...',
    'error': 'Error',
    'success': 'Success',
  };

  /// 언어 코드에 따라 문자열을 반환합니다.
  static String get(String key, String languageCode) {
    final strings = languageCode == 'ko' ? ko : en;
    return strings[key] ?? key;
  }
}
