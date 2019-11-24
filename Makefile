# Makefile for releasing tradebot
#
# The release version is controlled from pkg/version

TAG?=latest
NAME:=tradebot
DOCKER_REPOSITORY:=praveensastry
DOCKER_IMAGE_NAME:=$(DOCKER_REPOSITORY)/$(NAME)
GIT_COMMIT:=$(shell git describe --dirty --always)
VERSION:=$(shell grep 'VERSION' pkg/version/version.go | awk '{ print $$4 }' | tr -d '"')

run:
	GO111MODULE=on go run -ldflags "-s -w -X github.com/praveensastry/tradebot/pkg/version.REVISION=$(GIT_COMMIT)" cmd/tradebot/* \
	--level=debug --grpc-port=9999 --backend-url=https://httpbin.org/status/401 --backend-url=https://httpbin.org/status/500 \
	--ui-logo=https://raw.githubusercontent.com/praveensastry/tradebot/gh-pages/cuddle_clap.gif --ui-color=#34577c

test:
	GO111MODULE=on go test -v -race ./...

build:
	GO111MODULE=on GIT_COMMIT=$$(git rev-list -1 HEAD) && GO111MODULE=on CGO_ENABLED=0 go build  -ldflags "-s -w -X github.com/praveensastry/tradebot/pkg/version.REVISION=$(GIT_COMMIT)" -a -o ./bin/tradebot ./cmd/tradebot/*
	GO111MODULE=on GIT_COMMIT=$$(git rev-list -1 HEAD) && GO111MODULE=on CGO_ENABLED=0 go build  -ldflags "-s -w -X github.com/praveensastry/tradebot/pkg/version.REVISION=$(GIT_COMMIT)" -a -o ./bin/cli ./cmd/cli/*

build-charts:
	helm lint charts/*
	helm package charts/*

build-container:
	docker build -t $(DOCKER_IMAGE_NAME):$(VERSION) .

test-container:
	@docker rm -f tradebot || true
	@docker run -dp 9898:9898 --name=tradebot $(DOCKER_IMAGE_NAME):$(VERSION)
	@docker ps
	@TOKEN=$$(curl -sd 'test' localhost:9898/token | jq -r .token) && \
	curl -sH "Authorization: Bearer $${TOKEN}" localhost:9898/token/validate | grep test

push-container:
	docker tag $(DOCKER_IMAGE_NAME):$(VERSION) $(DOCKER_IMAGE_NAME):latest
	docker push $(DOCKER_IMAGE_NAME):$(VERSION)
	docker push $(DOCKER_IMAGE_NAME):latest
	docker tag $(DOCKER_IMAGE_NAME):$(VERSION) quay.io/$(DOCKER_IMAGE_NAME):$(VERSION)
	docker tag $(DOCKER_IMAGE_NAME):$(VERSION) quay.io/$(DOCKER_IMAGE_NAME):latest
	docker push quay.io/$(DOCKER_IMAGE_NAME):$(VERSION)
	docker push quay.io/$(DOCKER_IMAGE_NAME):latest

version-set:
	@next="$(TAG)" && \
	current="$(VERSION)" && \
	sed -i '' "s/$$current/$$next/g" pkg/version/version.go && \
	sed -i '' "s/tag: $$current/tag: $$next/g" charts/tradebot/values.yaml && \
	sed -i '' "s/appVersion: $$current/appVersion: $$next/g" charts/tradebot/Chart.yaml && \
	sed -i '' "s/version: $$current/version: $$next/g" charts/tradebot/Chart.yaml && \
	sed -i '' "s/tradebot:$$current/tradebot:$$next/g" kustomize/deployment.yaml && \
	echo "Version $$next set in code, deployment, chart and kustomize"

release:
	git tag $(VERSION)
	git push origin $(VERSION)

swagger:
	GO111MODULE=on go get github.com/swaggo/swag/cmd/swag
	cd pkg/api && $$(go env GOPATH)/bin/swag init -g server.go