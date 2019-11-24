FROM golang:1.13 as builder

RUN mkdir -p /tradebot/

WORKDIR /tradebot

COPY . .

RUN go mod download

RUN go test -v -race ./...

RUN GIT_COMMIT=$(git rev-list -1 HEAD) && \
  CGO_ENABLED=0 GOOS=linux go build -ldflags "-s -w \
  -X github.com/praveensastry/tradebot/pkg/version.REVISION=${GIT_COMMIT}" \
  -a -o bin/tradebot cmd/tradebot/*

RUN GIT_COMMIT=$(git rev-list -1 HEAD) && \
  CGO_ENABLED=0 GOOS=linux go build -ldflags "-s -w \
  -X github.com/praveensastry/tradebot/pkg/version.REVISION=${GIT_COMMIT}" \
  -a -o bin/cli cmd/cli/*

FROM alpine:3.10

RUN addgroup -S app \
  && adduser -S -g app app \
  && apk --no-cache add \
  curl openssl netcat-openbsd

WORKDIR /home/app

COPY --from=builder /tradebot/bin/tradebot .
COPY --from=builder /tradebot/bin/cli /usr/local/bin/cli
RUN chown -R app:app ./

USER app

CMD ["./tradebot"]
