# NixOS 설정 개선 완료 보고서

## 적용된 개선사항

### 1. Unfree 패키지 관리 중앙화
- **변경 전**: `allowUnfree = true` (모든 unfree 패키지 허용)
- **변경 후**: `allowUnfreePredicate`로 명시적 허용 리스트 관리
- **효과**: 보안 향상, 의도하지 않은 unfree 패키지 설치 방지

**허용된 패키지 목록**:
- nvidia-x11, nvidia-settings
- discord, spotify, slack
- steam 관련 패키지
- claude-code, opencode, codex, amp-cli (unstable)
- blender, davinci-resolve (unstable)

### 2. Nerd Fonts 적용
- **fonts.nix**: `nerd-fonts.jetbrains-mono` 추가
- **programs.nix**: Alacritty 폰트를 `JetBrainsMono Nerd Font`로 변경
- **효과**: 아이콘 및 심볼 정상 표시

### 3. CUDA 지원 비활성화
- OBS Studio의 `cudaSupport = true` 제거
- Blender CUDA 지원 제거 (CUDA unfree 라이센스 이슈)
- **효과**: 빌드 안정성 향상

### 4. Nix Store 최적화 설정 추가
```nix
nix.settings.auto-optimise-store = true;
nix.gc = {
  automatic = true;
  dates = "weekly";
  options = "--delete-older-than 30d";
};
```
- **효과**: 디스크 공간 자동 관리, 30일 이상 된 세대 자동 삭제

### 5. 사용하지 않는 모듈 정리
- `modules/home/unfree.nix` import 제거
- 중복 설정 제거

### 6. 자동 업그레이드 비활성화 유지
- `system.autoUpgrade.enable = false`
- 수동 제어로 시스템 안정성 확보

## 현재 설정 상태

### Flake 구조
- **nixpkgs**: stable (25.05)
- **nixpkgs-unstable**: 최신 패키지용
- **home-manager**: release-25.05
- **sops-nix**: secrets 관리

### 주요 서비스
- Hyprland (Wayland compositor)
- NVIDIA 드라이버 (오픈소스)
- Tor 서비스
- SSH 서버

### 자동화
- ✅ Nix garbage collection: 매주 실행
- ✅ Nix store 최적화: 자동
- ❌ 시스템 자동 업그레이드: 비활성화 (수동 권장)

## 향후 권장사항

### CUDA 지원이 필요한 경우
1. flake.nix의 `allowedUnfreePackages`에 추가:
   ```nix
   "cuda_cudart"
   "cuda_nvcc"
   "libcublas"
   ```
2. 또는 regex 패턴 사용:
   ```nix
   isCudaPackage = builtins.match "^(cuda_.*|libcu.*|libnv.*)" name != null;
   builtins.elem name allowedUnfreePackages || isCudaPackage
   ```

### 보안 강화
- SOPS secrets 정기 백업
- SSH 키 관리 점검
- Firefox Tor 프로필 설정 검증

### 성능 모니터링
```bash
# NVIDIA GPU 확인
nvidia-smi

# Nix store 크기 확인
du -sh /nix/store

# GC 이후 정리된 공간 확인
nix-store --gc --print-dead

# 수동 최적화 실행
nix-store --optimise
```

## 테스트 결과
✅ 모든 변경사항 빌드 성공
✅ Nix garbage collection 타이머 활성화 확인
✅ Nerd Fonts 정상 적용
