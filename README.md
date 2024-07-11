### Outline

---

![로고.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/f6cb388f-3934-47d6-9928-26d2e10eb0fc/7eaef655-a6f2-4349-8ec1-f6999bda7bd4/0d9cc7e7-48c3-40bc-b451-d7a1bc017920.png)

***‘플메가되..*** 🎀***’***는 팀플을 함께할 팀원을 구하고, 팀플을 진행하는 데에 있어 필요한 다양한 기능들을 제공해주는 앱입니다.

**개발환경**

- Front-end: Android Studio (Flutter)
- Back-end: Django, MySQL, AWS

### Team

---

[강지우](https://www.notion.so/a5baceb985844e619e8c56373b6120ab?pvs=21) 

[ashley271 - Overview](https://github.com/ashley271)

[김서영](https://www.notion.so/311946d346434147a28e847dd315b320?pvs=21) 

[syeongkim - Overview](https://github.com/syeongkim)

[윤우성](https://www.notion.so/de835d34bcea4575857161b4e44c363b?pvs=21) 

[SPWooSeong - Overview](https://github.com/SPWooSeong)

### Databases

---

![Untitled](https://prod-files-secure.s3.us-west-2.amazonaws.com/f6cb388f-3934-47d6-9928-26d2e10eb0fc/c8f8539c-0d96-444c-8cfe-5f9b48bd13f5/Untitled.png)

### APIs

---

[APIs (2)](https://www.notion.so/5885a49388bc443f9e506ce3f7494b63?pvs=21)

### Basic UI & Colors

---

![Untitled.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/f6cb388f-3934-47d6-9928-26d2e10eb0fc/c8a83245-77dc-4054-a67f-301f9d39cce2/Untitled.png)

![2.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/f6cb388f-3934-47d6-9928-26d2e10eb0fc/d78b3126-2ce1-4b95-a8db-597247961a5b/2.png)

![3.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/f6cb388f-3934-47d6-9928-26d2e10eb0fc/81158203-7732-4e9f-a9c6-4f20add5d4a7/3.png)

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

![Untitled](https://prod-files-secure.s3.us-west-2.amazonaws.com/f6cb388f-3934-47d6-9928-26d2e10eb0fc/3691112d-5d1d-42d9-b94d-3b08623ea225/Untitled.png)

![Untitled](https://prod-files-secure.s3.us-west-2.amazonaws.com/f6cb388f-3934-47d6-9928-26d2e10eb0fc/f7a511f0-fefc-4606-925d-e89200c22c51/Untitled.png)

![Untitled](https://prod-files-secure.s3.us-west-2.amazonaws.com/f6cb388f-3934-47d6-9928-26d2e10eb0fc/64e76b7d-b280-4e8d-963a-9f3560300e39/Untitled.png)

### Tab 1

- 팀원을 구할 과목을 선택하여 팀원 구하는 글 작성 가능
    - 팀플 제목, 팀플 설명, 정원, 마감일 설정하여 업로드
- 다른 사용자가 올린 팀원 구하는 글 열람 가능
    - 원하는 팀플을 선택하여 팀플을 올린 이용자의 프로필 열람 가능
    - 원하는 팀플을 지원가능
- 알림창이 존재하여, 팀플의 지원, 팀플의 수락과 거절 여부가 보임

![Untitled](https://prod-files-secure.s3.us-west-2.amazonaws.com/f6cb388f-3934-47d6-9928-26d2e10eb0fc/e615c28e-45f0-4c0a-9648-2566d4c40048/54824c23-5343-4456-be6f-4ba85df37ceb.png)

![Untitled](https://prod-files-secure.s3.us-west-2.amazonaws.com/f6cb388f-3934-47d6-9928-26d2e10eb0fc/8994f85d-cd0a-4b4a-bd35-b58be8fde7c4/Untitled.png)

![Untitled](https://prod-files-secure.s3.us-west-2.amazonaws.com/f6cb388f-3934-47d6-9928-26d2e10eb0fc/945329de-78d2-4b4d-9c21-db4eb7c48190/Untitled.png)

![Untitled](https://prod-files-secure.s3.us-west-2.amazonaws.com/f6cb388f-3934-47d6-9928-26d2e10eb0fc/8dcd0b9b-4a93-42bb-9bd5-57cd0a4ee7cb/Untitled.png)

![Untitled](https://prod-files-secure.s3.us-west-2.amazonaws.com/f6cb388f-3934-47d6-9928-26d2e10eb0fc/4dae0f38-b687-4886-b8c8-1913dc096ffd/Untitled.png)

### Tab 2

- 본인이 현재 참여 중인 팀플이 나옴
- 팀플의 상태에 따라, 진행 중, 진행 전, 완료로 나뉨
    - tab1에서 구인글을 올리면, tab2의 진행 전 파트에 추가됨
    - 팀의 리더(구인 글 게시자)가 tab1의 알림에서 정원만큼의 팀원을 받아 `is_fulled` 가 True가 된다면, 진행 전에서 진행 중으로 변경됨
    - 팀의 리더가 진행 중인 ‘팀플 끝내기’를 눌러 팀플을 끝낸다면 `is_finished` 가 True가 되며,
        
        진행 중에서 완료로 이동함
        

![Untitled](https://prod-files-secure.s3.us-west-2.amazonaws.com/f6cb388f-3934-47d6-9928-26d2e10eb0fc/64399168-156d-4add-98f2-c0a693f3ee57/Untitled.png)

![Untitled](https://prod-files-secure.s3.us-west-2.amazonaws.com/f6cb388f-3934-47d6-9928-26d2e10eb0fc/ee4fe858-5270-4528-9305-551c72a10bfc/Untitled.png)

![Untitled](https://prod-files-secure.s3.us-west-2.amazonaws.com/f6cb388f-3934-47d6-9928-26d2e10eb0fc/2ceaebbf-04e7-4e0a-88f1-ad2d43e7e3f4/Untitled.png)

### Tab 3

- 자신이 설정한 프로필 정보들을 열람할 수 있음
- 편집이 가능하여 타인이 자신의 프로필을 열람할 시, 보이게 될 멘트들을 설정할 수 있음
    - 스킬, 한마디 등

![Untitled](https://prod-files-secure.s3.us-west-2.amazonaws.com/f6cb388f-3934-47d6-9928-26d2e10eb0fc/c77f4145-585c-4864-80a2-2361eaf5d567/Untitled.png)

![Untitled](https://prod-files-secure.s3.us-west-2.amazonaws.com/f6cb388f-3934-47d6-9928-26d2e10eb0fc/3dbd8594-fb05-428a-8c44-fbf5b16878c3/Untitled.png)

### 후기

초반에 로그인한다고 까먹은 시간이 조금만 덜 했다면 조금 더 완성도 높은 앱을 만들 수 있을 것 같았고(월요일 오후가 되어서야 본격적인 api 제작 시작), 여러 db를 만듬으로 하나의 기능에 여러 db의 정보가 바뀌게 되며, 한 곳의 오류를 막으면 다른 쪽 오류가 발생하는 상황이 일어나 너무 어지러웠음.
