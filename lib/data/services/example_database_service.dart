import 'package:hive/hive.dart';

/// 자체 예문 데이터베이스 서비스 (Tatoeba 기반)
class ExampleDatabaseService {
  static const String _boxName = 'example_database';
  static Box? _box;

  /// 데이터베이스 초기화
  static Future<void> init() async {
    _box = await Hive.openBox(_boxName);
    await _loadInitialData();
  }

  /// 초기 예문 데이터 로드 (Tatoeba 기반 커리큘럼 예문들)
  static Future<void> _loadInitialData() async {
    if (_box == null) return;

    // 이미 데이터가 있으면 스킵
    if (_box!.isNotEmpty) return;

    // Tatoeba 기반 고품질 예문 데이터
    final exampleData = {
      // 기본 동사들
      'be': [
        'I am a student.',
        'You are my friend.',
        'He is very tall.',
        'She is from Korea.',
        'It is a beautiful day.',
        'We are learning English.',
        'They are happy.',
        'I was at home yesterday.',
        'You were right.',
        'He was sleeping.',
        'She was working.',
        'It was raining.',
        'We were studying.',
        'They were playing.',
      ],
      'have': [
        'I have a car.',
        'You have a nice house.',
        'He has three children.',
        'She has a good job.',
        'It has four legs.',
        'We have dinner at 7 PM.',
        'They have a big family.',
        'I had breakfast this morning.',
        'You had a great time.',
        'He had a meeting yesterday.',
        'She had a headache.',
        'It had a problem.',
        'We had fun at the party.',
        'They had a good vacation.',
      ],
      'do': [
        'I do my homework every day.',
        'You do a great job.',
        'He does his best.',
        'She does yoga in the morning.',
        'It does not work properly.',
        'We do our shopping on weekends.',
        'They do volunteer work.',
        'I did my laundry yesterday.',
        'You did well on the test.',
        'He did his homework.',
        'She did the dishes.',
        'It did not rain.',
        'We did our best.',
        'They did a good job.',
      ],
      'go': [
        'I go to school by bus.',
        'You go to work early.',
        'He goes to the gym.',
        'She goes shopping on weekends.',
        'It goes very fast.',
        'We go to the movies.',
        'They go on vacation.',
        'I went to the store.',
        'You went home early.',
        'He went to the doctor.',
        'She went to the library.',
        'It went wrong.',
        'We went to the beach.',
        'They went to the concert.',
      ],
      'come': [
        'I come from Korea.',
        'You come to visit us.',
        'He comes to work by car.',
        'She comes home late.',
        'It comes in different colors.',
        'We come here often.',
        'They come from different countries.',
        'I came to see you.',
        'You came to the party.',
        'He came home yesterday.',
        'She came to the meeting.',
        'It came as a surprise.',
        'We came to help.',
        'They came to visit.',
      ],
      'get': [
        'I get up at 7 AM.',
        'You get good grades.',
        'He gets angry easily.',
        'She gets tired quickly.',
        'It gets dark early.',
        'We get along well.',
        'They get together often.',
        'I got a new job.',
        'You got the message.',
        'He got married last year.',
        'She got a promotion.',
        'It got better.',
        'We got lost.',
        'They got home safely.',
      ],
      'make': [
        'I make coffee every morning.',
        'You make delicious food.',
        'He makes a lot of money.',
        'She makes friends easily.',
        'It makes sense.',
        'We make plans for the weekend.',
        'They make a difference.',
        'I made a mistake.',
        'You made a good point.',
        'He made dinner for us.',
        'She made a reservation.',
        'It made me happy.',
        'We made progress.',
        'They made a decision.',
      ],
      'take': [
        'I take a shower every morning.',
        'You take good care of your family.',
        'He takes the bus to work.',
        'She takes her time.',
        'It takes time to learn.',
        'We take a break at noon.',
        'They take turns driving.',
        'I took a photo.',
        'You took the wrong turn.',
        'He took a vacation.',
        'She took the medicine.',
        'It took three hours.',
        'We took a walk.',
        'They took the train.',
      ],
      'see': [
        'I see my friends every week.',
        'You see the problem clearly.',
        'He sees a doctor regularly.',
        'She sees the world differently.',
        'It sees the light.',
        'We see each other often.',
        'They see the opportunity.',
        'I saw a movie yesterday.',
        'You saw what happened.',
        'He saw the accident.',
        'She saw her family.',
        'It saw the sunrise.',
        'We saw the concert.',
        'They saw the results.',
      ],
      'know': [
        'I know the answer.',
        'You know what to do.',
        'He knows how to cook.',
        'She knows the truth.',
        'It knows the way.',
        'We know each other well.',
        'They know the secret.',
        'I knew him in college.',
        'You knew the answer.',
        'He knew the way.',
        'She knew the truth.',
        'It knew the time.',
        'We knew the problem.',
        'They knew the solution.',
      ],
      // 일반적인 명사들
      'time': [
        'Time flies when you are having fun.',
        'What time is it?',
        'I have no time for this.',
        'Time will tell.',
        'It is time to go.',
        'Time is money.',
        'I need more time.',
        'Time heals all wounds.',
        'Time is precious.',
        'Time waits for no one.',
      ],
      'way': [
        'This is the way to the station.',
        'I know the way home.',
        'There is no way to do this.',
        'Which way should I go?',
        'The way you speak is interesting.',
        'In a way, you are right.',
        'This is the way it is.',
        'The way forward is clear.',
        'I like the way you think.',
        'The way things are going.',
      ],
      'people': [
        'People are generally good.',
        'Many people came to the party.',
        'People say it is true.',
        'I like meeting new people.',
        'People need to work together.',
        'Some people are very kind.',
        'People often make mistakes.',
        'I respect all people.',
        'People have different opinions.',
        'People want to be happy.',
      ],
      'work': [
        'I work at a company.',
        'You work very hard.',
        'He works in an office.',
        'She works from home.',
        'It works perfectly.',
        'We work together well.',
        'They work on weekends.',
        'I worked late yesterday.',
        'You worked on this project.',
        'He worked for many years.',
        'She worked as a teacher.',
        'It worked as expected.',
        'We worked all night.',
        'They worked in teams.',
      ],
      'life': [
        'Life is beautiful.',
        'I love my life.',
        'Life can be difficult.',
        'Life is full of surprises.',
        'Life goes on.',
        'Life is what you make it.',
        'Life is precious.',
        'Life has its ups and downs.',
        'Life is a journey.',
        'Life is too short.',
      ],
      'day': [
        'Today is a beautiful day.',
        'I have a busy day ahead.',
        'Every day is a new beginning.',
        'The day is getting longer.',
        'I work during the day.',
        'What a wonderful day!',
        'The day went by quickly.',
        'I had a great day.',
        'The day is almost over.',
        'Tomorrow is another day.',
      ],
      'year': [
        'This year has been amazing.',
        'I am 25 years old.',
        'The year is almost over.',
        'Next year will be better.',
        'I have been here for a year.',
        'The year went by fast.',
        'I plan to travel this year.',
        'The year started well.',
        'I learned a lot this year.',
        'The year is ending soon.',
      ],
      'world': [
        'The world is a big place.',
        'I want to see the world.',
        'The world is changing.',
        'We live in a connected world.',
        'The world needs peace.',
        'I love the world we live in.',
        'The world is full of possibilities.',
        'We share this world.',
        'The world is beautiful.',
        'The world is getting smaller.',
      ],
      'home': [
        'I am going home.',
        'Home is where the heart is.',
        'I feel at home here.',
        'Home sweet home.',
        'I miss my home.',
        'There is no place like home.',
        'I work from home.',
        'Home is my favorite place.',
        'I left home early.',
        'Home is where I belong.',
      ],
      'friend': [
        'You are my best friend.',
        'I have many friends.',
        'A friend in need is a friend indeed.',
        'I made a new friend.',
        'Friends are important.',
        'I trust my friends.',
        'Friends help each other.',
        'I value my friends.',
        'Friends share everything.',
        'I love my friends.',
      ],
      // 형용사들
      'good': [
        'This is a good book.',
        'You are a good person.',
        'He has good ideas.',
        'She is a good teacher.',
        'It is good weather today.',
        'We had a good time.',
        'They are good friends.',
        'I feel good today.',
        'This looks good.',
        'That sounds good.',
      ],
      'new': [
        'I bought a new car.',
        'You have a new job.',
        'He is learning new skills.',
        'She moved to a new city.',
        'It is a new beginning.',
        'We have new neighbors.',
        'They started a new business.',
        'I made new friends.',
        'This is new to me.',
        'That is a new idea.',
      ],
      'first': [
        'This is my first time.',
        'You are the first person.',
        'He won first place.',
        'She was first in line.',
        'It is the first step.',
        'We met for the first time.',
        'They arrived first.',
        'I remember the first day.',
        'This is the first time.',
        'That was the first time.',
      ],
      'last': [
        'This is the last time.',
        'You were the last one.',
        'He came last.',
        'She was the last person.',
        'It is the last chance.',
        'We saw each other last week.',
        'They left last month.',
        'I saw him last year.',
        'This is the last one.',
        'That was the last time.',
      ],
      'long': [
        'This is a long story.',
        'You have long hair.',
        'He has been here a long time.',
        'She waited a long time.',
        'It takes a long time.',
        'We have a long way to go.',
        'They have long memories.',
        'I have been waiting long.',
        'This is too long.',
        'That was a long day.',
      ],
      'great': [
        'This is a great idea.',
        'You did a great job.',
        'He is a great person.',
        'She has great talent.',
        'It is a great opportunity.',
        'We had a great time.',
        'They are great friends.',
        'I feel great today.',
        'This looks great.',
        'That sounds great.',
      ],
      'little': [
        'I have a little time.',
        'You are a little late.',
        'He is a little tired.',
        'She needs a little help.',
        'It is a little difficult.',
        'We have a little money.',
        'They are a little confused.',
        'I know a little about it.',
        'This is a little better.',
        'That is a little strange.',
      ],
      'old': [
        'I am getting old.',
        'You look old today.',
        'He is an old friend.',
        'She has old habits.',
        'It is an old building.',
        'We have old memories.',
        'They are old-fashioned.',
        'I have an old car.',
        'This is old news.',
        'That is an old story.',
      ],
      'right': [
        'You are right.',
        'I have the right answer.',
        'He is right about this.',
        'She made the right choice.',
        'It is the right time.',
        'We are on the right track.',
        'They did the right thing.',
        'I think you are right.',
        'This is the right way.',
        'That is the right decision.',
      ],
      'big': [
        'This is a big house.',
        'You have big dreams.',
        'He is a big man.',
        'She has big plans.',
        'It is a big problem.',
        'We have big goals.',
        'They are big fans.',
        'I have a big family.',
        'This is a big deal.',
        'That is a big mistake.',
      ],
    };

    // 데이터베이스에 저장
    for (final entry in exampleData.entries) {
      await _box!.put(entry.key, entry.value);
    }
  }

  /// 단어에 대한 예문을 가져옵니다
  static Future<List<String>> getExamples(String word) async {
    if (_box == null) {
      await init();
    }

    final examples = _box!.get(word.toLowerCase()) as List<String>?;
    return examples ?? [];
  }

  /// 단어에 대한 랜덤 예문을 가져옵니다
  static Future<String?> getRandomExample(String word) async {
    final examples = await getExamples(word);
    if (examples.isEmpty) return null;

    examples.shuffle();
    return examples.first;
  }

  /// 단어에 대한 여러 예문을 가져옵니다 (최대 개수 제한)
  static Future<List<String>> getMultipleExamples(
    String word, {
    int maxCount = 3,
  }) async {
    final examples = await getExamples(word);
    if (examples.isEmpty) return [];

    examples.shuffle();
    return examples.take(maxCount).toList();
  }

  /// 예문 데이터베이스에 새로운 예문을 추가합니다
  static Future<void> addExample(String word, String example) async {
    if (_box == null) {
      await init();
    }

    final currentExamples = await getExamples(word);
    currentExamples.add(example);
    await _box!.put(word.toLowerCase(), currentExamples);
  }

  /// 예문 데이터베이스에 여러 예문을 추가합니다
  static Future<void> addExamples(String word, List<String> examples) async {
    if (_box == null) {
      await init();
    }

    final currentExamples = await getExamples(word);
    currentExamples.addAll(examples);
    await _box!.put(word.toLowerCase(), currentExamples);
  }

  /// 데이터베이스 닫기
  static Future<void> close() async {
    await _box?.close();
  }
}
