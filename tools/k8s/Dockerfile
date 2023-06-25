FROM golang:1.20
LABEL authors="aershov"

WORKDIR /usr/src/app
COPY app.go .
RUN go build -v -o /usr/local/bin/app app.go

EXPOSE 8081

ENTRYPOINT ["app"]