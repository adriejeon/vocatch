# Android 키스토어 설정 가이드

## 1. 키스토어 생성

터미널에서 다음 명령어를 실행하여 키스토어를 생성하세요:

```bash
cd /Users/adriejeon/Desktop/Vocatch
keytool -genkey -v -keystore android/app/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

### 입력해야 할 정보:

- **키스토어 비밀번호**: lovelymh
- **키 비밀번호**: lovelymh
- **이름과 성**: AdrieJeon
- **조직 단위**: 부서명 (예: Development)
- **조직**: 회사명 (예: Vocatch)
- **도시**: 도시명 (예: Seoul)
- **시/도**: 시/도명 (예: Seoul)
- **국가 코드**: KR

## 2. key.properties 파일 설정

`android/key.properties` 파일을 열고 다음 정보를 입력하세요:

```
storePassword=여기에_키스토어_비밀번호_입력
keyPassword=여기에_키_비밀번호_입력
keyAlias=upload
storeFile=upload-keystore.jks
```

## 3. 빌드 및 테스트

키스토어 설정이 완료되면 다음 명령어로 릴리즈 빌드를 테스트할 수 있습니다:

```bash
flutter build apk --release
```

## 4. 중요 사항

⚠️ **보안 주의사항**:

- `upload-keystore.jks` 파일과 `key.properties` 파일을 안전한 곳에 백업하세요
- 이 파일들을 잃어버리면 앱 업데이트가 불가능합니다
- Git에 업로드하지 마세요 (이미 .gitignore에 추가됨)
- 비밀번호를 안전한 곳에 기록해두세요

## 5. Google Play Console 업로드

1. Google Play Console에 로그인
2. 새 앱 생성 또는 기존 앱 선택
3. "앱 번들 또는 APK" 섹션에서 "릴리즈" 생성
4. `build/app/outputs/flutter-apk/app-release.apk` 파일 업로드

## 6. 문제 해결

만약 빌드 중 오류가 발생하면:

1. `key.properties` 파일의 경로와 비밀번호 확인
2. 키스토어 파일이 올바른 위치에 있는지 확인
3. `flutter clean` 후 다시 빌드 시도
