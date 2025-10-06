# Vocabooster (Vocatch)

외국어 단어 및 표현 학습을 위한 모바일 애플리케이션

## 📱 프로젝트 개요

Vocabooster는 영어와 한국어 학습을 지원하는 단어 및 표현 학습 애플리케이션입니다. 사용자는 매일 업데이트되는 초급, 중급, 고급 단계별 콘텐츠를 학습하고, 개인 단어장을 구성하며, 카드 매칭 게임을 통해 재미있게 학습할 수 있습니다.

### 주요 기능

- 📚 **단어 및 표현 학습**: 초급, 중급, 고급 레벨별 콘텐츠 제공 (매일 업데이트)
- 📖 **개인 단어장**: 학습한 단어와 표현을 저장하고 그룹별로 관리
- 🎮 **카드 매칭 게임**: 그룹별 단어/표현을 이용한 매칭 게임
- 🌐 **다국어 지원**: 영어 ↔ 한국어 학습
- 💾 **로컬 우선 아키텍처**: 오프라인에서도 모든 기능 사용 가능

---

## 🛠 기술 스택

| 카테고리        | 기술/라이브러리    | 선택 이유                            |
| --------------- | ------------------ | ------------------------------------ |
| **플랫폼**      | Flutter            | iOS/Android 모바일 앱 개발           |
| **언어**        | Dart               | Flutter 네이티브 언어, 높은 생산성   |
| **UI**          | Flutter Widgets    | 풍부한 커스터마이징 가능 UI 컴포넌트 |
| **상태 관리**   | Riverpod           | 효율적인 상태 관리 및 UI 업데이트    |
| **로컬 DB**     | Hive               | 구조적 데이터 저장 및 관리           |
| **설정 저장**   | shared_preferences | 간단한 키-값 데이터 저장             |
| **오디오**      | audioplayers       | 발음 오디오 재생                     |
| **의존성 주입** | get_it             | 코드 결합도 감소                     |
| **UI**          | flutter_svg        | SVG 아이콘 지원                      |

---

## 🏗 시스템 아키텍처

### 아키텍처 개요

```
┌─────────────────────────────────────────┐
│         Flutter Mobile App              │
│                                         │
│  ┌───────────────────────────────────┐  │
│  │  UI Layer (Screens/Widgets)       │  │
│  └──────────────┬────────────────────┘  │
│                 │ User Interaction       │
│  ┌──────────────▼────────────────────┐  │
│  │  State Management (Riverpod)     │  │
│  └──────────────┬────────────────────┘  │
│                 │ Calls Functions        │
│  ┌──────────────▼────────────────────┐  │
│  │  Repository/Data Access Layer   │  │
│  └──────────────┬────────────────────┘  │
│                 │ Reads/Writes Data      │
│  ┌──────────────▼────────────────────┐  │
│  │  Local Database (Hive)            │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

### 데이터 흐름

1. **UI Layer**: 사용자 인터랙션 처리
2. **State Management**: 앱 상태 관리 및 비즈니스 로직
3. **Repository Layer**: 로컬 데이터베이스 접근 추상화
4. **Local Database**: 데이터 영속성 관리

---

## 📂 프로젝트 구조

```
/lib
├── core/                      # 공통 유틸리티 및 상수
│   ├── constants/
│   ├── utils/
│   └── theme/
├── features/                  # 기능별 모듈
│   ├── word_learning/        # 단어 학습 기능
│   │   ├── models/
│   │   ├── providers/
│   │   ├── repositories/
│   │   ├── screens/
│   │   └── widgets/
│   ├── vocabulary/           # 단어장 관리 기능
│   │   ├── models/
│   │   ├── providers/
│   │   ├── repositories/
│   │   ├── screens/
│   │   └── widgets/
│   └── card_game/           # 카드 매칭 게임 기능
│       ├── models/
│       ├── providers/
│       ├── repositories/
│       ├── screens/
│       └── widgets/
├── data/                     # 데이터 계층
│   ├── local/               # 로컬 데이터베이스 설정
│   └── models/              # 공통 데이터 모델
└── main.dart                # 앱 진입점
```

---

## 🚀 개발 로드맵

### Phase 1: Foundation (MVP 구현) - 6주

#### Week 1-2: 프로젝트 초기 설정

- [x] Flutter 프로젝트 초기화
- [x] Git 저장소 설정 및 GitHub 연동
- [x] 폴더 구조 생성 (Clean Architecture 기반)
- [x] 필수 패키지 설치 (Riverpod, Hive, shared_preferences)
- [ ] 테마 및 디자인 시스템 구축
- [ ] 기본 라우팅 설정

#### Week 3-4: 핵심 데이터 레이어 구축

- [ ] 로컬 데이터베이스 스키마 설계
  - 단어(Word) 모델
  - 표현(Expression) 모델
  - 단어장 그룹(VocabularyGroup) 모델
- [ ] Hive 초기 설정 및 데이터 접근 계층 구현
- [ ] Repository 패턴 구현
- [ ] 샘플 데이터 생성 (초급 단어 50개)
- [ ] 상태 관리 Provider 구성

#### Week 5-6: MVP 기능 구현

- [ ] **단어 학습 화면** (초급 레벨만)
  - 단어 리스트 표시
  - 단어 상세 보기
  - 오디오 재생 기능 (audioplayers 연동)
- [ ] **개인 단어장 기능**
  - 단어 저장/삭제
  - 저장된 단어 목록 보기
- [ ] **간단한 카드 매칭 게임**
  - 4x2 그리드 (8장 카드)
  - 단어-뜻 매칭
  - 점수 및 완료 시간 표시
- [ ] 기본 내비게이션 및 홈 화면

**마일스톤 1 완료**: 기본 학습 및 게임 기능이 작동하는 MVP

---

### Phase 2: Feature Enhancement - 8주

#### Week 7-9: 콘텐츠 확장

- [ ] 중급, 고급 레벨 단어 및 표현 데이터 추가
- [ ] 레벨 필터링 기능 구현
- [ ] 학습 언어 전환 기능 (영어 학습 / 한국어 학습)
- [ ] 단어장 그룹 생성/수정/삭제 기능
- [ ] 그룹별 단어 관리 UI

#### Week 10-11: 게임 기능 고도화

- [ ] 카드 매칭 게임 난이도 선택 (4x2, 4x3, 4x4)
- [ ] 게임 통계 저장 (점수, 시간, 정확도)
- [ ] 게임 결과 화면 개선
- [ ] 애니메이션 및 사운드 효과 추가

#### Week 12-13: 성능 최적화

- [ ] 이미지 및 오디오 파일 최적화
- [ ] ListView Lazy Loading 적용
- [ ] 불필요한 Widget rebuild 최소화
- [ ] 데이터베이스 쿼리 최적화
- [ ] 앱 시작 속도 개선

#### Week 14: 모니터링 및 테스트

- [ ] Firebase Performance Monitoring 연동
- [ ] Sentry 오류 로깅 설정
- [ ] 단위 테스트 작성 (Repository, Provider)
- [ ] 위젯 테스트 작성
- [ ] 통합 테스트 작성

**마일스톤 2 완료**: 완전한 기능을 갖춘 프로덕션 레디 앱

---

## ⚠️ 리스크 관리

### 기술적 리스크

| 리스크                       | 완화 전략                                   |
| ---------------------------- | ------------------------------------------- |
| **Flutter/Dart 버전 호환성** | 주기적인 버전 업데이트 및 테스트            |
| **대용량 데이터 처리 성능**  | Lazy Loading, 효율적인 DB 쿼리, 코드 최적화 |
| **로컬 데이터 보안**         | flutter_secure_storage로 민감 정보 암호화   |
| **DB 스키마 마이그레이션**   | 버전별 마이그레이션 로직 사전 설계          |

---

## 🎯 성능 최적화 전략

- 이미지 및 오디오 파일 압축
- Lazy Loading을 통한 초기 로딩 시간 단축
- `const` 키워드 활용으로 불필요한 rebuild 방지
- 효율적인 데이터베이스 인덱싱
- 메모리 사용량 모니터링 및 최적화

---

## 📄 Technical Requirements Document (TRD)

### 1. Executive Technical Summary

**프로젝트 개요**: Vocabooster 모바일 애플리케이션 개발을 위한 기술적 요구사항 정의. Flutter를 사용하여 iOS 및 Android 플랫폼을 동시에 지원하고, 모든 사용자 데이터와 콘텐츠는 기기 내 로컬 스토리지에 저장하여 관리한다.

**핵심 기술 스택**: Flutter, Dart를 기반으로 모바일 애플리케이션을 개발한다. 백엔드 서버는 구축하지 않는다.

**주요 기술 목표**: 안정적인 앱 성능, 효율적인 로컬 데이터 관리, 직관적인 사용자 경험 제공.

**핵심 기술 가정**: 앱은 오프라인 상태에서도 모든 기능이 정상적으로 동작해야 한다.

### 2. 코드 구성 및 컨벤션

```
/lib
├── features/
│   └── word_learning/
│       ├── providers/          # State management for word learning
│       └── repositories/       # 로컬 DB 접근 로직
```

- `services` 또는 `api` 디렉토리는 `repositories` 또는 `data_sources`로 명명하여 로컬 데이터베이스 접근 역할을 명확히 함

### 3. 데이터 흐름 및 통신 패턴

**로컬 데이터 흐름**: 앱의 모든 데이터 흐름은 기기 내에서 완결됩니다. UI에서 발생한 이벤트는 상태 관리 객체를 통해 비즈니스 로직을 처리하고, Repository를 통해 로컬 데이터베이스에 데이터를 저장하거나 조회합니다.

**데이터 모델**: 앱에서 사용하는 데이터(단어, 단어장 그룹 등)는 Dart 클래스로 모델링하여 일관성 있게 사용합니다.

---

## 🔧 시작하기

### 필수 요구사항

- Flutter SDK 3.0 이상
- Dart SDK 3.0 이상
- Android Studio (Android 개발용)
- Xcode (iOS 개발용, macOS에서만)

### 설치 및 실행

```bash
# 1. 저장소 클론
git clone https://github.com/adriejeon/vocatch.git
cd vocatch

# 2. 의존성 설치
flutter pub get

# 3. 앱 실행 (Android)
flutter run

# 또는 iOS 시뮬레이터에서 실행
flutter run -d ios
```

### 개발 환경 설정

```bash
# 코드 생성 (Hive 모델)
flutter packages pub run build_runner build

# 코드 생성 (파일 변경 시 자동)
flutter packages pub run build_runner watch
```

---

## 📝 개발 진행 상황

- [x] Phase 1: Foundation (MVP 구현) - 6주
  - [x] 프로젝트 초기화 및 Git 연동
  - [x] 폴더 구조 및 패키지 설정
  - [ ] 데이터 레이어 구축
  - [ ] MVP 기능 구현
- [ ] Phase 2: Feature Enhancement - 8주

---

## 👥 기여하기

이 프로젝트는 현재 개인 프로젝트로 진행 중입니다.

---

## 📞 문의

프로젝트 관련 문의사항이 있으시면 이슈를 등록해주세요.

---

**Last Updated**: 2025-01-06
