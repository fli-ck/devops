# 4주차

# 자동화와 협업

## 자동화 체험

디렉터리 100개를 GUI로 만들면 몇 분이 걸리지만, 명령어로는 한 줄.

```sh
for i in $(seq 1 100); do mkdir -p test/dir$i; done
ls test
rm -rf test
```

## 디렉터리는 서버의 지도

- `/home`: 사용자 작업 공간
- `/etc`: 시스템과 프로그램의 설정
- `/var/log`: 시스템과 서비스의 로그
- `/tmp`: 임시 파일
- `/usr/bin`: 주요 실행 파일과 명령어

내가 만든 파일은 홈 디렉터리 `~`, 시스템 전역 설정은 `/etc`, 실패 원인은 `/var/log` 또는 애플리케이션 로그에서 찾음.

```sh
ls -ld /home /etc /var/log /tmp /usr/bin # -l: 상세 보기, -d: 디렉터리 자체 정보
```

## 절대 경로와 상대 경로

- 절대 경로: `/home/nx/devops/week03/qwen-web/start.sh`
- 상대 경로: `./week03/qwen-web/start.sh` 또는 `week03/qwen-web/start.sh` (현재 위치가 `~/devops`일 때)
- `.`: 현재 위치, `..`: 상위 위치, `~`: 홈, `/`: 루트

상대 경로는 **현재 위치**에 따라 가리키는 곳이 달라짐.

3주차 스크립트에서 `cd "$(dirname "$0")"`를 쓴 이유도 이것. 어디에서 호출하든 스크립트가 있는 위치를 기준으로 실행하기 위함.

## 파일 찾기

```sh
cd ~/devops
find . -type f -name "*.sh" # 셸 스크립트 파일 찾기
grep -R -n "exit 1" week03 2>/dev/null # -R: 하위 디렉터리까지, -n: 줄 번호
grep -R "exit 1" week03 2>/dev/null | wc -l # 줄 수 세기
```

- `|` (파이프): 앞 명령의 **표준 출력**을 뒤 명령의 **표준 입력**으로 연결
- `grep`: `g/re/p` (global / regular expression / print)에서 유래. 텍스트에서 패턴이 포함된 줄을 찾음

### 텍스트 파일 다루기

[test/diary.txt](./test/diary.txt)

```sh
cd ~/devops/week04
mkdir -p test && cd test
cat > diary.txt << 'EOF'
월요일 - 리눅스를 배웠다.
화요일 - Git과 GitHub를 배웠다.
수요일 - 네트워크를 배웠다.
목요일 - 도커는 언제나 배울까?
EOF

head -2 diary.txt # 앞 2줄
tail -1 diary.txt # 마지막 1줄
wc -l diary.txt # 전체 줄 수
```

### 로그 검색

[test/server.log](./test/server.log)

```sh
grep "ERROR" server.log # ERROR가 든 줄만
grep -i "error" server.log # 대소문자 무시
grep -c "ERROR" server.log # 개수만
grep -n "ERROR" server.log # 줄 번호와 함께
grep -v "INFO" server.log # INFO가 없는 줄만

find . -name "*.txt" # txt 파일 찾기
find . -type d # 디렉터리만 찾기
find / -name "start.sh" 2>/dev/null # 시스템 전체에서 찾기, 권한 오류는 버림
```

### 파이프와 리다이렉션

```sh
cat server.log | grep ERROR # grep ERROR server.log 와 같음
cat server.log | grep ERROR | wc -l
ls -l /etc | grep conf | head -5

grep ERROR server.log > errors.txt # 파일로 저장
```

결과: [test/errors.txt](./test/errors.txt)

## 변수와 명령 치환

[test/var.sh](./test/var.sh)

```sh
#!/usr/bin/bash
USERNAME="홍길동"
TODAY=$(date +%Y%m%d)
echo "이름: $USERNAME"
echo "파일명: backup_${TODAY}.tar.gz"
```

- `USERNAME = "홍길동"`처럼 `=` 주변에 공백이 있으면 안 됨
  - 셸은 공백으로 단어를 나누기 때문에 `USERNAME`이라는 명령어에 `=`, `"홍길동"`을 인자로 넘기는 것으로 해석함
- `echo USERNAME`처럼 `$`가 없으면 문자열 그대로 출력

## 인자와 exit code

[test/greet.sh](./test/greet.sh)

```sh
#!/usr/bin/bash
if [ $# -eq 0 ]; then
  echo "사용법: $0 [이름]"
  exit 1
fi
echo "안녕하세요, $1님! (인자 개수: $#)"
```

```sh
./greet.sh # 사용법 출력
echo $? # 1
./greet.sh 홍길동 # 안녕하세요, 홍길동님! (인자 개수: 1)
echo $? # 0
```

`[ ]` 주변에는 공백이 필요함. `[`도 명령어(`test`)라서 인자와 띄어 써야 함.

## 조건문과 파일 검사

[test/check.sh](./test/check.sh)

```sh
#!/usr/bin/bash
FILE="$1"
if [ -z "$FILE" ]; then
  echo "파일명을 입력하세요"; exit 1
fi
if [ -f "$FILE" ]; then
  echo "파일"
elif [ -d "$FILE" ]; then
  echo "디렉터리"
else
  echo "없음"; exit 1
fi
```

```sh
./check.sh var.sh # 파일
./check.sh /etc # 디렉터리
./check.sh 없는파일 # 없음
```

- `-f`: 파일이 존재하는지, `-d`: 폴더가 존재하는지
- `-z`: 문자열 길이가 0인지, `-n`: 0이 아닌지
- `-eq`, `-ne`, `-gt`, `-lt`, `-ge`, `-le`: 정수 비교 (같음, 다름, 큼, 작음, 크거나 같음, 작거나 같음)

## 반복문

```sh
for f in *.sh; do echo "스크립트: $f"; done
```

# 프로세스와 백업

## 패키지 관리

```sh
sudo apt update
sudo apt install -y tree jq htop
tree ~/devops -L 2 # 최대 2단계 깊이까지 표시
```

Q. 내 PC에 `tree`, `jq`, `htop`을 설치했는데 친구 PC나 서버에는 없다. 서버마다 매번 설치해야 할까?

A. 설치까지 통째로 포장하면 됨. → 도커

## 프로그램 vs. 프로세스

- 프로그램: 디스크에 저장된 실행 코드
- 프로세스: 실행 중인 프로그램

```sh
ps aux | head -5
ps aux | grep bash
htop # 실시간 프로세스, CPU, 메모리 확인 (종료: q)

sleep 300 & # 백그라운드 실행
jobs
ps aux | grep sleep # PID 확인
kill <PID> # 정상 종료 요청 (SIGTERM)

sleep 300 &
kill -9 <PID> # 강제 종료 (SIGKILL)
```

- `ps aux`: `a`는 모든 사용자, `u`는 사용자 중심의 상세 정보, `x`는 터미널에 연결되지 않은 프로세스 포함
- SIGTERM(15): 정상 종료 요청. 프로세스가 받아서 정리(파일 저장, 연결 종료 등)할 기회를 가짐
- SIGKILL(9): 즉시 종료. 커널이 바로 프로세스를 없애기 때문에 정리할 틈이 없어 데이터 손실 위험이 있음
- SIGINT(2): `Ctrl + C`

## 백업 스크립트

[backup.sh](./backup.sh)

```sh
#!/usr/bin/bash

cd "$(dirname "$0")" || exit 1

SOURCE_DIR=${1:-test} # 인자가 없으면 test 디렉터리
BACKUP_DIR="backups"
TODAY=$(date +%Y%m%d_%H%M%S)
FILENAME="${TODAY}_$$.tar.gz" # $$: 현재 셸의 PID

# 1) 원본 확인
if [ ! -d "$SOURCE_DIR" ]; then
	echo "오류: '$SOURCE_DIR' 디렉터리가 없습니다."
	exit 1
fi

# 2) 백업 폴더 준비
mkdir -p "$BACKUP_DIR" || exit 1

# 3) 압축
echo "백업 시작:$SOURCE_DIR → $BACKUP_DIR/$FILENAME"
tar -czf "$BACKUP_DIR/$FILENAME" "$SOURCE_DIR"

# 4) 결과 확인
if [ $? -eq 0 ]; then
	SIZE=$(du -sh "$BACKUP_DIR/$FILENAME" | cut -f1)
	echo "백업 완료! (크기: $SIZE)"
else
	echo "백업 실패"
	exit 1
fi

# 5) 목록
echo "현재 보관 중인 백업:"
ls -1 "$BACKUP_DIR"

# 로그 기록
echo "$(date '+%Y-%m-%d %H:%M:%S') 백업 완료: $FILENAME" >> "$BACKUP_DIR/backup.log"
echo "[완료] 로그 기록"
```

- `${1:-test}`: `$1`이 비어 있으면 `test`를 기본값으로 사용
- `$$`를 파일명에 붙여 이름 충돌 가능성을 줄임

## 백업 복원 확인

```sh
cd ~/devops/week04
./backup.sh test
ls backups/*.tar.gz
ARCHIVE="backups/<방금 생성된 파일명>.tar.gz"
tar -tzf "$ARCHIVE" # 내용 확인
mkdir -p restore-check
tar -xzf "$ARCHIVE" -C restore-check # 압축 풀기
diff -rq test restore-check/test # 비교
echo $? # 0이면 원본과 복원본이 같음
```

- `tar`: 여러 파일을 하나의 아카이브로 묶는 도구
  - `c`: 생성, `t`: 목록 확인, `x`: 압축 해제, `z`: gzip, `f`: 파일명 지정
  - `-C`: 작업할 디렉터리 지정
- `diff -rq`: `r`은 하위 디렉터리까지, `q`는 다른지만 간단히 표시
  - exit code 0은 같음, 1은 다름, 2는 오류
  - `diff -ru A B`는 다른 내용을 `-`와 `+`로 표시

## `.gitignore`로 백업 결과물 제외

`backups/`와 `restore-check/`는 실행할 때마다 생기는 결과물이라 Git으로 관리하지 않음.

```sh
cd ~/devops
cat >> .gitignore << 'EOF'
week04/backups/
week04/restore-check/
EOF
git add .gitignore
git add week04
git commit -m "week04: 백업 스크립트 초안"
git push
```

- `.gitignore`: 지정한 파일을 Git 추적 대상에 새로 포함하지 않도록 함
- 이미 Git이 추적 중인 파일은 `.gitignore`에 추가해도 자동으로 빠지지 않음
  - `git rm --cached <파일명>` 또는 `git rm -r --cached <디렉터리명>`으로 추적만 해제

# Git 협업

Q. 같은 파일을 여러 명이 고치다 충돌이 나면? 한 명이 다 하거나, 카톡으로 논의하면 될까?

A. Git/GitHub으로 협업하는 이유:

- 실패해도 안전한 공간 → **브랜치**
- 합치기 전에 누군가 봐줌 → **Pull Request** (코드 리뷰)
- 컴퓨터가 자동으로 검사 → **CI** (PR 생성/업데이트 시 GitHub Actions 실행 가능)

## 브랜치

`main`은 기준이 되는 안정적인 브랜치, 기능 브랜치는 내 작업실. 작업 브랜치가 망가져도 `main`은 안전함.

```sh
cd ~/devops
git branch # * main
git switch -c feature/backup-log # 브랜치 생성 및 이동
git branch # * feature/backup-log, main
```

브랜치 이름은 보통 `feature/기능명` (또는 `feat/`), `fix/버그명`, `docs/문서명` 형식.

## 커밋, 푸시, PR, Merge

```sh
git switch feature/backup-log
cat >> week04/backup.sh << 'EOF' # > 가 아니라 >> (이어쓰기)

# 로그 기록
echo "$(date '+%Y-%m-%d %H:%M:%S') 백업 완료: $FILENAME" >> "$BACKUP_DIR/backup.log"
echo "로그 기록 완료"
EOF

git status
git diff week04/backup.sh
git add week04/backup.sh
git commit -m "feat: 백업 로그 기록 기능 추가"
git push -u origin feature/backup-log

gh pr create --title "백업 로그 기록 기능 추가" \
  --body "백업이 끝나면 backup.log에 백업 일시와 파일명을 기록합니다." \
  --base main
gh pr view --web

gh pr merge --squash --delete-branch # main에 합치고 브랜치 삭제
git switch main
git pull --ff-only # fast-forward만 허용
git log --oneline -3
```

`git status`와 `git diff`는 커밋 전에 습관적으로 확인.

# Conflict와 Merge

## 충돌 만들기

`main`과 `fix/message`에서 `backup.sh`의 **같은 줄**을 서로 다르게 수정.

```sh
cd week04
git branch fix/message

git switch main
sed -i 's/로그 기록 완료/로그 기록/' backup.sh
git add backup.sh && git commit -m "문구 수정" && git push

git switch fix/message
sed -i 's/로그 기록 완료/[완료] 로그 기록/' backup.sh
git add backup.sh && git commit -m "문구 수정"
git push -u origin fix/message
gh pr create --title "문구 수정" --body "수정" --base main
```

## 충돌의 이유

공통 조상 커밋에서 갈라진 뒤, `main`은 `echo "로그 기록"`으로, `fix/message`는 `echo "[완료] 로그 기록"`으로 **같은 줄을 서로 다르게** 수정함.

Git은 둘 중 무엇을 남겨야 할지 판단할 근거가 없음. 모르는 게 아니라 **함부로 결정하지 않는 것**.

## Merge 실패와 해결

```sh
gh pr merge --squash --delete-branch # not mergeable 오류

gh pr checkout fix/message
git fetch origin
git merge origin/main # CONFLICT (content): Merge conflict in week04/backup.sh
```

`backup.sh` 마지막 부분:

```
<<<<<<< HEAD
echo "[완료] 로그 기록"
=======
echo "로그 기록"
>>>>>>> origin/main
```

- `<<<<<<< HEAD`부터 `=======`까지: 현재 브랜치 내용
- `=======`부터 `>>>>>>> origin/main`까지: 합치려는 브랜치 내용

Git이 망가진 게 아니라 무엇을 사용할지 사람이 결정하라는 뜻. 표시 줄 3개를 지우고 원하는 내용만 남기면 됨 (둘 다 남겨도 됨).

`[완료] 로그 기록`을 남기기로 결정. (현재 [backup.sh](./backup.sh)의 마지막 줄)

```sh
cd ~/devops
git status
git add week04/backup.sh
git commit -m "resolve: merge conflict"
git push
gh pr merge --squash --delete-branch
git switch main
git pull --ff-only
```

해결 → add → commit → push → PR 업데이트 → merge 순서.

간단한 텍스트 충돌은 GitHub 웹에서도 해결 가능.

## PR Merge 옵션

- `--merge`: 기존 커밋을 유지하고 merge commit을 생성
- `--squash`: 기능 브랜치의 여러 커밋을 하나로 합쳐서 반영
- `--rebase`: 기능 브랜치의 각 커밋을 새 커밋으로 만들어 `main` 뒤에 일렬로 적용

## main 브랜치에 직접 푸시 막기

공개 리포지터리이거나, 비공개 리포지터리는 Pro/Team/Enterprise 플랜 등이 필요.

웹에서는 Settings → Rulesets → New branch ruleset에서 Active, Include default branch, **Require a pull request before merging**을 선택.

터미널에서는 Branch Protection API 사용 (admin 권한 필요).

```sh
gh api --method PUT repos/<깃허브아이디>/<레포이름>/branches/main/protection --input - <<'EOF'
{
  "required_status_checks": null,
  "enforce_admins": true,
  "required_pull_request_reviews": {
    "required_approving_review_count": 0
  },
  "restrictions": null
}
EOF

gh api repos/<깃허브아이디>/<레포이름>/branches/main/protection
```

`required_approving_review_count`가 0이므로 리뷰 없이 merge는 허용하되, PR은 반드시 거쳐야 함.

이후 main에 직접 푸시하면 `GH006: Protected branch update failed` 오류와 함께 거부됨.

# 네트워크

Q. 브라우저에 `cs.inhatc.ac.kr`을 입력하면 무슨 일이 일어날까?

1. DNS로 도메인을 IP(`221.154.90.200`)로 변환
2. 해당 IP의 TCP 443 포트로 연결
3. TLS 연결
4. HTTPS 요청
5. 웹 서버가 HTML 응답

## IP 주소

네트워크에서 장치를 식별하기 위한 주소.

- 공인 IP: 인터넷에서 라우팅 가능한 주소. 전체에서 유일
- 사설 IP: 사설 네트워크 내부에서만 쓰는 주소. 그 안에서만 유일
  - `192.168.x.x`, `10.x.x.x`, `172.16~31.x.x`
- `127.0.0.1` = `localhost` = 내 컴퓨터 자신

### NAT

사설 IP는 인터넷으로 바로 나갈 수 없음. 공유기나 게이트웨이가 내부의 사설 IP를 공인 IP와 매핑하여 통신함. → NAT (Network Address Translation)

## 포트

IP가 컴퓨터를 찾는 주소라면, 포트는 그 컴퓨터 안의 서비스를 구분하는 번호. `192.168.0.13:8080`처럼 `IP:포트`로 표현.

- 범위: 0 ~ 65,535 (Well-known: 0 ~ 1023)
- 반드시 써야 하는 번호가 아니라 관례적으로 많이 쓰는 번호가 있음
  - 22: SSH, 80: HTTP, 443: HTTPS, 3306: MySQL, 6379: Redis, 5000: Flask 개발 서버, 8080: 개발용 웹 서버

도커의 `docker run -p 8080:80 nginx`는 내 컴퓨터 8080 포트로 온 요청을 컨테이너 80 포트로 전달하는 것. (`-p 호스트포트:컨테이너포트`)

## TCP/IP 구조

1. 응용 계층: HTTP, DNS, SSH
2. 전송 계층: TCP / UDP (포트)
3. 인터넷 계층: IP (IP 주소)
4. 링크 계층: 이더넷, WiFi

택배로 비유하면 물건(HTTP)을 상자에 번호 붙여 포장(TCP)하고, 주소 라벨을 붙여(IP) 트럭으로 배송(이더넷).

- TCP: 전달 확인, 순서 보장 (등기우편)
- UDP: 전달 확인 없음, 순서 보장 없음 (빠른우편)

## DNS

도메인 이름을 IP 주소로 변환. 사람이 외우는 이름(`cs.inhatc.ac.kr`)을 컴퓨터가 쓰는 주소(`221.154.90.200`)로 바꿔주는 전화번호부 역할.

## 네트워크 명령어

### 내 IP

```sh
ip addr
ip addr show eth0 # 특정 인터페이스
hostname -I # 사설 IP
curl ifconfig.me # 공인 IP
```

기본 NAT 방식의 WSL2는 윈도우와 별도의 가상 네트워크 IP를 사용하지만, 윈도우 브라우저에서 `localhost`로 WSL 서버에 접근할 수 있음.

### ping

```sh
ping -c 4 8.8.8.8
ping -c 4 cs.inhatc.ac.kr
ping -c 4 127.0.0.1
```

**ping이 실패한다고 서버가 죽은 것은 아님.** ICMP 응답을 방화벽에서 막는 서비스가 많음.

```sh
ping cs.inhatc.ac.kr # 100% packet loss
curl -I https://cs.inhatc.ac.kr # HTTP/1.1 400 Bad Request
```

400이더라도 HTTP 응답을 받았으므로 웹 서버까지 통신은 된 것.

### DNS 조회

```sh
sudo apt install -y dnsutils
dig cs.inhatc.ac.kr # DNS 레코드까지 자세히
dig cs.inhatc.ac.kr +short # IP만
nslookup cs.inhatc.ac.kr
cat /etc/hosts # 로컬 이름 매핑
```

- `dig`: domain information groper
- `nslookup`: name server lookup

### curl과 jq

```sh
curl https://google.com # HTML 본문
curl -I https://google.com # 헤더만
curl -s https://api.github.com/users/torvalds | jq .name # -s: 진행 메시지 숨김
curl -o test.html https://google.com # 파일로 저장
```

`jq`는 JSON을 보기 좋게 출력하거나 원하는 값만 추출하는 도구.

```sh
echo '{"name":"Kam","age":"21"}' | jq '.name' # "Kam"
echo '{"name":"Kam","age":"21"}' | jq -r '.name' # Kam
echo '{"users":[{"name":"Neary"},{"name":"Kam"}]}' | jq '.users[0].name' # "Neary"
```

### 응답 코드

- 200: OK
- 400: Bad Request
- 404: Not Found
- 500: Internal Server Error
- 503: Service Unavailable

4xx는 클라이언트 요청 관련 오류, 5xx는 서버 측 오류.

### ss

```sh
ss -tlnp # t=TCP, l=listen, n=숫자, p=프로세스
sudo ss -tlnp # 프로세스 이름까지
ss -tlnp | grep 8080
```

서버 프로그램이 실행 중이어도 외부 요청을 받을 준비가 된 건 아님. **LISTEN 상태**인지 확인해야 함.

## 내 컴퓨터를 웹 서버로

```sh
mkdir -p ~/devops/week04/site
cd ~/devops/week04/site

# index.html이 이미 있다는 가정으로 실행
# 본래 Windows에서 가져왔음 (/mnt/c/(...)/index.html)

python3 -m http.server 8080
```

다른 터미널에서:

```sh
curl http://localhost:8080
curl -I http://localhost:8080 # 200 OK
ss -tlnp | grep 8080
```

### `127.0.0.1` vs. `0.0.0.0`

- `127.0.0.1`: 내 컴퓨터 자신에게서 오는 연결만 받음
- `0.0.0.0`: 모든 IPv4 네트워크 인터페이스에서 연결을 받음

3주차 `chat.py`가 `127.0.0.1`에 bind해서 다른 기기에서 접속이 안 되는 것도 같은 이유.

## 포트 충돌

이미 8080을 쓰는 서버가 있는데 같은 포트로 또 띄우면 `OSError: [Errno 98] Address already in use` 발생.

하나의 포트는 한 번에 하나의 프로세스만 LISTEN할 수 있음.

```sh
python3 -m http.server 8000 # 다른 포트 사용

ss -tlnp | grep 8080 # PID 확인
kill <PID> # 기존 프로세스 종료
pkill -f "http.server" # 여러 개 정리
```

`pkill -f`는 조건에 맞는 다른 프로세스도 종료될 수 있으니 주의.

### 여러 포트 띄워보기

```sh
python3 -m http.server 8080 &
python3 -m http.server 8081 &
python3 -m http.server 8082 &
ss -tlnp | grep python
curl -s localhost:8080 | head -3
pkill -f "http.server"
```

## 방화벽

서버가 포트를 LISTEN 중이어도 방화벽이 해당 포트를 막으면 외부에서 접근할 수 없음.

# 정리

- 자동화
  - 경로를 이해하고 `find`, `grep`, 파이프로 필요한 정보 찾기
  - 변수, 인자, 조건, 반복으로 셸 스크립트 작성
  - 프로세스와 PID 확인, 백업 및 복원 자동화
- 협업
  - `.gitignore`로 관리하지 않을 결과물 제외
  - 브랜치 → 커밋/푸시 → PR → Merge
  - Conflict 발생 → 로컬에서 해결 → Commit/Push → PR Merge
- 네트워크
  - IP: 장치 식별, 포트: 서비스 구분, DNS: 이름 → IP
  - `ip addr`, `ping`, `dig`, `curl`, `ss`
  - 이미 사용 중인 포트를 다시 쓰면 포트 충돌