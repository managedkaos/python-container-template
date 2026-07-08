APP = $(notdir $(CURDIR))
TAG = $(shell echo "$$(date +%F)-$$(git rev-parse --short HEAD)")
GREEN := \033[0;32m
NC := \033[0m

help: ## Show this help message
	@echo "$(GREEN)Usage: make [target]$(NC)"
	@echo ''
	@echo "$(GREEN)Available targets:$(NC)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-25s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

all: requirements lint test build ## Run requirements, lint, test, and build

requirements: ## Install runtime dependencies
	pip install --quiet --upgrade --requirement requirements.txt

development-requirements: requirements ## Install development dependencies
	pip install --quiet --upgrade --requirement development-requirements.txt

pre-commit-install: development-requirements ## Install pre-commit hooks
	pre-commit install
	detect-secrets scan > .secrets.baseline

pre-commit-update: development-requirements ## Update pre-commit hooks
	pre-commit autoupdate
	$(MAKE) pre-commit-run

pre-commit-run: development-requirements ## Run pre-commit on all files
	pre-commit run --all-files

x_pre-commit-clean:
	pre-commit uninstall

lint: ## Run ruff checks
	ruff check *.py

fmt: ## Format code with ruff
	ruff format *.py
	ruff check --fix *.py

test: ## Run unit tests
	python -m unittest --verbose --failfast

build: lint test ## Build docker container
	docker build --tag $(APP):$(TAG) .

clean: ## Clean up workspace and containers
	docker container stop $(APP) || true
	docker container rm $(APP) || true
	@rm -rf ./__pycache__ ./tests/__pycache__ .ruff_cache
	@rm -f .*~ *.pyc

.PHONY: help requirements lint fmt test build clean development-requirements pre-commit-install pre-commit-run pre-commit-clean
