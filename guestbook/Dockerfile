# ---------------------------------------------------------------
# 학생 과제: 아래 각 줄이 무엇을 하는지 주석으로 설명을 달아보세요.
# ---------------------------------------------------------------

# 컨테이너의 바탕이 될 기본 환경을 정의. 공식 Docker Hub에서 제공하는 Python 3.12 버전의 경량화 이미지 사용.
FROM python:3.12-slim

# 컨테이너 내부에서 이후에 실행될 명령어(COPY, RUN, CMD)가 작업할 기본 경로를 /app으로 지정
WORKDIR /app

# 컴퓨터에 있는 requirements.txt 파일을 컨테이너의 현재 작업 디렉토리(/app/requirements.txt)로 복사
# requirements.txt를 먼저 복사하는 이유는 Docker 레이어 캐싱을 활용하기 위해서이다.
COPY requirements.txt .

# 컨테이너 빌드 과정에서 requirements.txt에 명시된 의존성 라이브러리들을 설치.
# --no-cache-dir를 통해 캐시 디렉토리 없이 설치
RUN pip install --no-cache-dir -r requirements.txt

# 컴퓨터의 현재 디렉토리에 있는 모든 파일과 폴더를 컨테이너 내부의 작업 디렉토리로 복사.
COPY . .

# 비 root 사용자인 appuser 생성
RUN useradd -m appuser

# appuser로 전환
USER appuser

# 컨테이너 내에서 실행할 환경 변수 지정
ENV APP_TITLE="배현우 방명록" \
    THEME_COLOR="#0a0a0a"

# 컨테이너가 실행될 때 사용할 포트 번호
EXPOSE 5000

#컨테이너 실행 시 기본으로 동작할 명령어
CMD ["python", "app.py"]
