# Factory CLI Nix Package 설계

## 레포지토리 구조

### 파일 구성
```
factory-cli-nix/
├── flake.nix              # 메인 flake, outputs 정의
├── overlay.nix            # factory-cli 패키지 정의
├── module.nix             # NixOS/home-manager 통합 모듈
├── README.md              # 사용 가이드 및 예제
├── CHANGELOG.md           # 버전별 변경사항
└── .github/
    └── workflows/
        └── update-version.yml  # 자동 버전 체크
```

## 모듈화 원칙

### 1. Overlay (overlay.nix)
**목적**: 재사용 가능한 패키지 정의

**포함**:
- 패키지 빌드 로직
- 플랫폼별 처리 (Linux/macOS)
- 의존성 정의
- steam-run wrapper (Linux)

**제외**:
- 사용자 설정
- enable 옵션
- unfree 정책

**사용 시나리오**:
```nix
# 다른 프로젝트에서 overlay만 가져오기
nixpkgs.overlays = [
  (import (fetchTarball "https://github.com/user/factory-cli-nix/archive/main.tar.gz")).overlays.default
];
```

### 2. Module (module.nix)
**목적**: 선언적 설정 제공

**제공 옵션**:
```nix
{
  services.factory-cli = {
    enable = true;              # 설치 여부
    package = pkgs.factory-cli; # 커스텀 패키지
  };
}
```

**자동 처리**:
- unfree 허용 자동 설정
- PATH 자동 추가
- overlay 자동 적용

**사용 시나리오**:
```nix
# home-manager
imports = [ inputs.factory-cli-nix.homeManagerModules.default ];

# NixOS
imports = [ inputs.factory-cli-nix.nixosModules.default ];
```

### 3. Flake Outputs
**제공**:
```nix
{
  overlays.default = import ./overlay.nix;

  nixosModules.default = import ./module.nix;
  homeManagerModules.default = import ./module.nix;

  packages.${system} = {
    factory-cli = ...;
    default = ...;
  };
}
```

## 사용 방법

### 방법 1: Flake Input (권장)
```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    factory-cli-nix.url = "github:user/factory-cli-nix";
  };

  outputs = { nixpkgs, factory-cli-nix, ... }: {
    homeConfigurations.user = home-manager.lib.homeManagerConfiguration {
      modules = [
        factory-cli-nix.homeManagerModules.default
        {
          services.factory-cli.enable = true;
        }
      ];
    };
  };
}
```

### 방법 2: Overlay만 사용
```nix
{
  nixpkgs.overlays = [
    factory-cli-nix.overlays.default
  ];

  home.packages = [ pkgs.factory-cli ];
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [ "factory-cli" ];
}
```

### 방법 3: 직접 설치
```bash
nix profile install github:user/factory-cli-nix
```

## 버전 관리

### 버전 업데이트 프로세스
1. GitHub Actions로 주기적 체크
2. 새 버전 감지 시 PR 자동 생성
3. 해시 자동 업데이트
4. 테스트 후 머지

### 버전 핀닝
```nix
{
  inputs.factory-cli-nix = {
    url = "github:user/factory-cli-nix";
    # 특정 버전 고정
    # url = "github:user/factory-cli-nix/v0.21.4";
  };
}
```

## 플랫폼 지원

### Linux
- steam-run FHS wrapper 사용
- unfree 자동 설정
- xdg-utils 의존성 자동 추가

### macOS
- 네이티브 바이너리 직접 실행
- 추가 wrapper 불필요

## 라이선스 고려사항

### Factory CLI
- **라이선스**: Unfree
- **배포**: 바이너리만 (소스 없음)
- **사용**: Factory AI 서비스 이용 필요

### 이 레포지토리
- **라이선스**: MIT (Nix 설정만)
- **포함**: 패키지 정의, 모듈, 문서
- **제외**: Factory CLI 바이너리

## 테스트

### 필수 테스트
- [ ] Linux x86_64 빌드
- [ ] macOS x86_64 빌드
- [ ] macOS aarch64 빌드
- [ ] 버전 명령 확인
- [ ] Interactive mode 시작

### CI/CD
```yaml
# .github/workflows/test.yml
name: Test
on: [push, pull_request]
jobs:
  test:
    strategy:
      matrix:
        os: [ubuntu-latest, macos-latest]
    runs-on: ${{ matrix.os }}
    steps:
      - uses: actions/checkout@v3
      - uses: cachix/install-nix-action@v22
      - run: nix build
      - run: nix run . -- --version
```

## 문서화

### README.md 필수 섹션
1. **Quick Start**: 3줄로 시작하기
2. **Installation**: 3가지 방법
3. **Configuration**: 옵션 설명
4. **Troubleshooting**: 일반적 문제
5. **License**: 명확한 라이선스 정보

### 예제 제공
- Flake 사용 예제
- Overlay 사용 예제
- Standalone 사용 예제
