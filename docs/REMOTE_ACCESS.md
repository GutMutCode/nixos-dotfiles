# 원격 접속 가이드: tmux + mosh

NixOS 시스템에 모바일 기기에서 안정적으로 접속하여 터미널 작업을 수행하는 방법을 설명합니다.

## 목차

1. [개요](#개요)
2. [설치 확인](#설치-확인)
3. [tmux 사용법](#tmux-사용법)
4. [Mosh 사용법](#mosh-사용법)
5. [tmux + Mosh 조합 워크플로우](#tmux--mosh-조합-워크플로우)
6. [모바일 클라이언트 설정](#모바일-클라이언트-설정)
7. [문제 해결](#문제-해결)

## 개요

### 도구 소개

- **tmux**: 터미널 멀티플렉서로 세션 유지 및 화면 분할 기능 제공
- **Mosh**: 모바일 네트워크에 최적화된 SSH 대체 도구

### 주요 장점

- **세션 유지**: 네트워크 연결이 끊겨도 작업 계속 실행
- **멀티플렉싱**: 하나의 연결로 여러 터미널 동시 사용
- **네트워크 복원력**: WiFi ↔ LTE 전환 시에도 끊김 없음
- **즉각적인 반응**: 로컬 에코로 입력 지연 최소화

## 설치 확인

시스템 재빌드 후 설치 확인:

```bash
tmux -V     # tmux 버전 확인
mosh --version  # mosh 버전 확인
```

## tmux 사용법

### 기본 세션 관리

```bash
# 새 세션 생성
tmux new -s SESSION_NAME

# 세션 목록 확인
tmux ls

# 기존 세션에 재접속
tmux attach -t SESSION_NAME
tmux a -t SESSION_NAME  # 축약형

# 세션에서 분리 (detach)
# tmux 내부에서: Ctrl+B, D

# 세션 종료
tmux kill-session -t SESSION_NAME

# 모든 세션 종료
tmux kill-server
```

### 윈도우 관리

| 단축키 | 기능 |
|--------|------|
| `Ctrl+B, C` | 새 윈도우 생성 |
| `Ctrl+B, N` | 다음 윈도우로 이동 |
| `Ctrl+B, P` | 이전 윈도우로 이동 |
| `Ctrl+B, 0-9` | 특정 윈도우로 이동 |
| `Ctrl+B, ,` | 윈도우 이름 변경 |
| `Ctrl+B, &` | 윈도우 종료 |
| `Ctrl+B, W` | 윈도우 목록 표시 |

### 화면 분할 (Pane)

| 단축키 | 기능 |
|--------|------|
| `Ctrl+B, %` | 세로 분할 |
| `Ctrl+B, "` | 가로 분할 |
| `Ctrl+B, 방향키` | 분할된 창 간 이동 |
| `Ctrl+B, O` | 다음 창으로 이동 |
| `Ctrl+B, X` | 현재 창 종료 |
| `Ctrl+B, Z` | 현재 창 확대/축소 |
| `Ctrl+B, {` | 창 위치 왼쪽으로 이동 |
| `Ctrl+B, }` | 창 위치 오른쪽으로 이동 |

### 스크롤 및 복사 모드

```bash
# 스크롤 모드 진입: Ctrl+B, [
# 스크롤: 방향키 또는 PageUp/PageDown
# 검색: / (전방) 또는 ? (후방)
# 종료: q 또는 ESC
```

### 유용한 명령어

```bash
# 설정 리로드
tmux source-file ~/.tmux.conf

# 세션 이름 변경
tmux rename-session -t OLD_NAME NEW_NAME

# 모든 클라이언트 목록
tmux list-clients

# 현재 세션 정보
tmux info
```

## Mosh 사용법

### 기본 접속

```bash
# 기본 SSH 포트 사용 (22)
mosh USERNAME@HOSTNAME

# 특정 SSH 포트 지정
mosh --ssh="ssh -p 2222" USERNAME@HOSTNAME

# 특정 Mosh 포트 범위 지정
mosh -p 60001 USERNAME@HOSTNAME
```

### 연결 상태 확인

- `Ctrl+^` (Ctrl+Shift+6): 네트워크 상태 표시
- 화면 상단에 연결 품질 정보 표시

### 주요 특징

1. **로밍 지원**: IP 주소 변경되어도 연결 유지
2. **로컬 에코**: 입력 즉시 화면 표시 (예측 에코)
3. **자동 재연결**: 네트워크 복구 시 자동 재접속

## tmux + Mosh 조합 워크플로우

### 기본 워크플로우

```bash
# 1. NixOS 서버에서 tmux 세션 생성 (최초 1회)
ssh gmc@nixos-ip
tmux new -s mobile
# 작업 설정...
# Ctrl+B, D로 detach

# 2. 모바일에서 Mosh로 접속
mosh gmc@nixos-ip

# 3. tmux 세션에 재접속
tmux attach -t mobile

# 4. 작업 진행
# 네트워크 끊겨도 OK, 앱 종료해도 OK

# 5. 작업 완료 후 detach
# Ctrl+B, D

# 6. Mosh 종료
exit
```

### 개발 환경 예시

```bash
# 세션 생성 및 윈도우 구성
tmux new -s dev

# Window 0: 코드 편집
nvim configuration.nix

# Window 1: 빌드 (Ctrl+B, C로 새 윈도우)
nix build .#nixosConfigurations.nixos-gmc.config.system.build.toplevel

# Window 2: Git 작업 (Ctrl+B, C)
git status
git diff

# Window 3: 시스템 모니터링 (Ctrl+B, C)
# Ctrl+B, % (세로 분할)
journalctl -f  # 왼쪽 창
# Ctrl+B, 방향키로 오른쪽 이동
htop           # 오른쪽 창
```

### 장기 실행 작업

```bash
# tmux 세션에서 긴 작업 실행
tmux new -s build
nix build --print-build-logs

# Ctrl+B, D로 detach
# Mosh 종료해도 빌드는 계속 진행

# 나중에 확인
mosh gmc@nixos-ip
tmux attach -t build
# 빌드 진행 상황 확인
```

## 모바일 클라이언트 설정

### Android

**Termux** (추천):

```bash
# Termux 설치: Google Play Store 또는 F-Droid
# Termux 내에서 패키지 설치
pkg update
pkg install openssh mosh

# 접속
mosh gmc@nixos-ip
```

**JuiceSSH**:
- SSH만 지원 (Mosh 불가)
- GUI가 편리함

### iOS

**Blink Shell** (추천):
- Mosh 기본 지원
- tmux 통합 기능
- 유료 ($19.99)

**Terminus**:
- 무료
- SSH/Mosh 지원

## 문제 해결

### Mosh 연결 실패

**문제**: `mosh: Nothing received from server on UDP port`

**해결**:

1. 방화벽 설정 확인:
   ```bash
   # NixOS에서
   sudo nixos-rebuild switch --flake .#nixos-gmc

   # 방화벽 상태 확인
   sudo iptables -L -n | grep 60000
   ```

2. Mosh 서버 실행 확인:
   ```bash
   ps aux | grep mosh-server
   ```

3. 특정 포트로 연결 시도:
   ```bash
   mosh -p 60001 gmc@nixos-ip
   ```

### tmux 세션 복구 불가

**문제**: 세션이 사라짐

**원인**: 서버 재부팅 또는 tmux 서버 종료

**예방**:
- tmux-resurrect 플러그인 사용 (세션 저장/복원)
- 중요 작업은 스크립트로 자동화

### 네트워크 전환 시 연결 끊김

**문제**: WiFi → LTE 전환 시 Mosh 끊김

**해결**:
- Mosh는 자동 재연결되어야 함
- 재연결 안 되면: 앱 종료 후 재접속
- tmux 세션은 유지되므로 작업 손실 없음

### 화면 깨짐

**문제**: tmux 화면이 깨져 보임

**해결**:
```bash
# tmux 내부에서
Ctrl+B, :
source-file ~/.tmux.conf  # 설정 리로드

# 또는 세션 재접속
tmux detach
tmux attach
```

## 참고 자료

### tmux

- 공식 문서: https://github.com/tmux/tmux/wiki
- Man page: `man tmux`
- 치트시트: https://tmuxcheatsheet.com/

### Mosh

- 공식 사이트: https://mosh.org/
- GitHub: https://github.com/mobile-shell/mosh

### 추가 도구

- **tmux-resurrect**: 세션 영구 저장
- **tmuxinator**: tmux 세션 자동 구성
- **byobu**: tmux wrapper with enhanced features
