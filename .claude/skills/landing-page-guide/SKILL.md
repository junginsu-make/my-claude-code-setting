---
name: landing-page-guide
description: Next.js 또는 React를 사용한 효과적인 랜딩 페이지 제작을 위한 종합 가이드입니다. 사용자가 랜딩 페이지, 마케팅 페이지 또는 고전환율 랜딩 페이지의 11가지 필수 요소가 필요한 제품 페이지 제작을 요청할 때 이 스킬을 사용하세요. Next.js 14+ App Router와 ShadCN UI 컴포넌트에 특화되어 있습니다.
---

# 랜딩 페이지 가이드

## 개요

이 스킬은 DESIGNNAS의 11가지 필수 요소 프레임워크를 따르는 전문적이고 고전환율의 랜딩 페이지 제작을 지원합니다. ShadCN UI 통합과 함께 Next.js 14+ 및 React에 대한 완전한 구현 패턴을 제공하며, 모든 랜딩 페이지에 적절한 SEO 최적화, 접근성 표준, 전환 중심 디자인이 포함되도록 합니다.

## 이 스킬을 사용할 때

사용자가 다음을 요청할 때 사용하세요:
- 랜딩 페이지, 마케팅 페이지 또는 제품 페이지 제작
- Next.js 또는 React 기반 프로모션 웹사이트
- 방문자를 고객으로 전환해야 하는 페이지
- SEO 최적화가 포함된 전문 마케팅 페이지
- 업계 모범 사례를 따르는 랜딩 페이지

## 11가지 필수 요소 프레임워크

모든 효과적인 랜딩 페이지에는 이 11가지 필수 요소가 포함되어야 합니다. 이는 DESIGNNAS의 검증된 고전환율 랜딩 페이지 프레임워크를 기반으로 합니다:

1. **키워드가 포함된 URL** - SEO 최적화된 설명적 URL 구조
2. **회사 로고** - 브랜드 아이덴티티를 눈에 띄게 배치 (좌측 상단)
3. **SEO 최적화된 제목과 부제목** - 키워드가 포함된 명확한 가치 제안
4. **주요 CTA** - 히어로 섹션의 주요 행동 유도 버튼
5. **소셜 프루프** - 리뷰, 평점, 사용자 통계
6. **이미지 또는 비디오** - 제품/서비스의 시각적 시연
7. **핵심 혜택/기능** - 아이콘과 함께 3-6개의 주요 장점
8. **고객 후기** - 사진이 포함된 4-6개의 실제 리뷰
9. **FAQ 섹션** - 아코디언 UI로 5-10개의 자주 묻는 질문
10. **최종 CTA** - 두 번째 전환 기회를 위한 하단 행동 유도
11. **연락처 정보/법적 페이지** - 완전한 정보가 포함된 푸터

**핵심**: 모든 11가지 요소가 모든 랜딩 페이지에 포함되어야 합니다. 예외 없음.

각 요소에 대한 상세 설명은 `references/11-essential-elements.md`를 참조하세요.

## 기술 스택 요구사항

랜딩 페이지 제작 시 항상 다음을 사용하세요:

### 필수 기술
- **Next.js 14+** App Router 포함
- **TypeScript** 타입 안전성
- **Tailwind CSS** 스타일링
- **ShadCN UI** 모든 UI 컴포넌트

### 설치할 ShadCN UI 컴포넌트

랜딩 페이지 제작 전에 다음 컴포넌트가 설치되어 있는지 확인하세요:

```bash
npx shadcn-ui@latest add button
npx shadcn-ui@latest add card
npx shadcn-ui@latest add accordion
npx shadcn-ui@latest add badge
npx shadcn-ui@latest add avatar
npx shadcn-ui@latest add separator
npx shadcn-ui@latest add input
```

### ShadCN UI를 사용하는 이유
- **접근성**: WCAG 호환 컴포넌트
- **커스터마이징**: Tailwind CSS로 완전한 커스터마이징 가능
- **타입 안전**: TypeScript로 작성
- **성능**: 필요한 것만 복사, 최소 번들 크기
- **일관성**: 내장 디자인 시스템

## 프로젝트 구조

다음 구조로 랜딩 페이지를 생성하세요:

```
landing-page/
├── app/
│   ├── layout.tsx          # 메타데이터가 포함된 루트 레이아웃
│   ├── page.tsx            # 메인 랜딩 페이지
│   └── globals.css         # 글로벌 스타일
├── components/
│   ├── Header.tsx          # 로고 & 네비게이션 (요소 2)
│   ├── Hero.tsx            # 제목, CTA, 소셜 프루프 (요소 3-5)
│   ├── MediaSection.tsx    # 이미지/비디오 (요소 6)
│   ├── Benefits.tsx        # 핵심 혜택 (요소 7)
│   ├── Testimonials.tsx    # 고객 후기 (요소 8)
│   ├── FAQ.tsx             # FAQ 아코디언 (요소 9)
│   ├── FinalCTA.tsx        # 하단 CTA (요소 10)
│   └── Footer.tsx          # 연락처 & 법적 정보 (요소 11)
├── public/
│   └── images/             # 최적화된 이미지
└── package.json
```

## 구현 워크플로우

### 1단계: 메타데이터 설정 (SEO)

항상 `layout.tsx` 또는 `page.tsx`에 적절한 SEO 메타데이터로 시작하세요:

```typescript
import type { Metadata } from 'next'

export const metadata: Metadata = {
  title: 'SEO Optimized Title with Keywords | Brand Name',
  description: 'Compelling description with main keywords',
  keywords: ['keyword1', 'keyword2', 'keyword3'],
  openGraph: {
    title: 'OG Title',
    description: 'OG Description',
    images: ['/og-image.jpg'],
  },
}
```

### 2단계: 컴포넌트 구조 생성

적절한 흐름을 보장하기 위해 이 순서로 컴포넌트를 빌드하세요:

1. **Header** 로고 포함 (요소 2)
2. **Hero** 섹션 — 제목, 부제목, 주요 CTA, 소셜 프루프 (요소 3-5)
3. **MediaSection** 제품 이미지/비디오 (요소 6)
4. **Benefits** 섹션 — 3-6개 기능 카드 (요소 7)
5. **Testimonials** 고객 후기 (요소 8)
6. **FAQ** 아코디언 (요소 9)
7. **FinalCTA** 하단 (요소 10)
8. **Footer** 연락처 및 법적 링크 (요소 11)

### 3단계: ShadCN UI 컴포넌트 사용

각 섹션을 적절한 ShadCN 컴포넌트에 매핑하세요:

- **Hero CTA**: `Button` 컴포넌트 size="lg" 사용
- **Benefits**: `Card`, `CardHeader`, `CardTitle`, `CardContent` 사용
- **Testimonials**: `Card`, `Avatar`, `Badge` 사용
- **FAQ**: `Accordion`, `AccordionItem`, `AccordionTrigger`, `AccordionContent` 사용
- **Final CTA**: `Button`과 `Card` 사용
- **Footer**: `Separator`, 뉴스레터용 `Input` 사용

### 4단계: 반응형 디자인 구현

모바일 퍼스트 반응형 디자인을 보장하세요:

- Tailwind 반응형 접두사 사용: `sm:`, `md:`, `lg:`, `xl:`
- 모든 브레이크포인트 테스트: 640px (sm), 768px (md), 1024px (lg), 1280px (xl)
- 최소 터치 타겟 크기: 버튼 44x44px
- 기본 폰트 크기: 모바일에서 최소 16px

### 5단계: 성능 최적화

- 모든 이미지에 Next.js `Image` 컴포넌트 사용
- 스크롤 상단 이미지에 `priority` prop 추가
- 스크롤 하단 콘텐츠에 지연 로딩 구현
- 무거운 컴포넌트에 필요 시 동적 import 사용

### 6단계: 접근성 보장

- 시맨틱 HTML5 요소 사용 (`<header>`, `<main>`, `<section>`, `<footer>`)
- 필요한 곳에 ARIA 레이블 추가
- 키보드 네비게이션 작동 확인
- 모든 이미지에 alt 텍스트 제공
- 충분한 색상 대비 유지 (최소 WCAG AA)

## 컴포넌트 예제

ShadCN UI를 사용한 완전한 프로덕션 수준의 컴포넌트 구현은 `references/component-examples.md`를 참조하세요.

이 참조 파일에 포함된 내용:
- Button, Badge, Image 최적화가 포함된 히어로 섹션
- Card 컴포넌트를 사용한 혜택 섹션
- Avatar와 Card를 사용한 후기
- Accordion을 사용한 FAQ
- Card와 Button을 사용한 최종 CTA
- Separator와 링크가 포함된 푸터

컴포넌트 구현 시 모범 사례를 따르기 위해 이 참조를 로드하세요.

## 검증 체크리스트

랜딩 페이지 완료 전에 확인하세요:

**11가지 필수 요소:**
- [ ] 1. 키워드가 포함된 URL
- [ ] 2. 회사 로고 (좌측 상단)
- [ ] 3. SEO 최적화된 제목과 부제목
- [ ] 4. 히어로에 주요 CTA
- [ ] 5. 소셜 프루프 (리뷰, 통계)
- [ ] 6. 이미지 또는 비디오
- [ ] 7. 혜택/기능 섹션 (3-6개 항목)
- [ ] 8. 고객 후기 (4-6개 항목)
- [ ] 9. FAQ 섹션 (5-10개 질문)
- [ ] 10. 하단 최종 CTA
- [ ] 11. 연락처 및 법적 링크가 포함된 푸터

**기술 요구사항:**
- [ ] Next.js 14+ App Router 사용
- [ ] TypeScript 타입 정의
- [ ] Tailwind CSS 스타일링
- [ ] ShadCN UI 컴포넌트 사용
- [ ] SEO용 메타데이터 설정
- [ ] Next.js Image로 이미지 최적화
- [ ] 반응형 디자인 구현
- [ ] 접근성 표준 충족
- [ ] 성능 최적화

## 모범 사례

### 콘텐츠 가이드라인
- 명확하고 혜택 중심의 카피 작성
- CTA에 행동 지향적 언어 사용
- 적절한 제목으로 섹션을 스캔 가능하게 유지
- 구체적인 숫자와 통계 포함
- 실명이 포함된 실제 후기 사용

### 디자인 가이드라인
- 전체에 걸쳐 시각적 위계 유지
- 일관된 색상 팔레트 사용
- 적절한 여백 확보
- 읽기 쉬운 폰트 (기본 크기 16px+)
- 모바일 퍼스트로 디자인

### SEO 최적화
- 콘텐츠에 자연스럽게 키워드 포함
- 적절한 제목 태그 구조 사용 (H1 → H2 → H3)
- 모든 이미지에 alt 텍스트 추가
- 페이지 로드 속도 최적화
- 설명적인 메타 태그 작성

### 전환 최적화
- CTA를 전략적으로 배치 (최소 히어로 + 하단)
- 사용자 여정에서 마찰 감소
- 신뢰 신호를 눈에 띄게 강조
- CTA에 대비되는 색상 사용
- 다양한 CTA 문구 변형 테스트

## 일반적인 패턴

### SaaS 제품 랜딩 페이지
중점: 무료 체험 CTA, 기능 비교, 가격 명확성, 보안 배지

### 이커머스 제품 랜딩 페이지
중점: 제품 이미지, 가격, 배송 정보, 반품 정책, 긴급성

### 서비스/에이전시 랜딩 페이지
중점: 포트폴리오/사례 연구, 프로세스 설명, 팀 자격, 연락 양식

### 이벤트/웨비나 랜딩 페이지
중점: 날짜/시간 강조, 발표자 프로필, 아젠다, 등록 양식, 카운트다운 타이머

## 리소스

### references/
이 스킬에는 상세한 참조 문서가 포함되어 있습니다:

- `11-essential-elements.md` - 11가지 필수 요소 각각에 대한 심층 설명(원칙, 구현 팁, 예제 포함)
- `component-examples.md` - 모든 주요 섹션에 대한 ShadCN UI 사용 완전한 프로덕션 수준 컴포넌트 코드

특정 섹션을 구현하거나 요소에 대한 상세 안내가 필요할 때 이 참조를 로드하세요.

## 참고사항

- 이 프레임워크는 DESIGNNAS의 "11가지 필수 랜딩 페이지 요소"를 기반으로 합니다
- 브랜드 가이드라인과 대상 고객에 맞게 조정하세요
- A/B 테스트로 전환율을 지속적으로 개선하세요
- 모든 구현은 사용자 경험과 전환 최적화를 우선시해야 합니다
