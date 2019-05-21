FROM golang:1.11 as builder
COPY . $GOPATH/src/github.com/msiedlarek/nifi_exporter
WORKDIR $GOPATH/src/github.com/msiedlarek/nifi_exporter

RUN CGO_ENABLED=0 GOOS=linux go build -o /exporter main.go

FROM alpine:3.9

RUN apk update && apk add bash curl ca-certificates && apk upgrade

COPY --from=builder /exporter /exporter