# Outline
<img src="https://github.com/user-attachments/assets/33fc7d7e-8432-4461-8947-3e7a3cc10b39">

‘**플메가되..** 🎀’는 팀플을 함께할 팀원을 구하고, 팀플을 진행하는 데에 있어 필요한 다양한 기능들을 제공해주는 앱입니다.

**개발환경**

- Front-end: Android Studio (Flutter)
- Back-end: Django, MySQL, AWS
<br><br>

# Team
- 강지우
- 김서영
- 윤우성
<br><br>

# Databases
<img src="https://github.com/user-attachments/assets/90a7fb54-eaa3-4d64-b2bd-edfab5b460bf">
<br><br>

# Basic UI & Colors
<img src="https://github.com/user-attachments/assets/98dada77-0f15-4fda-827d-061011e4046f">
<img src="https://github.com/user-attachments/assets/b95cf03b-5884-4d74-91a6-5f271d81557f">
<img src="https://github.com/user-attachments/assets/560e51a4-cf5f-4b13-bc5f-ee9805b32fce">
<br><br>

# Details

## Intro & TabLayout

- 스플래시 화면 구현
<img src="https://github.com/user-attachments/assets/2c5dd660-3a42-4e20-b3a5-042aa246a0fb">
<br>

## Login & SignUp

- 카카오 로그인으로 앱 자체 로그인 가능
- 같은 기기에서 로그인 여부를 기록하여 앱 다시 실행시 자동로그
<br>
<img src="https://github.com/user-attachments/assets/b00c1cce-83f0-4562-a4bf-4c773aa09b03">
<img src="https://github.com/user-attachments/assets/9907c119-b2c7-4238-bf9d-38faa1aa1c38">
<br>

## Tab 1

- 팀원을 구할 과목을 선택하여 팀원 구하는 글 작성 가능
    - 팀플 제목, 팀플 설명, 정원, 마감일 설정하여 업로드
- 다른 사용자가 올린 팀원 구하는 글 열람 가능
    - 원하는 팀플을 선택하여 팀플을 올린 이용자의 프로필 열람 가능
    - 원하는 팀플을 지원가능
- 알림창이 존재하여, 팀플의 지원, 팀플의 수락과 거절 여부가 보임
<br>
<img src="https://github.com/user-attachments/assets/ef29a519-3e50-4714-87e8-ccb4dc1226e1">
<img src="https://github.com/user-attachments/assets/0f534148-a280-4473-86b0-378914e41dfc">
<img src="https://github.com/user-attachments/assets/e266a43e-c2fb-45c3-abb8-9e2c62149a67">
<img src="https://github.com/user-attachments/assets/661119ea-5906-4295-b540-6f684c624f5f">
<img src="https://github.com/user-attachments/assets/0f0c8162-972a-47dc-b32b-76aa5fd5e09b">
<br>

## Tab 2

- 본인이 현재 참여 중인 팀플이 나옴
- 팀플의 상태에 따라, 진행 중, 진행 전, 완료로 나뉨
    - tab1에서 구인글을 올리면, tab2의 진행 전 파트에 추가됨
    - 팀의 리더(구인 글 게시자)가 tab1의 알림에서 정원만큼의 팀원을 받아 `is_fulled` 가 True가 된다면, 진행 전에서 진행 중으로 변경됨
    - 팀의 리더가 진행 중인 ‘팀플 끝내기’를 눌러 팀플을 끝낸다면 `is_finished` 가 True가 되며, 진행 중에서 완료로 이동함
<br>
<img src="https://github.com/user-attachments/assets/0c83b576-f7cf-4333-9458-c9f5ecbcd5ce">
<img src="https://github.com/user-attachments/assets/d427bb77-8a0d-40a4-a69e-54d1965eef51">
<img src="https://github.com/user-attachments/assets/6e10e64a-a622-4a4d-8250-9ea386d569f9">
<br>

## Tab 3

- 자신이 설정한 프로필 정보들을 열람할 수 있음
- 편집이 가능하여 타인이 자신의 프로필을 열람할 시, 보이게 될 멘트들을 설정할 수 있음
    - 스킬, 한마디 등
<br>
<img src="https://github.com/user-attachments/assets/f9563843-e8fb-4bcd-b7e8-d80eeead2709">
<img src="https://github.com/user-attachments/assets/e82b5f8d-6016-44a2-9df1-a176f5076378">
<br>


