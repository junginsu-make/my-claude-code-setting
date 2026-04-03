---
name: xlsx
description: "스프레드시트 파일이 주요 입력 또는 출력인 모든 작업에 이 스킬을 사용합니다. 기존 .xlsx, .xlsm, .csv, .tsv 파일 열기/읽기/편집/수정(예: 열 추가, 수식 계산, 서식 지정, 차트, 데이터 정리), 새 스프레드시트를 처음부터 또는 다른 데이터 소스에서 생성, 표 형식 파일 포맷 간 변환 등의 작업이 포함됩니다. 특히 사용자가 스프레드시트 파일을 이름이나 경로로 언급할 때(예: '내 다운로드의 xlsx') 무언가를 하거나 생성하려고 할 때 트리거합니다. 또한 지저분한 표 형식 데이터 파일(잘못된 행, 잘못 배치된 헤더, 정크 데이터)을 올바른 스프레드시트로 정리하거나 재구성할 때도 트리거합니다. 결과물은 반드시 스프레드시트 파일이어야 합니다. Word 문서, HTML 보고서, 독립 실행형 Python 스크립트, 데이터베이스 파이프라인 또는 Google Sheets API 통합이 주요 결과물인 경우에는 트리거하지 마세요."
license: Proprietary. LICENSE.txt has complete terms
---

# 출력 요구사항

## 모든 Excel 파일

### 전문적인 폰트
- 사용자가 별도 지시하지 않는 한, 모든 결과물에 일관된 전문적 폰트(예: Arial, Times New Roman)를 사용합니다

### 수식 오류 제로
- 모든 Excel 모델은 반드시 수식 오류(#REF!, #DIV/0!, #VALUE!, #N/A, #NAME?) 없이 제공되어야 합니다

### 기존 템플릿 보존 (템플릿 업데이트 시)
- 파일 수정 시 기존 형식, 스타일, 규칙을 정확히 연구하고 일치시킵니다
- 확립된 패턴이 있는 파일에 표준화된 서식을 강제 적용하지 않습니다
- 기존 템플릿 규칙은 항상 이 가이드라인보다 우선합니다

## 재무 모델

### 색상 코딩 표준
사용자나 기존 템플릿에서 별도 지정하지 않는 한

#### 업계 표준 색상 규칙
- **파란색 텍스트 (RGB: 0,0,255)**: 하드코딩된 입력값, 시나리오용으로 사용자가 변경할 숫자
- **검은색 텍스트 (RGB: 0,0,0)**: 모든 수식과 계산
- **녹색 텍스트 (RGB: 0,128,0)**: 같은 워크북 내 다른 워크시트에서 가져오는 링크
- **빨간색 텍스트 (RGB: 255,0,0)**: 다른 파일로의 외부 링크
- **노란색 배경 (RGB: 255,255,0)**: 주의가 필요한 핵심 가정이나 업데이트가 필요한 셀

### 숫자 서식 표준

#### 필수 서식 규칙
- **연도**: 텍스트 문자열로 서식 지정 (예: "2024"이지 "2,024"가 아님)
- **통화**: $#,##0 형식 사용; 헤더에 항상 단위 명시 ("Revenue ($mm)")
- **영**: 숫자 서식으로 모든 영을 "-"로 표시, 백분율 포함 (예: "$#,##0;($#,##0);-")
- **백분율**: 기본 0.0% 형식 (소수점 한 자리)
- **배수**: 밸류에이션 배수(EV/EBITDA, P/E)에 0.0x 형식
- **음수**: 마이너스(-123)가 아닌 괄호(123) 사용

### 수식 작성 규칙

#### 가정값 배치
- 모든 가정(성장률, 마진, 배수 등)을 별도의 가정 셀에 배치합니다
- 수식에서 하드코딩된 값 대신 셀 참조를 사용합니다
- 예시: =B5*1.05 대신 =B5*(1+$B$6) 사용

#### 수식 오류 방지
- 모든 셀 참조가 올바른지 확인합니다
- 범위의 오프바이원 오류를 검사합니다
- 모든 추정 기간에 걸쳐 일관된 수식을 보장합니다
- 엣지 케이스(영, 음수, 매우 큰 값)로 테스트합니다
- 의도하지 않은 순환 참조가 없는지 확인합니다

#### 하드코딩에 대한 문서화 요구사항
- 셀 옆에 주석이나 설명을 추가합니다 (테이블 끝인 경우). 형식: "Source: [시스템/문서], [날짜], [구체적 참조], [해당되는 경우 URL]"
- 예시:
  - "Source: Company 10-K, FY2024, Page 45, Revenue Note, [SEC EDGAR URL]"
  - "Source: Company 10-Q, Q2 2025, Exhibit 99.1, [SEC EDGAR URL]"
  - "Source: Bloomberg Terminal, 8/15/2025, AAPL US Equity"
  - "Source: FactSet, 8/20/2025, Consensus Estimates Screen"

# XLSX 생성, 편집 및 분석

## 개요

사용자가 .xlsx 파일을 생성, 편집 또는 분석하도록 요청할 수 있습니다. 작업에 따라 다양한 도구와 워크플로우를 사용할 수 있습니다.

## 중요 요구사항

**수식 재계산을 위해 LibreOffice 필요**: 수식 값을 재계산하기 위해 `scripts/recalc.py` 스크립트를 사용하여 LibreOffice가 설치되어 있다고 가정할 수 있습니다. 이 스크립트는 첫 실행 시 LibreOffice를 자동으로 구성하며, Unix 소켓이 제한된 샌드박스 환경에서도 작동합니다 (`scripts/office/soffice.py`로 처리)

## 데이터 읽기 및 분석

### pandas를 사용한 데이터 분석
데이터 분석, 시각화 및 기본 작업에는 강력한 데이터 조작 기능을 제공하는 **pandas**를 사용합니다:

```python
import pandas as pd

# Excel 읽기
df = pd.read_excel('file.xlsx')  # 기본: 첫 번째 시트
all_sheets = pd.read_excel('file.xlsx', sheet_name=None)  # 모든 시트를 딕셔너리로

# 분석
df.head()      # 데이터 미리보기
df.info()      # 열 정보
df.describe()  # 통계

# Excel 쓰기
df.to_excel('output.xlsx', index=False)
```

## Excel 파일 워크플로우

## 중요: 하드코딩된 값이 아닌 수식을 사용하세요

**항상 Python에서 값을 계산하고 하드코딩하는 대신 Excel 수식을 사용하세요.** 이렇게 하면 스프레드시트가 동적이고 업데이트 가능하게 유지됩니다.

### 잘못된 예시 - 계산된 값 하드코딩
```python
# 나쁨: Python에서 계산하고 결과를 하드코딩
total = df['Sales'].sum()
sheet['B10'] = total  # 5000을 하드코딩

# 나쁨: Python에서 성장률 계산
growth = (df.iloc[-1]['Revenue'] - df.iloc[0]['Revenue']) / df.iloc[0]['Revenue']
sheet['C5'] = growth  # 0.15를 하드코딩

# 나쁨: Python으로 평균 계산
avg = sum(values) / len(values)
sheet['D20'] = avg  # 42.5를 하드코딩
```

### 올바른 예시 - Excel 수식 사용
```python
# 좋음: Excel이 합계를 계산하도록
sheet['B10'] = '=SUM(B2:B9)'

# 좋음: 성장률을 Excel 수식으로
sheet['C5'] = '=(C4-C2)/C2'

# 좋음: 평균을 Excel 함수로
sheet['D20'] = '=AVERAGE(D2:D19)'
```

이것은 모든 계산 — 합계, 백분율, 비율, 차이 등 — 에 적용됩니다. 소스 데이터가 변경될 때 스프레드시트가 재계산할 수 있어야 합니다.

## 일반적인 워크플로우
1. **도구 선택**: 데이터에는 pandas, 수식/서식에는 openpyxl
2. **생성/로드**: 새 워크북을 생성하거나 기존 파일을 로드
3. **수정**: 데이터, 수식, 서식 추가/편집
4. **저장**: 파일에 쓰기
5. **수식 재계산 (수식 사용 시 필수)**: scripts/recalc.py 스크립트 사용
   ```bash
   python scripts/recalc.py output.xlsx
   ```
6. **오류 확인 및 수정**:
   - 스크립트가 오류 상세 정보가 포함된 JSON을 반환합니다
   - `status`가 `errors_found`이면 `error_summary`에서 구체적인 오류 유형과 위치를 확인합니다
   - 식별된 오류를 수정하고 다시 재계산합니다
   - 수정할 일반적인 오류:
     - `#REF!`: 잘못된 셀 참조
     - `#DIV/0!`: 영으로 나누기
     - `#VALUE!`: 수식에 잘못된 데이터 타입
     - `#NAME?`: 인식할 수 없는 수식 이름

### 새 Excel 파일 만들기

```python
# 수식과 서식을 위해 openpyxl 사용
from openpyxl import Workbook
from openpyxl.styles import Font, PatternFill, Alignment

wb = Workbook()
sheet = wb.active

# 데이터 추가
sheet['A1'] = 'Hello'
sheet['B1'] = 'World'
sheet.append(['Row', 'of', 'data'])

# 수식 추가
sheet['B2'] = '=SUM(A1:A10)'

# 서식 지정
sheet['A1'].font = Font(bold=True, color='FF0000')
sheet['A1'].fill = PatternFill('solid', start_color='FFFF00')
sheet['A1'].alignment = Alignment(horizontal='center')

# 열 너비
sheet.column_dimensions['A'].width = 20

wb.save('output.xlsx')
```

### 기존 Excel 파일 편집

```python
# 수식과 서식을 보존하기 위해 openpyxl 사용
from openpyxl import load_workbook

# 기존 파일 로드
wb = load_workbook('existing.xlsx')
sheet = wb.active  # 또는 특정 시트: wb['SheetName']

# 여러 시트 작업
for sheet_name in wb.sheetnames:
    sheet = wb[sheet_name]
    print(f"Sheet: {sheet_name}")

# 셀 수정
sheet['A1'] = 'New Value'
sheet.insert_rows(2)  # 2번 위치에 행 삽입
sheet.delete_cols(3)  # 3번 열 삭제

# 새 시트 추가
new_sheet = wb.create_sheet('NewSheet')
new_sheet['A1'] = 'Data'

wb.save('modified.xlsx')
```

## 수식 재계산

openpyxl로 생성되거나 수정된 Excel 파일에는 수식이 문자열로 포함되어 있지만 계산된 값은 포함되어 있지 않습니다. 제공된 `scripts/recalc.py` 스크립트를 사용하여 수식을 재계산합니다:

```bash
python scripts/recalc.py <excel_file> [timeout_seconds]
```

예시:
```bash
python scripts/recalc.py output.xlsx 30
```

이 스크립트는:
- 첫 실행 시 LibreOffice 매크로를 자동으로 설정합니다
- 모든 시트의 모든 수식을 재계산합니다
- 모든 셀에서 Excel 오류(#REF!, #DIV/0! 등)를 검사합니다
- 상세한 오류 위치와 개수가 포함된 JSON을 반환합니다
- Linux와 macOS 모두에서 작동합니다

## 수식 검증 체크리스트

수식이 올바르게 작동하는지 확인하는 빠른 검사:

### 필수 검증
- [ ] **샘플 참조 2-3개 테스트**: 전체 모델을 구축하기 전에 올바른 값을 가져오는지 확인
- [ ] **열 매핑**: Excel 열이 일치하는지 확인 (예: 64번 열 = BL, BK가 아님)
- [ ] **행 오프셋**: Excel 행은 1부터 시작 (DataFrame 5행 = Excel 6행)

### 일반적인 함정
- [ ] **NaN 처리**: `pd.notna()`로 null 값 확인
- [ ] **맨 오른쪽 열**: FY 데이터는 보통 50번 이상의 열에 위치
- [ ] **다중 일치**: 첫 번째만이 아닌 모든 항목 검색
- [ ] **영으로 나누기**: 수식에서 `/`를 사용하기 전에 분모 확인 (#DIV/0!)
- [ ] **잘못된 참조**: 모든 셀 참조가 의도한 셀을 가리키는지 확인 (#REF!)
- [ ] **시트 간 참조**: 시트 연결 시 올바른 형식 사용 (Sheet1!A1)

### 수식 테스트 전략
- [ ] **작게 시작**: 넓게 적용하기 전에 2-3개 셀에서 수식 테스트
- [ ] **의존성 확인**: 수식에서 참조하는 모든 셀이 존재하는지 확인
- [ ] **엣지 케이스 테스트**: 영, 음수, 매우 큰 값 포함

### scripts/recalc.py 출력 해석
스크립트가 오류 상세 정보가 포함된 JSON을 반환합니다:
```json
{
  "status": "success",           // 또는 "errors_found"
  "total_errors": 0,              // 총 오류 수
  "total_formulas": 42,           // 파일의 수식 수
  "error_summary": {              // 오류가 발견된 경우에만 존재
    "#REF!": {
      "count": 2,
      "locations": ["Sheet1!B5", "Sheet1!C10"]
    }
  }
}
```

## 모범 사례

### 라이브러리 선택
- **pandas**: 데이터 분석, 대량 작업, 간단한 데이터 내보내기에 최적
- **openpyxl**: 복잡한 서식, 수식, Excel 전용 기능에 최적

### openpyxl 작업 시
- 셀 인덱스는 1부터 시작 (row=1, column=1은 셀 A1을 가리킴)
- 계산된 값을 읽으려면 `data_only=True` 사용: `load_workbook('file.xlsx', data_only=True)`
- **주의**: `data_only=True`로 열고 저장하면 수식이 값으로 대체되어 영구적으로 손실됩니다
- 대용량 파일: 읽기에는 `read_only=True`, 쓰기에는 `write_only=True` 사용
- 수식은 보존되지만 평가되지 않음 — scripts/recalc.py로 값을 업데이트합니다

### pandas 작업 시
- 추론 문제를 피하려면 데이터 타입 지정: `pd.read_excel('file.xlsx', dtype={'id': str})`
- 대용량 파일은 특정 열만 읽기: `pd.read_excel('file.xlsx', usecols=['A', 'C', 'E'])`
- 날짜를 올바르게 처리: `pd.read_excel('file.xlsx', parse_dates=['date_column'])`

## 코드 스타일 가이드라인
**중요**: Excel 작업용 Python 코드를 생성할 때:
- 불필요한 주석 없이 최소한의 간결한 Python 코드를 작성합니다
- 장황한 변수명과 중복 작업을 피합니다
- 불필요한 print 문을 피합니다

**Excel 파일 자체에 대해서는**:
- 복잡한 수식이나 중요한 가정이 있는 셀에 주석을 추가합니다
- 하드코딩된 값에 대한 데이터 소스를 문서화합니다
- 주요 계산과 모델 섹션에 대한 노트를 포함합니다
