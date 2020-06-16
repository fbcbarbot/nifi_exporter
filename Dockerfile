FROM golang:1.14 as builder
RUN mkdir /exporter
COPY . /exporter
WORKDIR /exporter

RUN go mod download
RUN CGO_ENABLED=0 GOOS=linux go build -o /exporter/exporter main.go

FROM alpine:3.9

RUN apk update && apk add bash curl ca-certificates && apk upgrade

COPY --from=builder /exporter/exporter /exporter
