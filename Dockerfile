# The Dockerfile for build localhost source, not git repo
FROM alpine:latest as builder

MAINTAINER cppla https://cpp.la

RUN apk update && apk add gcc g++ make curl-dev musl-dev

COPY . .

WORKDIR /server

RUN make -j
RUN pwd && ls -a

# Nginx Alpine as base image
FROM nginx:alpine

RUN mkdir -p /ServerStatus/server/

COPY --from=builder server /ServerStatus/server/
COPY --from=builder web /usr/share/nginx/html/

# china time
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

EXPOSE 80 35601

CMD nohup sh -c '/etc/init.d/nginx start && /ServerStatus/server/sergate --config=/ServerStatus/server/config.json --web-dir=/usr/share/nginx/html'
