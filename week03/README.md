# 3주차

# 셸 스크립팅

## 왜 셸 스크립트?

자동화의 시작.

- 하고 싶은 작업 예시
  - 어제 로그에서 오류 개수 세기
  - 로그를 백업 폴더로 복사
  - 파일명에 날짜 붙이기
  - 30일 지난 백업 삭제

위 작업을 손으로 하면 하루 10분이라도 1년이면 3,650분.

게다가 사람은 오타, 순서 바뀜, 단계 생략 등으로 반드시 실수함.

기계는 수백만 번을 시켜도 똑같이 작업함. 단, **스크립트가 제대로 작성되었을 때만.**

## 자주 만나는 에러

- `Permission denied`
  - 실행 권한이 없음 → `chmod u+x <파일 이름.sh>`

- `command not found`
  - 명령어 이름만 입력하면 셸은 `PATH`에 등록된 디렉터리에서만 찾음
  - 현재 디렉터리는 `PATH`에 없으므로 `./`를 붙여서 경로로 실행해야 함

```sh
start.sh    # 실행 안 됨
./start.sh  # 실행 됨

echo $PATH
# PATH에 추가하면 이름만으로도 실행 가능 (단, 재접속 시 해제)
export PATH="$PATH:$HOME/devops/week03/qwen-web/"
```

# Qwen w/ Ollama로 로컬 대화방 만들기

## Qwen

알리바바 클라우드에서 개발한 대형 언어 모델(LLM).

- 이번 실습에서는 텍스트 질문/답변 모델 사용
- `qwen3:0.6b` (약 523MB)
  - `think: false`, 짧은 답변, 출력 최대 512토큰
- 작은 모델이라 한국어 답변이 어색하거나 틀릴 수 있음
  - 답변 품질이 아니라 **실행 → 종료 → 재실행 흐름**을 보는 게 목적

### 파라미터 크기 (`b`)

- `b` = Billion (10억), 모델이 학습한 파라미터 개수
  - `0.6b` = 약 6억 개, `1.7b` = 약 17억 개
- 파라미터가 클수록 더 많은 패턴을 저장할 수 있어 비슷한 조건이면 성능이 좋음
  - 대신 연산량이 커져 응답이 느려지고, 저장 공간과 메모리도 더 필요
  - 실제 성능은 모델 구조, 학습 데이터, 학습 방법에 따라 달라짐

- 사양 낮은 PC는 `qwen3:1.7b`, 실습은 `qwen3:4b`, 사양이 괜찮은 PC는 `qwen3:8b`, 코드 생성 특화는 `qwen2.5-coder:3b` 등을 사용

## Ollama

로컬 환경에서 LLM을 쉽게 설치 및 실행할 수 있게 해주는 오픈소스 플랫폼.

- 생성 API는 기본적으로 스트리밍
  - `stream: false`: 응답을 한 번에 받기
  - `think: false`: 생각 모드 비활성화

### 설치

WSL Ubuntu.

```sh
sudo apt update
sudo apt install -y python3 curl zstd
curl -fsSL https://ollama.com/install.sh | sh
```

### 서버 확인 및 모델 다운로드

```sh
ollama --version
python3 --version

# JSON이 나오면 Ollama 서버가 응답한 것 (예: {"models":[]})
curl -fsS http://127.0.0.1:11434/api/tags

# 연결 실패 시에만 실행
ollama serve

ollama pull qwen3:0.6b
ollama list
```

### 사전 응답 점검

```sh
curl --max-time 90 -fsS http://127.0.0.1:11434/api/generate \
  -H 'Content-Type: application/json' \
  -d '{"model":"qwen3:0.6b", "prompt":"안녕! 한 문장으로 인사해 봐!", "think":false, "stream":false,
  "options":{"num_ctx":8192,"num_predict":512}}'
```

결과 `response`에 답변이 들어 있음. 결과는 매번 달라질 수 있음.

## 구조

1. 브라우저의 `http://localhost:8080` 에서 질문 전송
2. Python 웹 앱인 chat.py가 질문을 Ollama API로 전달
3. Ollama 서버가 모델을 실행
4. Qwen 모델이 명령 처리

- `chat.py`는 파이썬 표준 라이브러리만 사용하므로 Flask 설치나 가상 환경이 필요 없음
- 모델은 Ollama가 따로 보관

## 실행

```sh
cd ~/devops
mkdir -p week03/qwen-web
cd week03/qwen-web

# chat.py가 이미 있다는 가정으로 실행
# 본래 Windows의 Downloads 폴더에서 가져왔음 (/mnt/c/Users/(...)/Downloads/chat.py)

python3 chat.py
```

모델을 바꾸고 싶으면 `nano chat.py`로 수정 후 `!python3`로 마지막 `python3` 명령을 다시 실행.

`Ctrl + C`로 Python 웹 앱 종료.

Q. 며칠 뒤에도 이 경로와 파일 이름을 기억해서 다시 실행할 수 있을까?

A. 매번 `cd ~/devops/week03/qwen-web && python3 chat.py`를 외워야 함. → 셸 스크립트로 해결.

# 셸 스크립트

## `start.sh`

[start.sh](./qwen-web/start.sh)

```sh
#!/usr/bin/bash

cd "$(dirname "$0")" || exit 1
exec python3 chat.py
```

```sh
./start.sh # Permission denied 오류
ls -l # 실행 권한(x)이 없음
chmod u+x start.sh # chmod로 실행 권한 부여
ls -l
./start.sh # 실행 가능
```

### `#!` (shebang)

- 파일의 첫 줄에 작성하여 **어떤 인터프리터로 실행할지** OS에 알려줌
  - "이 파일을 실행할 때, 바로 뒤에 적힌 프로그램으로 해석하라"
- `#`만 하나 있으면 Bash에서는 그냥 주석
- 파이썬도 가능

```sh
cat > run_py.sh << 'EOF'
#!/usr/bin/env python3
print('Hello, DevOps!')
EOF
chmod +x run_py.sh
./run_py.sh # Hello, DevOps!
```

`#!/usr/bin/env python3`는 `PATH`에서 `python3`를 찾고, `#!/usr/bin/python3`는 절대 경로를 직접 지정.

### `cd "$(dirname "$0")" || exit 1`

스크립트가 있는 디렉터리로 이동하고, 실패하면 스크립트 종료.

```sh
cd ~
./devops/week03/qwen-web/start.sh # 어디서 실행하든 chat.py를 찾을 수 있음
```

- `$0`: 현재 실행한 스크립트의 이름 또는 경로
  - 경로에 공백이 있을 수 있으므로 `"$0"`처럼 따옴표 사용
- `dirname`: 경로에서 파일 이름을 뺀 디렉터리 부분만 출력
- `$( ... )`: 명령어 치환. 괄호 안 명령의 표준 출력을 그 자리에 넣음
  - `echo "$(pwd)"`와 `pwd`는 같은 결과

인자 관련 특수 변수:

```
./command.sh qwen3:0.6b 8000
     $0          $1      $2
```

- `$#`: 전달받은 인자 개수
- `$@`: 전달받은 모든 인자
- `$?`: 직전 명령의 exit code

### exit code와 `||`

- 리눅스 명령은 exit code를 남김
  - 성공: `0`
  - 실패: `0` 이외
- `||`: 앞 명령이 **실패하면** 뒤 명령을 실행
  - `cd`가 성공하면 `exit 1`은 실행하지 않음
- **exit code 0은 성공**.
- 파이썬의 `A or B`에서 `A`가 참이면 `B`를 보지 않는 것과 같은 것

### `exec`

현재 bash 프로세스를 `python3`로 **대체**(PID 유지).

```sh
# exec 사용: Ctrl+C 시 "End" 출력 X
exec python3 chat.py
echo "End"

# exec 미사용: Ctrl+C 시 "End" 출력 O
python3 chat.py
echo "End"
```

## 환경 변수로 설정 넘기기

`chat.py`는 `MODEL`, `WEB_PORT` 환경 변수를 읽어서 설정함.

[start_with_export.sh](./qwen-web/start_with_export.sh)

```sh
cat > start_with_export.sh << 'EOF'
#!/bin/bash
cd "$(dirname "$0")" || exit 1
export MODEL="qwen3:0.6b"   # 원래 터미널의 환경 변수는 바꾸지 않음
exec ./start.sh
EOF
chmod u+x start_with_export.sh
./start_with_export.sh
```

- `export`한 변수는 스크립트 프로세스와 그 자식 프로세스에만 적용됨
- 스크립트는 새 프로세스에서 실행되므로 원래 터미널의 환경 변수는 그대로

### heredoc

```sh
cat > start_with_export.sh << 'EOF'
```

- `cat`: `concatenate`의 준말. 입력 받은 내용을 그대로 출력하는 명령
- `>`: 표준 출력을 파일로
- `start_with_export.sh`: 저장 파일
- `<<`: heredoc 시작
- `'EOF'`: `EOF` 텍스트를 만나면 종료. 무조건 EOF라는 텍스트일 필요 없이 지정하는건 자유.

  - `'EOF'`처럼 **따옴표를 써야** 변수가 문자 그대로 저장됨. 따옴표가 없으면 저장하는 시점의 변수 값으로 치환되어 저장됨

```sh
MODEL="qwen3"
cat > test.sh << 'END'
echo "$MODEL"
END
cat test.sh   # echo "$MODEL"

cat > test.sh << END
echo "$MODEL"
END
cat test.sh   # echo "qwen3"
```

### 실습: 포트 번호를 8080으로 바꿔서 실행

```sh
cat > start_with_export_2.sh << 'EOF'
#!/bin/bash
cd "$(dirname "$0")" || exit 1
export WEB_PORT="8080"
exec ./start.sh
EOF
chmod u+x start_with_export_2.sh
./start_with_export_2.sh
```

## 조건문으로 친절한 스크립트 만들기

```sh
cd "$(dirname "$0")" || exit 1

if ! command -v python3 >/dev/null 2>&1; then
  echo "Python3를 먼저 설치하세요." >&2
  exit 1
fi

exec python3 chat.py
```

```sh
if 명령어; then
  실행할 내용
fi
```

`if`는 조건식이 아니라 **명령어의 exit code**를 보고 분기함.

- `command -v python3`
  - 실행 가능한 명령이면 경로를 출력하고 성공
  - 없으면 아무것도 출력하지 않고 실패
- `!`: 결과 반전. "python3를 찾을 수 **없다면**"
- `>/dev/null`: 표준 출력을 버림 (`/dev/null`은 일종의 쓰레기통)
  - 알고 싶은 건 "있는지 없는지"뿐이라 경로 출력은 필요 없음
- `2>&1`: 표준 오류(2)를 표준 출력(1)이 가는 곳으로 보냄
  - 왼쪽에서 오른쪽 순서로 해석하므로 순서가 중요
  - `2>&1 >/dev/null`이면 표준 오류는 원래 표준 출력이 향하던 화면에 남음
- `>&2`: 메시지를 일반 출력이 아닌 오류 출력으로 보냄
- `exit 1`: 오류 상태로 종료
  - 오류 메시지를 출력하는 것과 실패로 종료하는 것은 별개. `exit 1`이 없으면 실패로 처리되지 않음

### 표준 입력/출력 번호 정리

- 0: stdin
- 1: stdout
- 2: stderr

# 정리

- Qwen: 답변을 만드는 모델
- Ollama: 모델을 실행하고 관리하는 로컬 서버 및 도구
- 셸 스크립트
  - 여러 명령을 파일에 작성하여 같은 절차로 실행
  - 실행 권한, shebang 확인 및 작업 경로 설정
  - 환경 변수로 프로그램 실행 설정 전달
  - 명령의 exit code로 성공/실패 판단
  - 표준 출력, 표준 오류, 실패 종료 구분