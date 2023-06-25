FROM golang:1.20
LABEL authors="aershov"

WORKDIR /usr/src/app
COPY app_v2.go .
RUN go build -v -o /usr/local/bin/app_v2 app_v2.go

EXPOSE 8081

ENTRYPOINT ["app_v2"]