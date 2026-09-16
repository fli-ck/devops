# 2주차

# 서버와 가상화

## 서버

Q. 서버는 하드웨어인가? 소프트웨어인가?

A. "둘 다."

하드웨어로서의 서버는 "전원을 키고 끄다"의 의미를 가질 수 있고, 소프트웨어로서의 서버는 "서버를 설치했다" 등으로 인식될 수 있다.

정확한 문맥과 의미를 파악하는것이 중요...

### 서버의 역할

- 서버의 어원은 Serve

- "Serve를 하는 주체"라는 뜻으로 Serve**r**가 됨.

- 서버는 기본적으로 Request/Response의 구조를 가지게 됨
  - Request: 서버에 원하는 것을 **요청**
  - Response: 클라이언트가 원하는 것으로 **응답**

### 서버의 운영 방법

- 물리적인 하드웨어를 통한 운영
  - 베어메탈 (Bare Metal)
    - PC 한 대에 OS 설치 후 여러 소프트웨어 운영

- 가상화 기술을 통한 운영
  - 하이퍼바이저 (hypervisor)
    - PC 한 대에 여러개의 가상 머신

  - 컨테이너 (container)
    - PC 한 대에 여러개의 컨테이너

## 가상화

- 실제 서버가 존재하지 않아도 마치 있는것처럼 만드는 기술

- 물리적인 컴퓨터 환경 내에서 여러 개의 논리적인 컴퓨팅 환경을 만들 수 있는 기술
  - 컨테이너는 서버를 효율적으로 사용하기 위한 가상화 기술

### 베어메탈과의 비교

- 베어메탈의 장점
  - 하나의 OS에서 모든 프로그램을 관리할 수 있음

- 베어메탈의 단점
  - 프로그램 하나가 해킹되면 다른 프로그램의 정보도 위험
  - 프로그램 하나의 리소스(자원) 사용량이 급증할 때 나머지 프로그램들이 비정상 동작할 가능성이 있음

위 단점을 해결하기 위해 가상화 기술은 격리된 공간에서 소프트웨어를 실행함.

### 경제성에 대한 고민

Q. 독립된 OS 환경이 고민이라면 여러 대의 저사양 하드웨어를 사용하는것이 낫지 않은가?

A. 아님. 낮은 사양의 컴퓨터를 여러 대 운영하는 것보다 높은 사양의 컴퓨터를 한 대 사용하는 편이 나음.

비용, 설치 공간, 인력, 서버 운영 등을 고려했을 때 고사양을 한 대 두는것이 더 경제적임.

## 하이퍼바이저(Hypervisor)

호스트 OS 리소스를 이용하여 게스트 OS를 실행하는 전통적인 가상화 기술

- Host OS
  - 하이퍼바이저를 실행하는 OS (예: Proxmox)
  - 물리적인 하드웨어 서버를 관리

- Guest OS
  - 가상 머신 (Virtual Machine)
  - 리소스 할당: CPU, 메모리, 디스크, 네트워크

### 하이퍼바이저의 역할

- 기본 상식
  - 프로세스를 실행하기 위해서 리소스(CPU, 메모리)가 필요함
    - 하드웨어 리소스를 사용하기 위해서는 OS에 리소스 사용을 요청
  - 커널 (kernel)
    - 프로그램의 요청을 받아 하드웨어 리소스를 안전하게 관리하고 연결해주는 역할
    - 프로세스의 리소스 사용 요청을 처리하기 위한 시스템 콜(system call)을 제공

- 하이퍼바이저
  - 여러 가상 머신이 하나의 물리 하드웨어를 공유할 수 있도록 리소스를 가상화하고 관리
    - 각 가상 머신은 자신의 Guest OS와 커널을 가짐
  - Program → System Call → Guest OS Kernel → Virtual Hardware → Hypervisor → Physical Hardware 

## 컨테이너

하이퍼바이저 가상화와 달리 호스트 OS의 커널을 이용해 격리된 공간을 제작하기에 가볍고 빠름.

- 모든 컨테이너가 호스트 OS의 커널을 공유
  - 호스트 OS와 다른 종류의 OS를 실행할 수는 없음.
- 리눅스 컨테이너의 핵심 기술
  - 네임스페이스(namespace): 프로세스, 파일 시스템, 네트워크 등의 격리
  - 제어 그룹(cgroups) 기술: 리소스 사용량 제어

## 가상화 확인

BIOS에서 Intel VT-d나 AMD SVM Mode가 활성되어있는지 확인.

# WSL2로 환경 구축

## WSL

Windows Subsystem for Linux

- WSL의 장점
  - 빠름. 가상 머신보다 적은 리소스를 사용함
  - Windows 시스템 아래에서 통합되어 동작함. 파일 탐색기에서 쉽게 접근 가능
  - 실제 리눅스 머신이 필요하질 않음.
  - bash 명령을 그대로 사용할 수 있어 편리함.

### WSL 설치

```
wsl --install
wsl install -d Ubuntu
# wsl install -d Ubuntu-26.04
wsl --set-default Ubuntu-26.04

# 앞으로 설치할 OS의 기본 버전값 지정
wsl --set-default-version 2

# WSL 실행
wsl
```

# 리눅스 터미널 익히기

- mkdir
- cd
- pwd
- exit
- whoami
- cat
- su

```sh
sudo apt update
sudo apt upgrade -y
sudo apt autoremove -y
```

## chmod

8진수 권한 표기

- read: 4
- write: 2
- execute: 1

`chmod +x file.sh`

`chmod -R 777 directory/`

## 기타

```sh
df -h
free -h
clear
history

# History의 103번째 명령어 실행
!103

less <filename>
head <filename>
tail <filename>
tail -f <filename>
```

# Git으로 버전 관리 진행

- Git
  - Version Control System (VCS)
  - 코드의 변경 이력을 관리한다
  - 이전 버전으로 돌아가거나 변경 내용을 비교할 수 있음
  - 여러 브랜치를 만들어 독립 작업이 가능하다
  - Push를 제외하고 인터넷 연결을 필요로 하지 않는다

```sh
sudo apt install git -y
git --version

git config --global user.name "Bae Hyeon Woo"
git config --global user.email yoursanstv@gmail.com
git config --global init.defaultBranch main
```

```sh
echo "Hello, DevOps!" >> text.txt
git status
git add text.txt
git status
git commit -m "first commit"
git log
# git log --oneline

echo "Inha tech college" >> text.txt
cat test.txt
git add .
git commit -m "second commit"
git log --oneline

# 커밋 변경 (detached)
git switch -d <commit hash>

# 커밋 비교
git diff <commit1> <commit2>
```

```sh
# -c: create
git switch -c <new branch>

# 브랜치 변경
git switch <branch>

# 현재 브랜치 확인
git branch

# 현재 브랜치 포함 현재 상태 확인
git log --oneline --all --graph
```
