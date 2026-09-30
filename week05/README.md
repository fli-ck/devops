# 5주차

## Issue ([#3](https://github.com/fli-ck/devops/issues/3))

- [x] `docker --version` 정상 출력
- [x] `docker run hello-world` 실행
- [x] `web`이라는 이름으로 nginx 컨테이너 실행
- [x] 브라우저 또는 `curl`로 `http://localhost:8080` 응답 확인
- [x] `docker ps`에서 실행 상태를 확인
- [x] 실습 결과를 `week05/README.md`에 기록
- [x] 수업에서 만든 컨테이너 정리
- [x] 혼자서 해보기 완료

## 혼자서 해보기 컨테이너 내 파일 변경

exec으로 진입해서 경로 이동한 다음 파일을 바꿔도 되지만 컨테이너 들어갔다 나오는게 귀찮기에

약간 야매지만 `sed`를 이용해서 replace하여 변경

One-liner로 해결했으며 명령은 아래와 같음:

```sh
docker exec -it nginx3 /bin/bash -c "sed -i 's/Welcome to nginx/Welcome to nginx3/g' /usr/share/nginx/html/index.html"
```

후술될 혼자서 해보기 curl 결과처럼 for loop로 돌릴걸 그랬음. (...)

## 혼자서 해보기 curl 결과

### 사용한 명령

```sh
for i in {1..3}; do curl -I "http://localhost:808${i}"; done
```

### 결과

```
HTTP/1.1 200 OK
Server: nginx/1.31.6
Date: Wed, 30 Sep 2026 03:28:48 GMT
Content-Type: text/html
Content-Length: 898
Last-Modified: Wed, 30 Sep 2026 03:25:39 GMT
Connection: keep-alive
ETag: "6abc8133-382"
Accept-Ranges: bytes

HTTP/1.1 200 OK
Server: nginx/1.31.6
Date: Wed, 30 Sep 2026 03:28:48 GMT
Content-Type: text/html
Content-Length: 898
Last-Modified: Wed, 30 Sep 2026 03:26:37 GMT
Connection: keep-alive
ETag: "6abc816d-382"
Accept-Ranges: bytes

HTTP/1.1 200 OK
Server: nginx/1.31.6
Date: Wed, 30 Sep 2026 03:28:48 GMT
Content-Type: text/html
Content-Length: 898
Last-Modified: Wed, 30 Sep 2026 03:26:49 GMT
Connection: keep-alive
ETag: "6abc8179-382"
Accept-Ranges: bytes
```
