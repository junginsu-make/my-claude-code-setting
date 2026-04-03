---
name: prompt-enhancer
description: 프로젝트 컨텍스트(코드 구조, 의존성, 컨벤션, 기존 패턴)를 분석하여 사용자 프롬프트를 강화합니다. 사용자가 간단한 개발 요청을 할 때 프로젝트별 맥락을 반영하여 더 정확하고 상황에 맞는 프롬프트를 생성합니다.
---

# 프롬프트 강화기

프로젝트 컨텍스트를 분석하여 간단한 개발 요청을 명확하고 상세한 요구사항으로 변환합니다. 강화된 요구사항을 사용자에게 제시하고 구현 전 확인을 받습니다.

## 이 스킬을 사용할 때

다음 경우에 사용합니다:
- 사용자가 "로그인 기능 만들어줘", "API 추가해줘" 같은 간단한 개발 요청을 할 때
- 요청에 구체적인 구현 세부사항이 부족할 때
- 사용자가 프로젝트 파일을 업로드하거나 "이 프로젝트"를 언급할 때
- 작업에 프로젝트 아키텍처 이해가 필요할 때

## 핵심 워크플로우

### 1단계: 프로젝트 컨텍스트 분석

**업로드된 파일 확인:**
```bash
view /mnt/user-data/uploads
```

**핵심 정보 수집:**
- 프로젝트 구조 및 구성
- 기술 스택 (package.json, pubspec.yaml, requirements.txt 등)
- 기존 패턴 (상태 관리, API 호출, 라우팅)
- 코드 컨벤션 (네이밍, 파일 구조)
- 유사한 기존 기능

### 2단계: 요청 의도 파악

사용자의 간단한 요청에서 다음을 식별합니다:
- **기능 유형**: 신규 기능, 버그 수정, 리팩토링, API 연동
- **범위**: 단일 화면, 전체 플로우, 백엔드 + 프론트엔드
- **의존성**: 관련 기능 또는 시스템

### 3단계: 강화된 요구사항 작성

다음 구조의 요구사항 문서를 생성합니다:

```markdown
# [기능명] 구현 요구사항

## 프로젝트 컨텍스트
- Framework: [감지된 프레임워크 및 버전]
- Architecture: [감지된 패턴]
- State Management: [감지된 라이브러리]
- Key Libraries: [관련 의존성 목록]

## 구현 범위

### 주요 기능
1. [주요 기능 1]
2. [주요 기능 2]
3. [주요 기능 3]

### 파일 구조
```
[프로젝트 기반 예상 파일 구조]
```

## 상세 요구사항

### 1. [레이어/컴포넌트명]
- **위치**: [파일 경로]
- **목적**: [기능 설명]
- **구현 내용**:
  - [구체적 요구사항 1]
  - [구체적 요구사항 2]
- **기존 패턴 따르기**: [기존 패턴 참조]

### 2. [다음 레이어/컴포넌트]
...

## 성공 기준
- [ ] [인수 기준 1]
- [ ] [인수 기준 2]
- [ ] [인수 기준 3]
- [ ] 기존 코드 스타일 및 아키텍처 일관성 유지
- [ ] 모든 주요 기능에 대한 테스트 작성

## 확인 사항
- [필요한 질문이나 명확화 사항]
- [가정한 내용]

---
이 요구사항으로 진행할까요? 수정이 필요한 부분이 있다면 말씀해주세요.
```

### 4단계: 사용자에게 제시

**중요**: 강화된 요구사항을 작성한 후, 사용자에게 제시하고 확인을 요청합니다:

```
위 요구사항을 분석해서 정리했습니다. 

이대로 진행해도 될까요? 
수정하거나 추가할 내용이 있으면 말씀해주세요!
```

사용자가 확인하기 전까지 **구현하지 마세요**. 목표는 먼저 요구사항을 명확히 하는 것입니다.

## 스택별 분석 패턴

### Flutter 프로젝트

**감지 기준**: pubspec.yaml, lib/ 디렉토리

**수집할 핵심 컨텍스트:**
- 상태 관리 (Riverpod, Bloc, Provider, GetX)
- 아키텍처 (Clean Architecture, MVVM, MVC)
- 네비게이션 (go_router, auto_route, Navigator)
- 네트워크 (Dio, http)
- 로컬 저장소 (Hive, SharedPreferences, SQLite)

**강화된 요구사항에 포함할 내용:**
```markdown
## 구현 범위

### Presentation Layer
- 화면: lib/presentation/[feature]/[screen]_screen.dart
- 상태: [StateNotifier/Bloc/Controller] with [state pattern]
- 위젯: 재사용 가능한 컴포넌트

### Domain Layer
- Entity: lib/domain/entities/[name].dart
- UseCase: lib/domain/usecases/[action]_usecase.dart
- Repository Interface: lib/domain/repositories/

### Data Layer
- Model: lib/data/models/[name]_model.dart (fromJson/toJson)
- Repository Implementation: lib/data/repositories/
- DataSource: lib/data/datasources/

### 네비게이션
- Route: [라우트 경로]
- Navigation method: [라우터 기반 context.go/push]

## 성공 기준
- [State management]로 상태 관리
- [Existing widget] 스타일 일관성 유지
- API 응답 에러 처리
- 로딩 상태 표시
- Widget test 작성
```

### Next.js/React 프로젝트

**감지 기준**: package.json에 "next" 또는 "react" 포함

**수집할 핵심 컨텍스트:**
- Next.js 버전 (App Router vs Pages Router)
- 상태 관리 (Zustand, Redux, Context)
- 스타일링 (Tailwind, CSS Modules, styled-components)
- API 방식 (Next.js API routes, 외부 API)
- TypeScript 사용 여부

**강화된 요구사항에 포함할 내용:**
```markdown
## 구현 범위

### UI 컴포넌트
- 컴포넌트: [path]/[ComponentName].tsx
- Props interface: [기존 패턴]
- Styling: [Tailwind classes/CSS modules]

### 상태 관리
- Store: [기존 상태 구조]
- Actions: [액션 네이밍 컨벤션]

### API 레이어
- Endpoint: [app/api 또는 외부]
- Method: [GET/POST/PUT/DELETE]
- Response type: [TypeScript interface]

### 라우팅
- Route: [app/[route] 또는 pages/[route]]
- Dynamic segments: [필요 시]

## 성공 기준
- TypeScript 타입 안정성
- [Existing components] 재사용
- 반응형 디자인 (모바일/데스크톱)
- SEO 최적화 (메타데이터)
- Unit test + Integration test
```

### Python (Django/FastAPI) 프로젝트

**감지 기준**: requirements.txt, manage.py, main.py

**수집할 핵심 컨텍스트:**
- 프레임워크 (Django, FastAPI, Flask)
- ORM (SQLAlchemy, Django ORM, Tortoise)
- 인증 방식
- API 문서화 (OpenAPI/Swagger)

**강화된 요구사항에 포함할 내용:**
```markdown
## 구현 범위

### 모델/스키마
- Model: [app]/models.py 또는 schemas/[name].py
- Fields: [타입 포함 필드 정의]
- Relationships: [ForeignKey/relationships]

### 뷰/엔드포인트
- Route: [경로]
- Method: [HTTP 메서드]
- Request/Response schema: [Pydantic 모델]

### 비즈니스 로직
- Service: [해당 시]
- Validation: [입력 검증]

### 데이터베이스
- Migration: [마이그레이션 명령어]

## 성공 기준
- API 문서 자동 생성
- 요청 검증
- 적절한 상태 코드 포함 에러 처리
- Unit test + Integration test
- [Authentication] 적용
```

## 강화 예시

**사용자 입력:**
```
로그인 기능 구현해줘
```

**스킬 출력:**
```markdown
# 로그인 기능 구현 요구사항

## 프로젝트 컨텍스트
- Framework: Flutter 3.16.0 with null safety
- Architecture: Clean Architecture
- State Management: Riverpod (StateNotifier pattern)
- Network: Dio 5.3.0
- Storage: flutter_secure_storage
- Navigation: go_router

## 구현 범위

### 주요 기능
1. 이메일/비밀번호 로그인 폼
2. JWT 토큰 기반 인증
3. 로그인 성공 시 홈 화면 이동
4. 에러 처리 및 사용자 피드백

### 파일 구조
```
lib/
├── presentation/
│   └── auth/
│       ├── login_screen.dart
│       ├── login_notifier.dart
│       └── login_state.dart
├── domain/
│   ├── entities/user.dart
│   ├── usecases/login_usecase.dart
│   └── repositories/auth_repository.dart
└── data/
    ├── models/
    │   ├── user_model.dart
    │   └── login_response.dart
    ├── repositories/auth_repository_impl.dart
    └── datasources/auth_remote_datasource.dart
```

## 상세 요구사항

### 1. Presentation Layer - 로그인 화면
- **위치**: lib/presentation/auth/login_screen.dart
- **목적**: 사용자 로그인 UI 제공
- **구현 내용**:
  - ConsumerStatefulWidget 사용
  - Email TextFormField (이메일 형식 검증)
  - Password TextFormField (8자 이상, obscureText)
  - 로그인 PrimaryButton
  - 회원가입 링크
  - 로딩 상태 시 오버레이 표시
- **기존 패턴 따르기**: core/widgets/custom_text_field.dart 스타일 사용

### 2. 상태 관리
- **위치**: lib/presentation/auth/login_notifier.dart
- **목적**: 로그인 상태 관리
- **구현 내용**:
  - StateNotifier<LoginState> 상속
  - login(email, password) 메서드
  - 성공 시 토큰 저장 후 상태 업데이트
  - 에러 시 에러 메시지 상태 설정
- **기존 패턴 따르기**: 다른 notifier들과 동일한 패턴

### 3. Domain Layer - 엔티티
- **위치**: lib/domain/entities/user.dart
- **목적**: 사용자 도메인 모델
- **구현 내용**:
  - Freezed로 불변 클래스 생성
  - id, email, name, profileImageUrl 필드
- **기존 패턴 따르기**: 다른 entity들과 동일한 구조

### 4. Domain Layer - UseCase
- **위치**: lib/domain/usecases/login_usecase.dart
- **목적**: 로그인 비즈니스 로직
- **구현 내용**:
  - call(LoginParams) 메서드
  - Either<Failure, User> 반환
  - repository 의존성 주입
- **기존 패턴 따르기**: 단일 책임 UseCase 패턴

### 5. Data Layer - API 통신
- **위치**: lib/data/datasources/auth_remote_datasource.dart
- **목적**: 로그인 API 호출
- **구현 내용**:
  - POST /api/auth/login
  - Request: {"email": string, "password": string}
  - Response: LoginResponse (accessToken, refreshToken, user)
  - Dio instance 재사용
- **기존 패턴 따르기**: 기존 datasource들의 에러 처리 방식

### 6. Data Layer - Repository 구현
- **위치**: lib/data/repositories/auth_repository_impl.dart
- **목적**: Repository 인터페이스 구현
- **구현 내용**:
  - login 메서드 구현
  - 토큰 저장 (TokenStorage 사용)
  - DioException 처리
  - UserModel을 User entity로 변환
- **기존 패턴 따르기**: try-catch-Either 패턴

### 7. 네비게이션 설정
- **위치**: lib/core/router/app_router.dart
- **목적**: 로그인 라우트 추가
- **구현 내용**:
  - /login 라우트 추가
  - 로그인 성공 시 /home으로 리다이렉트
  - 인증 가드 로직
- **기존 패턴 따르기**: 기존 go_router 설정 방식

## 성공 기준
- [ ] 사용자가 이메일과 비밀번호 입력
- [ ] 로그인 버튼 클릭 시 API 호출
- [ ] 성공 시 토큰 저장 및 홈 화면 이동
- [ ] 실패 시 적절한 에러 메시지 표시 (SnackBar)
- [ ] 로딩 중 버튼 비활성화 및 로딩 인디케이터
- [ ] 이메일 형식 및 비밀번호 길이 검증
- [ ] 기존 코드 스타일 및 아키텍처 일관성 유지
- [ ] Widget test 작성 (로그인 화면)
- [ ] Repository test 작성 (mock API)
- [ ] UseCase test 작성

## 확인 사항
- API 엔드포인트 주소가 `https://api.example.com`이 맞나요?
- 토큰 만료 시 자동 갱신 기능이 필요한가요?
- 소셜 로그인(구글, 애플 등)도 함께 구현할까요?
- "비밀번호 찾기" 기능이 필요한가요?

---
위 요구사항으로 진행할까요? 수정이 필요한 부분이 있다면 말씀해주세요!
```

## 효과적인 강화를 위한 팁

### 항상 명확화를 요청하세요

프로젝트 컨텍스트가 불명확하거나 부족한 경우:
```
프로젝트 파일을 업로드해주시면 더 정확한 요구사항을 만들 수 있습니다.
또는 다음 정보를 알려주세요:
- 사용 중인 프레임워크
- 상태 관리 라이브러리
- 기존 프로젝트 구조
```

### 시각적 예시를 포함하세요

도움이 될 때 기존 화면/컴포넌트를 언급합니다:
```
기존 ProfileScreen과 유사한 레이아웃으로 구현
- AppBar 스타일 동일
- TextFormField 디자인 재사용
- PrimaryButton 컴포넌트 사용
```

### 의존성을 강조하세요

```
## 연관 기능
- UserRepository: 사용자 정보 조회에 재사용
- TokenStorage: 기존 토큰 저장 로직 활용
- ErrorHandler: 공통 에러 처리 적용
```

## 참고 파일

상세 패턴 참조:
- **강화 패턴**: references/enhancement-patterns.md
- **프레임워크 가이드**: references/framework-guides.md
