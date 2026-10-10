IMAGE ?= bfranske/imapsync
TAG ?= dev
UPSTREAM_TAG ?= master
PLATFORMS ?= linux/amd64,linux/arm64

.PHONY: upstream build test buildx-push

upstream:
	rm -rf upstream
	git clone --depth 1 --branch "$(UPSTREAM_TAG)" https://github.com/imapsync/imapsync.git upstream

build: upstream
	docker build \
		--build-arg IMAPSYNC_VERSION="$(UPSTREAM_TAG)" \
		--build-arg VCS_REF="$(UPSTREAM_TAG)" \
		--build-arg BUILD_DATE="$$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
		--tag "$(IMAGE):$(TAG)" .

test: build
	docker run --rm "$(IMAGE):$(TAG)" --version

buildx-push: upstream
	docker buildx build \
		--platform "$(PLATFORMS)" \
		--build-arg IMAPSYNC_VERSION="$(UPSTREAM_TAG)" \
		--build-arg VCS_REF="$(UPSTREAM_TAG)" \
		--build-arg BUILD_DATE="$$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
		--tag "$(IMAGE):$(TAG)" \
		--push .