.PHONY:  help
.DEFAULT_GOAL := help
SHELL = /bin/bash


run: ## runs kourier locally with "go run"
	@echo "[i] Remember to have a valid kubeconfig in $(HOME)/.kube/config"
	@go run ./cmd/kourier/main.go

docker-run-envoy: ## Runs envoy in a docker
	docker run --rm  -p 19000:19000 -p 10000:10000 --link kourier --name kourier_envoy -v $(PWD)/conf/:/tmp/conf -ti envoyproxy/envoy-alpine:latest -c /tmp/conf/envoy-bootstrap.yaml

docker-run: docker-build ## Runs kourier in a docker
	@echo "[i] Remember to have a valid kubeconfig in $(HOME)/.kube/config"
	docker run --rm  --name kourier -v $(HOME)/.kube:/tmp/.kube -ti 3scale-courier:test -kubeconfig /tmp/.kube/config

build: ## Builds kourier binary, outputs binary to ./build
	mkdir -p ./build
	go build -o build/kourier cmd/kourier/main.go 

docker-build: ## Builds kourier docker, tagged by default as 3scale-kourier:test
	docker build -t 3scale-courier:test ./

help: ## Print this help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-39s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)