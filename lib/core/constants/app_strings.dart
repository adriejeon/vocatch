/// 앱에서 사용하는 다국어 문자열을 정의합니다.
class AppStrings {
  // Private constructor
  AppStrings._();

  // 한국어 문자열
  static const Map<String, String> ko = {
    // App
    'app_name': 'Vocatch',

    // Bottom Navigation
    'nav_today_learning': '오늘의 단어',
    'nav_vocabulary': '단어장',
    'nav_card_matching': '카드 매칭',

    // Language Selection
    'select_learning_language': '학습할 언어를 선택하세요',
    'select_ui_language': 'UI 언어를 선택하세요',
    'korean': '한국어',
    'english': '영어',
    'start': '시작하기',

    // Today's Learning
    'today_learning_title': '오늘의 단어',
    'level_foundation': '기초 다지기',
    'level_expression': '표현력 확장',
    'level_native': '원어민 수준',
    'level_beginner': '기초다지기',
    'level_intermediate': '표현력확장',
    'level_advanced': '원어민수준',
    'no_words_today': '오늘 학습할 단어가 없습니다',
    'add_to_vocabulary': '단어장에 추가',
    'remove_from_vocabulary': '단어장에서 제거',
    'word': '단어',
    'expression': '표현',
    'meaning': '의미',
    'example': '예문',
    'pronunciation': '발음',
    'verb_conjugations': '동사 변화형',

    // Parts of Speech
    'pos_noun': '명사',
    'pos_verb': '동사',
    'pos_adjective': '형용사',
    'pos_adverb': '부사',
    'pos_pronoun': '대명사',
    'pos_preposition': '전치사',
    'pos_conjunction': '접속사',
    'pos_interjection': '감탄사',
    'pos_article': '관사',
    'pos_determiner': '한정사',
    'pos_auxiliary': '조동사',
    'pos_modal': '조동사',
    'pos_particle': '조사',
    'pos_numeral': '수사',
    'pos_cardinal': '기수',
    'pos_ordinal': '서수',

    // Vocabulary
    'vocabulary_title': '단어장',
    'create_group': '그룹 생성',
    'group_name': '그룹 이름',
    'create': '생성',
    'cancel': '취소',
    'no_vocabulary': '저장된 단어가 없습니다',
    'all_words': '모든 단어',
    'delete_group': '그룹 삭제',
    'delete_group_confirm': '이 그룹을 삭제하시겠습니까',
    'group_deleted': '그룹이 삭제되었습니다',
    'delete_failed': '삭제 실패',
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
    'game_restart': '게임 재시작',
    'go_home': '홈으로',
    'create_group_first': '단어장에서 그룹을 먼저 만들어주세요',
    'moves': '이동',
    'matches': '매칭',
    'game_start_failed': '게임 시작 실패',
    'game_complete': '게임 완료!',
    'total_moves': '총 이동 횟수',
    'completion_time': '완료 시간',
    'accuracy': '정확도',
    'final_score': '최종 점수',

    // Level Test
    'level_test_title': '언어 수준 테스트',
    'level_test_subtitle': '간단한 테스트로 당신의 수준을 확인해보세요',
    'level_test_question': '다음 단어를 아시나요?',
    'i_know': '알아요',
    'i_dont_know': '몰라요',
    'skip_test': '테스트 건너뛰기',
    'test_complete': '테스트 완료!',
    'your_level_is': '당신의 수준은',
    'level_setting': '난이도 설정',
    'change_level': '수준 변경',
    'start_studying': '공부 시작하기',
    'get_words_today': '오늘의 단어를 받아보세요',
    'get_words_button': '단어 받아보기',

    // Category
    'category_conversation': '일상 회화',
    'category_travel': '여행',
    'category_business': '비즈니스',
    'category_news': '뉴스/시사',

    // Vocabulary Group
    'add_to_group': '그룹에 추가',
    'select_group_to_add': '추가할 그룹을 선택하세요',
    'added_to_group': '그룹에 추가되었습니다',

    // Add Word
    'add_new_word': '새 단어 추가',
    'word_text': '단어',
    'word_hint': '단어를 입력하세요',
    'meaning_hint': '의미를 입력하세요',
    'pronunciation_hint': '발음을 입력하세요 (선택)',
    'example_hint': '예문을 입력하세요 (선택)',
    'select_level': '난이도 선택',
    'select_type': '타입 선택',
    'type_word': '단어',
    'type_expression': '표현',
    'word_added': '단어가 추가되었습니다',
    'please_enter_word': '단어를 입력해주세요',
    'please_enter_meaning': '의미를 입력해주세요',
    'refreshed': '새로고침되었습니다',

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
    'nav_today_learning': 'Today\'s Words',
    'nav_vocabulary': 'Vocabulary',
    'nav_card_matching': 'Card Matching',

    // Language Selection
    'select_learning_language': 'Select learning language',
    'select_ui_language': 'Select UI language',
    'korean': 'Korean',
    'english': 'English',
    'start': 'Start',

    // Today's Learning
    'today_learning_title': 'Today\'s Words',
    'level_foundation': 'Build Foundation',
    'level_expression': 'Expand Expression',
    'level_native': 'Native Level',
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
    'verb_conjugations': 'Verb Conjugations',

    // Parts of Speech
    'pos_noun': 'Noun',
    'pos_verb': 'Verb',
    'pos_adjective': 'Adjective',
    'pos_adverb': 'Adverb',
    'pos_pronoun': 'Pronoun',
    'pos_preposition': 'Preposition',
    'pos_conjunction': 'Conjunction',
    'pos_interjection': 'Interjection',
    'pos_article': 'Article',
    'pos_determiner': 'Determiner',
    'pos_auxiliary': 'Auxiliary',
    'pos_modal': 'Modal',
    'pos_particle': 'Particle',
    'pos_numeral': 'Numeral',
    'pos_cardinal': 'Cardinal',
    'pos_ordinal': 'Ordinal',

    // Vocabulary
    'vocabulary_title': 'My Vocabulary',
    'create_group': 'Create Group',
    'group_name': 'Group Name',
    'create': 'Create',
    'cancel': 'Cancel',
    'no_vocabulary': 'No saved words',
    'all_words': 'All Words',
    'delete_group': 'Delete Group',
    'delete_group_confirm': 'Are you sure you want to delete this group',
    'group_deleted': 'Group deleted successfully',
    'delete_failed': 'Delete failed',
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
    'game_restart': 'Restart Game',
    'go_home': 'Go Home',
    'create_group_first': 'Please create a group in vocabulary first',
    'moves': 'Moves',
    'matches': 'Matches',
    'game_start_failed': 'Failed to start game',
    'game_complete': 'Game Complete!',
    'total_moves': 'Total Moves',
    'completion_time': 'Completion Time',
    'accuracy': 'Accuracy',
    'final_score': 'Final Score',

    // Level Test
    'level_test_title': 'Language Level Test',
    'level_test_subtitle': 'Let\'s check your level with a simple test',
    'level_test_question': 'Do you know this word?',
    'i_know': 'I Know',
    'i_dont_know': 'I Don\'t Know',
    'skip_test': 'Skip Test',
    'test_complete': 'Test Complete!',
    'your_level_is': 'Your level is',
    'level_setting': 'Level Setting',
    'change_level': 'Change Level',
    'start_studying': 'Start Studying',
    'get_words_today': 'Get today\'s words',
    'get_words_button': 'Get Words',

    // Category
    'category_conversation': 'Chat',
    'category_travel': 'Travel',
    'category_business': 'Business',
    'category_news': 'News',

    // Vocabulary Group
    'add_to_group': 'Add to Group',
    'select_group_to_add': 'Select a group to add',
    'added_to_group': 'Added to group',

    // Add Word
    'add_new_word': 'Add New Word',
    'word_text': 'Word',
    'word_hint': 'Enter word',
    'meaning_hint': 'Enter meaning',
    'pronunciation_hint': 'Enter pronunciation (optional)',
    'example_hint': 'Enter example (optional)',
    'select_level': 'Select Level',
    'select_type': 'Select Type',
    'type_word': 'Word',
    'type_expression': 'Expression',
    'word_added': 'Word added',
    'please_enter_word': 'Please enter word',
    'please_enter_meaning': 'Please enter meaning',
    'refreshed': 'Refreshed',

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
