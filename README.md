### Outline

---
<img src="https://github.com/user-attachments/assets/33fc7d7e-8432-4461-8947-3e7a3cc10b39">
***‘플메가되..*** 🎀’는 팀플을 함께할 팀원을 구하고, 팀플을 진행하는 데에 있어 필요한 다양한 기능들을 제공해주는 앱입니다.

**개발환경**

- Front-end: Android Studio (Flutter)
- Back-end: Django, MySQL, AWS

### Team

---

- 강지우
- 김서영
- 윤우성


### Databases

---

<img src="https://github.com/user-attachments/assets/90a7fb54-eaa3-4d64-b2bd-edfab5b460bf">

### Basic UI & Colors

---

<img src="https://github.com/user-attachments/assets/98dada77-0f15-4fda-827d-061011e4046f">
<img src="https://github.com/user-attachments/assets/b95cf03b-5884-4d74-91a6-5f271d81557f">
<img src="https://github.com/user-attachments/assets/560e51a4-cf5f-4b13-bc5f-ee9805b32fce">

### Details

---

### Intro & TabLayout

- 스플래시 화면 구현
- 카카오 로그인
- 이후 앱 자체 회원가입
- 회원가입 완료되었고, 해당 기기에서 한 번 이상 로그인한 적 있으면 로그인 과정 생략하고 바로 메인페이지 보여줌

### Login & SignUp

- 카카오 로그인으로 앱 자체 로그인 가능
- 같은 기기에서 로그인 여부를 기록하여 앱 다시 실행시 자동로그

### Tab 1

- 팀원을 구할 과목을 선택하여 팀원 구하는 글 작성 가능
    - 팀플 제목, 팀플 설명, 정원, 마감일 설정하여 업로드
- 다른 사용자가 올린 팀원 구하는 글 열람 가능
    - 원하는 팀플을 선택하여 팀플을 올린 이용자의 프로필 열람 가능
    - 원하는 팀플을 지원가능
- 알림창이 존재하여, 팀플의 지원, 팀플의 수락과 거절 여부가 보임

### Tab 2

- 본인이 현재 참여 중인 팀플이 나옴
- 팀플의 상태에 따라, 진행 중, 진행 전, 완료로 나뉨
    - tab1에서 구인글을 올리면, tab2의 진행 전 파트에 추가됨
    - 팀의 리더(구인 글 게시자)가 tab1의 알림에서 정원만큼의 팀원을 받아 `is_fulled` 가 True가 된다면, 진행 전에서 진행 중으로 변경됨
    - 팀의 리더가 진행 중인 ‘팀플 끝내기’를 눌러 팀플을 끝낸다면 `is_finished` 가 True가 되며,
        
        진행 중에서 완료로 이동함
        

### Tab 3

- 자신이 설정한 프로필 정보들을 열람할 수 있음
- 편집이 가능하여 타인이 자신의 프로필을 열람할 시, 보이게 될 멘트들을 설정할 수 있음
    - 스킬, 한마디 등



### 후기

초반에 로그인한다고 까먹은 시간이 조금만 덜 했다면 조금 더 완성도 높은 앱을 만들 수 있을 것 같았고(월요일 오후가 되어서야 본격적인 api 제작 시작), 여러 db를 만듬으로 하나의 기능에 여러 db의 정보가 바뀌게 되며, 한 곳의 오류를 막으면 다른 쪽 오류가 발생하는 상황이 일어나 너무 어지러웠음.
