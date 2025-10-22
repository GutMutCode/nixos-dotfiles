# Configuration Guide

Complete guide explaining each configuration setting, why it's needed, and how to configure it.

## Table of Contents

- [Domain Configuration](#domain-configuration)
- [Cloudflare DNS Setup](#cloudflare-dns-setup)
- [Cloudflare API Token](#cloudflare-api-token)
- [Traefik Email](#traefik-email)
- [Traefik Dashboard Authentication](#traefik-dashboard-authentication)
- [Service Passwords](#service-passwords)
- [Port Forwarding](#port-forwarding)
- [Environment Variables Reference](#environment-variables-reference)

---

## Domain Configuration

### Why (목적)

**IP 주소 대신 기억하기 쉬운 이름을 사용하기 위함**

- Public IP: `<your-public-ip>` (기억하기 어려움)
- Domain: `example.com` (기억하기 쉬움)
- 각 서비스마다 서브도메인 자동 생성:
  - `nextcloud.example.com` → Nextcloud
  - `jellyfin.example.com` → Jellyfin
  - `gitea.example.com` → Gitea

### How (설정 방법)

#### Step 1: 도메인 구매

도메인 등록업체에서 도메인 구매:
- [Namecheap](https://www.namecheap.com)
- [GoDaddy](https://www.godaddy.com)
- [Cloudflare Registrar](https://www.cloudflare.com/products/registrar/)

#### Step 2: .env 파일에 도메인 설정

```bash
# /srv/docker/.env
DOMAIN=example.com
```

#### Step 3: 확인

```bash
# .env 파일 확인
cat /srv/docker/.env | grep DOMAIN
```

**출력 예시:**
```
DOMAIN=example.com
```

### Technical Details

Traefik은 `${DOMAIN}` 환경 변수를 사용하여 각 서비스의 라우팅 규칙을 동적으로 생성합니다:

```yaml
# docker-compose.yml 예시
labels:
  - "traefik.http.routers.nextcloud.rule=Host(`nextcloud.${DOMAIN}`)"
```

위 설정은 다음과 같이 해석됩니다:
- `DOMAIN=local` → `nextcloud.local`
- `DOMAIN=example.com` → `nextcloud.example.com`

---

## Cloudflare DNS Setup

### Why (목적)

**도메인 이름을 서버 IP 주소로 연결하기 위함**

사용자가 `nextcloud.example.com`에 접속하면:
1. DNS가 `<your-public-ip>`으로 변환
2. 사용자의 브라우저가 해당 IP로 연결
3. Traefik이 요청을 Nextcloud 컨테이너로 전달

### How (설정 방법)

#### Step 1: Cloudflare 계정 생성

1. https://cloudflare.com 접속
2. 계정 생성 및 로그인

#### Step 2: 도메인 추가

1. "Add a Site" 클릭
2. 도메인 이름 입력 (예: `example.com`)
3. Free 플랜 선택
4. Cloudflare가 제공하는 네임서버 확인

#### Step 3: 네임서버 변경

도메인 등록업체(Namecheap, GoDaddy 등)에서:

1. DNS 설정 페이지로 이동
2. 네임서버를 Cloudflare의 네임서버로 변경:
   ```
   예시:
   - ns1.cloudflare.com
   - ns2.cloudflare.com
   ```
3. 저장 (변경 사항이 적용되기까지 최대 24시간 소요)

#### Step 4: DNS 레코드 추가

Cloudflare Dashboard → DNS → Records에서 다음 레코드 추가:

**레코드 1: 루트 도메인**
```
Type: A
Name: @
IPv4 address: <your-public-ip>
Proxy status: DNS only (회색 구름)
TTL: Auto
```

**레코드 2: 와일드카드 (모든 서브도메인)**
```
Type: A
Name: *
IPv4 address: <your-public-ip>
Proxy status: DNS only (회색 구름)
TTL: Auto
```

> **중요**: Proxy status를 "DNS only"로 설정해야 Let's Encrypt DNS challenge가 작동합니다.

#### Step 5: DNS 전파 확인

```bash
# 로컬에서 DNS 조회
nslookup nextcloud.example.com

# 또는 온라인 도구 사용
# https://www.whatsmydns.net/
```

**예상 출력:**
```
Server:  1.1.1.1
Address: 1.1.1.1#53

Name:    nextcloud.example.com
Address: <your-public-ip>
```

### Why DNS Only? (왜 Proxy를 사용하지 않나요?)

Cloudflare의 Proxy 모드(주황색 구름)를 사용하면:
- ✅ 실제 IP 주소 숨김 (DDoS 보호)
- ✅ Cloudflare의 CDN 사용
- ❌ Let's Encrypt DNS challenge 실패 가능

DNS only 모드(회색 구름)를 사용하면:
- ✅ Let's Encrypt DNS challenge 작동
- ✅ SSL 인증서 자동 발급
- ❌ 실제 IP 주소 노출

**권장사항**: 초기 설정 시 DNS only 사용, SSL 인증서 발급 후 선택적으로 Proxy 모드 전환

---

## Cloudflare API Token

### Why (목적)

**SSL 인증서 자동 발급 및 갱신을 위함**

1. **자동 인증서 발급**: Let's Encrypt가 도메인 소유권 확인
2. **자동 갱신**: 인증서 만료(90일) 전 자동 갱신
3. **DNS Challenge**: Cloudflare API를 통해 TXT 레코드 생성/삭제

### How It Works (작동 원리)

```
1. Traefik이 SSL 인증서 요청
   ↓
2. Let's Encrypt가 도메인 소유권 확인 요구
   ↓
3. Traefik이 Cloudflare API로 TXT 레코드 생성
   (_acme-challenge.example.com)
   ↓
4. Let's Encrypt가 TXT 레코드 확인
   ↓
5. 인증서 발급 완료
   ↓
6. Traefik이 TXT 레코드 삭제
```

### How (설정 방법)

#### Step 1: API Token 생성

1. Cloudflare Dashboard 로그인
2. 우측 상단 프로필 아이콘 → "My Profile"
3. 좌측 메뉴 → "API Tokens"
4. "Create Token" 클릭

#### Step 2: Token 권한 설정

**템플릿 선택:**
- "Edit zone DNS" 템플릿 사용

**권한 설정:**
```
Permissions:
  Zone - DNS - Edit

Zone Resources:
  Include - Specific zone - example.com
```

#### Step 3: Token 생성 및 저장

1. "Continue to summary" 클릭
2. "Create Token" 클릭
3. **Token 복사 및 안전하게 저장** (다시 볼 수 없음)

**생성된 Token 예시:**
```
<your-cloudflare-api-token>
```

#### Step 4: .env 파일에 설정

```bash
# /srv/docker/.env
CF_DNS_API_TOKEN=<your-cloudflare-api-token>
```

#### Step 5: Token 유효성 검증

```bash
# API Token 확인
curl -X GET "https://api.cloudflare.com/client/v4/user/tokens/verify" \
  -H "Authorization: Bearer <your-cloudflare-api-token>" \
  -H "Content-Type:application/json"
```

**예상 출력:**
```json
{
  "result": {
    "id": "59a9a366d0af9a7fc07a3543cf952e47",
    "status": "active"
  },
  "success": true,
  "messages": [
    {
      "code": 10000,
      "message": "This API Token is valid and active"
    }
  ]
}
```

### Troubleshooting

**문제: Token이 유효하지 않음**
```json
{
  "success": false,
  "errors": [{"code": 6003, "message": "Invalid request headers"}]
}
```

**해결방법:**
1. Token을 정확히 복사했는지 확인
2. Cloudflare에서 Token 재생성
3. 권한이 올바르게 설정되었는지 확인 (Zone DNS Edit)

---

## Traefik Email

### Why (목적)

**SSL 인증서 관리 및 만료 알림 수신**

1. **Let's Encrypt 알림 수신**: 인증서 만료 30일/7일 전 이메일 발송
2. **문제 발생 시 통지**: 인증서 갱신 실패 시 알림
3. **계정 복구**: Let's Encrypt 계정 관리

### How (설정 방법)

#### Step 1: Traefik 설정 파일 편집

```bash
# 파일 위치
~/nixos-dotfiles/docker/traefik/traefik.yml
```

#### Step 2: 이메일 주소 변경

```yaml
certificatesResolvers:
  cloudflare:
    acme:
      email: gutmutcode@gmail.com  # ← 실제 이메일로 변경
      storage: acme.json
      dnsChallenge:
        provider: cloudflare
        resolvers:
          - "1.1.1.1:53"
          - "1.0.0.1:53"
```

#### Step 3: NixOS 재빌드 (symlink 업데이트)

```bash
cd ~/nixos-dotfiles
sudo nixos-rebuild switch --flake .#nixos-gmc
```

이 명령은 `~/nixos-dotfiles/docker/`를 `/srv/docker/`로 symlink하므로, 변경사항이 자동으로 반영됩니다.

### Email Notifications (이메일 알림 예시)

**인증서 만료 알림:**
```
Subject: Let's Encrypt certificate expiration notice for example.com

Hello,

Your certificate (or certificates) for the names listed below will expire in 30 days.
Please make sure to renew your certificate before then.

Domains:
- nextcloud.example.com
- jellyfin.example.com
```

**갱신 성공 알림:**
```
Subject: Your certificate has been renewed

Your certificate for example.com has been successfully renewed.
```

### Best Practices

1. **실제 이메일 사용**: 스팸 메일함도 확인
2. **알림 필터링**: Gmail에서 "[Let's Encrypt]" 레이블 생성
3. **백업 이메일**: 여러 이메일 주소는 지원되지 않음

---

## Traefik Dashboard Authentication

### Why (목적)

**Traefik 관리 대시보드 무단 접근 방지**

Traefik 대시보드(`https://traefik.example.com`)에서 확인 가능한 정보:
- 실행 중인 모든 서비스 목록
- 라우팅 규칙 (어떤 도메인이 어떤 서비스로 연결되는지)
- 인증서 상태
- 서버 구조 정보

→ **민감한 정보이므로 인증 필요**

### How (설정 방법)

#### Step 1: 비밀번호 해시 생성

**Docker를 사용한 방법 (권장):**

```bash
docker run --rm httpd:2.4-alpine htpasswd -nb admin your_password
```

**예시:**
```bash
docker run --rm httpd:2.4-alpine htpasswd -nb admin 'KJHwhsgh1!'
```

**출력:**
```
admin:$apr1$qDC/JCcD$umiyptKVgIYlh/JH2ypmr0
```

#### Step 2: .env 파일에 설정

**중요**: `$` 기호를 `$$`로 이스케이프해야 합니다!

```bash
# /srv/docker/.env

# 잘못된 예시 (작동하지 않음)
TRAEFIK_ADMIN_AUTH=admin:$apr1$qDC/JCcD$umiyptKVgIYlh/JH2ypmr0

# 올바른 예시
TRAEFIK_ADMIN_AUTH=admin:$$apr1$$qDC/JCcD$$umiyptKVgIYlh/JH2ypmr0
```

#### Step 3: 로그인 정보 확인

- **Username**: `admin`
- **Password**: `KJHwhsgh1!` (해시 생성 시 사용한 비밀번호)

### Why Escape $ ? (왜 $ 기호를 이스케이프하나요?)

Docker Compose는 `.env` 파일에서 `$`를 환경 변수 참조로 해석합니다:

```bash
# .env 파일
PASSWORD=$apr1$abc

# Docker Compose가 해석
PASSWORD=  # $apr1과 $abc를 환경 변수로 찾지만 없으므로 빈 문자열
```

`$$`를 사용하면 리터럴 `$`로 해석됩니다:

```bash
# .env 파일
PASSWORD=$$apr1$$abc

# Docker Compose가 해석
PASSWORD=$apr1$abc  # 올바르게 해석됨
```

### Testing

1. Traefik 컨테이너 시작 후:
   ```bash
   cd /srv/docker/traefik
   docker-compose up -d
   ```

2. 브라우저에서 접속:
   ```
   https://traefik.example.com
   ```

3. 로그인 프롬프트가 나타나면 성공:
   - Username: `admin`
   - Password: `KJHwhsgh1!`

### Troubleshooting

**문제: 로그인이 안됨**

```bash
# 1. .env 파일 확인
cat /srv/docker/.env | grep TRAEFIK_ADMIN_AUTH

# 2. Docker Compose가 올바르게 읽는지 확인
cd /srv/docker/traefik
docker-compose config | grep TRAEFIK_ADMIN_AUTH
```

**문제: 인증 창이 아예 안나타남**

Traefik 라벨 설정 확인:
```yaml
# docker-compose.yml
labels:
  - "traefik.http.middlewares.traefik-auth.basicauth.users=${TRAEFIK_ADMIN_AUTH}"
```

---

## Service Passwords

### Why (목적)

**각 서비스의 관리자 계정 보호**

다음 서비스들은 웹 인터페이스가 외부에 노출됩니다:
- **Nextcloud**: 개인 파일 저장소
- **Gitea**: Git 저장소
- **Grafana**: 모니터링 대시보드
- **PostgreSQL**: Nextcloud 데이터베이스

기본 비밀번호 사용 시 보안 위험:
- 무작위 대입 공격 (Brute Force)
- 사전 공격 (Dictionary Attack)
- 자동화된 봇 공격

### How (설정 방법)

#### Step 1: 강력한 비밀번호 생성

**방법 1: 랜덤 생성 (권장)**

```bash
# 20자 랜덤 비밀번호 생성
tr -dc 'A-Za-z0-9!@#$%^&*' < /dev/urandom | head -c 20; echo
```

**출력 예시:**
```
Kx9#mP2$vN8@qR5!wT3&
```

**방법 2: Docker 사용**

```bash
docker run --rm alpine sh -c "cat /dev/urandom | tr -dc 'A-Za-z0-9!@#$%^&*' | head -c 20"
```

#### Step 2: .env 파일 편집

```bash
cd /srv/docker
nano .env
```

#### Step 3: 비밀번호 변경

```bash
# Nextcloud
NEXTCLOUD_ADMIN_USER=admin
NEXTCLOUD_ADMIN_PASSWORD=Kx9#mP2$vN8@qR5!wT3&  # ← 강력한 비밀번호

# PostgreSQL (Nextcloud 데이터베이스)
POSTGRES_PASSWORD=Yx7!nM4$bP1@tS6#rQ2^  # ← Nextcloud 비밀번호와 다르게
POSTGRES_DB=nextcloud
POSTGRES_USER=nextcloud

# Gitea
GITEA_ADMIN_USER=admin
GITEA_ADMIN_PASSWORD=Lp8@wK5$cN3!xR9#mT1&  # ← 강력한 비밀번호
GITEA_ADMIN_EMAIL=gutmutcode@gmail.com

# Grafana
GRAFANA_ADMIN_PASSWORD=Zq4!bM7$vP2@kS8#nW5^  # ← 강력한 비밀번호
```

#### Step 4: 비밀번호 안전하게 저장

**권장 방법:**
1. **비밀번호 관리자 사용**: 1Password, Bitwarden, LastPass
2. **암호화된 파일**: GPG로 암호화하여 저장
3. **종이에 기록**: 물리적으로 안전한 장소에 보관

**절대 하지 말아야 할 것:**
- ❌ 브라우저 저장 (동기화 시 유출 위험)
- ❌ 클라우드에 평문 저장
- ❌ Git 저장소에 커밋

### Password Security Best Practices

#### 강력한 비밀번호 조건

- ✅ 최소 20자 이상
- ✅ 대문자, 소문자, 숫자, 특수문자 혼합
- ✅ 각 서비스마다 다른 비밀번호
- ✅ 예측 불가능한 랜덤 문자열

#### 취약한 비밀번호 예시

- ❌ `password123`
- ❌ `admin1234`
- ❌ `qwerty`
- ❌ 생일, 전화번호
- ❌ 사전에 있는 단어

### Special Characters Warning

`.env` 파일에서 특수문자 사용 시 주의사항:

```bash
# 문제가 될 수 있는 문자
PASSWORD=test'123  # 작은따옴표
PASSWORD=test"123  # 큰따옴표
PASSWORD=test`123  # 백틱
PASSWORD=test$123  # 달러 기호

# 안전한 특수문자
PASSWORD=test!@#%^&*()_+-=
```

**권장**: 따옴표, 백틱, 달러 기호는 피하고 `!@#%^&*()_+-=` 사용

---

## Port Forwarding

### Why (목적)

**외부에서 서버로 접속 가능하게 만들기**

기본적으로 라우터는 외부 인터넷에서 내부 네트워크로의 접속을 차단합니다:

```
인터넷 → [라우터 방화벽 ⛔] → 내부 네트워크
```

포트 포워딩 설정 후:

```
인터넷 → [라우터 포트 80/443 ✅] → 서버 (192.168.0.194)
```

### Required Ports (필요한 포트)

| 외부 포트 | 내부 IP:포트 | 프로토콜 | 서비스 | 설명 |
|---------|------------|---------|--------|------|
| 80 | 192.168.0.194:80 | TCP | HTTP | Let's Encrypt 인증서 발급, HTTP→HTTPS 리다이렉트 |
| 443 | 192.168.0.194:443 | TCP | HTTPS | 모든 웹 서비스 (Nextcloud, Jellyfin 등) |
| 51820 | 192.168.0.194:51820 | UDP | WireGuard | VPN 연결 |
| 2222 | 192.168.0.194:2222 | TCP | Gitea SSH | Git push/pull (선택사항) |

### How (설정 방법)

포트 포워딩 설정은 라우터마다 다릅니다. 일반적인 단계:

#### Step 1: 라우터 관리 페이지 접속

```bash
# 라우터 IP 확인
ip route | grep default
```

**일반적인 라우터 주소:**
- `192.168.0.1`
- `192.168.1.1`
- `192.168.123.1`
- `10.0.0.1`

브라우저에서 접속: `http://192.168.0.1`

#### Step 2: 관리자 로그인

- 라우터 설명서 참조
- 일반적인 기본 계정:
  - Username: `admin`
  - Password: 라우터 뒷면 스티커 확인

#### Step 3: 포트 포워딩 설정 찾기

라우터 메뉴에서 다음 중 하나를 찾으세요:
- "Port Forwarding"
- "Virtual Server"
- "NAT Forwarding"
- "Application & Gaming"

#### Step 4: 규칙 추가

**규칙 1: HTTP**
```
Service Name: HTTP
External Port: 80
Internal IP: 192.168.0.194
Internal Port: 80
Protocol: TCP
Enable: ✓
```

**규칙 2: HTTPS**
```
Service Name: HTTPS
External Port: 443
Internal IP: 192.168.0.194
Internal Port: 443
Protocol: TCP
Enable: ✓
```

**규칙 3: WireGuard VPN**
```
Service Name: WireGuard
External Port: 51820
Internal IP: 192.168.0.194
Internal Port: 51820
Protocol: UDP  # ⚠️ UDP임에 주의!
Enable: ✓
```

**규칙 4: Gitea SSH (선택사항)**
```
Service Name: Gitea-SSH
External Port: 2222
Internal IP: 192.168.0.194
Internal Port: 2222
Protocol: TCP
Enable: ✓
```

#### Step 5: 저장 및 재시작

1. "Save" / "Apply" 클릭
2. 필요시 라우터 재시작

### Verification (확인)

#### 로컬 네트워크에서 확인

```bash
# 서버가 포트를 리스닝하고 있는지 확인
sudo netstat -tulpn | grep -E ':(80|443|51820|2222)'
```

**예상 출력:**
```
tcp        0      0 0.0.0.0:80              0.0.0.0:*               LISTEN      1234/traefik
tcp        0      0 0.0.0.0:443             0.0.0.0:*               LISTEN      1234/traefik
udp        0      0 0.0.0.0:51820           0.0.0.0:*                           5678/wireguard
tcp        0      0 0.0.0.0:2222            0.0.0.0:*               LISTEN      9012/gitea
```

#### 외부에서 확인

**방법 1: 온라인 포트 체커**

https://www.yougetsignal.com/tools/open-ports/ 접속 후:
1. Public IP 입력: `<your-public-ip>`
2. Port 입력: `443`
3. "Check" 클릭

**예상 결과:**
```
Port 443 is open on <your-public-ip>
```

**방법 2: 스마트폰 (셀룰러 데이터)**

1. WiFi 끄기 (셀룰러 데이터만 사용)
2. 브라우저에서 접속: `https://example.com`
3. 서비스가 로드되면 성공

**방법 3: 외부 서버에서 테스트**

```bash
# 다른 서버나 VPS에서
nc -zv <your-public-ip> 443
```

**예상 출력:**
```
Connection to <your-public-ip> 443 port [tcp/https] succeeded!
```

### Troubleshooting

#### 문제 1: 포트가 열리지 않음

**원인 분석:**

```bash
# 1. 로컬에서 서비스가 실행 중인지 확인
docker ps

# 2. 방화벽 확인
sudo iptables -L -n | grep -E '(80|443)'

# 3. NixOS 방화벽 설정 확인
sudo nixos-rebuild switch --flake .#nixos-gmc
```

**해결방법:**

NixOS 방화벽이 올바르게 설정되었는지 확인:

```nix
# modules/services/home-server.nix
networking.firewall = {
  enable = true;
  allowedTCPPorts = [ 80 443 2222 ];
  allowedUDPPorts = [ 51820 ];
};
```

#### 문제 2: Double NAT

**증상:**
- 라우터 WAN IP가 Public IP와 다름
- 포트 포워딩 설정했지만 외부에서 접속 불가

**확인 방법:**

```bash
# 1. 서버에서 Public IP 확인
curl ifconfig.me
# 출력: <your-public-ip>

# 2. 라우터 관리 페이지에서 WAN IP 확인
# Status → WAN IP
# 출력: 100.64.x.x (다르면 Double NAT!)
```

**해결방법:**
1. ISP 라우터를 Bridge 모드로 설정
2. 또는 DMZ 기능 사용
3. ISP에 연락하여 Public IP 요청

#### 문제 3: ISP가 포트 차단

일부 ISP는 주거용 인터넷에서 포트 80/443을 차단합니다.

**확인 방법:**
```bash
# ISP 라우터 밖에서 테스트 (셀룰러 데이터)
nc -zv <your-public-ip> 80
nc -zv <your-public-ip> 443
```

**해결방법:**
1. ISP에 연락하여 포트 개방 요청
2. 또는 비즈니스 인터넷 플랜으로 변경
3. 또는 대체 포트 사용 (예: 8080, 8443) + Cloudflare Tunnel

---

## Environment Variables Reference

Complete list of all environment variables in `/srv/docker/.env`:

### Domain & DNS

```bash
# Your domain name
DOMAIN=example.com

# Cloudflare API token for DNS challenge (SSL certificate issuance)
CF_DNS_API_TOKEN=your_cloudflare_api_token
```

### Traefik

```bash
# Traefik dashboard authentication (format: username:$$apr1$$hash)
# Generate with: docker run --rm httpd:2.4-alpine htpasswd -nb admin password
TRAEFIK_ADMIN_AUTH=admin:$$apr1$$qDC/JCcD$$umiyptKVgIYlh/JH2ypmr0
```

### Nextcloud

```bash
# Nextcloud admin credentials
NEXTCLOUD_ADMIN_USER=admin
NEXTCLOUD_ADMIN_PASSWORD=your_strong_password

# PostgreSQL database credentials (used by Nextcloud)
POSTGRES_PASSWORD=different_strong_password
POSTGRES_DB=nextcloud
POSTGRES_USER=nextcloud
```

### Gitea

```bash
# Gitea admin credentials
GITEA_ADMIN_USER=admin
GITEA_ADMIN_PASSWORD=your_strong_password
GITEA_ADMIN_EMAIL=gutmutcode@gmail.com
```

### Grafana

```bash
# Grafana admin password (username is always 'admin')
GRAFANA_ADMIN_PASSWORD=your_strong_password
```

### WireGuard VPN

```bash
# Number of VPN client configurations to generate
WIREGUARD_PEERS=2

# WireGuard server port (must match port forwarding)
WIREGUARD_SERVERPORT=51820
```

### System

```bash
# Timezone for all containers
TZ=Asia/Seoul
```

---

## Complete Setup Checklist

Use this checklist to ensure all configurations are complete:

### Prerequisites
- [ ] Domain purchased
- [ ] Cloudflare account created
- [ ] Server IP address known: `<your-public-ip>`
- [ ] Server local IP known: `192.168.0.194`

### DNS Configuration
- [ ] Domain added to Cloudflare
- [ ] Nameservers changed at registrar
- [ ] DNS A record for `@` created
- [ ] DNS A record for `*` created
- [ ] DNS propagation verified

### Cloudflare API
- [ ] API token created with "Edit zone DNS" permission
- [ ] Token saved securely
- [ ] Token validity verified

### Configuration Files
- [ ] `docker/traefik/traefik.yml` email updated
- [ ] `/srv/docker/.env` created from template
- [ ] `DOMAIN` set to actual domain
- [ ] `CF_DNS_API_TOKEN` set
- [ ] `TRAEFIK_ADMIN_AUTH` generated and set
- [ ] All service passwords changed from defaults
- [ ] `GITEA_ADMIN_EMAIL` updated

### Network Configuration
- [ ] Router admin access obtained
- [ ] Port 80 forwarded to 192.168.0.194:80
- [ ] Port 443 forwarded to 192.168.0.194:443
- [ ] Port 51820 (UDP) forwarded to 192.168.0.194:51820
- [ ] Port forwarding verified from external network

### System Setup
- [ ] NixOS rebuilt: `sudo nixos-rebuild switch --flake .#nixos-gmc`
- [ ] Docker network created: `docker network create proxy`
- [ ] `acme.json` created with 600 permissions
- [ ] All services started: `./manage.sh start`

### Verification
- [ ] SSL certificates issued (check Traefik logs)
- [ ] Services accessible via HTTPS externally
- [ ] Traefik dashboard login works
- [ ] No certificate warnings in browser

---

## Security Best Practices Summary

### Passwords
- ✅ Use 20+ character random passwords
- ✅ Different password for each service
- ✅ Store in password manager
- ✅ Never commit passwords to git

### Network
- ✅ Use VPN (WireGuard) for remote access
- ✅ Consider restricting sensitive services to VPN-only access
- ✅ Enable Cloudflare proxy after SSL setup (optional)
- ✅ Monitor Traefik logs regularly

### Maintenance
- ✅ Update services weekly: `./manage.sh update`
- ✅ Monitor SSL certificate expiration emails
- ✅ Backup data regularly
- ✅ Review access logs periodically

### Cloudflare Protection
- ✅ Enable "Under Attack Mode" if experiencing DDoS
- ✅ Configure rate limiting rules
- ✅ Use Cloudflare Access for additional authentication layer

---

## Additional Resources

- [Traefik Documentation](https://doc.traefik.io/traefik/)
- [Cloudflare DNS API Documentation](https://developers.cloudflare.com/api/operations/dns-records-for-a-zone-list-dns-records)
- [Let's Encrypt Documentation](https://letsencrypt.org/docs/)
- [Docker Compose Environment Variables](https://docs.docker.com/compose/environment-variables/)
- [WireGuard Documentation](https://www.wireguard.com/quickstart/)

---

## Getting Help

If you encounter issues:

1. **Check logs**: `./manage.sh logs traefik`
2. **Verify DNS**: `nslookup yourdomain.com`
3. **Test ports**: https://www.yougetsignal.com/tools/open-ports/
4. **Review this guide**: Ensure all steps completed
5. **Check service-specific documentation**: Each service has its own troubleshooting guide

---

**Last Updated**: 2025-10-22
