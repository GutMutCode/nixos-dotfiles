# Troubleshooting Guide

## 1. Double NAT 문제

**증상:** WAN IP가 Private IP (192.168.x.x)로 표시됨

**원인:** ISP 라우터와 사용자 라우터가 이중으로 NAT 수행

**해결:**
- ipTIME 라우터를 AP/브리지 모드로 변경
- 설정: ISP LAN <-> ipTIME LAN 으로 연결
- 결과: 서버가 ISP 네트워크에 직접 연결됨 (192.168.35.x)

## 2. 포트 포워딩 충돌

**증상:** "사용중인 서비스 포트는 입력할 수 없다" 오류

**원인:** ISP 라우터가 80, 443 포트를 관리 페이지로 사용 중

**해결:**
- ISP 라우터에서 DMZ 호스트 설정
- DMZ IP: 서버 IP 주소 (예: 192.168.35.185)
- 모든 포트가 자동으로 서버로 포워딩됨

## 3. SSL 인증서 발급 실패

**증상:** Firefox 보안 경고, 자체 서명 인증서

**원인:** Traefik docker-compose.yml에 HTTPS 라우터 설정 누락

**해결:**
```yaml
labels:
  # HTTP router (redirect to HTTPS)
  - "traefik.http.routers.traefik.entrypoints=http"
  - "traefik.http.routers.traefik.middlewares=traefik-https-redirect"
  # HTTPS router
  - "traefik.http.routers.traefik-secure.entrypoints=https"
  - "traefik.http.routers.traefik-secure.rule=Host(`traefik.${DOMAIN}`)"
  - "traefik.http.routers.traefik-secure.tls=true"
  - "traefik.http.routers.traefik-secure.tls.certresolver=cloudflare"
  - "traefik.http.middlewares.traefik-https-redirect.redirectscheme.scheme=https"
```

**주의:** 변경 후 `docker-compose restart`가 아닌 `down && up -d` 필요 (labels 갱신)

## 4. htpasswd 특수 문자 문제

**증상:** 비밀번호에 `!` 포함 시 인증 실패

**원인:** Bash history expansion (`!`는 히스토리 명령 참조)

**해결 방법:**

### A. 특수 문자 제외 (권장)
```bash
htpasswd -nb admin SecurePassword123
```

### B. stdin 방식 사용
```bash
echo 'password!' | htpasswd -i -n admin
```

### C. History expansion 비활성화
```bash
set +H
htpasswd -nb admin 'password!'
```

**주의:** 큰따옴표(`"`)는 불충분, 작은따옴표(`'`) 필수

## 5. 환경 변수 로딩 문제

**증상:** docker-compose 실행 시 환경 변수 "not set" 경고

**원인:** docker-compose가 현재 디렉토리의 .env만 자동 로드

**해결:**
```bash
cd /srv/docker/traefik
docker-compose --env-file ../.env up -d
```

## 6. Traefik 설정 변경이 적용되지 않음

**증상:** .env 파일 수정 후에도 이전 값 사용

**원인:** `docker-compose restart`는 labels를 갱신하지 않음

**해결:**
```bash
docker-compose --env-file ../.env down
docker-compose --env-file ../.env up -d
```

## 일반적인 체크리스트

### DNS 확인
```bash
host traefik.yourdomain.com 8.8.8.8
# 결과: Public IP 주소 확인
```

### 포트 리스닝 확인
```bash
docker ps --format "table {{.Names}}\t{{.Ports}}"
```

### SSL 인증서 확인
```bash
ls -lh /srv/docker/traefik/acme.json
# 0 바이트가 아닌지 확인
```

### 인증 테스트
```bash
curl -I https://traefik.yourdomain.com
# 401 Unauthorized = 정상 (인증 필요)
# 405 Method Not Allowed = 인증 성공 (HEAD 메서드 미지원)
```

### 로그 확인
```bash
docker logs traefik | tail -50
```
