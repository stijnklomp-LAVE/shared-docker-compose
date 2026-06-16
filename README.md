# Shared Docker Compose

This compose file connects all services. It provides shared infrastructure (RabbitMQ, Valkey/Redis, PostgreSQL) that each service can depend on without running its own copy.

## How it works

- **Infra services** (`rabbitmq`, `cache`, `db`, etc.) have **no profile** — they always start. Run `docker compose up -d` to start the shared infra.
- **Application services** (`client`, `fragment-composer`, etc.) are **profile-gated**. Opt in to the ones you need via `--profile`, or use `--profile full` for everything.
- **Each service's own compose file** has a `shared` profile that connects to the external `shared` network created here, allowing local hot-reload development against the shared infra.

## Usage examples

## Everything (shared compose, pre-built images)

```sh
docker compose --profile full up
```

## Just fragment-composer + infra

```sh
docker compose --profile fragment-composer up
```

## Develop client locally with shared infra

```sh
docker compose up -d                                                # Infra in background
docker compose -f ../client/docker-compose.yml --profile shared up  # Client with hot-reload
```

## Develop client standalone (with local infra)

```sh
docker compose -f ../client/docker-compose.yml --profile dev up
```