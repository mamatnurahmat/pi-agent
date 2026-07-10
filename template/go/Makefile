ORG_REGISTRY?=loyaltolpi
IMAGE_NAME?=plus-be-transaction-module
# Get tag if exactly on a tag, otherwise get 7-char commit hash
IMAGE_TAG?=$(shell git describe --tags --exact-match 2>/dev/null || git rev-parse --short HEAD)
ENV?=staging
PORT?=9106
PROJECT?=qoinplus

.PHONY: staging production build release run deploy release-staging release-production run-staging run-production deploy-staging deploy-production

# Usage: make staging OR make production (Full Flow: Build -> Release -> Deploy)
staging:
	@$(MAKE) build ENV=staging
	@$(MAKE) release ENV=staging
	@$(MAKE) deploy ENV=staging

production:
	@$(MAKE) build ENV=production
	@$(MAKE) release ENV=production
	@$(MAKE) deploy ENV=production

# Usage: make build ENV=staging
build:
	@echo "Building $(ENV) image: $(ORG_REGISTRY)/$(IMAGE_NAME):$(IMAGE_TAG)"
	ORG_REGISTRY=$(ORG_REGISTRY) IMAGE_NAME=$(IMAGE_NAME) IMAGE_TAG=$(IMAGE_TAG) BUILD_ENV=$(ENV) PORT=$(PORT) PROJECT=$(PROJECT) GITHUB_USER=$(GITHUB_USER) GITHUB_PASSWORD=$(GITHUB_PASSWORD) docker compose build

# Usage: make release ENV=staging
release:
	@echo "Pushing $(ENV) image: $(ORG_REGISTRY)/$(IMAGE_NAME):$(IMAGE_TAG)"
	ORG_REGISTRY=$(ORG_REGISTRY) IMAGE_NAME=$(IMAGE_NAME) IMAGE_TAG=$(IMAGE_TAG) BUILD_ENV=$(ENV) docker compose push

# Usage: make run ENV=staging
run:
	@echo "Running $(ENV) image: $(ORG_REGISTRY)/$(IMAGE_NAME):$(IMAGE_TAG)"
	ORG_REGISTRY=$(ORG_REGISTRY) IMAGE_NAME=$(IMAGE_NAME) IMAGE_TAG=$(IMAGE_TAG) BUILD_ENV=$(ENV) docker compose up

# Helpers
release-staging:
	$(MAKE) release ENV=staging

release-production:
	$(MAKE) release ENV=production

run-staging:
	$(MAKE) run ENV=staging

run-production:
	$(MAKE) run ENV=production

# Usage: make deploy ENV=staging
deploy:
	@chmod +x deploy.sh
	@echo "Deploying $(ENV) image: $(ORG_REGISTRY)/$(IMAGE_NAME):$(IMAGE_TAG)"
	./deploy.sh $(IMAGE_NAME) $(ENV) $(ORG_REGISTRY)/$(IMAGE_NAME):$(IMAGE_TAG)

deploy-staging:
	$(MAKE) deploy ENV=staging

deploy-production:
	$(MAKE) deploy ENV=production
