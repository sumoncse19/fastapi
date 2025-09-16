# FastAPI Blog API - Makefile
# Make commands for development workflow

.PHONY: help install run dev build up down clean logs shell test lint format check-deps

# Default target
help: ## Show this help message
	@echo "FastAPI Blog API - Available Commands:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# Development Environment
install: ## Install dependencies
	pip install -r requirements.txt

venv: ## Create virtual environment
	python3 -m venv venv
	@echo "Activate with: source venv/bin/activate"

# Running the Application
run: ## Run FastAPI app with uvicorn (local development)
	uvicorn src.main:app --reload --host 0.0.0.0 --port 8000

dev: ## Start development environment with Docker
	docker-compose up --build

up: ## Start all services in background
	docker-compose up -d

down: ## Stop all services
	docker-compose down

restart: ## Restart all services
	docker-compose restart

# Docker Management
build: ## Build Docker images
	docker-compose build

clean: ## Clean up Docker containers and images
	docker-compose down -v
	docker system prune -f

logs: ## Show logs from all services
	docker-compose logs -f

logs-app: ## Show logs from FastAPI app only
	docker-compose logs -f app

logs-db: ## Show logs from database only
	docker-compose logs -f db

# Database Management
db-shell: ## Connect to PostgreSQL database
	docker-compose exec db psql -U blog_user -d blog_db

app-shell: ## Access application container shell
	docker-compose exec app bash

# Code Quality
lint: ## Run linting with ruff
	ruff check src/

format: ## Format code with ruff
	ruff format src/

lint-fix: ## Run linting and fix auto-fixable issues
	ruff check --fix src/

check: ## Run all code quality checks
	@echo "Running linting..."
	ruff check src/
	@echo "Checking formatting..."
	ruff format --check src/

# Testing
test: ## Run tests with pytest
	pytest

test-cov: ## Run tests with coverage report
	pytest --cov=src --cov-report=html

# Dependencies Management
freeze: ## Update requirements.txt
	pip freeze > requirements.txt

check-deps: ## Check for outdated dependencies
	pip list --outdated

# Project Information
status: ## Show Docker containers status
	docker-compose ps

health: ## Check application health
	curl -f http://localhost:8000/ || echo "Application is not running"

# API Documentation
docs: ## Open API documentation in browser
	@echo "API Docs available at:"
	@echo "  Swagger UI: http://localhost:8000/docs"
	@echo "  ReDoc: http://localhost:8000/redoc"

# Quick Setup Commands
first-run: venv install up ## Complete first-time setup
	@echo "🚀 Project setup complete!"
	@echo "📖 Visit http://localhost:8000/docs for API documentation"

stop-all: down clean ## Stop everything and clean up
	@echo "🛑 All services stopped and cleaned up"