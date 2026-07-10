# FROM --platform=$BUILDPLATFORM golang:1.24-alpine AS builder
FROM --platform=$BUILDPLATFORM golang:1.25.0-alpine AS builder
LABEL maintainer="Mamat Nurahmat <mamat@loyalto.id>"

ARG BRANCH=staging
ARG PORT
ARG PROJECT

RUN apk add git gcc g++ tzdata zip ca-certificates

ENV GOPRIVATE="github.com/Qoin-Digital-Indonesia/*"
# Izinkan Go auto-download toolchain sesuai go.mod
ENV GOTOOLCHAIN=auto

RUN mkdir -p /go/src/${PROJECT}
WORKDIR /go/src/${PROJECT}

COPY go.mod .
COPY go.sum .

# Download dependencies - inject GitHub creds from secrets
RUN --mount=type=secret,id=github_token \
    --mount=type=secret,id=github_user \
    GITHUB_TOKEN=$(cat /run/secrets/github_token) && \
    GITHUB_USER=$(cat /run/secrets/github_user) && \
    git config --global url."https://${GITHUB_USER}:${GITHUB_TOKEN}@github.com/".insteadOf "https://github.com/" && \
    GONOSUMDB="github.com/Qoin-Digital-Indonesia/*" GONOPROXY="github.com/Qoin-Digital-Indonesia/*" go mod download


COPY . .
COPY .env.${BRANCH} .env


# Build the application
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /go/bin/${PROJECT} server.go

# Final stage
FROM alpine:latest

ARG BRANCH=staging
ARG PORT
ARG PROJECT

ENV TIMEZONE=Asia/Jakarta

RUN apk add --no-cache tzdata && \
    cp /usr/share/zoneinfo/${TIMEZONE} /etc/localtime && \
    echo "${TIMEZONE}" > /etc/timezone && \
    apk del tzdata

EXPOSE ${PORT}

COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /go/bin/${PROJECT} .
COPY .env.${BRANCH} .env

RUN printf "#!/bin/sh\n\nwhile true; do\n\techo \"[INFO] Starting Service at \$(date)\"\n\t(./${PROJECT} >> ./history.log || echo \"[ERROR] Restarting Service at \$(date)\")\ndone" > run.sh
RUN printf "#!/bin/sh\n./run.sh & tail -F ./history.log" > up.sh
RUN chmod +x up.sh run.sh
CMD ["./up.sh"]
