# Lean Optics - Makefile for Development and Distribution
# =======================================================

# Variables
PROJECT_NAME := lean-optics
VERSION := 1.0.0
DOCKER_IMAGE := ghcr.io/fraware/lean-optics
DOCKER_TAG := $(VERSION)
DOCKER_LATEST := $(DOCKER_IMAGE):latest
DOCKER_VERSIONED := $(DOCKER_IMAGE):$(DOCKER_TAG)

# Colors for output
GREEN := \033[0;32m
YELLOW := \033[1;33m
RED := \033[0;31m
NC := \033[0m # No Color

# Default target
.PHONY: help
help: ## Show this help message
	@echo "$(GREEN)Lean Optics - Available Commands$(NC)"
	@echo "=================================="
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "$(YELLOW)%-15s$(NC) %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# Development targets
.PHONY: dev
dev: ## Set up local development environment
	@echo "$(GREEN)Setting up development environment...$(NC)"
	@if ! command -v lake >/dev/null 2>&1; then \
		echo "$(RED)Error: Lake not found. Please install Lean 4 first.$(NC)"; \
		echo "Visit: https://leanprover.github.io/lean4/doc/setup.html"; \
		exit 1; \
	fi
	@echo "$(YELLOW)Installing dependencies...$(NC)"
	lake build
	@echo "$(YELLOW)Building project...$(NC)"
	lake build
	@echo "$(GREEN)✅ Development environment ready!$(NC)"
	@echo "Run 'make run' to test the library"

.PHONY: run
run: dev ## Run the application/CLI locally
	@echo "$(GREEN)Running Lean Optics...$(NC)"
	@echo ""
	lake exe lean-optics
	@echo ""
	@echo "$(GREEN)✅ Lean Optics executed successfully!$(NC)"

.PHONY: test
test: dev ## Run the test suite
	@echo "$(GREEN)Running test suite...$(NC)"
	@echo ""
	lake exe test-runner
	@echo ""
	@echo "$(GREEN)✅ All tests completed!$(NC)"

.PHONY: test-comprehensive
test-comprehensive: dev ## Run comprehensive test suite
	@echo "$(GREEN)Running comprehensive test suite...$(NC)"
	@echo ""
	@if [ -f scripts/test.sh ]; then \
		./scripts/test.sh; \
	elif [ -f scripts/test.bat ]; then \
		scripts/test.bat; \
	else \
		echo "$(YELLOW)Using fallback test method...$(NC)"; \
		$(MAKE) test; \
	fi
	@echo ""
	@echo "$(GREEN)✅ Comprehensive tests completed!$(NC)"

.PHONY: test-verbose
test-verbose: dev ## Run tests with verbose output
	@echo "$(GREEN)Running verbose test suite...$(NC)"
	@echo ""
	lake build Tests
	lake exe test-lens
	lake exe test-prism
	lake exe test-traversal
	lake exe test-compose
	lake exe test-runner
	@echo ""
	@echo "$(GREEN)✅ All tests completed!$(NC)"

.PHONY: bench
bench: dev ## Run performance benchmarks
	@echo "$(GREEN)Running performance benchmarks...$(NC)"
	@echo ""
	lake exe bench
	@echo ""
	@echo "$(GREEN)✅ Benchmarks completed!$(NC)"

.PHONY: docs
docs: dev ## Generate documentation
	@echo "$(GREEN)Generating documentation...$(NC)"
	@echo ""
	lake build docs
	@echo ""
	@echo "$(GREEN)✅ Documentation generated!$(NC)"

# Docker targets
.PHONY: docker-build
docker-build: ## Build Docker image
	@echo "$(GREEN)Building Docker image...$(NC)"
	docker build -t $(DOCKER_VERSIONED) -t $(DOCKER_LATEST) .
	@echo "$(GREEN)✅ Docker image built: $(DOCKER_VERSIONED)$(NC)"

.PHONY: docker-run
docker-run: docker-build ## Run the application in Docker
	@echo "$(GREEN)Running Lean Optics in Docker...$(NC)"
	@echo ""
	docker run --rm $(DOCKER_LATEST)
	@echo ""
	@echo "$(GREEN)✅ Docker run completed!$(NC)"

.PHONY: docker-test
docker-test: docker-build ## Run tests in Docker
	@echo "$(GREEN)Running tests in Docker...$(NC)"
	@echo ""
	docker run --rm $(DOCKER_LATEST) test
	@echo ""
	@echo "$(GREEN)✅ Docker tests completed!$(NC)"

.PHONY: docker-push
docker-push: docker-build ## Push Docker image to registry (requires authentication)
	@echo "$(GREEN)Pushing Docker image to registry...$(NC)"
	docker push $(DOCKER_VERSIONED)
	docker push $(DOCKER_LATEST)
	@echo "$(GREEN)✅ Docker image pushed!$(NC)"

# Release targets
.PHONY: release
release: ## Build and publish artifacts (dry-run supported)
	@echo "$(GREEN)Preparing release...$(NC)"
	@echo ""
	@echo "$(YELLOW)Step 1: Running full test suite...$(NC)"
	$(MAKE) test
	@echo ""
	@echo "$(YELLOW)Step 2: Running benchmarks...$(NC)"
	$(MAKE) bench
	@echo ""
	@echo "$(YELLOW)Step 3: Building Docker image...$(NC)"
	$(MAKE) docker-build
	@echo ""
	@echo "$(YELLOW)Step 4: Testing Docker image...$(NC)"
	$(MAKE) docker-test
	@echo ""
	@echo "$(GREEN)✅ Release preparation complete!$(NC)"
	@echo ""
	@echo "$(YELLOW)To publish the release:$(NC)"
	@echo "1. Push Docker image: $(YELLOW)make docker-push$(NC)"
	@echo "2. Create GitHub release with tag: $(YELLOW)v$(VERSION)$(NC)"
	@echo "3. Update documentation with new version"

.PHONY: release-dry-run
release-dry-run: ## Run release preparation without publishing
	@echo "$(GREEN)Running release dry-run...$(NC)"
	$(MAKE) release
	@echo "$(GREEN)✅ Dry-run completed successfully!$(NC)"

# Utility targets
.PHONY: clean
clean: ## Clean build artifacts
	@echo "$(GREEN)Cleaning build artifacts...$(NC)"
	lake clean
	docker rmi $(DOCKER_VERSIONED) $(DOCKER_LATEST) 2>/dev/null || true
	@echo "$(GREEN)✅ Clean completed!$(NC)"

.PHONY: check-deps
check-deps: ## Check if all dependencies are installed
	@echo "$(GREEN)Checking dependencies...$(NC)"
	@if ! command -v lake >/dev/null 2>&1; then \
		echo "$(RED)❌ Lake not found$(NC)"; \
		echo "Install Lean 4: https://leanprover.github.io/lean4/doc/setup.html"; \
		exit 1; \
	else \
		echo "$(GREEN)✅ Lake found$(NC)"; \
	fi
	@if ! command -v docker >/dev/null 2>&1; then \
		echo "$(YELLOW)⚠️  Docker not found (optional for containerized runs)$(NC)"; \
	else \
		echo "$(GREEN)✅ Docker found$(NC)"; \
	fi

.PHONY: version
version: ## Show version information
	@echo "$(GREEN)Lean Optics Version Information$(NC)"
	@echo "=================================="
	@echo "Project: $(PROJECT_NAME)"
	@echo "Version: $(VERSION)"
	@echo "Docker Image: $(DOCKER_VERSIONED)"
	@echo "Lake Version: $$(lake --version 2>/dev/null || echo 'Not available')"

# Quick start targets for new users
.PHONY: quickstart
quickstart: ## Complete quickstart for new users
	@echo "$(GREEN)🚀 Lean Optics Quickstart$(NC)"
	@echo "=============================="
	@echo ""
	@echo "$(YELLOW)1. Checking dependencies...$(NC)"
	$(MAKE) check-deps
	@echo ""
	@echo "$(YELLOW)2. Setting up development environment...$(NC)"
	$(MAKE) dev
	@echo ""
	@echo "$(YELLOW)3. Running the application...$(NC)"
	$(MAKE) run
	@echo ""
	@echo "$(YELLOW)4. Running tests...$(NC)"
	$(MAKE) test
	@echo ""
	@echo "$(GREEN)🎉 Quickstart completed successfully!$(NC)"
	@echo ""
	@echo "$(YELLOW)Next steps:$(NC)"
	@echo "- Explore the documentation: $(YELLOW)make docs$(NC)"
	@echo "- Run benchmarks: $(YELLOW)make bench$(NC)"
	@echo "- Try Docker: $(YELLOW)make docker-run$(NC)"

# CI/CD targets
.PHONY: ci-test
ci-test: ## Run tests suitable for CI environment
	@echo "$(GREEN)Running CI tests...$(NC)"
	$(MAKE) test
	@echo "$(GREEN)✅ CI tests passed!$(NC)"

.PHONY: ci-release
ci-release: ## Full release process for CI
	@echo "$(GREEN)Running CI release...$(NC)"
	$(MAKE) release
	$(MAKE) docker-push
	@echo "$(GREEN)✅ CI release completed!$(NC)"
