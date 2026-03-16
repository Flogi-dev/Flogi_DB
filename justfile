# repo-autopilot generated justfile
# Ports: db=5432

set dotenv-load

db_port := "5432"

# 도움말 출력
default:
    @just --list

# --- Development ---

# PostgreSQL + pgvector 개발 서버 실행 (port: 5432)
dev:
    docker run --rm -p {{db_port}}:5432 -e POSTGRES_PASSWORD=postgres ankane/pgvector:latest

# --- Build ---

# Docker 이미지 빌드 (pgvector 기반)
build:
    docker build -t flogi-db .

# --- Test ---

# 테스트 (현재 프로젝트에 테스트 명령어 없음)
test:
    @echo "⚠️  No test commands detected"

# --- Database ---

# DB 마이그레이션 (현재 프로젝트에 마이그레이션 도구 없음)
db-migrate *ARGS:
    @echo "⚠️  No migration tool detected. Use psql or pgAdmin for manual migrations."

# DB 초기화 (데이터베이스 재생성)
db-reset:
    docker run --rm -e POSTGRES_PASSWORD=postgres ankane/pgvector:latest psql -U postgres -c "DROP DATABASE IF EXISTS flogi_db; CREATE DATABASE flogi_db;"

# --- Docker ---

docker-up:
    docker compose up -d
docker-down:
    docker compose down
docker-build:
    docker build -t flogi-db .
docker-logs *ARGS:
    docker compose logs -f {{ARGS}}

# --- Utility ---

check-env:
    @test -n "$POSTGRES_PASSWORD" || (echo "❌ POSTGRES_PASSWORD not set" && exit 1)
    @echo "✅ All env vars OK"

clean:
    docker system prune -a --volumes -f

# --- Deploy ---

deploy:
    @echo "⚠️  Deploy not configured. Edit this recipe for your deployment target."
