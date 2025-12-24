FROM golang:1.25-alpine AS builder
WORKDIR /app
RUN apk add --no-cache ca-certificates git

COPY go.mod go.sum ./
RUN go mod download

COPY *.go ./
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
    go build -mod=mod -ldflags="-w -s" -o /docker_state_exporter .

FROM alpine:3
RUN apk add --no-cache ca-certificates
COPY --from=builder /docker_state_exporter /docker_state_exporter
EXPOSE 8080
ENTRYPOINT ["/docker_state_exporter"]
CMD ["-listen-address=:8080"]
