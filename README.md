
# Money Is Mine
<p align="center">
<img src="https://cyj893.github.io/img/Projects/1/readme/화면.gif" width="300px" title="화면" alt="화면"></img>
</p>

- **간편하게 / 자세하게 지출과 수입 입력**
- **한눈에 보고 관리할 수 있는 내 돈**

## 개요

### 2nd Mozza-Rella 프로젝트
> **Flutter로 가계부 앱 만들기**

### 개발 동기
사용자의 편의에 맞춰 간편하게 쓰고 싶을 때에는 간편하게 금액 정도만, 자세하게 쓰고 싶다면 메모와 사진까지 더하여 자유롭게 쓸 수 있는 가계부를 생각했다. 가계부를 보고 하루를 요약할 수 있을 것이다.  
또, 내 돈을 얼마나 썼는지 숫자로 보는 것보다는 색을 이용하여 시각적으로 한 번에 보여주고, 다양한 그래프를 제공하면 좋을 것 같았다.  

### 개발 환경
- Flutter 2.8.1
- Dart 2.15.1

### 개발 기간
2022/01/07 ~ 2022/02/18 (6주)

## 기능
### 홈화면/설정

<p align="center">
<img src="https://cyj893.github.io/img/Projects/1/readme/설정1.gif" width="300px" title="설정1" alt="설정1"></img>
&nbsp &nbsp
<img src="https://cyj893.github.io/img/Projects/1/readme/설정2.gif" width="300px" title="설정2" alt="설정2"></img>
</p>

- 홈 화면에 그 날의 내역들과 요약, 해당 달의 요약을 보여줌
    - `+` 버튼으로 내역 추가, 각 내역을 꾹 눌러 삭제
- 설정
    - 앱 색상 선택
    - 내역 추가 페이지에서 내역에 입력할 요소들을 사용자 편의에 따라 선택


사용 패키지: [path](https://pub.dev/packages/path), [sqflite](https://pub.dev/packages/sqflite), [provider](https://pub.dev/packages/provider)

---

### 내역 추가
<p align="center">
<img src="https://cyj893.github.io/img/Projects/1/readme/내역입력1.gif" width="300px" title="내역입력1" alt="내역입력1"></img>
&nbsp &nbsp
<img src="https://cyj893.github.io/img/Projects/1/readme/내역입력2.gif" width="300px" title="내역입력2" alt="내역입력2"></img>
</p>

- 지출/수입, 결제 수단, 카테고리, 내용, 금액, 날짜, 메모, 사진으로 내역 입력
    - 지출/수입, 금액 필수 입력, 나머지는 선택 입력
- 카테고리 편집
    - 아이콘, 카테고리 이름으로 새 카테고리 추가
    - 노출 순서 편집
- 고정 지출 입력
    - 매월 n1일, n2일, ... m회 입력
    - 매주 n1요일, n2요일, ... m회 입력

사용 패키지: [image_picker](https://pub.dev/packages/image_picker), [scrolling_page_indicator](https://pub.dev/packages/scrolling_page_indicator), [numberpicker](https://pub.dev/packages/numberpicker)

---

### 검색
<p align="center">
<img src="https://cyj893.github.io/img/Projects/1/readme/검색.gif" width="300px" title="검색" alt="검색"></img>
</p>

- 지출/수입 여부, 카테고리, 과거순/최신순, 금액으로 내역 검색

---

### 달력

<p align="center">
<img src="https://cyj893.github.io/img/Projects/1/readme/달력.gif" width="300px" title="달력" alt="달력"></img>
</p>

- 사용 금액에 따라 날짜 별 금액 표시
    - 금액이 클 수록 진한 색으로 표시

사용 패키지: [table_calendar](https://pub.dev/packages/table_calendar)

---

### 차트

<p align="center">
<img src="https://cyj893.github.io/img/Projects/1/readme/차트.gif" width="300px" title="차트" alt="차트"></img>
</p>

- 카테고리 별 지출
    - 월간 카테고리 별 지출 원 그래프
- 주간 지출/수입
    - 해당 주간의 지출 또는 수입 막대 그래프
- 최근 경향: 
    - 지출, 수입, 그에 따른 누적합 선 그래프
    - 일, 월, 연 단위로 볼 수 있음

사용 패키지: [fl_chart](https://pub.dev/packages/fl_chart), [bezier_chart](https://pub.dev/packages/bezier_chart)

---

## License
MoneyIsMine is released under the [MIT License](http://www.opensource.org/licenses/mit-license).