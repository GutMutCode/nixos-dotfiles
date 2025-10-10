# OBS Studio 설정 가이드

**날짜:** 2025-10-10
**환경:** NixOS + Wayland (Hyprland) + PipeWire

---

## 목차

1. [OBS Studio란?](#obs-studio란)
2. [설치된 플러그인 설명](#설치된-플러그인-설명)
3. [Virtual Camera (가상 카메라)](#virtual-camera-가상-카메라)
4. [실제 사용 방법](#실제-사용-방법)
5. [설정 파일 위치](#설정-파일-위치)

---

## OBS Studio란?

**Open Broadcaster Software** - 무료 오픈소스 스트리밍/녹화 프로그램

### 주요 용도
- Twitch/YouTube 라이브 방송
- 게임 플레이 녹화
- 온라인 강의 영상 제작
- 화상회의 고급 기능 (가상 카메라)
- 화면 녹화 및 편집

### 주요 기능
- 화면/창/영역 캡처
- 웹캠 연결 및 합성
- 여러 소스(Scene) 믹싱
- 오디오 믹싱 및 필터링
- 실시간 스트리밍
- 로컬 녹화

---

## 설치된 플러그인 설명

현재 `home.nix`에 설정된 플러그인: (home.nix:163-172)

### 1. **wlrobs** (Wayland Screen Capture)

**무엇인가:**
- Wayland 환경에서 화면을 캡처하는 플러그인
- wlroots 기반 컴포지터(Hyprland, Sway 등) 지원

**왜 필요한가:**
- X11과 달리 Wayland는 보안상 화면 캡처가 제한됨
- 일반 화면 캡처 방식으로는 Wayland에서 검은 화면만 나옴
- PipeWire 화면 공유 프로토콜 사용

**사용 예시:**
- 게임 플레이 전체 화면 녹화
- 데스크톱 튜토리얼 영상 제작
- 작업 화면 공유
- 멀티 모니터 선택적 캡처

**OBS에서 사용:**
- Source 추가 → "PipeWire Screen Capture" 선택
- 캡처할 모니터/창 선택

---

### 2. **obs-pipewire-audio-capture** (PipeWire Audio Integration)

**무엇인가:**
- PipeWire 오디오 시스템과 OBS 통합
- 시스템의 모든 오디오 스트림 접근 가능

**왜 필요한가:**
- 시스템 오디오(음악, 게임 소리, 앱 사운드)를 녹화/방송에 포함
- 개별 애플리케이션 오디오를 선택적으로 캡처 가능
- 오디오 소스별 독립적 볼륨 조절

**사용 예시:**
- Discord 통화 + 게임 소리 동시 녹화
- Spotify 배경음악을 포함한 방송
- 마이크 + 시스템 오디오 분리 제어
- 특정 앱(브라우저만, 게임만) 오디오만 캡처

**OBS에서 사용:**
- Source 추가 → "PipeWire Audio Capture"
- 캡처할 오디오 스트림 선택 (앱별/장치별)

---

### 3. **하드웨어 가속 (GPU Encoding)**

GPU 하드웨어 인코더를 사용하여 CPU 부하를 줄이고 성능을 향상시킵니다.

#### 공통 효과
- CPU 대신 GPU로 영상 인코딩 → CPU 부하 대폭 감소
- 게임 플레이 중 프레임 드롭 감소
- 더 높은 해상도(1440p, 4K)로 녹화 가능
- 더 높은 비트레이트 사용 가능
- 시스템 발열 및 전력 소비 감소

---

#### 3-1. **NVIDIA NVENC** (NVIDIA GPU용)

**무엇인가:**
- NVIDIA GPU의 전용 하드웨어 비디오 인코더
- CUDA를 통한 하드웨어 가속
- 6세대 이상 (GTX 10 시리즈~): H.264, H.265
- 8세대 (RTX 40 시리즈): H.264, H.265, AV1

**NixOS 설정:**
```nix
programs.obs-studio = {
  enable = true;
  package = (pkgs.obs-studio.override {
    cudaSupport = true;  # NVIDIA CUDA/NVENC 활성화
  });
  plugins = with pkgs.obs-studio-plugins; [
    wlrobs
    obs-pipewire-audio-capture
    obs-vkcapture
    obs-backgroundremoval
  ];
};
```

**OBS에서 사용:**
- Settings → Output → Encoder 선택:
  - **NVIDIA NVENC H.264**: 스트리밍 권장 (호환성 최고)
  - **NVIDIA NVENC HEVC (H.265)**: 녹화 권장 (파일 크기 50% 감소)
  - **NVIDIA NVENC AV1**: 최신 코덱 (RTX 40 시리즈, 최고 압축률)

**프리셋 설정:**
- **P1 (Fastest)**: 최저 품질, 최고 성능
- **P4 (Balanced)**: 균형잡힌 설정 (권장)
- **P7 (Slowest)**: 최고 품질, 약간의 성능 저하

**장점:**
- 거의 성능 손실 없음 (1-3%)
- 8세대 NVENC는 x264 medium과 비슷한 화질
- 동시 녹화+스트리밍 가능 (듀얼 인코더)
- 최고의 실시간 인코딩 성능

**GPU 확인:**
```bash
# NVIDIA GPU 및 드라이버 확인
nvidia-smi

# NVENC 지원 확인
nvidia-smi -q | grep "Encoder"
```

**지원 GPU:**
- GeForce: GTX 10 시리즈 이상 (GTX 1050, RTX 2060, RTX 4080 등)
- Quadro/Tesla: 모든 현대 모델

---

#### 3-2. **obs-vaapi** (AMD/Intel GPU용)

**무엇인가:**
- AMD GPU: 하드웨어 비디오 인코더 (VCE/VCN)
- Intel GPU: QuickSync Video
- VA-API (Video Acceleration API) 통한 하드웨어 가속

**NixOS 설정:**
```nix
programs.obs-studio = {
  enable = true;
  plugins = with pkgs.obs-studio-plugins; [
    obs-vaapi  # AMD/Intel 하드웨어 가속
    wlrobs
    obs-pipewire-audio-capture
    obs-vkcapture
    obs-backgroundremoval
  ];
};
```

**OBS에서 사용:**
- Settings → Output → Encoder 선택:
  - **FFMPEG VAAPI H.264**: 기본 코덱
  - **FFMPEG VAAPI H.265/HEVC**: 높은 압축률

**장점 (AMD):**
- 중간 정도의 성능 오버헤드 (5-10%)
- 괜찮은 화질 (x264 fast~medium 수준)
- RX 400 시리즈 이상에서 안정적

**장점 (Intel QuickSync):**
- 매우 낮은 전력 소비
- 통합 GPU 사용으로 전용 GPU 부담 없음
- 11세대(Tiger Lake) 이상에서 우수한 화질

**GPU 확인:**
```bash
# VA-API 지원 확인
vainfo

# AMD GPU 확인
lspci -k | grep -A 3 VGA

# Intel GPU 확인
lspci | grep VGA
```

**지원 GPU:**
- AMD: RX 400 시리즈 이상 (RX 470, RX 5700, RX 7900 등)
- Intel: HD Graphics 2000 이상 (11세대 이상 권장)

---

#### 하드웨어 가속 선택 가이드

| GPU 종류 | 권장 설정 | 화질 | 성능 | 비고 |
|---------|---------|------|------|------|
| **NVIDIA RTX 40/30** | NVENC (8/7세대) | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | 최고 선택 |
| **NVIDIA GTX 16/10** | NVENC (6세대) | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | 여전히 우수 |
| **AMD RX 6000/7000** | VAAPI | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | 좋은 선택 |
| **AMD RX 5000 이하** | VAAPI | ⭐⭐⭐ | ⭐⭐⭐⭐ | 괜찮음 |
| **Intel 11세대+** | QuickSync (VAAPI) | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | 저전력 |
| **Intel 10세대 이하** | QuickSync (VAAPI) | ⭐⭐⭐ | ⭐⭐⭐⭐ | 보조용 |

**일반 권장사항:**
- **게이밍 스트리밍**: NVIDIA NVENC (있다면) > AMD VAAPI > Intel QuickSync
- **장시간 녹화**: HEVC/H.265 코덱 사용 (파일 크기 절약)
- **최고 화질 필요**: x264 소프트웨어 인코더 (CPU 부하 큼)
- **저사양 시스템**: 하드웨어 인코더 필수

---

### 4. **obs-vkcapture** (Vulkan Game Capture)

**무엇인가:**
- Vulkan API 게임을 직접 프레임버퍼에서 캡처
- OpenGL 게임도 지원

**왜 필요한가:**
- 일반 화면 캡처보다 성능이 훨씬 좋음
- 게임과 OBS가 프레임버퍼를 공유하여 오버헤드 최소화
- 전체 화면 게임도 안정적으로 캡처

**사용 방법:**
```bash
# 게임 실행 시 obs-vkcapture로 래핑
obs-vkcapture <게임실행파일>

# 예시
obs-vkcapture steam
obs-vkcapture ./game-binary
```

**장점:**
- 게임 성능 저하 최소화 (5% 미만)
- 게임 화면만 깔끔하게 캡처 (다른 창 안 나옴)
- OBS 오버레이가 게임에 나타나지 않음
- 전체화면 게임도 문제없이 캡처

**OBS에서 사용:**
- Source 추가 → "Vulkan/OpenGL Capture"
- obs-vkcapture로 실행한 게임이 자동으로 표시됨

**지원 게임:**
- Vulkan: 대부분의 최신 게임
- OpenGL: Minecraft, 구형 게임 등

---

### 5. **obs-backgroundremoval** (AI Background Removal)

**무엇인가:**
- AI 머신러닝으로 웹캠 배경을 자동으로 제거
- 그린스크린 없이도 배경 분리 가능

**왜 필요한가:**
- 물리적 그린스크린 설치 불필요
- 조명 없이도 깔끔한 배경 제거
- 실시간 처리로 자연스러운 효과

**사용 예시:**
- 방이 지저분해도 깔끔한 방송 가능
- 게임 화면 위에 자신만 투명하게 합성
- 프로페셔널한 프레젠테이션
- 화상회의에서 배경 숨김

**OBS에서 사용:**
- 웹캠 Source 우클릭 → Filters → Add → "Background Removal"
- Background Type 선택:
  - None (Remove): 배경 완전 제거 (투명)
  - Blur: 배경 블러 처리
  - Image: 배경을 이미지로 교체

**성능:**
- GPU 사용 (ONNX 모델)
- CPU: 약간의 부하 (10-20%)
- 저사양에서는 프레임 드롭 가능

---

## Virtual Camera (가상 카메라)

### 개념

**Virtual Camera란:**
- OBS에서 구성한 화면을 가상 웹캠 장치로 출력
- 다른 프로그램에서 "웹캠"처럼 인식되어 사용 가능

### 기술적 구현

#### v4l2loopback 커널 모듈
```nix
boot.kernelModules = [ "v4l2loopback" ];
```
→ 시스템 부팅 시 v4l2loopback 모듈 로드

**v4l2loopback이란:**
- Video for Linux 2 (V4L2) 루프백 장치
- 가상 비디오 장치를 만드는 리눅스 커널 모듈
- 한 프로그램의 출력을 다른 프로그램의 입력으로 연결

#### 모듈 설정 (configuration.nix:19-21)
```nix
options v4l2loopback exclusive_caps=1 devices=2 video_nr=0,1 card_label="OBS Virtual Camera"
```

**파라미터 설명:**
- `exclusive_caps=1`: V4L2_CAP_VIDEO_CAPTURE만 광고 (Chrome/Firefox 호환성)
- `devices=2`: 가상 카메라 2개 생성
- `video_nr=0,1`: `/dev/video0`, `/dev/video1` 장치로 생성
- `card_label="OBS Virtual Camera"`: 장치 이름 (앱에서 표시됨)

**장치 확인:**
```bash
ls -l /dev/video*
v4l2-ctl --list-devices
```

### 사용 예시

#### 기본 사용 흐름
1. OBS에서 화면 구성 (게임 + 웹캠 + 오버레이)
2. OBS 메뉴: "Tools → Start Virtual Camera" 클릭
3. Discord/Zoom/Google Meet에서 카메라 선택
4. "OBS Virtual Camera" 선택
5. OBS에서 만든 화면이 그대로 상대방에게 전송됨

#### 실제 활용 사례

**1. 게이밍 스트리머 Setup**
```
OBS Scene 구성:
├─ 게임 화면 (전체 배경)
├─ 웹캠 (우측 하단, 배경 제거)
├─ 채팅창 오버레이
├─ 후원 알림
└─ 로고/워터마크

→ Discord에서 Virtual Camera 사용
→ 친구들이 스트리머처럼 구성된 화면 시청
```

**2. 온라인 강의/프레젠테이션**
```
OBS Scene 구성:
├─ PPT 화면공유 (메인)
├─ 강사 웹캠 (Picture-in-Picture)
├─ 강의 제목 오버레이
└─ 타이머

→ Zoom/Google Meet에서 Virtual Camera 사용
→ 전문적인 강의 화면 송출
```

**3. 화상회의 고급 설정**
```
OBS Scene 구성:
├─ 웹캠 (AI 배경 제거)
├─ 회사 로고 (우측 상단)
├─ 이름/직책 텍스트
└─ 배경 이미지/영상

→ Teams/Slack에서 Virtual Camera 사용
→ 프로페셔널한 화상회의
```

**4. 콘텐츠 제작**
```
OBS Scene 구성:
├─ 브라우저 창 (튜토리얼 작업 화면)
├─ 웹캠 (설명하는 모습)
├─ 자막 오버레이
└─ 로고

→ 녹화하면서 동시에 Virtual Camera로 송출
→ 실시간 피드백 가능
```

---

## 실제 사용 방법

### 1. 기본 녹화/방송

#### Scene 구성
1. OBS 실행
2. "Scenes" 패널에서 "+" 클릭 → Scene 이름 입력
3. "Sources" 패널에서 "+" 클릭 → Source 추가

#### Source 종류
- **Display Capture**: 전체 모니터 캡처 (wlrobs 사용)
- **Window Capture**: 특정 창만 캡처
- **PipeWire Screen Capture**: Wayland 화면 캡처
- **Video Capture Device**: 웹캠
- **Audio Input/Output Capture**: 마이크/스피커
- **Text**: 텍스트 오버레이
- **Image**: 로고, 워터마크
- **Browser**: 웹페이지 (채팅, 위젯 등)

#### 녹화 시작
1. Settings → Output → Recording
   - Recording Path: 저장 경로 설정
   - Recording Format: mp4 추천
   - Encoder: FFMPEG VAAPI (AMD GPU) 선택
2. "Start Recording" 버튼 클릭

#### 스트리밍 시작
1. Settings → Stream
   - Service: Twitch/YouTube 선택
   - Server: Auto (권장)
   - Stream Key: 플랫폼에서 복사
2. "Start Streaming" 버튼 클릭

---

### 2. 게임 캡처 (고성능)

#### Vulkan/OpenGL 게임 캡처

**Step 1: 게임 실행**
```bash
# Terminal에서 게임을 obs-vkcapture로 실행
obs-vkcapture <게임실행명령>

# Steam 게임 예시
obs-vkcapture steam steam://rungameid/1234567

# 바이너리 직접 실행
obs-vkcapture ./game-binary

# Lutris 게임
obs-vkcapture lutris lutris:rungame/game-name
```

**Step 2: OBS에서 Source 추가**
1. Scene에서 "+" 클릭
2. "Vulkan/OpenGL Capture" 선택
3. obs-vkcapture로 실행한 게임이 자동으로 표시됨

**장점:**
- Window Capture보다 성능 우수 (5-10% 오버헤드만)
- 전체 화면 게임도 안정적 캡처
- 게임 FPS 저하 최소화

---

### 3. Virtual Camera 사용

#### OBS 설정
1. Scene 구성 (원하는 레이아웃 만들기)
2. 메뉴: Tools → Start Virtual Camera
3. 상태바에 "Virtual Camera Active" 표시 확인

#### Discord에서 사용
1. Settings → Voice & Video
2. Camera: "OBS Virtual Camera" 선택
3. 화면 공유 시작하면 OBS 화면이 송출됨

#### Zoom에서 사용
1. Settings → Video
2. Camera 드롭다운: "OBS Virtual Camera" 선택
3. 회의 참여 시 OBS 화면이 송출됨

#### Google Meet에서 사용
1. 회의 참여
2. 카메라 아이콘 우측 "..." 메뉴
3. "OBS Virtual Camera" 선택

---

### 4. 오디오 믹싱

#### PipeWire Audio Capture 설정
1. Source 추가 → "PipeWire Audio Capture"
2. Source 선택:
   - **Monitor of Sink**: 시스템 출력 오디오 (스피커 소리)
   - **Specific Application**: 특정 앱만 선택 (Discord, 게임 등)
3. Audio Mixer에서 볼륨 조절

#### 오디오 필터
1. Audio Source 우클릭 → Filters
2. 유용한 필터:
   - **Noise Suppression**: 배경 소음 제거
   - **Noise Gate**: 소리 임계값 이하 음소거
   - **Compressor**: 볼륨 자동 조절
   - **Gain**: 볼륨 증폭

---

### 5. AI 배경 제거

#### 설정 방법
1. 웹캠 Source 추가 (Video Capture Device)
2. 웹캠 Source 우클릭 → Filters → "+"
3. "Background Removal" 선택
4. 설정:
   - **Background Type**: None/Blur/Image 선택
   - **Threshold**: 0.5 (배경 감지 민감도, 0.3-0.7 권장)
   - **Contour Filter**: 2.0 (경계선 부드럽게, 1.0-3.0)

#### 최적화 팁
- **조명**: 밝은 조명일수록 정확도 상승
- **배경**: 단색 배경이 더 잘 인식됨 (그린스크린 불필요)
- **거리**: 배경과 1m 이상 떨어질수록 좋음
- **성능**: GPU 사용, 저사양이면 해상도 낮추기

---

## 설정 파일 위치

### NixOS 설정
```
/home/gmc/nixos-dotfiles/
├── home.nix (line 163-172)          # OBS 플러그인 설정
└── configuration.nix (line 17-22)   # Virtual Camera 커널 모듈
```

### OBS 사용자 설정
```
~/.config/obs-studio/
├── basic/
│   ├── scenes/      # Scene 구성
│   ├── profiles/    # 프로필 (출력 설정 등)
│   └── service.json # 스트리밍 키
└── plugin_config/   # 플러그인 설정
```

### 녹화 파일 기본 경로
```
~/Videos/
```
(Settings → Output → Recording Path에서 변경 가능)

---

## 추가 리소스

### 공식 문서
- OBS Studio Wiki: https://obsproject.com/wiki/
- OBS Forums: https://obsproject.com/forum/

### NixOS 관련
- NixOS Wiki - OBS Studio: https://wiki.nixos.org/wiki/OBS_Studio
- Home-Manager OBS Module: https://github.com/nix-community/home-manager

### 플러그인 저장소
- wlrobs: https://sr.ht/~scoopta/wlrobs/
- obs-backgroundremoval: https://github.com/occ-ai/obs-backgroundremoval
- obs-vkcapture: https://github.com/nowrep/obs-vkcapture

---

## 트러블슈팅

### 화면이 검은색으로 나옴
- Wayland 환경: "PipeWire Screen Capture" 사용
- wlrobs 플러그인 확인: Settings → General → Sources

### Virtual Camera가 다른 앱에서 안 보임
```bash
# v4l2loopback 모듈 로드 확인
lsmod | grep v4l2loopback

# 장치 확인
ls -l /dev/video*

# 재부팅 필요할 수 있음
sudo nixos-rebuild switch --flake .#nixos-gmc
reboot
```

### AMD 하드웨어 인코더 사용 불가
```bash
# VA-API 드라이버 확인
vainfo

# AMD GPU 드라이버 확인
lspci -k | grep -A 3 VGA
```

### 게임 캡처 시 성능 저하
- obs-vkcapture 사용 (일반 Window Capture 대신)
- 하드웨어 인코더 사용 (VAAPI)
- 출력 해상도/FPS 낮추기
- Game Mode 활성화

---

**작성자**: Claude Code
**최종 수정**: 2025-10-10
