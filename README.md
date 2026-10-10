# imapsync Docker image

Multi-architecture, CLI-only container image for [imapsync](https://github.com/imapsync/imapsync). Published images support `linux/amd64` and `linux/arm64`.

## Run a migration

Copy the standard TLS example, set the source and destination credentials, then run the one-shot Compose service:

```sh
cp .env.example .env
docker compose --env-file .env run --rm imapsync
```

The container writes imapsync logs to `./logs`. The local `.env` file and logs are ignored by Git. For non-TLS servers and selected runtime options, start from `.env.advanced.example` instead.

The supported settings are:

| Variable | Required | Purpose |
| --- | --- | --- |
| `IMAPSYNC_HOST1`, `IMAPSYNC_USER1`, `IMAPSYNC_PASSWORD1` | Yes | Source server and account |
| `IMAPSYNC_HOST2`, `IMAPSYNC_USER2`, `IMAPSYNC_PASSWORD2` | Yes | Destination server and account |
| `IMAPSYNC_PORT1`, `IMAPSYNC_PORT2` | No | IMAP ports; default `993` |
| `IMAPSYNC_SSL1`, `IMAPSYNC_SSL2` | No | Set `true` for TLS; default `true` |
| `IMAPSYNC_TIMEOUT1`, `IMAPSYNC_TIMEOUT2` | No | Per-server timeouts in seconds |
| `IMAPSYNC_MAXAGE` | No | Copy only messages no older than this many days |
| `IMAPSYNC_MAX_BYTES_PER_SECOND` | No | Maximum transfer rate |
| `IMAPSYNC_MAX_MESSAGES_PER_SECOND` | No | Maximum message rate |
| `IMAPSYNC_EXCLUDE` | No | Folder-selection pattern passed to `--exclude` |
| `IMAPSYNC_DELETE2` | No | Set `true` to remove destination-only messages |
| `IMAPSYNC_NOFOLDERSIZES` | No | Set `true` to skip folder-size calculations |

Passwords remain environment variables and are not constructed as command-line arguments by the entrypoint. Treat `.env` as a secret; use Docker secrets or your deployment platform's secret mechanism for production automation.

## Direct Docker usage

Docker accepts the same environment file without Compose:

```sh
docker run --rm --env-file .env -v "$PWD/logs:/home/imapsync/logs" bfranske/imapsync:latest
```

To invoke native imapsync arguments rather than the environment adapter, pass the command explicitly:

```sh
docker run --rm bfranske/imapsync:latest imapsync --version
```

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

Set these repository Actions secrets before enabling publication:

| Secret | Value |
| --- | --- |
| `DOCKERHUB_USERNAME` | `bfranske` |
| `DOCKERHUB_TOKEN` | Docker Hub personal access token with read/write access to `bfranske/imapsync` |

Use **Actions > Publish imapsync image > Run workflow** with a known `upstream_tag` for the first release. The workflow builds one manifest only after both target architectures complete successfully. Its final manifest inspection verifies both `linux/amd64` and `linux/arm64` were published.

The CI workflow validates Compose rendering, builds a native image, runs `--version`, and checks the entrypoint's missing-configuration error. It does not perform a live mailbox synchronization.