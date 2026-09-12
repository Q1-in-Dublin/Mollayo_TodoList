# Molayo 🐟

**자꾸 까먹는 나, 금붕어일까?**
잘 까먹는 ADHD 사용자를 위한 macOS 네이티브 할 일 관리 + 뽀모도로 타이머 앱입니다.

## 왜 만들었나

일은 하고 있는데 뭘 하고 있었는지 기억이 안 날 때가 있습니다. Molayo는 그럴 때 다시 알려주는, 금붕어 같은 기억력을 가진 사람들을 위한 작은 도우미입니다.

## 기능

- **할 일 관리** — 이름, 메모, 기한을 등록하고 체크박스로 완료 처리
- **캘린더 뷰** — 월간 캘린더에서 날짜별 마감 작업 확인, 날짜 클릭해서 바로 추가
- **통계** — 전체 / 완료 / 남음 작업 수를 상시 표시
- **뽀모도로 타이머** — 기본 집중 50분 / 휴식 10분(설정에서 자유롭게 조절), 세션 종료 시 팝업 + macOS 시스템 알림으로 즉시 인지
- **Molayo 브리핑** — 사이드바의 Molayo 버튼을 누르면 지금 타이머 상태 + 남은 작업 전체 목록을 한 번에 확인
- **"몰라요" 리마인더** — 미완료 작업 옆 물고기 버튼을 누르면 15분 뒤 다시 알림 (깜빡했을 때를 위한 스누즈 기능)
- **다국어 지원** — English / 한국어 / Español / Português (Brasil) / Français / Deutsch, 설정에서 즉시 전환
- **완전 로컬** — 서버·계정·인터넷 연결 없이 동작, 모든 데이터는 내 Mac에만 저장

## 설치 및 실행

```bash
git clone <repo-url>
cd Molayo_TodoList
./build.sh
open .build/release/Molayo.app
```

`/Applications`에 옮겨서 쓰고 싶다면:

```bash
cp -R .build/release/Molayo.app /Applications/
```

처음 실행 시 서명 경고가 뜨면 Finder에서 앱을 우클릭 → "열기"로 한 번 열어주세요.

## 요구사항

- macOS 13 이상
- Xcode Command Line Tools (`swift` 명령어가 필요합니다)

## 라이선스

Open source by @Jacob Jung
