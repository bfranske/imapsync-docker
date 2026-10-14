# imapsync Docker image

Multi-architecture, CLI-only container image for [imapsync](https://github.com/imapsync/imapsync). Published images support `linux/amd64` and `linux/arm64`.

Images are published at https://hub.docker.com/r/bfranske/imapsync

## Run a migration

Copy the password and standard TLS argument templates, edit both files, then run the one-shot Compose service:

```sh
cp .env.example .env
cp imapsync.args.example imapsync.args
docker compose run --rm imapsync
```

The container writes imapsync logs to `./logs`. Local `.env`, `imapsync.args`, and logs are ignored by Git. For non-TLS servers and selected runtime options, start from `imapsync.args.advanced.example` instead.

Passwords belong in `.env`:

| Variable | Required | Purpose |
| --- | --- | --- |
| `IMAPSYNC_PASSWORD1` | Yes | Source mailbox password |
| `IMAPSYNC_PASSWORD2` | Yes | Destination mailbox password |

`imapsync.args` contains one complete imapsync option or option value per line. Blank lines and lines beginning with `#` are ignored. All other lines, including values containing spaces, are passed literally as one imapsync argument. This supports every imapsync option without an entrypoint allowlist.

Passwords remain environment variables and are not placed in the argument file or constructed as command-line arguments by the entrypoint. Treat `.env` as a secret; use Docker secrets or your deployment platform's secret mechanism for production automation.

## Direct Docker usage

Docker accepts the same environment file and argument file without Compose:

```sh
docker run --rm --env-file .env \
	--mount type=bind,source="$PWD/imapsync.args",target=/config/imapsync.args,readonly \
	-v "$PWD/logs:/home/imapsync/logs" \
	-e IMAPSYNC_ARGS_FILE=/config/imapsync.args \
	bfranske/imapsync:latest
```

For ad hoc use, pass native imapsync options directly; this bypasses the argument-file loader:

```sh
docker run --rm bfranske/imapsync:latest --version
```

An explicit command is also passed through unchanged, for example `docker run --rm bfranske/imapsync:latest imapsync --version`.

## Build locally

Docker and Docker Buildx are required. The Make targets fetch upstream source into the ignored `upstream/` directory.

```sh
make test TAG=test UPSTREAM_TAG=imapsync-2.314
make buildx-push TAG=2.314 UPSTREAM_TAG=imapsync-2.314
```

`make test` builds for the local architecture and runs `imapsync --version`. `make buildx-push` publishes a multi-platform manifest, so authenticate with Docker Hub before using it.

## Automated publishing

[`.github/workflows/publish.yml`](.github/workflows/publish.yml) polls upstream tags once each day at `04:17 UTC`. It recognizes stable tags in either `imapsync-X.Y` or legacy `X.Y` form. Scheduled runs skip versions already on Docker Hub; a manual dispatch or any push to `main` rebuilds and replaces the version and `latest` tags. It publishes both:

```text
bfranske/imapsync:<version>
bfranske/imapsync:latest
```

The CI workflow validates Compose rendering, builds a native image, runs `--version`, and checks the entrypoint's missing-configuration error. It does not perform a live mailbox synchronization.