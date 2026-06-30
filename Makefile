.PHONY: help run test lint coverage docker-build docker-run k8s-apply

help:
	@echo "Available targets:"
	@echo "  run          Start Django development server"
	@echo "  test         Run unit tests with pytest"
	@echo "  lint         Run static code analysis with ruff"
	@echo "  coverage     Generate test coverage report"
	@echo "  docker-build Build the Docker image"
	@echo "  docker-run   Run the application locally with Docker"
	@echo "  k8s-apply    Apply Kubernetes manifests to the current cluster"

run:
	python manage.py runserver 0.0.0.0:8000

test:
	pytest

lint:
	ruff check .

coverage:
	pytest --cov=api --cov=demo --cov-report=term-missing

docker-build:
	docker build -t devsu-demo-python:latest .

docker-run:
	docker run --env-file .env -p 8000:8000 devsu-demo-python:latest

k8s-apply:
	kubectl apply -k k8s
